import { Request, Response, NextFunction } from 'express';
import { ZodError }                         from 'zod';
import logger                               from '../utils/logger';

const STATUS_MAP: Record<string, number> = {
  CONFLICT:      409,
  UNAUTHORIZED:  401,
  FORBIDDEN:     403,
  NOT_FOUND:     404,
  INVALID_INPUT: 400,
  RATE_LIMITED:  429,
  AI_FAILURE:    502,
};

export class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public details?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof ZodError) {
    res.status(400).json({
      error: {
        code:      'INVALID_INPUT',
        message:   'Validation failed',
        details:   err.flatten().fieldErrors,
        retryable: false,
      },
    });
    return;
  }

  if (err instanceof AppError) {
    const status = STATUS_MAP[err.code] ?? 400;
    res.status(status).json({
      error: { code: err.code, message: err.message, details: err.details ?? null, retryable: false },
    });
    return;
  }

  logger.error(err, 'Unhandled error');
  res.status(500).json({
    error: { code: 'SERVER_ERROR', message: 'Internal server error', retryable: true },
  });
}
