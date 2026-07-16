import mongoose, { Schema, Document } from "mongoose";

export type RiskLevel = "green" | "amber" | "red";

export interface IDomainScores {
  attention: number;
  behavioral: number;
  social_communication: number;
  receptive_language: number;
  expressive_language: number;
  speech_production: number;
  imitation: number;
  visual_perception: number;
  fine_motor: number;
  gross_motor: number;
  sensory: number;
  adl: number;
  academics: number;
  cognitive: number;
  emotional_regulation: number;
}

export interface IAssessmentSnapshot {
  type: "initial" | "monthly" | "quarterly";

  date: Date;

  assessed_by: mongoose.Types.ObjectId;

  is_complete: boolean;

  domain_data: Record<string, Record<string, unknown>>;

  domain_scores: Partial<IDomainScores>;

  overall_score_pct: number;

  risk_level: RiskLevel;

  developmental_quotient: number;

  general_notes: string;
}

export interface IAssessment extends Document {
  child_id: mongoose.Types.ObjectId;

  initial: IAssessmentSnapshot | null;

  previous: IAssessmentSnapshot | null;

  latest: IAssessmentSnapshot | null;

  created_at: Date;

  updated_at: Date;
}

const assessmentSnapshotSchema = new Schema<IAssessmentSnapshot>(
  {
    type: {
      type: String,

      enum: ["initial", "monthly", "quarterly"],

      required: true,
    },

    date: {
      type: Date,

      default: Date.now,
    },

    assessed_by: {
      type: Schema.Types.ObjectId,

      ref: "User",

      required: true,
    },

    is_complete: {
      type: Boolean,

      default: false,
    },

    domain_data: {
      type: Schema.Types.Mixed,

      default: {},
    },

    domain_scores: {
      attention: {
        type: Number,
        default: 0,
      },

      behavioral: {
        type: Number,
        default: 0,
      },

      social_communication: {
        type: Number,
        default: 0,
      },

      receptive_language: {
        type: Number,
        default: 0,
      },

      expressive_language: {
        type: Number,
        default: 0,
      },

      speech_production: {
        type: Number,
        default: 0,
      },

      imitation: {
        type: Number,
        default: 0,
      },

      visual_perception: {
        type: Number,
        default: 0,
      },

      fine_motor: {
        type: Number,
        default: 0,
      },

      gross_motor: {
        type: Number,
        default: 0,
      },

      sensory: {
        type: Number,
        default: 0,
      },

      adl: {
        type: Number,
        default: 0,
      },

      academics: {
        type: Number,
        default: 0,
      },

      cognitive: {
        type: Number,
        default: 0,
      },

      emotional_regulation: {
        type: Number,
        default: 0,
      },
    },

    overall_score_pct: {
      type: Number,

      default: 0,
    },

    risk_level: {
      type: String,

      enum: ["green", "amber", "red"],

      default: "amber",
    },

    developmental_quotient: {
      type: Number,

      default: 0,
    },

    general_notes: {
      type: String,

      default: "",
    },
  },

  {
    _id: false,
  }
);

const assessmentSchema = new Schema<IAssessment>(
  {
    child_id: {
      type: Schema.Types.ObjectId,

      ref: "Child",

      required: true,

      unique: true,
    },

    initial: {
      type: assessmentSnapshotSchema,

      default: null,
    },

    latest: {
      type: assessmentSnapshotSchema,

      default: null,
    },
  },

  {
    timestamps: {
      createdAt: "created_at",

      updatedAt: "updated_at",
    },
  }
);

assessmentSchema.index(
  {
    child_id: 1,
  },
  {
    unique: true,
  }
);

export const AssessmentModel = mongoose.model<IAssessment>(
  "Assessment",
  assessmentSchema
);
