import * as AssessmentService      from './assessments.service';
import { CreateAssessmentSchema } from './assessments.schema';
import { AppError }               from '../../middleware/error';
import { asyncHandler }           from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input      = CreateAssessmentSchema.parse(req.body);
  const assessment = await AssessmentService.createAssessment(input, req.user!);
  res.status(201).json(assessment);
});

export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const assessments = await AssessmentService.listAssessments(childId, req.user!);
  res.json(assessments);
});

export const get = asyncHandler(async (req, res) => {
  const assessment = await AssessmentService.getAssessment(req.params.id, req.user!);
  res.json(assessment);
});
