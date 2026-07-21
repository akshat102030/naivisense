import { Router } from "express";

import * as ParentController from "./parent.controller";

import { requireAuth } from "../../middleware/auth";
import { requireRole } from "../../middleware/role";

const router = Router();

router.use(requireAuth);

router.use(requireRole("parent"));

router.get("/child/:childId/progress", ParentController.showProgress);

router.get(
  "/child/:childId/sessions/upcoming",
  ParentController.upcomingSessions
);

router.get(
  "/child/:childId/sessions/pending-attendance",
  ParentController.pendingAttendance
);

router.get("/child/:childId/sessions/history", ParentController.sessionHistory);

router.get("/session/:sessionId/notes", ParentController.sessionNotes);

router.get("/child/:childId/homework", ParentController.homework);

router.get("/dashboard", ParentController.dashboard);

export default router;
