import { z } from 'zod';

const MealSchema = z.object({
  meal_id:         z.string().min(1),
  name:            z.string().min(1).max(200),
  description:     z.string().optional(),
  meal_time:       z.enum(['breakfast', 'lunch', 'dinner', 'snack']),
  calories_approx: z.number().int().min(0).default(0),
  ingredients:     z.array(z.string()).default([]),
  instructions:    z.string().optional(),
  frequency:       z.enum(['daily', 'weekly']).default('daily'),
});

export const CreateDietPlanSchema = z.object({
  child_id:   z.string().length(24),
  start_date: z.string().datetime({ offset: true }),
  end_date:   z.string().datetime({ offset: true }),
  meals:      z.array(MealSchema).min(1),
  notes:      z.string().optional(),
});

export type CreateDietPlanInput = z.infer<typeof CreateDietPlanSchema>;
