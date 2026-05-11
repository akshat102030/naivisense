import { z } from 'zod';

export const RegisterSchema = z.object({
  name:     z.string().min(2).max(100).trim(),
  phone:    z.string().regex(/^\+?[1-9]\d{9,14}$/, 'Invalid phone number'),
  password: z.string().min(6).max(100),
  role:     z.enum(['center_head', 'therapist', 'parent']),
});

export const LoginSchema = z.object({
  phone:    z.string(),
  password: z.string(),
});

export const RefreshSchema = z.object({
  refreshToken: z.string(),
});

export type RegisterInput = z.infer<typeof RegisterSchema>;
export type LoginInput    = z.infer<typeof LoginSchema>;
