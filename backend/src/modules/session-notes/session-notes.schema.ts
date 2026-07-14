import { z } from "zod";


export const SessionNotesSchema = z.object({

    mood: z
    .enum([
        "sad",
        "calm",
        "happy",
        "excited"
    ])
    .optional(),


    attention_score:
    z.number()
    .min(1)
    .max(10)
    .optional(),


    communication_score:
    z.number()
    .min(1)
    .max(10)
    .optional(),


    motor_score:
    z.number()
    .min(1)
    .max(10)
    .optional(),


    behavior_score:
    z.number()
    .min(1)
    .max(10)
    .optional(),



    activities:
    z.array(
        z.string()
    )
    .optional(),



    what_worked:
    z.string()
    .optional(),



    what_didnt_work:
    z.string()
    .optional(),



    homework:
    z.string()
    .optional(),



    notes:
    z.string()
    .optional(),



    observations:
    z.string()
    .optional(),



    progress_log:
    z.string()
    .optional(),



    tantrums_observed:
    z.string()
    .optional(),



    resolution_notes:
    z.string()
    .optional(),



    follow_up_required:
    z.boolean()
    .optional()

});


export type SessionNotesInput =
z.infer<
typeof SessionNotesSchema
>;