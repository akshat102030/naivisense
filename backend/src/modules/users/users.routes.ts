import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { upload }      from '../../middleware/upload';
import * as UsersCtrl  from './users.controller';

const router = Router();
router.use(requireAuth);

router.get('/therapists-overview',                UsersCtrl.getTherapistsOverview); // center_head only
router.post('/therapists',                        UsersCtrl.enrollTherapist);        // center_head only
router.post('/parents',                           UsersCtrl.enrollParent);           // center_head only
router.post('/therapists/:id/:docType',           upload.single('file'), UsersCtrl.uploadTherapistDocument); // center_head only
router.get('/staff',                              UsersCtrl.listStaff);              // ?role=therapist|parent
router.get('/',                                   UsersCtrl.getMe);
router.get('/me',                                 UsersCtrl.getMe);
router.patch('/me',                               UsersCtrl.updateMe);
router.post('/me/photo',                          upload.single('photo'), UsersCtrl.uploadPhoto);
router.get('/:id',                                UsersCtrl.getUser);                // must be last

export default router;
