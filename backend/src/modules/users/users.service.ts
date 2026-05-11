import { UserModel }       from '../../models/user.model';
import { AppError }        from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';

export async function getMe(user: AuthPayload) {
  const doc = await UserModel.findById(user.sub).lean();
  if (!doc) throw new AppError('NOT_FOUND', 'User not found');
  return doc;
}

export async function listByRole(role: string, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  return UserModel.find({ role }, { password_hash: 0 }).sort({ name: 1 }).lean();
}

export async function getById(id: string, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  const doc = await UserModel.findById(id, { password_hash: 0 }).lean();
  if (!doc) throw new AppError('NOT_FOUND', 'User not found');
  return doc;
}

export async function updateMe(user: AuthPayload, updates: { name?: string; photo_url?: string }) {
  const doc = await UserModel.findByIdAndUpdate(
    user.sub,
    { $set: updates },
    { new: true, runValidators: true },
  );
  if (!doc) throw new AppError('NOT_FOUND', 'User not found');
  return doc;
}
