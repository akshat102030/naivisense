import { SessionModel } from "../../models/session.model";
import { ChildModel } from "../../models/child.model";
import { UserModel } from "../../models/user.model";
import { CenterProfileModel } from "../../models/center-profile.model"; // Added for geofencing coordinates
import { AppError } from "../../middleware/error";
import type { AuthPayload } from "../../middleware/auth";
import { snapshotQueue } from "../../jobs/queues";
import {
  syncCalendarEvent,
  updateCalendarEvent,
  deleteCalendarEvent,
} from "../google/google.service";
import type {
  CreateSessionInput,
  SubmitNotesInput,
  UpdateSessionInput,
  GeofenceAttendanceInput,
} from "./sessions.schema";
import { sendSessionRescheduledMailToParent } from "../mail/mail.service";
import { getDistanceInMeters } from "../../utils/distance"; // Added distance utility

export async function createSession(
  input: CreateSessionInput,
  user: AuthPayload
) {
  if (user.role !== "therapist") {
    throw new AppError("FORBIDDEN", "Only therapists can create sessions");
  }

  const child =
    input.mode === "online"
      ? await ChildModel.findById(input.child_id).lean()
      : null;

  if (input.mode === "online" && !child) {
    throw new AppError("NOT_FOUND", "Child not found");
  }

  const session = await SessionModel.create({
    ...input,
    therapist_id: user.sub,
    scheduled_at: input.scheduled_at
      ? new Date(input.scheduled_at)
      : new Date(),
  });

  if (input.mode === "online" && child) {
    const [parent, therapist] = await Promise.all([
      UserModel.findById(child.parent_id).lean(),
      UserModel.findById(user.sub).lean(),
    ]);

    const calendar = await syncCalendarEvent({
      sessionId: session._id.toString(),
      centerId: child.center_id!.toString(),
      scheduledAt: session.scheduled_at,
      durationMin: session.duration_min,
      childName: child.name,
      parentEmail: child.parent_email ?? parent?.email,
      therapistEmail: therapist?.email,
    });

    session.meeting_link = calendar.meeting_link;
    session.calendar_event_id = calendar.calendar_event_id;
    session.calendar_provider = calendar.calendar_provider;
    session.calendar_synced_at = new Date();
    await session.save();
  }

  return session;
}

export async function updateSession(
  sessionId: string,
  input: UpdateSessionInput,
  user: AuthPayload
) {
  if (user.role !== "therapist") {
    throw new AppError("FORBIDDEN", "Only therapists can update sessions");
  }

  const session = await SessionModel.findById(sessionId);

  if (!session) {
    throw new AppError("NOT_FOUND", "Session not found");
  }

  if (session.therapist_id.toString() !== user.sub) {
    throw new AppError("FORBIDDEN", "This is not your session");
  }

  if (input.scheduled_at) {
    session.scheduled_at = new Date(input.scheduled_at);
  }

  if (input.duration_min !== undefined) {
    session.duration_min = input.duration_min;
  }

  if (input.mode) {
    session.mode = input.mode;
  }

  if (input.type) {
    session.type = input.type;
  }

  await session.save();

  if (session.mode === "online" && session.calendar_event_id) {
    const child = await ChildModel.findById(session.child_id);

    if (child) {
      const [parent, therapist] = await Promise.all([
        UserModel.findById(child.parent_id),

        UserModel.findById(user.sub),
      ]);

      await updateCalendarEvent({
        eventId: session.calendar_event_id,
        centerId: child.center_id!.toString(),

        scheduledAt: session.scheduled_at,

        durationMin: session.duration_min,

        childName: child.name,

        parentEmail: child.parent_email ?? parent?.email,

        therapistEmail: therapist?.email,
      });

      //Mail

      if (parent?.email) {
        await sendSessionRescheduledMailToParent(
          child.center_id!.toString(), // sender SMTP owner

          parent.email,

          parent.name,

          child.name,

          therapist?.name ?? "Therapist",

          session.scheduled_at,

          session.meeting_link
        );
      }
    }
  }
  return session;
}

export async function cancelSession(sessionId: string, user: AuthPayload) {
  if (user.role !== "therapist") {
    throw new AppError("FORBIDDEN", "Only therapists can cancel sessions");
  }

  const session = await SessionModel.findById(sessionId);

  if (!session) {
    throw new AppError("NOT_FOUND", "Session not found");
  }

  if (session.therapist_id.toString() !== user.sub) {
    throw new AppError("FORBIDDEN", "This is not your session");
  }

  if (session.mode === "online" && session.calendar_event_id) {
    await deleteCalendarEvent(session.calendar_event_id, user.sub);
  }

  session.status = "cancelled";
  session.meeting_link = undefined;
  session.calendar_event_id = undefined;
  session.calendar_provider = undefined;
  session.calendar_synced_at = undefined;

  await session.save();
  return session;
}

