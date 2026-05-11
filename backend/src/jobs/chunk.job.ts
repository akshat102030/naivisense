import { Worker } from 'bullmq';
import { redis }  from '../config/redis';
import logger     from '../utils/logger';

export const chunkWorker = new Worker(
  'chunk.from-event',
  async (job) => {
    const { event_type, child_id } = job.data as { event_type: string; child_id: string };
    logger.info({ event_type, child_id }, 'Chunk event queued — AI service not yet connected (stub)');
    // Full: POST to AI service /chunk/from-event
  },
  { connection: redis, concurrency: 10 },
);

chunkWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Chunk job failed');
});
