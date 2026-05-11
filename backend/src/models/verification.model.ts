import mongoose, { Schema, Document } from 'mongoose';

export interface IVerification extends Document {
  log_id:      mongoose.Types.ObjectId;
  log_type:    'home' | 'diet' | 'attendance';
  child_id:    mongoose.Types.ObjectId;
  verified_by: mongoose.Types.ObjectId | null;
  status:      'pending' | 'approved' | 'rejected';
  remarks?:    string;
  verified_at: Date | null;
  created_at:  Date;
}

const verificationSchema = new Schema<IVerification>(
  {
    log_id:      { type: Schema.Types.ObjectId, required: true },
    log_type:    { type: String, enum: ['home', 'diet', 'attendance'], required: true },
    child_id:    { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    verified_by: { type: Schema.Types.ObjectId, ref: 'User',  default: null },
    status:      { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
    remarks:     { type: String },
    verified_at: { type: Date, default: null },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } },
);

verificationSchema.index({ status: 1, created_at: -1 });

export const VerificationModel = mongoose.model<IVerification>('Verification', verificationSchema);
