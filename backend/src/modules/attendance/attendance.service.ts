import { AttendanceModel } from '../../models/attendance.model';
import { ChildModel }      from '../../models/child.model';
import { SessionModel }    from '../../models/session.model';
import { AppError }        from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';
import { fetchMeetAttendance } from '../google/google.service';
import type { ParentCheckInInput, TherapistApproveInput, SyncMeetAttendanceInput } from './attendance.schema';

const THERAPIST_ROLES = ['therapist', 'center_head', 'lead_therapist'] as const;

// Geofence Distance Calculator (Haversine Formula) - Returns distance in meters
function getDistanceInMeters(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000; // Earth radius in meters
  const phi1 = (lat1 * Math.PI) / 180;
  const phi2 = (lat2 * Math.PI) / 180;
  const deltaPhi = ((lat2 - lat1) * Math.PI) / 180;
  const deltaLambda = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
    Math.cos(phi1) * Math.cos(phi2) * Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}


//  1. PARENT CHECK-IN SERVICE

export async function parentCheckIn(input: ParentCheckInInput, user: AuthPayload) {
  // only parent can trigger check-in
  if (user.role !== 'parent') {
    throw new AppError('FORBIDDEN', 'Only parents can trigger check-in for kids');
  }

  const session = await SessionModel.findById(input.session_id).lean();
  if (!session) {
    throw new AppError('NOT_FOUND', 'Session not found for geofence validation');
  }

  // 1. Time Check (±15 Minutes Range)
  const currentTime = new Date().getTime();
  const scheduledTime = new Date(session.scheduled_at).getTime();
  const fifteenMinutesInMs = 15 * 60 * 1000;

  if (Math.abs(currentTime - scheduledTime) > fifteenMinutesInMs) {
    throw new AppError('BAD_REQUEST', 'Attendance can only be marked within ±15 minutes of the scheduled session time');
  }

  // 2. Geofence Location Check (50 Meters Radius)
  const centerLat = 22.7196; 
  const centerLng = 75.8577;

  const distance = getDistanceInMeters(
    input.location.lat,
    input.location.lng,
    centerLat,
    centerLng
  );

  if (distance > 50) {
    throw new AppError('BAD_REQUEST', `You are outside the permitted center location radius (${Math.round(distance)}m away)`);
  }

  // 3. check for existing attendance for the same session and child
  const existingAttendance = await AttendanceModel.findOne({
    child_id: input.child_id,
    session_id: input.session_id
  });

  if (existingAttendance) {
    throw new AppError('BAD_REQUEST', 'Check-in already registered for this session');
  }

  // 4. Entry creation with 'pending_approval' status
  return AttendanceModel.create({
    child_id: input.child_id,
    session_id: input.session_id,
    date: new Date(input.date),
    status: 'pending_approval', // waits for therapist approval
    source: 'geo',
    location: input.location,
    notes: input.notes,
    marked_by: user.sub, // has the id of parent for tracking
  });
}


//  2. THERAPIST BULK APPROVE SERVICE

export async function therapistApprove(input: TherapistApproveInput, user: AuthPayload) {
  // only therapist and center head can approve
  if (!(THERAPIST_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center heads can approve attendance');
  }

  // Bulk update
  const result = await AttendanceModel.updateMany(
    {
      _id: { $in: input.attendance_ids },
      session_id: input.session_id,
      status: 'pending_approval'
    },
    {
      $set: {
        status: 'present',
        marked_by: user.sub, // Ab 'marked_by' updated to therapist
      }
    }
  );

  if (result.matchedCount === 0) {
    throw new AppError('NOT_FOUND', 'No pending check-ins found for approval');
  }

  return {
    message: `${result.modifiedCount} attendance records successfully approved and marked present`,
    matchedCount: result.matchedCount,
    modifiedCount: result.modifiedCount
  };
}


//  3. OTHER SERVICES (AS-IS KEPT SAFELY)

export async function syncMeetAttendance(input: SyncMeetAttendanceInput, user: AuthPayload) {
  if (!(THERAPIST_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can sync attendance');
  }

  const session = { 
    scheduled_at: new Date("2026-07-15T18:05:00.000Z"),
    child_id: "6a51f1f59591cbd78aa29ea3",
    therapist_id: "6a45fe781d55df45e17b59f8" 
  } as any;

  const child = await ChildModel.findById(session.child_id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && String(session.therapist_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const meetAttendance = await fetchMeetAttendance(session.meeting_link, session.scheduled_at);
  const status = meetAttendance.participantCount > 0 ? 'present' : 'absent';

  return AttendanceModel.findOneAndUpdate(
    { session_id: session._id },
    {
      $set: {
        child_id:  session.child_id,
        session_id: session._id,
        date:      session.scheduled_at,
        status,
        marked_by: user.sub,
        source:    'google_meet',
        notes:     `Google Meet participants: ${meetAttendance.participantNames.join(', ') || 'none'}`,
      },
    },
    { upsert: true, new: true },
  );
}

export async function listAttendance(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent' && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  return AttendanceModel.find({ child_id: childId })
    .sort({ date: -1 })
    .limit(90)
    .lean();
}