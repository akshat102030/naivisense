import * as AttendanceService from './attendance.service';
import { 
  ParentCheckInSchema, 
  TherapistApproveSchema, 
  SyncMeetAttendanceSchema 
} from './attendance.schema';
import { AppError }     from '../../middleware/error';
import { asyncHandler } from '../../utils/http';

// 1. Parent Check-In Controller (Direct present or manual override)
export const parentCheckIn = asyncHandler(async (req, res) => {
  // Validating against updated parent schema (which accepts 'geo' or 'manual_override')
  const input = ParentCheckInSchema.parse(req.body);
  
  const attendance = await AttendanceService.parentCheckIn(input, req.user!);
  res.status(201).json(attendance);
});

// 2. Therapist/Admin Status Update Controller (Handles approve, unmark, or change status)
export const updateStatus = asyncHandler(async (req, res) => {
  // Validating against updated therapist schema (which now supports optional 'status')
  const input = TherapistApproveSchema.parse(req.body);
  
  const result = await AttendanceService.updateAttendanceStatus(input, req.user!);
  res.status(200).json(result);
});

// 3. Sync Meet Controller (As-is)
export const syncMeet = asyncHandler(async (req, res) => {
  const input = SyncMeetAttendanceSchema.parse(req.body);
  const attendance = await AttendanceService.syncMeetAttendance(input, req.user!);
  res.status(201).json(attendance);
});

// 4. List Controller (As-is)
export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const records = await AttendanceService.listAttendance(childId, req.user!);
  res.json(records);
});