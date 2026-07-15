import * as AttendanceService from './attendance.service';
import { 
  ParentCheckInSchema, 
  TherapistApproveSchema, 
  SyncMeetAttendanceSchema 
} from './attendance.schema';
import { AppError }     from '../../middleware/error';
import { asyncHandler } from '../../utils/http';

// 1. Parent Check-In Controller
export const parentCheckIn = asyncHandler(async (req, res) => {
  // validating against parent schema
  const input = ParentCheckInSchema.parse(req.body);
  
  const attendance = await AttendanceService.parentCheckIn(input, req.user!);
  res.status(201).json(attendance);
});

//  2. Therapist Bulk Approve Controller
export const therapistApprove = asyncHandler(async (req, res) => {
  // validating against therapist schema
  const input = TherapistApproveSchema.parse(req.body);
  
  const result = await AttendanceService.therapistApprove(input, req.user!);
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