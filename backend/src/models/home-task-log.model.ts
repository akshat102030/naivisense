import mongoose, { Schema, Document } from 'mongoose';

export interface IHomeTaskLog extends Document {
  home_plan_id:    mongoose.Types.ObjectId;
  task_id:         string;
  child_id:        mongoose.Types.ObjectId;
  logged_by:       mongoose.Types.ObjectId;
  logged_at:       Date;
  image_url:       string;
  status:          'pending' | 'approved' | 'rejected';
  verification_id: mongoose.Types.ObjectId | null;
}

const homeTaskLogSchema = new Schema<IHomeTaskLog>(
  {
    home_plan_id:    { type: Schema.Types.ObjectId, ref: 'HomePlan', required: true },
    task_id:         { type: String, required: true },
    child_id:        { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    logged_by:       { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    logged_at:       { type: Date, default: Date.now },
    image_url:       { type: String, required: true },
    status:          { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
    verification_id: { type: Schema.Types.ObjectId, default: null },
  },
  { timestamps: true },
);

homeTaskLogSchema.index({ child_id: 1, logged_at: -1 });
homeTaskLogSchema.index({ home_plan_id: 1, task_id: 1 });

export const HomeTaskLogModel = mongoose.model<IHomeTaskLog>('HomeTaskLog', homeTaskLogSchema);
