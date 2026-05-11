import { AlertModel }           from '../../models/alert.model';
import { ChildModel }           from '../../models/child.model';
import { AppError }             from '../../middleware/error';
import type { AuthPayload }     from '../../middleware/auth';
import type { CreateAlertInput, UpdateAlertInput } from './alerts.schema';

export async function createAlert(input: CreateAlertInput, user: AuthPayload) {
  if (user.role !== 'parent') {
    throw new AppError('FORBIDDEN', 'Only parents can raise alerts');
  }
  return AlertModel.create({ ...input, raised_by: user.sub });
}

export async function listAlerts(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    (user.role === 'therapist' && String(child.therapist_id) === user.sub) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');
  return AlertModel.find({ child_id: childId }).sort({ created_at: -1 }).lean();
}

export async function updateAlert(id: string, updates: UpdateAlertInput, user: AuthPayload) {
  if (!['therapist', 'center_head'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can update alerts');
  }
  const alert = await AlertModel.findByIdAndUpdate(
    id,
    {
      $set: {
        ...(updates.status          && { status: updates.status }),
        ...(updates.acknowledged_at && { acknowledged_at: new Date(updates.acknowledged_at) }),
        ...(updates.resolved_at     && { resolved_at: new Date(updates.resolved_at) }),
      },
    },
    { new: true },
  );
  if (!alert) throw new AppError('NOT_FOUND', 'Alert not found');
  return alert;
}
