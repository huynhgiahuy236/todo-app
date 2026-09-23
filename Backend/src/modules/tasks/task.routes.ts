import { Router } from 'express';
import { TaskController } from './task.controller';
import { authenticateJWT } from '../../middlewares/auth.middleware';

const router = Router();

router.use(authenticateJWT);

router.get('/', TaskController.getTasks);
router.post('/', TaskController.createTask);
router.patch('/:id', TaskController.updateTask);
router.patch('/:id/toggle', TaskController.toggleTask);
router.delete('/:id', TaskController.deleteTask);

export const taskRoutes = router;
