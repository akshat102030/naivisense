import { AssessmentModel }          from '../../models/assessment.model';
import { ChildModel }               from '../../models/child.model';
import { AppError }                 from '../../middleware/error';
import type { AuthPayload }         from '../../middleware/auth';
import type { CreateAssessmentInput } from './assessments.schema';

export async function createAssessment(input: CreateAssessmentInput, user: AuthPayload) {
  const child = await ChildModel.findById(input.child_id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const assessment = await AssessmentModel.create({
    ...input,
    date:       input.date ? new Date(input.date) : new Date(),
    created_by: user.sub,
  });
  return assessment;
}

export async function listAssessments(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    (user.role === 'therapist' && String(child.therapist_id) === user.sub) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  return AssessmentModel.find({ child_id: childId }).sort({ date: -1 }).lean();
}

export async function getAssessment(id: string, user: AuthPayload) {
  const assessment = await AssessmentModel.findById(id).lean();
  if (!assessment) throw new AppError('NOT_FOUND', 'Assessment not found');

  const child = await ChildModel.findById(assessment.child_id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    (user.role === 'therapist' && String(child.therapist_id) === user.sub) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');
  return assessment;
}
