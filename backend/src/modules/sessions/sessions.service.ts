import { SessionModel } from "../../models/session.model";
import { ChildModel } from "../../models/child.model";
import { UserModel } from "../../models/user.model";
import { AppError } from "../../middleware/error";
import type { AuthPayload } from "../../middleware/auth";
import { snapshotQueue } from "../../jobs/queues";
import { CenterProfileModel } from "../../models/center-profile.model";
import {
  syncCalendarEvent,
  updateCalendarEvent,
  deleteCalendarEvent,
} from "../google/google.service";
import type {
  CreateSessionInput,
  SubmitNotesInput,
  UpdateSessionInput,
 } from "./sessions.schema";
import { sendSessionRescheduledMailToParent } from "../mail/mail.service";
import { AttendanceModel } from "../../models/attendance.model";


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

  const scheduledAt = input.scheduled_at
    ? new Date(input.scheduled_at)
    : new Date();

  const duration = input.duration_min ?? 45;

  const endAt = new Date(scheduledAt.getTime() + duration * 60_000);


  const session = await SessionModel.create({
    ...input,
    therapist_id: user.sub,
    scheduled_at: scheduledAt,
    end_at: endAt,
    
  });

  if (input.mode === "online" && child) {
    
    const center = await CenterProfileModel.findOne({
      user_id: child.center_id,
    });

    if (!center?.google_calendar?.refresh_token) {
      throw new AppError(
        "BAD_REQUEST",
        "Center head must connect Google Calendar first before creating online sessions"
      );
    }
    
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

  session.end_at = new Date(
  session.scheduled_at.getTime() +
  session.duration_min * 60000
);

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
// return upcoming sessions with attendance (Changed)
export async function getUpcomingSessions(user: AuthPayload) {
  const now = new Date();

  const filter =
    user.role === "therapist"
      ? {
          therapist_id: user.sub,
          end_at: { $gte: now },
          status: "scheduled",
        }
      : {
          end_at: { $gte: now },
          status: "scheduled",
        };

  const sessions = await SessionModel.find(filter)
    .sort({ scheduled_at: 1 })
    .limit(20)
    .lean();

  const sessionsWithAttendance = await Promise.all(
    sessions.map(async (session) => {
      const attendance = await AttendanceModel.findOne({
        session_id: session._id,
      }).lean();

      return {
        ...session,
        hasPendingAttendance: !attendance,
      };
    })
  );

  return sessionsWithAttendance;
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
    end_at: { $gte: now },
    status: "scheduled",
  })
    .sort({ scheduled_at: 1 })
    .lean();

  return next ?? null;
}

export async function getPendingAttendanceSessions(user: AuthPayload) {
  const now = new Date();

  const filter =
    user.role === "therapist"
      ? {
          therapist_id: user.sub,
          end_at: { $lt: now },
          status: "scheduled",
        }
      : {
          end_at: { $lt: now },
          status: "scheduled",
        };

  const sessions = await SessionModel.find(filter)
    .sort({ scheduled_at: -1 })
    .limit(20)
    .lean();

 const sessionsWithAttendance = await Promise.all(
  sessions.map(async (session) => {
    const attendance = await AttendanceModel.findOne({
      session_id: session._id,
    }).lean();

    return {
      ...session,
      hasPendingAttendance: !attendance,
    };
  })
);

return sessionsWithAttendance.filter(
  (session) => session.hasPendingAttendance
);
}

