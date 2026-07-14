import { z } from 'zod';

export const CreateSessionSchema = z.object({
  child_id:     z.string().length(24),
  scheduled_at: z.string().datetime({ offset: true }).optional(),
  type:         z.enum(['speech', 'ot', 'behavior', 'special_ed']),
  mode:         z.enum(['online', 'offline']).default('offline'),
  duration_min: z.number().int().min(15).max(180).default(45),
});

export const SubmitNotesSchema = z.object({
  mood:                z.enum(['sad', 'calm', 'happy', 'excited']),
  attention_score:     z.number().int().min(1).max(10),
  communication_score: z.number().int().min(1).max(10),
  motor_score:         z.number().int().min(1).max(10),
  behavior_score:      z.number().int().min(1).max(10),
  activities:          z.array(z.string()).default([]),
  what_worked:         z.string().max(1000).optional(),
  what_didnt_work:     z.string().max(1000).optional(),
  homework:            z.string().max(1000).optional(),
  notes:               z.string().max(3000).optional(),
  observations:        z.string().max(3000).optional(),
  progress_log:        z.string().max(3000).optional(),
  tantrums_observed:   z.string().max(2000).optional(),
  resolution_notes:    z.string().max(2000).optional(),
  follow_up_required:  z.boolean().default(false),
});

export const UpdateSessionSchema = z.object({
  scheduled_at: z.string()
    .datetime({ offset: true })
    .optional(),

  duration_min: z.number()
    .int()
    .min(15)
    .max(180)
    .optional(),

  type: z.enum([
    "speech",
    "ot",
    "behavior",
    "special_ed",
  ]).optional(),

  mode: z.enum([
    "online",
    "offline",
  ]).optional(),
});


//geofencing

export const GeofenceAttendanceSchema = z.object({
  child_id:       z.string().length(24), 
  center_id:      z.string().length(24), 
  user_latitude:  z.number(),            // live latitude in number format
  user_longitude: z.number(),            // live longitude in number format
});

// Infer types to use in controller
export type CreateSessionInput = z.infer<typeof CreateSessionSchema>;
export type SubmitNotesInput   = z.infer<typeof SubmitNotesSchema>;
export type UpdateSessionInput = z.infer<typeof UpdateSessionSchema>;
export type GeofenceAttendanceInput = z.infer<typeof GeofenceAttendanceSchema>; // New Type