import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './diet-plans.controller';

const router = Router();
router.use(requireAuth);

router.post('/',                          requireRole('therapist'), Ctrl.create);
router.get('/active',                     Ctrl.getActive);
router.post('/:id/meals/:mealId/log',     requireRole('parent'),    Ctrl.logMeal);

export default router;
