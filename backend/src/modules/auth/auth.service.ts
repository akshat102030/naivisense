import bcrypt         from 'bcrypt';
import jwt            from 'jsonwebtoken';
import { UserModel }  from '../../models/user.model';
import { AppError }   from '../../middleware/error';
import { env }        from '../../config/env';
import type { RegisterInput, LoginInput } from './auth.schema';

export async function register(input: RegisterInput) {
  const existing = await UserModel.findOne({ phone: input.phone });
  if (existing) throw new AppError('CONFLICT', 'Phone number already registered');

  const hash = await bcrypt.hash(input.password, 12);
  const user = await UserModel.create({
    name:          input.name,
    phone:         input.phone,
    password_hash: hash,
    role:          input.role,
  });
  return { user, tokens: issueTokens(user.id as string, user.role) };
}

export async function login(input: LoginInput) {
  const user = await UserModel.findOne({ phone: input.phone });
  if (!user) throw new AppError('UNAUTHORIZED', 'Invalid phone or password');

  const ok = await bcrypt.compare(input.password, user.password_hash);
  if (!ok) throw new AppError('UNAUTHORIZED', 'Invalid phone or password');

  return { user, tokens: issueTokens(user.id as string, user.role) };
}

export async function refreshTokens(refreshToken: string) {
  let payload: { sub: string; role: string };
  try {
    payload = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET) as { sub: string; role: string };
  } catch {
    throw new AppError('UNAUTHORIZED', 'Refresh token invalid or expired');
  }
  const user = await UserModel.findById(payload.sub);
  if (!user) throw new AppError('UNAUTHORIZED', 'User not found');
  return issueTokens(user.id as string, user.role);
}

function issueTokens(userId: string, role: string) {
  const payload      = { sub: userId, role };
  const accessToken  = jwt.sign(payload, env.JWT_ACCESS_SECRET,  { expiresIn: env.ACCESS_TOKEN_EXPIRES  as never });
  const refreshToken = jwt.sign(payload, env.JWT_REFRESH_SECRET, { expiresIn: env.REFRESH_TOKEN_EXPIRES as never });
  return { accessToken, refreshToken };
}
