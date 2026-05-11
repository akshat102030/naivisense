import { Worker } from 'bullmq';
import { redis }                  from '../config/redis';
import logger                     from '../utils/logger';

export const reportWorker = new Worker(
  'report.monthly',
  async (job) => {
    logger.info({ jobId: job.id }, 'Monthly report job triggered — stub');
    // Full: generate and store monthly PDF reports for all active children
  },
  { connection: redis },
);

reportWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Report job failed');
});
