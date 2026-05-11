import mongoose, { Schema, Document } from 'mongoose';

export interface IChild extends Document {
  name:             string;
  nickname?:        string;
  dob:              Date;
  gender:           'boy' | 'girl' | 'other';
  photo_url?:       string;
  diagnosis:        string[];
  severity:         'mild' | 'moderate' | 'high_support';
  primary_concerns: string[];
  therapy_targets:  string[];
  therapist_id?:    mongoose.Types.ObjectId;
  parent_id:        mongoose.Types.ObjectId;
  center_id?:       mongoose.Types.ObjectId;
  medical: {
    birth_history:       string;
    milestones_delay:    boolean;
    hearing_issues:      boolean;
    vision_issues:       boolean;
    current_medications: string[];
  };
  emergency_contact: { name: string; phone: string };
  documents:         { url: string; type: string; uploaded_at: Date }[];
  home_context: {
    primary_caregiver:  string;
    screen_time_hours:  number;
    play_type:          string;
    parent_involvement: string;
  };
  goals: { priorities: string[]; timeline_months: number };
  consent_record: { given_at: Date; given_by: string };
  functional_baseline: {
    communication_level: string;
    attention_span_mins: number;
    social_interaction:  string;
    motor_skills:        string;
    behavior_pattern:    string;
  };
  previous_therapy: {
    had_therapy:     boolean;
    types:           string[];
    duration_months: number;
    progress_noted:  string;
  };
  created_at: Date;
  updated_at: Date;
}

const childSchema = new Schema<IChild>(
  {
    name:             { type: String, required: true, trim: true },
    nickname:         { type: String, trim: true },
    dob:              { type: Date, required: true },
    gender:           { type: String, enum: ['boy', 'girl', 'other'], required: true },
    photo_url:        { type: String },
    diagnosis:        [{ type: String }],
    severity:         { type: String, enum: ['mild', 'moderate', 'high_support'] },
    primary_concerns: [{ type: String }],
    therapy_targets:  [{ type: String }],
    therapist_id:     { type: Schema.Types.ObjectId, ref: 'User' },
    parent_id:        { type: Schema.Types.ObjectId, ref: 'User', required: true },
    center_id:        { type: Schema.Types.ObjectId },
    medical: {
      birth_history:       { type: String, enum: ['normal', 'premature', 'complications'], default: 'normal' },
      milestones_delay:    { type: Boolean, default: false },
      hearing_issues:      { type: Boolean, default: false },
      vision_issues:       { type: Boolean, default: false },
      current_medications: [{ type: String }],
    },
    emergency_contact: { name: String, phone: String },
    documents: [{
      url:         String,
      type:        String,
      uploaded_at: { type: Date, default: Date.now },
    }],
    home_context: {
      primary_caregiver:  { type: String, default: '' },
      screen_time_hours:  { type: Number, default: 0 },
      play_type:          { type: String, enum: ['alone', 'guided', 'group'], default: 'guided' },
      parent_involvement: { type: String, enum: ['low', 'medium', 'high'], default: 'medium' },
    },
    goals: {
      priorities:      [{ type: String }],
      timeline_months: { type: Number, default: 6 },
    },
    consent_record: { given_at: Date, given_by: String },
    functional_baseline: {
      communication_level: { type: String, enum: ['non_verbal', 'single_words', 'phrases', 'sentences'], default: 'non_verbal' },
      attention_span_mins: { type: Number, default: 5 },
      social_interaction:  { type: String, enum: ['avoids', 'parallel', 'interactive'], default: 'avoids' },
      motor_skills:        { type: String, enum: ['low', 'medium', 'age_appropriate'], default: 'low' },
      behavior_pattern:    { type: String, enum: ['calm', 'challenging', 'mixed'], default: 'mixed' },
    },
    previous_therapy: {
      had_therapy:     { type: Boolean, default: false },
      types:           [{ type: String }],
      duration_months: { type: Number, default: 0 },
      progress_noted:  { type: String, default: '' },
    },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

childSchema.index({ parent_id:    1 });
childSchema.index({ therapist_id: 1 });

export const ChildModel = mongoose.model<IChild>('Child', childSchema);
