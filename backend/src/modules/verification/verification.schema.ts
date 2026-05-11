import { z } from 'zod';

export const VerifySchema = z.object({
  status:  z.enum(['approved', 'rejected']),
  remarks: z.string().max(500).optional(),
});

export type VerifyInput = z.infer<typeof VerifySchema>;
