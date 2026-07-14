import { z } from "zod";


export const AssessmentSnapshotSchema = z.object({

    type: z.enum([
        "initial",
        "monthly",
        "quarterly"
    ]),


    date: z.string().optional(),


    assessed_by: z.string().optional(),


    is_complete: z.boolean()
    .optional(),


    domain_data:
    z.record(
        z.string(),
        z.record(z.any())
    ),


    domain_scores:
    z.record(
        z.string(),
        z.number()
    )
    .optional(),


    overall_score_pct:
    z.number()
    .optional(),


    risk_level:
    z.enum([
        "green",
        "amber",
        "red"
    ])
    .optional(),


    developmental_quotient:
    z.number()
    .optional(),


    general_notes:
    z.string()
    .optional()

});



export const CreateAssessmentSchema =
z.object({

    child_id:
    z.string(),


    assessment:
    AssessmentSnapshotSchema

});



export type CreateAssessmentInput =
z.infer<
typeof CreateAssessmentSchema
>;
