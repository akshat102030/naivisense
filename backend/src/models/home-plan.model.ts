import mongoose, { Schema, Document } from 'mongoose';

export interface ITask {
  task_id:      string;
  title:        string;
  description?: string;
  icon:         string;
  time_of_day:  'morning' | 'afternoon' | 'evening';
  duration_min: number;
  frequency:    'daily' | 'weekly';
  target_count: number;
}

export interface IHomePlan extends Document {
  child_id:      mongoose.Types.ObjectId;
  therapist_id:  mongoose.Types.ObjectId;
  start_date:    Date;
  end_date:      Date;
  tasks:         ITask[];
  ai_draft_diff: Record<string, unknown> | null;
  is_active:     boolean;
  created_at:    Date;
  updated_at:    Date;
}

const taskSchema = new Schema<ITask>(
  {
    task_id:      { type: String, required: true },
    title:        { type: String, required: true },
    description:  { type: String },
    icon:         { type: String, default: '✅' },
    time_of_day:  { type: String, enum: ['morning', 'afternoon', 'evening'], required: true },
    duration_min: { type: Number, required: true },
    frequency:    { type: String, enum: ['daily', 'weekly'], default: 'daily' },
    target_count: { type: Number, default: 1 },
  },
  { _id: false },
);

const homePlanSchema = new Schema<IHomePlan>(
  {
    child_id:      { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    therapist_id:  { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    start_date:    { type: Date, required: true },
    end_date:      { type: Date, required: true },
    tasks:         [taskSchema],
    ai_draft_diff: { type: Schema.Types.Mixed, default: null },
    is_active:     { type: Boolean, default: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

homePlanSchema.index({ child_id: 1, is_active: 1 });

export const HomePlanModel = mongoose.model<IHomePlan>('HomePlan', homePlanSchema);
