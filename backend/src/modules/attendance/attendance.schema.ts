import { z } from 'zod';

// 📱 1. Parent Check-In Ke Liye Schema
export const ParentCheckInSchema = z.object({
  child_id:   z.string().length(24),
  session_id: z.string().length(24), // reuired now
  date:       z.string().datetime({ offset: true }),
  
  // Status 
  status:     z.enum(['pending_approval', 'present', 'absent']).optional(),
  
  source:     z.enum(['geo']).default('geo'), //parent will check-in thru geo-location
  
  // location is strictly required for geo check-in, isliye optional nahi hai
  location:   z.object({
    lat:     z.number(),
    lng:     z.number(),
    address: z.string().optional(),
  }),
  notes:      z.string().max(500).optional(),
});

//  2.schema for therapist approval 
export const TherapistApproveSchema = z.object({
  session_id:     z.string().length(24),
  attendance_ids: z.array(z.string().length(24)), // Array of attendance strings/IDs
});

export const SyncMeetAttendanceSchema = z.object({
  session_id: z.string().length(24),
});

// Types Export
export type ParentCheckInInput = z.infer<typeof ParentCheckInSchema>;
export type TherapistApproveInput = z.infer<typeof TherapistApproveSchema>;
export type SyncMeetAttendanceInput = z.infer<typeof SyncMeetAttendanceSchema>;