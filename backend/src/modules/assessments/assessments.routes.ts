import { Router, RequestHandler }      from 'express';
import { requireAuth } from '../../middleware/auth';
import * as Ctrl       from './assessments.controller';

const router = Router();
router.use(requireAuth);

// Fallback role middleware in case auth module doesn't export one
const roleMiddleware = (role: string): RequestHandler => {
	return (req, res, next) => {
		const user: any = (req as any).user;
		if (!user) return res.sendStatus(401);
		if (user.role !== role) return res.sendStatus(403);
		next();
	};
};

router.post('/',    Ctrl.create);
router.get('/',     Ctrl.list);
router.get('/:id',  Ctrl.get);
router.patch("/:childId/latest", roleMiddleware("therapist"), Ctrl.updateLatest);

export default router;


