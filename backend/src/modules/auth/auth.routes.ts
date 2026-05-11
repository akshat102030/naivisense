import { Router }        from 'express';
import { authRateLimit } from '../../middleware/rate-limit';
import { requireAuth }   from '../../middleware/auth';
import * as AuthCtrl     from './auth.controller';

const router = Router();

router.post('/register', authRateLimit, AuthCtrl.register);
router.post('/login',    authRateLimit, AuthCtrl.login);
router.post('/refresh',  AuthCtrl.refresh);
router.post('/logout',   AuthCtrl.logout);
router.get('/me',        requireAuth,   AuthCtrl.me);

export default router;
