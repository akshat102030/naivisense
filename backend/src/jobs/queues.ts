import { Queue }  from 'bullmq';
import { redis }  from '../config/redis';

const opts = { connection: redis };

export const snapshotQueue = new Queue('snapshot.rebuild', opts);
export const chunkQueue    = new Queue('chunk.from-event', opts);
export const embedQueue    = new Queue('embed.refresh',    opts);
export const reportQueue   = new Queue('report.monthly',   opts);
