import * as AlertService    from './alerts.service';
import { CreateAlertSchema, UpdateAlertSchema } from './alerts.schema';
import { AppError }          from '../../middleware/error';
import { asyncHandler }      from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input = CreateAlertSchema.parse(req.body);
  const alert = await AlertService.createAlert(input, req.user!);
  res.status(201).json(alert);
});

export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const alerts = await AlertService.listAlerts(childId, req.user!);
  res.json(alerts);
});

export const update = asyncHandler(async (req, res) => {
  const updates = UpdateAlertSchema.parse(req.body);
  const alert   = await AlertService.updateAlert(req.params.id, updates, req.user!);
  res.json(alert);
});
