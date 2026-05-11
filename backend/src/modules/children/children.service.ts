import { ChildModel }            from '../../models/child.model';
import { ChildSnapshotModel }    from '../../models/child-snapshot.model';
import { AppError }              from '../../middleware/error';
import type { CreateChildInput } from './children.schema';
import type { AuthPayload }      from '../../middleware/auth';

export async function listChildren(user: AuthPayload) {
  const filter =
    user.role === 'therapist'   ? { therapist_id: user.sub } :
    user.role === 'parent'      ? { parent_id:    user.sub } :
    {};  // center_head sees all

  const query = ChildModel.find(filter).sort({ created_at: -1 });

  // Populate staff names for admin so the frontend doesn't need extra lookups
  if (user.role === 'center_head') {
    query
      .populate('therapist_id', 'name phone')
      .populate('parent_id',    'name phone');
  }

  return query.lean();
}

export async function getChild(id: string, user: AuthPayload) {
  const child = await ChildModel.findById(id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  if (!canAccess(child, user)) throw new AppError('FORBIDDEN', 'Access denied');
  return child;
}

export async function createChild(input: CreateChildInput, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can register children');
  }
  return ChildModel.create({
    ...input,
    dob:            new Date(input.dob),
    consent_record: {
      given_at: new Date(input.consent_record.given_at),
      given_by: input.consent_record.given_by,
    },
  });
}

export async function updateChild(id: string, updates: Partial<CreateChildInput>, user: AuthPayload) {
  const child = await ChildModel.findById(id);
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');
  if (user.role === 'parent') throw new AppError('FORBIDDEN', 'Access denied');

  Object.assign(child, updates);
  return child.save();
}

export async function getSnapshot(id: string, user: AuthPayload) {
  const child = await ChildModel.findById(id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');
  if (!canAccess(child, user)) throw new AppError('FORBIDDEN', 'Access denied');

  const snapshot = await ChildSnapshotModel.findOne({ child_id: id, is_current: true }).lean();
  if (!snapshot) throw new AppError('NOT_FOUND', 'No snapshot available for this child yet');
  return snapshot;
}

function canAccess(child: { therapist_id?: unknown; parent_id: unknown }, user: AuthPayload): boolean {
  if (user.role === 'center_head') return true;
  if (user.role === 'therapist')   return String(child.therapist_id) === user.sub;
  if (user.role === 'parent')      return String(child.parent_id)    === user.sub;
  return false;
}
