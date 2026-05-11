import { VerificationModel }  from '../../models/verification.model';
import { HomeTaskLogModel }   from '../../models/home-task-log.model';
import { MealLogModel }       from '../../models/meal-log.model';
import { AppError }           from '../../middleware/error';
import { chunkQueue }         from '../../jobs/queues';
import type { AuthPayload }   from '../../middleware/auth';
import type { VerifyInput }   from './verification.schema';

export async function getPending(user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can view the verification queue');
  }
  return VerificationModel.find({ status: 'pending' }).sort({ created_at: -1 }).lean();
}

export async function verify(logId: string, decision: VerifyInput, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can verify submissions');
  }

  const record = await VerificationModel.findOne({ log_id: logId });
  if (!record) throw new AppError('NOT_FOUND', 'Verification record not found');
  if (record.status !== 'pending') throw new AppError('CONFLICT', 'Already verified');

  record.status      = decision.status;
  record.remarks     = decision.remarks;
  record.verified_by = user.sub as never;
  record.verified_at = new Date();
  await record.save();

  // Update the source log status to match
  if (record.log_type === 'home') {
    await HomeTaskLogModel.findByIdAndUpdate(logId, { status: decision.status });
  } else if (record.log_type === 'diet') {
    await MealLogModel.findByIdAndUpdate(logId, { status: decision.status });
  }

  await chunkQueue.add('verification-outcome', {
    verificationId: record.id,
    status:         decision.status,
    childId:        record.child_id.toString(),
    event_type:     'verification_outcome',
    child_id:       record.child_id.toString(),
  });

  return record;
}
