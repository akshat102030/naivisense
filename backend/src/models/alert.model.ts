import mongoose, { Schema, Document } from 'mongoose';

export interface IAlert extends Document {
  child_id:        mongoose.Types.ObjectId;
  raised_by:       mongoose.Types.ObjectId;
  type:            'fever' | 'regression' | 'aggression' | 'seizure' | 'sleep_issue' | 'injury' | 'emotional_stress' | 'other';
  description:     string;
  severity:        'low' | 'medium' | 'high';
  status:          'open' | 'seen' | 'resolved';
  created_at:      Date;
  acknowledged_at: Date | null;
  resolved_at:     Date | null;
}

const alertSchema = new Schema<IAlert>(
  {
    child_id:        { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    raised_by:       { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    type:            {
      type:     String,
      enum:     ['fever', 'regression', 'aggression', 'seizure', 'sleep_issue', 'injury', 'emotional_stress', 'other'],
      required: true,
    },
    description:     { type: String, required: true },
    severity:        { type: String, enum: ['low', 'medium', 'high'], required: true },
    status:          { type: String, enum: ['open', 'seen', 'resolved'], default: 'open' },
    acknowledged_at: { type: Date, default: null },
    resolved_at:     { type: Date, default: null },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } },
);

alertSchema.index({ child_id: 1, status: 1 });

export const AlertModel = mongoose.model<IAlert>('Alert', alertSchema);
