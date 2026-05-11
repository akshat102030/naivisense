import * as AuthService from './auth.service';
import { RegisterSchema, LoginSchema, RefreshSchema } from './auth.schema';
import { asyncHandler }  from '../../utils/http';
import { UserModel }     from '../../models/user.model';
import { AppError }      from '../../middleware/error';

export const register = asyncHandler(async (req, res) => {
  const input            = RegisterSchema.parse(req.body);
  const { user, tokens } = await AuthService.register(input);
  res.status(201).json({ user, ...tokens });
});

export const login = asyncHandler(async (req, res) => {
  const input            = LoginSchema.parse(req.body);
  const { user, tokens } = await AuthService.login(input);
  res.json({ user, ...tokens });
});

export const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = RefreshSchema.parse(req.body);
  const tokens           = await AuthService.refreshTokens(refreshToken);
  res.json(tokens);
});

export const logout = asyncHandler(async (_req, res) => {
  // V2: revoke refresh token in Redis blocklist
  res.json({ message: 'Logged out successfully' });
});

export const me = asyncHandler(async (req, res) => {
  const user = await UserModel.findById((req as any).user.sub);
  if (!user) throw new AppError('NOT_FOUND', 'User not found');
  res.json(user);
});
