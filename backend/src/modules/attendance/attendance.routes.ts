import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './attendance.controller';

const router = Router();

// Endpoints compulsory for every role
router.use(requireAuth);

// 1. Parent Check-In (only parents - direct present or manual override)
router.post(
  '/parent-checkin', 
  requireRole('parent'), 
  Ctrl.parentCheckIn
);

// 2. Therapist/Admin Status Update & Unmark (therapist, lead therapist, and center head)
router.patch(
  '/update-status', 
  requireRole('therapist', 'center_head', 'lead_therapist'), 
  Ctrl.updateStatus
);

// 3. Google Meet Sync (As-is)
router.post(
  '/google-meet', 
  requireRole('therapist', 'center_head', 'lead_therapist'), 
  Ctrl.syncMeet
);

// 4. List Attendance (As-is)
router.get('/', Ctrl.list);

export default router;