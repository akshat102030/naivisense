import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV:              z.enum(['development', 'production', 'test']).default('development'),
  PORT:                  z.coerce.number().default(8000),
  MONGO_URL:             z.string().min(1),
  REDIS_URL:             z.string().min(1),
  JWT_ACCESS_SECRET:     z.string().min(32),
  JWT_REFRESH_SECRET:    z.string().min(32),
  ACCESS_TOKEN_EXPIRES:  z.string().default('15m'),
  REFRESH_TOKEN_EXPIRES: z.string().default('7d'),
  CLOUDINARY_CLOUD_NAME: z.string().default('naivisense'),
  CLOUDINARY_API_KEY:    z.string().default('534326439175565'),
  CLOUDINARY_API_SECRET: z.string().default('4W4dqR52lVFS8dQdJks9zJn49E8'),
  AI_SERVICE_URL:        z.string().default('http://localhost:8001'),
  AI_SERVICE_TOKEN:      z.string().min(16).default('dev-token-placeholder-32chars!!'),
  ALLOWED_ORIGIN:        z.string().default('*'),
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('❌ Invalid environment variables:', parsed.error.format());
  process.exit(1);
}

export const env = parsed.data;
