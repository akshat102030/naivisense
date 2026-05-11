import { AppError }        from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';

export async function generatePlan(childId: string, therapyType: string, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can generate AI plans');
  }
  // STUB — full implementation wires to AI service (Python/FastAPI)
  return {
    message:    'AI service not yet connected',
    status:     'stub',
    child_id:   childId,
    therapy_type: therapyType,
  };
}

export async function approvePlan(draftId: string, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can approve AI plans');
  }
  return { message: 'AI service not yet connected', status: 'stub', draft_id: draftId };
}

export async function getInsights(childId: string, user: AuthPayload) {
  void childId;
  // STUB — full: retrieves RAG chunks + calls Claude for insights
  return { message: 'AI service not yet connected', status: 'stub' };
}
