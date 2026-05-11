import mongoose from 'mongoose';
import { env }   from './env';
import logger    from '../utils/logger';

export async function connectDB(): Promise<void> {
  mongoose.set('strictQuery', true);
  await mongoose.connect(env.MONGO_URL, { serverSelectionTimeoutMS: 5000 });
  logger.info('MongoDB connected');
}
