import mongoose, { Schema, Document } from 'mongoose';

export interface IChildSnapshot extends Document {
  child_id:   mongoose.Types.ObjectId;
  is_current: boolean;
  version:    number;
  updated_at: Date;
  profile: {
    age:          number;
    diagnosis:    string[];
    notes:        string;
    home_context: Record<string, unknown>;
  };
  baseline_assessment: { date: Date; traits: Record<string, number> };
  latest_assessment:   { date: Date; traits: Record<string, number>; summary: string };
  trends:              Record<string, string>;
  compliance: { home_plan_pct: number; diet_plan_pct: number; attendance_pct: number };
  recent_issues: string[];
  recent_wins:   string[];
  ai_insights: {
    progress_level:  string;
    risk_flags:      string[];
    strengths:       string[];
    recommendations: string[];
  };
  next_goals: string[];
}

const childSnapshotSchema = new Schema<IChildSnapshot>({
  child_id:   { type: Schema.Types.ObjectId, ref: 'Child', required: true },
  is_current: { type: Boolean, default: true },
  version:    { type: Number, default: 1 },
  updated_at: { type: Date, default: Date.now },
  profile: {
    age:          Number,
    diagnosis:    [String],
    notes:        String,
    home_context: Schema.Types.Mixed,
  },
  baseline_assessment: { date: Date, traits: Schema.Types.Mixed },
  latest_assessment:   { date: Date, traits: Schema.Types.Mixed, summary: String },
  trends:              Schema.Types.Mixed,
  compliance: {
    home_plan_pct:  { type: Number, default: 0 },
    diet_plan_pct:  { type: Number, default: 0 },
    attendance_pct: { type: Number, default: 0 },
  },
  recent_issues: [String],
  recent_wins:   [String],
  ai_insights: {
    progress_level:  String,
    risk_flags:      [String],
    strengths:       [String],
    recommendations: [String],
  },
  next_goals: [String],
});

childSnapshotSchema.index({ child_id: 1, is_current: 1 });

export const ChildSnapshotModel = mongoose.model<IChildSnapshot>(
  'ChildSnapshot',
  childSnapshotSchema,
);
