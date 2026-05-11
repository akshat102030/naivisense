import { Worker } from 'bullmq';
import { redis }  from '../config/redis';
import logger     from '../utils/logger';

export const snapshotWorker = new Worker(
  'snapshot.rebuild',
  async (job) => {
    const { childId } = job.data as { childId: string };
    logger.info({ childId }, 'Snapshot rebuild queued — AI service not yet connected (stub)');
    // Full: POST to AI service /snapshot/rebuild/:childId
  },
  { connection: redis, concurrency: 5 },
);

snapshotWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Snapshot job failed');
});
