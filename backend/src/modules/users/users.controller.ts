import { z }             from 'zod';
import * as UsersService  from './users.service';
import { uploadBuffer }   from '../../config/s3';
import { asyncHandler }   from '../../utils/http';
import { AppError }       from '../../middleware/error';

const UpdateMeSchema = z.object({
  name: z.string().min(2).max(100).trim().optional(),
});

export const getMe = asyncHandler(async (req, res) => {
  const user = await UsersService.getMe(req.user!);
  res.json(user);
});

export const updateMe = asyncHandler(async (req, res) => {
  const { name } = UpdateMeSchema.parse(req.body);
  const user     = await UsersService.updateMe(req.user!, { name });
  res.json(user);
});

export const listStaff = asyncHandler(async (req, res) => {
  const role = (req.query.role as string) ?? 'therapist';
  if (!['therapist', 'parent'].includes(role)) {
    throw new AppError('INVALID_INPUT', 'role must be therapist or parent');
  }
  const users = await UsersService.listByRole(role, req.user!);
  res.json(users);
});

export const getUser = asyncHandler(async (req, res) => {
  const user = await UsersService.getById(req.params.id, req.user!);
  res.json(user);
});

export const uploadPhoto = asyncHandler(async (req, res) => {
  if (!req.file) throw new AppError('INVALID_INPUT', 'No image file provided');
  const key       = `users/${req.user!.sub}/photo_${Date.now()}`;
  const photo_url = await uploadBuffer(req.file.buffer, key, req.file.mimetype);
  const user      = await UsersService.updateMe(req.user!, { photo_url });
  res.json(user);
});
