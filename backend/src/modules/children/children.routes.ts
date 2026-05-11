import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import * as ChildCtrl  from './children.controller';

const router = Router();
router.use(requireAuth);

router.get('/',           ChildCtrl.list);
router.post('/',          ChildCtrl.create);
router.get('/:id',        ChildCtrl.get);
router.patch('/:id',      ChildCtrl.update);
router.get('/:id/snapshot', ChildCtrl.getSnapshot);

export default router;
