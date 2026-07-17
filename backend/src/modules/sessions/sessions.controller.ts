import { Request, Response } from 'express';
import * as SessionService  from './sessions.service';
import { CreateSessionSchema, SubmitNotesSchema, UpdateSessionSchema } from './sessions.schema';
import { AppError }          from '../../middleware/error';
import { asyncHandler }      from '../../utils/http';
import { SessionModel } from '../../models/session.model';

export const create = asyncHandler(async (req: any, res: any): Promise<void> => {
  const input   = CreateSessionSchema.parse(req.body);
  const session = await SessionService.createSession(input, req.user!);
  res.status(201).json(session);
});

export const update = asyncHandler(async (req: any, res: any): Promise<void> => {
  const input = UpdateSessionSchema.parse(req.body);

  const session = await SessionService.updateSession(
    req.params.id,
    input,
    req.user!
  );

  res.json(session);
});

export const cancel = asyncHandler(async (req: any, res: any): Promise<void> => {
  const session =
    await SessionService.cancelSession(
      req.params.id,
      req.user!
    );

  res.json(session);
});

export const submitNotes = asyncHandler(async (req: any, res: any): Promise<void> => {
  const notes   = SubmitNotesSchema.parse(req.body);
  const session = await SessionService.submitNotes(req.params.id, notes, req.user!);
  res.json(session);
});

export const upcoming = asyncHandler(async (req: any, res: any): Promise<void> => {
  const sessions = await SessionService.getUpcomingSessions(req.user!);
  res.json(sessions);
});

//  attendance check list API
export const list = asyncHandler(async (req: any, res: any): Promise<void> => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const sessions = await SessionService.listSessions(childId, req.user!);
  
  const populatedSessions = await SessionModel.populate(sessions, { path: 'attendance' });
  res.json(populatedSessions);
});

//  attendance check next session API
export const nextSession = asyncHandler(async (req: any, res: any): Promise<void> => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const session = await SessionService.getNextSession(childId, req.user!);
  
  if (!session) {
    res.json(null);
    return;
  }

  const populatedSession = await SessionModel.populate(session, { path: 'attendance' });
  res.json(populatedSession);
});