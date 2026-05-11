import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './alerts.controller';

const router = Router();
router.use(requireAuth);

router.post('/',      requireRole('parent'), Ctrl.create);
router.get('/',       Ctrl.list);
router.patch('/:id',  requireRole('therapist', 'center_head'), Ctrl.update);

export default router;
