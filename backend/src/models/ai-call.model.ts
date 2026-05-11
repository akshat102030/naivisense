import mongoose, { Schema, Document } from 'mongoose';

export interface IAiCall extends Omit<Document, 'model'> {
  called_by:        mongoose.Types.ObjectId;
  child_id:         mongoose.Types.ObjectId;
  endpoint:         '/ai/plan' | '/ai/insights' | '/ai/report';
  model:            string;
  input_tokens:     number;
  output_tokens:    number;
  latency_ms:       number;
  prompt_id?:       string;
  redacted_request: Record<string, unknown>;
  response_summary: string;
  cost_usd:         number;
  created_at:       Date;
}

const aiCallSchema = new Schema<IAiCall>(
  {
    called_by:        { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    child_id:         { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    endpoint:         { type: String, enum: ['/ai/plan', '/ai/insights', '/ai/report'], required: true },
    model:            { type: String, required: true },
    input_tokens:     { type: Number, required: true },
    output_tokens:    { type: Number, required: true },
    latency_ms:       { type: Number, default: 0 },
    prompt_id:        { type: String },
    redacted_request: { type: Schema.Types.Mixed, default: {} },
    response_summary: { type: String, default: '' },
    cost_usd:         { type: Number, default: 0 },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } },
);

export const AiCallModel = mongoose.model<IAiCall>('AiCall', aiCallSchema);
