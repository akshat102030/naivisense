import * as VerifyService  from './verification.service';
import { VerifySchema }    from './verification.schema';
import { asyncHandler }    from '../../utils/http';

export const pending = asyncHandler(async (req, res) => {
  const records = await VerifyService.getPending(req.user!);
  res.json(records);
});

export const verify = asyncHandler(async (req, res) => {
  const decision = VerifySchema.parse(req.body);
  const record   = await VerifyService.verify(req.params.logId, decision, req.user!);
  res.json(record);
});
