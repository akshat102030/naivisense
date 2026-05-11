import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { upload }      from '../../middleware/upload';
import * as Ctrl       from './home-plans.controller';

const router = Router();
router.use(requireAuth);

router.post('/',                                          requireRole('therapist'), Ctrl.create);
router.get('/active',                                     Ctrl.getActive);
router.post('/:id/tasks/:taskId/log', requireRole('parent'), upload.single('image'), Ctrl.logTask);

export default router;
