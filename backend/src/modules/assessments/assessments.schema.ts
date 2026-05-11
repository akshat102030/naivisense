import { z } from 'zod';

const traitSchema = z.number().int().min(1).max(5);

export const CreateAssessmentSchema = z.object({
  child_id: z.string().length(24),
  type:     z.enum(['initial', 'reassessment', 'parent_feedback']),
  date:     z.string().datetime({ offset: true }).optional(),
  traits: z.object({
    eye_contact:   traitSchema.default(3),
    grip:          traitSchema.default(3),
    behavior:      traitSchema.default(3),
    walking:       traitSchema.default(3),
    communication: traitSchema.default(3),
    motor_skills:  traitSchema.default(3),
    attention:     traitSchema.default(3),
  }).optional(),
  notes: z.string().max(2000).default(''),
});

export type CreateAssessmentInput = z.infer<typeof CreateAssessmentSchema>;
