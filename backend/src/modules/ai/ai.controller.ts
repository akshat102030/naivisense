import * as AiService  from './ai.service';
import { asyncHandler } from '../../utils/http';
import { AppError }     from '../../middleware/error';

export const generatePlan = asyncHandler(async (req, res) => {
  const { child_id, therapy_type } = req.body as { child_id?: string; therapy_type?: string };
  if (!child_id)     throw new AppError('INVALID_INPUT', 'child_id is required');
  if (!therapy_type) throw new AppError('INVALID_INPUT', 'therapy_type is required');
  const result = await AiService.generatePlan(child_id, therapy_type, req.user!);
  res.json(result);
});

export const approvePlan = asyncHandler(async (req, res) => {
  const result = await AiService.approvePlan(req.params.draftId, req.user!);
  res.json(result);
});

export const getInsights = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const result = await AiService.getInsights(child_id, req.user!);
  res.json(result);
});
