import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import * as Ctrl       from './assessments.controller';

const router = Router();
router.use(requireAuth);

router.post('/',    Ctrl.create);
router.get('/',     Ctrl.list);
router.get('/:id',  Ctrl.get);

export default router;
