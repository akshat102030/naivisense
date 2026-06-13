import { z } from 'zod';

// 0=Not Present  1=Emerging  2=Partial  3=Independent
const domainItemSchema = z.object({
  score:   z.number().int().min(0).max(3).default(0),
  remarks: z.string().default(''),
});

const behavioralItemSchema = z.object({
  present:       z.boolean().default(false),
  frequency:     z.enum(['daily', 'weekly', 'monthly']).optional(),
  intensity:     z.number().int().min(1).max(5).optional(),
  duration_mins: z.number().min(0).optional(),
  triggers:      z.string().default(''),
});

const sensoryModalitySchema = z.object({
  pattern:  z.enum(['seeking', 'avoiding', 'typical']).default('typical'),
  severity: z.number().int().min(1).max(5).default(1),
  remarks:  z.string().default(''),
});

const standardDomainSchema = z.record(z.string(), domainItemSchema).default({});
const behavioralDomainSchema = z.record(z.string(), behavioralItemSchema).default({});
const sensoryDomainSchema   = z.record(z.string(), sensoryModalitySchema).default({});

export const CreateAssessmentSchema = z.object({
  child_id:     z.string().length(24),
  type:         z.enum(['initial', 'monthly', 'quarterly']),
  date:         z.string().datetime({ offset: true }).optional(),
  general_notes: z.string().max(4000).default(''),

  domain_data: z.object({
    attention:            standardDomainSchema,
    social_communication: standardDomainSchema,
    receptive_language:   standardDomainSchema,
    expressive_language:  standardDomainSchema,
    speech_production:    standardDomainSchema,
    imitation:            standardDomainSchema,
    visual_perception:    standardDomainSchema,
    fine_motor:           standardDomainSchema,
    gross_motor:          standardDomainSchema,
    adl:                  standardDomainSchema,
    academics:            standardDomainSchema,
    cognitive:            standardDomainSchema,
    emotional_regulation: standardDomainSchema,
    behavioral:           behavioralDomainSchema,
    sensory:              sensoryDomainSchema,
  }).default({}),
});

export type CreateAssessmentInput = z.infer<typeof CreateAssessmentSchema>;
