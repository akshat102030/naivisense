import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './attendance.controller';

const router = Router();

// endpoints compulsory for every role
router.use(requireAuth);

//  1. Parent Check-In (only parents)
router.post(
  '/parent-checkin', 
  requireRole('parent'), 
  Ctrl.parentCheckIn
);

//  2. Therapist Bulk Approval (therapist and center head)
router.patch(
  '/therapist-approve', 
  requireRole('therapist', 'center_head', 'lead_therapist'), 
  Ctrl.therapistApprove
);

//  3. Google Meet Sync (As-is)
router.post(
  '/google-meet', 
  requireRole('therapist', 'center_head', 'lead_therapist'), 
  Ctrl.syncMeet
);

//  4. List Attendance (As-is)
router.get('/', Ctrl.list);

export default router;
