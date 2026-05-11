import { z } from 'zod';

const TaskSchema = z.object({
  task_id:      z.string().min(1),
  title:        z.string().min(1).max(200),
  description:  z.string().optional(),
  icon:         z.string().default('✅'),
  time_of_day:  z.enum(['morning', 'afternoon', 'evening']),
  duration_min: z.number().int().min(1).max(240),
  frequency:    z.enum(['daily', 'weekly']).default('daily'),
  target_count: z.number().int().min(1).default(1),
});

export const CreateHomePlanSchema = z.object({
  child_id:      z.string().length(24),
  start_date:    z.string().datetime({ offset: true }),
  end_date:      z.string().datetime({ offset: true }),
  tasks:         z.array(TaskSchema).min(1),
  ai_draft_diff: z.record(z.unknown()).optional(),
});

export type CreateHomePlanInput = z.infer<typeof CreateHomePlanSchema>;
