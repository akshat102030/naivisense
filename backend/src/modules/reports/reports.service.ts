import mongoose               from 'mongoose';
import { SessionModel }       from '../../models/session.model';
import { HomeTaskLogModel }   from '../../models/home-task-log.model';
import { ChildModel }         from '../../models/child.model';
import { AppError }           from '../../middleware/error';
import type { AuthPayload }   from '../../middleware/auth';

export async function getProgressReport(
  childId: string,
  from: string,
  to: string,
  user: AuthPayload,
) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const fromDate = new Date(from);
  const toDate   = new Date(to);
  const childOid = new mongoose.Types.ObjectId(childId);

  const sessionStats = await SessionModel.aggregate([
    {
      $match: {
        child_id:     childOid,
        scheduled_at: { $gte: fromDate, $lte: toDate },
      },
    },
    {
      $group: {
        _id:               { $isoWeek: '$scheduled_at' },
        week:              { $first: { $isoWeek: '$scheduled_at' } },
        total:             { $sum: 1 },
        completed:         { $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] } },
        avg_attention:     { $avg: '$notes.attention_score' },
        avg_communication: { $avg: '$notes.communication_score' },
        avg_motor:         { $avg: '$notes.motor_score' },
        avg_behavior:      { $avg: '$notes.behavior_score' },
      },
    },
    { $sort: { _id: 1 } },
  ]);

  const taskLogs    = await HomeTaskLogModel.find({
    child_id:  childOid,
    logged_at: { $gte: fromDate, $lte: toDate },
  }).lean();

  const totalLogs    = taskLogs.length;
  const approvedLogs = taskLogs.filter((l) => l.status === 'approved').length;
  const compliancePct = totalLogs > 0 ? Math.round((approvedLogs / totalLogs) * 100) : 0;

  return {
    child_id:         childId,
    period:           { from, to },
    sessions_by_week: sessionStats,
    compliance: {
      total_logged: totalLogs,
      approved:     approvedLogs,
      percentage:   compliancePct,
    },
  };
}
