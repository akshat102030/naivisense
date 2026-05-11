import mongoose, { Schema, Document } from 'mongoose';

export interface ITherapistProfile extends Document {
  user_id:            mongoose.Types.ObjectId;
  qualification:      string;
  certifications:     string[];
  years_experience:   number;
  workplace_type:     'clinic' | 'hospital' | 'freelance' | 'ngo';
  organization_name?: string;
  license_number?:    string;
  age_groups:         string[];
  conditions_handled: string[];
  therapy_methods:    string[];
  available_days:     string[];
  session_modes:      string[];
  session_duration:   number;
}

const therapistProfileSchema = new Schema<ITherapistProfile>({
  user_id:            { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  qualification:      { type: String, default: '' },
  certifications:     [{ type: String }],
  years_experience:   { type: Number, default: 0 },
  workplace_type:     { type: String, enum: ['clinic', 'hospital', 'freelance', 'ngo'], default: 'clinic' },
  organization_name:  { type: String },
  license_number:     { type: String },
  age_groups:         [{ type: String }],
  conditions_handled: [{ type: String }],
  therapy_methods:    [{ type: String }],
  available_days:     [{ type: String }],
  session_modes:      [{ type: String }],
  session_duration:   { type: Number, default: 45 },
});

export const TherapistProfileModel = mongoose.model<ITherapistProfile>(
  'TherapistProfile',
  therapistProfileSchema,
);
