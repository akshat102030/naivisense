import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './verification.controller';

const router = Router();
router.use(requireAuth);

router.get('/pending',      requireRole('center_head'), Ctrl.pending);
router.post('/:logId',      requireRole('center_head'), Ctrl.verify);

export default router;
