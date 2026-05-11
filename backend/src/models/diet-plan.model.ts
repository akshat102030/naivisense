import mongoose, { Schema, Document } from 'mongoose';

export interface IMeal {
  meal_id:         string;
  name:            string;
  description?:    string;
  meal_time:       'breakfast' | 'lunch' | 'dinner' | 'snack';
  calories_approx: number;
  ingredients:     string[];
  instructions?:   string;
  frequency:       'daily' | 'weekly';
}

export interface IDietPlan extends Document {
  child_id:     mongoose.Types.ObjectId;
  therapist_id: mongoose.Types.ObjectId;
  start_date:   Date;
  end_date:     Date;
  meals:        IMeal[];
  notes?:       string;
  is_active:    boolean;
  created_at:   Date;
  updated_at:   Date;
}

const mealSchema = new Schema<IMeal>(
  {
    meal_id:         { type: String, required: true },
    name:            { type: String, required: true },
    description:     { type: String },
    meal_time:       { type: String, enum: ['breakfast', 'lunch', 'dinner', 'snack'], required: true },
    calories_approx: { type: Number, default: 0 },
    ingredients:     [{ type: String }],
    instructions:    { type: String },
    frequency:       { type: String, enum: ['daily', 'weekly'], default: 'daily' },
  },
  { _id: false },
);

const dietPlanSchema = new Schema<IDietPlan>(
  {
    child_id:     { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    therapist_id: { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    start_date:   { type: Date, required: true },
    end_date:     { type: Date, required: true },
    meals:        [mealSchema],
    notes:        { type: String },
    is_active:    { type: Boolean, default: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

dietPlanSchema.index({ child_id: 1, is_active: 1 });

export const DietPlanModel = mongoose.model<IDietPlan>('DietPlan', dietPlanSchema);
