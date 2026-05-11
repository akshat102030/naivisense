import * as ReportsService from './reports.service';
import { AppError }        from '../../middleware/error';
import { asyncHandler }    from '../../utils/http';

export const progress = asyncHandler(async (req, res) => {
  const { childId, from, to } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  if (!from || typeof from !== 'string') {
    throw new AppError('INVALID_INPUT', 'from query param is required (ISO date)');
  }
  if (!to || typeof to !== 'string') {
    throw new AppError('INVALID_INPUT', 'to query param is required (ISO date)');
  }
  const report = await ReportsService.getProgressReport(childId, from, to, req.user!);
  res.json(report);
});
