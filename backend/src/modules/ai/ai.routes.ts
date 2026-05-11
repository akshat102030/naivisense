import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './ai.controller';

const router = Router();
router.use(requireAuth);

router.post('/plan',              requireRole('therapist'), Ctrl.generatePlan);
router.post('/plan/:draftId/approve', requireRole('therapist'), Ctrl.approvePlan);
router.post('/insights',          requireRole('therapist', 'center_head'), Ctrl.getInsights);

export default router;
