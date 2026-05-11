import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import * as Ctrl       from './reports.controller';

const router = Router();
router.use(requireAuth);

router.get('/progress', Ctrl.progress);

export default router;
