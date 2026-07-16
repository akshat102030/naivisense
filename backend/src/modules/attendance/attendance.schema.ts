import { z } from 'zod';

// 1. Schema for Parent Check-In
export const ParentCheckInSchema = z.object({
  child_id:   z.string().length(24),
  session_id: z.string().length(24).optional(),
  date:       z.string().datetime({ offset: true }),
  
  status:     z.enum(['pending_approval', 'present', 'absent']).optional(),
  
  // Allowing either 'geo' (inside geofence) or 'manual_override' (outside geofence)
  source:     z.enum(['geo', 'manual_override']).default('geo'), 
  
  location:   z.object({
    lat:     z.number(),
    lng:     z.number(),
    address: z.string().optional(),
  }),
  notes:      z.string().max(500).optional(),
});

// 2. Schema for Therapist Status Update / Unmark
export const TherapistApproveSchema = z.object({
  session_id:     z.string().length(24),
  attendance_ids: z.array(z.string().length(24)),
  status:         z.enum(['pending_approval', 'present', 'absent']).optional(), // Allows changing status dynamically
});

export const SyncMeetAttendanceSchema = z.object({
  session_id: z.string().length(24),
});

// Types Export
export type ParentCheckInInput = z.infer<typeof ParentCheckInSchema>;
export type TherapistApproveInput = z.infer<typeof TherapistApproveSchema>;
export type SyncMeetAttendanceInput = z.infer<typeof SyncMeetAttendanceSchema>;