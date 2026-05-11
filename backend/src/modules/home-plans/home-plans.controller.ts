import * as HomePlanService   from './home-plans.service';
import { CreateHomePlanSchema } from './home-plans.schema';
import { AppError }             from '../../middleware/error';
import { asyncHandler }         from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input = CreateHomePlanSchema.parse(req.body);
  const plan  = await HomePlanService.createHomePlan(input, req.user!);
  res.status(201).json(plan);
});

export const getActive = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const plan = await HomePlanService.getActivePlan(childId, req.user!);
  res.json(plan);
});

export const logTask = asyncHandler(async (req, res) => {
  const { id, taskId } = req.params;
  const note           = req.body?.note as string | undefined;
  const result         = await HomePlanService.logTask(id, taskId, req.user!, note, req.file);
  res.status(201).json(result);
});