export async function submitNotes(
  sessionId: string,
  notes: SubmitNotesInput,
  user: AuthPayload
) {
  if (user.role !== "therapist") {
    throw new AppError("FORBIDDEN", "Only therapists can submit session notes");
  }
  const session = await SessionModel.findById(sessionId);
  if (!session) throw new AppError("NOT_FOUND", "Session not found");
  if (session.therapist_id.toString() !== user.sub) {
    throw new AppError("FORBIDDEN", "This is not your session");
  }

  session.notes = { ...notes, submitted_at: new Date() };
  session.status = "completed";
  await session.save();

  await snapshotQueue.add("rebuild", {
    childId: session.child_id.toString(),
  });

  return session;
}

export async function getUpcomingSessions(user: AuthPayload) {
  const now = new Date();
  const filter =
    user.role === "therapist"
      ? {
          therapist_id: user.sub,
          scheduled_at: { $gte: now },
          status: "scheduled",
        }
      : { scheduled_at: { $gte: now }, status: "scheduled" };

  return SessionModel.find(filter).sort({ scheduled_at: 1 }).limit(20).lean();
}

export async function listSessions(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError("NOT_FOUND", "Child not found");

  const canAccess =
    user.role === "center_head" ||
    user.role === "lead_therapist" ||
    (user.role === "therapist" &&
      (child.therapists ?? []).some(
        (t) => String(t.therapist_id) === user.sub
      )) ||
    (user.role === "parent" && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError("FORBIDDEN", "Access denied");
  return SessionModel.find({ child_id: childId })
    .sort({ scheduled_at: -1 })
    .lean();
}

export async function getNextSession(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError("NOT_FOUND", "Child not found");

  const canAccess =
    user.role === "center_head" ||
    user.role === "lead_therapist" ||
    (user.role === "therapist" &&
      (child.therapists ?? []).some(
        (t) => String(t.therapist_id) === user.sub
      )) ||
    (user.role === "parent" && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError("FORBIDDEN", "Access denied");

  const now = new Date();
  const next = await SessionModel.findOne({
    child_id: childId,
    scheduled_at: { $gte: now },
    status: "scheduled",
  })
    .sort({ scheduled_at: 1 })
    .lean();

  return next ?? null;
}

//  NEW CHANGES: GEOFENCE ATTENDANCE CORE BUSINESS LOGIC

export async function markGeofenceAttendance(
  input: GeofenceAttendanceInput,
  user: AuthPayload
) {
  // 1. Role validation check (sirf parents hi bache ki attendance mark kar sakte hain)
  if (user.role !== "parent") {
    throw new AppError(
      "FORBIDDEN",
      "Only parents can mark attendance via geofencing"
    );
  }

  // 2. Fetch center's coordinates
  const center = await CenterProfileModel.findOne({
    user_id: input.center_id,
  }).lean();
  if (
    !center ||
    (center as any).latitude === undefined ||
    (center as any).longitude === undefined
  ) {
    throw new AppError(
      "BAD_REQUEST",
      "Center location settings are not configured yet."
    );
  }

  // 3. Distance Check using Haversine Utility
  const distance = getDistanceInMeters(
    input.user_latitude,
    input.user_longitude,
    (center as any).latitude,
    (center as any).longitude
  );

  const allowedRadius = (center as any).radius_meters || 50;
  if (distance > allowedRadius) {
    throw new AppError(
      "BAD_REQUEST",
      `You are outside the center perimeter. Distance: ${Math.round(
        distance
      )} meters away.`
    );
  }

  // 4. Find Active Session within the Time Window (+/- 15 Mins)
  const currentTime = new Date();
  const fifteenMinsBefore = new Date(currentTime.getTime() - 15 * 60 * 1000);
  const fifteenMinsAfter = new Date(currentTime.getTime() + 15 * 60 * 1000);

  // Find a session scheduled for this child at this specific timing window
  const activeSession = await SessionModel.findOne({
    child_id: input.child_id,
    mode: "offline", // Offline maps to physical center attendance
    status: "scheduled",
    scheduled_at: { $gte: fifteenMinsBefore, $lte: fifteenMinsAfter },
  });

  if (!activeSession) {
    throw new AppError(
      "NOT_FOUND",
      "No offline session scheduled at this current time slot (+/- 15 mins window)."
    );
  }

  // 5. Check if therapist has already completed or marked it (Double check boundary)
  if (activeSession.status === "completed") {
    throw new AppError(
      "BAD_REQUEST",
      "Attendance has already been recorded for this session."
    );
  }

  // 6. Update Status & Attendance Source
  activeSession.status = "completed";
  activeSession.attendance_source = "geo";
  await activeSession.save();

  // 7. Trigger any background data rebuild if needed (copied style from submitNotes)
  await snapshotQueue.add("rebuild", {
    childId: activeSession.child_id.toString(),
  });

  return activeSession;
}
