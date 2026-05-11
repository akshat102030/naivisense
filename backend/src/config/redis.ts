import IORedis from 'ioredis';
import { env }  from './env';

export const redis = new IORedis(env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableOfflineQueue:   false,
  lazyConnect:          true,
});

redis.on('error', () => {
  // Prevent unhandled error event crash — connection failures logged in connectRedis()
});

export async function connectRedis(): Promise<void> {
  if (redis.status === 'ready') {
    return;
  }
  if (redis.status === 'connecting' || redis.status === 'connect') {
    await new Promise<void>((resolve, reject) => {
      redis.once('ready', resolve);
      redis.once('error', reject);
    });
    return;
  }
  await redis.connect();
  await redis.ping();
}
