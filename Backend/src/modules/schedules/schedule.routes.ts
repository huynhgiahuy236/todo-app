import { Router } from 'express';
import { ScheduleController } from './schedule.controller';
import { authenticateJWT } from '../../middlewares/auth.middleware';

const router = Router();

router.post('/seed-all', ScheduleController.seedUserSchedules);

router.use(authenticateJWT);

router.get('/', ScheduleController.getSchedules);
router.post('/', ScheduleController.createSchedule);
router.get('/:id', ScheduleController.getScheduleById);
router.patch('/:id', ScheduleController.updateSchedule);
router.patch('/:id/occurrence', ScheduleController.updateOccurrence);
router.patch('/:id/future', ScheduleController.updateFuture);
router.patch('/:id/series', ScheduleController.updateSeries);
router.delete('/:id', ScheduleController.deleteSchedule);

export const scheduleRoutes = router;
