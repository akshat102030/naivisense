import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { upload }      from '../../middleware/upload';
import * as UsersCtrl  from './users.controller';

const router = Router();
router.use(requireAuth);

router.get('/staff',    UsersCtrl.listStaff);  // ?role=therapist|parent (center_head only)
router.get('/',         UsersCtrl.getMe);       // alias for /me
router.get('/me',       UsersCtrl.getMe);
router.patch('/me',     UsersCtrl.updateMe);
router.post('/me/photo', upload.single('photo'), UsersCtrl.uploadPhoto);
router.get('/:id',      UsersCtrl.getUser);    // center_head only — must be last

export default router;
