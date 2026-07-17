import { asyncHandler } from "../../utils/http";

import * as ParentService from "./parent.service";

export const showProgress = asyncHandler(async (req, res) => {
  const data = await ParentService.showProgress(
    req.params.childId,

    req.user!
  );

  res.json(data);
});

export const upcomingSessions = asyncHandler(async (req, res) => {
  const data = await ParentService.getUpcomingSessions(
    req.params.childId,

    req.user!
  );

  res.json(data);
});

export const sessionHistory = asyncHandler(async (req, res) => {
  const data = await ParentService.getSessionHistory(
    req.params.childId,

    req.user!
  );

  res.json(data);
});

export const sessionNotes = asyncHandler(async (req, res) => {
  const data = await ParentService.getSessionNotes(
    req.params.sessionId,

    req.user!
  );

  res.json(data);
});

export const homework = asyncHandler(async (req, res) => {
  const data = await ParentService.getHomework(
    req.params.childId,

    req.user!
  );

  res.json(data);
});

export const dashboard = asyncHandler(async (req, res) => {
  const data = await ParentService.getDashboard(req.user!);

  res.json(data);
});
