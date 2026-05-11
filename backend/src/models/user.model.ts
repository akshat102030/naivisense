import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  role:          'center_head' | 'therapist' | 'parent';
  phone:         string;
  email?:        string;
  password_hash: string;
  name:          string;
  photo_url?:    string;
  is_verified:   boolean;
  created_at:    Date;
  updated_at:    Date;
}

const userSchema = new Schema<IUser>(
  {
    role:          { type: String, enum: ['center_head', 'therapist', 'parent'], required: true },
    phone:         { type: String, required: true, unique: true, index: true, trim: true },
    email:         { type: String, sparse: true, lowercase: true, trim: true },
    password_hash: { type: String, required: true },
    name:          { type: String, required: true, trim: true },
    photo_url:     { type: String },
    is_verified:   { type: Boolean, default: false },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

userSchema.set('toJSON', {
  transform: (_doc, ret) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (ret as any).password_hash;
    return ret;
  },
});

export const UserModel = mongoose.model<IUser>('User', userSchema);
