import { asyncHandler } from "../../utils/http";
import * as ParentService from "./parent.service";

export const showProgress = asyncHandler(async (req, res) => {

  const data = await ParentService.showProgress(
    req.params.childId,
    req.user!,
  );

  res.json(data);
});

export const upcomingSessions = asyncHandler(async (req, res) => {

  const data = await ParentService.getUpcomingSessions(
    req.params.childId,
    req.user!,
  );

  res.json(data);
});
//new pendingAttendance function
export const pendingAttendance = asyncHandler(async (req, res) => {
  const data = await ParentService.getPendingAttendanceSessions(
    req.params.childId,
    req.user!
  );

  res.json(data);
});

export const sessionHistory = asyncHandler(async (req, res) => {

  const session = await ParentService.getSessionHistory(
    req.params.childId,
    req.user!,
  );

  if (!session) {
    res.json([]);
    return;
  }

  const child = session.child_id as any;

  const schedules =
    child.therapists?.flatMap((therapist: any) =>
      (therapist.schedule ?? []).map((schedule: any) => ({
        therapyType: therapist.therapy_type,
        enrollmentMode: schedule.enrollment_mode,
        days: schedule.days,
        fromTime: schedule.from_time,
        toTime: schedule.to_time,
      })),
    ) ?? [];

  res.json(schedules);
});

export const sessionNotes = asyncHandler(async (req, res) => {

  const data = await ParentService.getSessionNotes(
    req.params.sessionId,
    req.user!,
  );

  res.json(data);
});

export const homework = asyncHandler(async (req, res) => {

  const data = await ParentService.getHomework(
    req.params.childId,
    req.user!,
  );

  res.json(data);
});

export const dashboard = asyncHandler(async (req, res) => {
  
  const data = await ParentService.getDashboard(req.user!);

  res.json(data);
});
