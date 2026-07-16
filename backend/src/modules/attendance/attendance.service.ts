import { AttendanceModel } from '../../models/attendance.model';
import { ChildModel }      from '../../models/child.model';
import { SessionModel }    from '../../models/session.model';
import { AppError }        from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';
import { fetchMeetAttendance } from '../google/google.service';
import { CenterProfileModel } from '../../models/center-profile.model'; // Added CenterProfileModel import
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


// 1. PARENT CHECK-IN SERVICE (NO TIME LIMIT, AUTOMATIC OR MANUAL OVERRIDE BYPASS)

export async function parentCheckIn(input: ParentCheckInInput, user: AuthPayload) {
  // Only parents can trigger check-in
  if (user.role !== 'parent') {
    throw new AppError('FORBIDDEN', 'Only parents can trigger check-in for kids');
  }

  const session = await SessionModel.findById(input.session_id).lean();
  if (!session) {
    throw new AppError('NOT_FOUND', 'Session not found for attendance validation');
  }

  // Prevent duplicate attendance entries for the same child, session, and date
  const existingAttendance = await AttendanceModel.findOne({
    child_id: input.child_id,
    session_id: input.session_id
  });

  if (existingAttendance) {
    throw new AppError('BAD_REQUEST', 'Attendance is already registered for this session');
  }

  // Calculate geofence distance
  const centerProfile = await CenterProfileModel.findOne().lean(); // Or fetch by user_id/center_id linked to session
const centerLat = centerProfile?.latitude ?? 22.7196;
const centerLng = centerProfile?.longitude ?? 75.8577;

  const distance = getDistanceInMeters(
    input.location.lat,
    input.location.lng,
    centerLat,
    centerLng
  );

  // If inside 50m, source is marked as 'geo' (auto-present). Otherwise, it is recorded as a manual check-in override.
  const isWithinGeofence = distance <= 50;
  const source = isWithinGeofence ? 'geo' : 'manual_override';

  // Entry is created directly with 'present' status
  return AttendanceModel.create({
    child_id: input.child_id,
    session_id: input.session_id,
    date: new Date(input.date),
    status: 'present', 
    source: source,
    location: input.location,
    notes: input.notes,
    marked_by: user.sub, // References parent's ID
  });
}


// 2. THERAPIST UNMARK / UPDATE STATUS SERVICE

export async function updateAttendanceStatus(input: TherapistApproveInput, user: AuthPayload) {
  // Only therapists and center heads can modify attendance status
  if (!(THERAPIST_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center heads can update attendance status');
  }

  // Updates status to target status 
  const targetStatus = input.status || 'present';

  const result = await AttendanceModel.updateMany(
    {
      _id: { $in: input.attendance_ids },
      session_id: input.session_id
    },
    {
      $set: {
        status: targetStatus,
        marked_by: user.sub, // Tracks the last admin/therapist who performed the action
      }
    }
  );

  if (result.matchedCount === 0) {
    throw new AppError('NOT_FOUND', 'No matching attendance records found');
  }

  return {
    message: `Successfully updated ${result.modifiedCount} attendance records to status: ${targetStatus}`,
    matchedCount: result.matchedCount,
    modifiedCount: result.modifiedCount
  };
}


// 3. GOOGLE MEET SYNC SERVICE

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


// 4. LIST ATTENDANCE SERVICE

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