import mongoose, { Schema, Document } from 'mongoose';

export interface IAssessment extends Document {
  child_id:   mongoose.Types.ObjectId;
  type:       'initial' | 'reassessment' | 'parent_feedback';
  date:       Date;
  traits: {
    eye_contact:    number;
    grip:           number;
    behavior:       number;
    walking:        number;
    communication:  number;
    motor_skills:   number;
    attention:      number;
  };
  notes:      string;
  created_by: mongoose.Types.ObjectId;
}

const traitField = { type: Number, min: 1, max: 5, default: 3 };

const assessmentSchema = new Schema<IAssessment>(
  {
    child_id:   { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    type:       { type: String, enum: ['initial', 'reassessment', 'parent_feedback'], required: true },
    date:       { type: Date, default: Date.now },
    traits: {
      eye_contact:   traitField,
      grip:          traitField,
      behavior:      traitField,
      walking:       traitField,
      communication: traitField,
      motor_skills:  traitField,
      attention:     traitField,
    },
    notes:      { type: String, default: '' },
    created_by: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true },
);

assessmentSchema.index({ child_id: 1, date: -1 });

export const AssessmentModel = mongoose.model<IAssessment>('Assessment', assessmentSchema);
