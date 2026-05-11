import mongoose, { Schema, Document } from 'mongoose';

export interface IMealLog extends Document {
  diet_plan_id:    mongoose.Types.ObjectId;
  meal_id:         string;
  child_id:        mongoose.Types.ObjectId;
  logged_by:       mongoose.Types.ObjectId;
  logged_at:       Date;
  image_url?:      string;
  notes?:          string;
  status:          'pending' | 'approved' | 'rejected';
  verification_id: mongoose.Types.ObjectId | null;
}

const mealLogSchema = new Schema<IMealLog>(
  {
    diet_plan_id:    { type: Schema.Types.ObjectId, ref: 'DietPlan', required: true },
    meal_id:         { type: String, required: true },
    child_id:        { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    logged_by:       { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    logged_at:       { type: Date, default: Date.now },
    image_url:       { type: String },
    notes:           { type: String },
    status:          { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
    verification_id: { type: Schema.Types.ObjectId, default: null },
  },
  { timestamps: true },
);

mealLogSchema.index({ child_id: 1, logged_at: -1 });

export const MealLogModel = mongoose.model<IMealLog>('MealLog', mealLogSchema);
