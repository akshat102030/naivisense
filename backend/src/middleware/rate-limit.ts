import rateLimit from 'express-rate-limit';

export const generalRateLimit = rateLimit({
  windowMs:        60 * 1000,
  max:             100,
  standardHeaders: true,
  legacyHeaders:   false,
  message:         { error: { code: 'RATE_LIMITED', message: 'Too many requests', retryable: true } },
});

export const authRateLimit = rateLimit({
  windowMs:        15 * 60 * 1000,
  max:             process.env.NODE_ENV === 'production' ? 10 : 1000,
  standardHeaders: true,
  legacyHeaders:   false,
  message:         { error: { code: 'RATE_LIMITED', message: 'Too many login attempts. Try in 15 minutes.', retryable: false } },
});
