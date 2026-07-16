import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { asyncHandler } from '../../utils/http';
import * as GoogleService from './google.service';
import * as GoogleCtrl from "./google.controller";

const router = Router();

router.get(
 "/callback",
 GoogleCtrl.callback
);

router.use(requireAuth);

// POST /api/v1/google/meet  — create a Meet link for a session
router.post(
  '/meet',
  requireRole('center_head', 'therapist'),
  asyncHandler(async (req, res) => {
    const { sessionId, centerId } = req.body as { sessionId: string; centerId: string };
    const link = await GoogleService.createMeetingLink(sessionId, centerId);
    res.json({ meeting_link: link });
  }),
);

// POST /api/v1/google/calendar — sync a session to Google Calendar
router.post(
  '/calendar',
  requireRole('center_head', 'therapist'),
asyncHandler(async (req, res) => {
    const event = await GoogleService.syncCalendarEvent(req.body);
    res.json(event);
  }),
);

// PUT /api/v1/google/calendar — update a session in Google Calendar
router.put(
  '/calendar',
  requireRole('center_head', 'therapist'),
  asyncHandler(async (req, res) => {
    const event = await GoogleService.updateCalendarEvent(req.body);
    res.json(event);
  })
);

// DELETE /api/v1/google/calendar/:eventId — delete a session from Google Calendar
router.delete(
  '/calendar/:eventId',
  requireRole('center_head', 'therapist'),
  asyncHandler(async (req, res) => {
    const event = await GoogleService.deleteCalendarEvent(req.params.eventId, req.body.centerId);
    res.json(event);
  })
);

router.get(
  "/auth",
  requireAuth,  
  GoogleCtrl.auth
);

export default router;
