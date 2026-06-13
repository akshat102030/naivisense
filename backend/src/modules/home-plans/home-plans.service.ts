import { HomePlanModel }     from '../../models/home-plan.model';
import { HomeTaskLogModel }  from '../../models/home-task-log.model';
import { VerificationModel } from '../../models/verification.model';
import { ChildModel }        from '../../models/child.model';
import { AppError }          from '../../middleware/error';
import { uploadToCloudinary } from '../../config/cloudinary';
import type { AuthPayload }  from '../../middleware/auth';
import type { CreateHomePlanInput } from './home-plans.schema';

export async function createHomePlan(input: CreateHomePlanInput, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can create home plans');
  }
  return HomePlanModel.create({
    ...input,
    therapist_id: user.sub,
    start_date:   new Date(input.start_date),
    end_date:     new Date(input.end_date),
  });
}

export async function getActivePlan(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const plan = await HomePlanModel.findOne({ child_id: childId, is_active: true })
    .sort({ created_at: -1 })
    .lean();
  if (!plan) throw new AppError('NOT_FOUND', 'No active home plan found');
  return plan;
}

export async function logTask(
  planId: string,
  taskId: string,
  user: AuthPayload,
  note?: string,
  file?: Express.Multer.File,
) {
  if (user.role !== 'parent') {
    throw new AppError('FORBIDDEN', 'Only parents can log task completion');
  }
  const plan = await HomePlanModel.findById(planId).lean();
  if (!plan) throw new AppError('NOT_FOUND', 'Home plan not found');

  const task = plan.tasks.find((t) => t.task_id === taskId);
  if (!task) throw new AppError('NOT_FOUND', 'Task not found in this plan');

  let image_url: string | null = null;
  if (file) {
    image_url = await uploadToCloudinary(
      file.buffer,
      'task-logs',
      `${plan.child_id}/${planId}/${taskId}_${Date.now()}`,
      file.mimetype,
    );
  }

  const log = await HomeTaskLogModel.create({
    home_plan_id: planId,
    task_id:      taskId,
    child_id:     plan.child_id,
    logged_by:    user.sub,
    image_url,
    note: note ?? 'Completed',
  });

  const verification = await VerificationModel.create({
    log_id:   log._id,
    log_type: 'home',
    child_id: plan.child_id,
  });

  await HomeTaskLogModel.findByIdAndUpdate(log._id, { verification_id: verification._id });

  return { log, verification };
}
