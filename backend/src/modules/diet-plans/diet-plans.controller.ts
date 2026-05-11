import * as DietPlanService   from './diet-plans.service';
import { CreateDietPlanSchema } from './diet-plans.schema';
import { AppError }             from '../../middleware/error';
import { asyncHandler }         from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input = CreateDietPlanSchema.parse(req.body);
  const plan  = await DietPlanService.createDietPlan(input, req.user!);
  res.status(201).json(plan);
});

export const getActive = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const plan = await DietPlanService.getActivePlan(childId, req.user!);
  res.json(plan);
});

export const logMeal = asyncHandler(async (req, res) => {
  const { id, mealId } = req.params;
  const result         = await DietPlanService.logMeal(id, mealId, req.user!);
  res.status(201).json(result);
});
