import express, { Request, Response } from 'express';
import cors from 'cors';
import { authRoutes } from './modules/auth/auth.routes';
import { scheduleRoutes } from './modules/schedules/schedule.routes';
import { taskRoutes } from './modules/tasks/task.routes';
import { noteRoutes } from './modules/notes/note.routes';
import { errorHandler } from './middlewares/error.middleware';

const app = express();

// Middlewares
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get('/api/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    message: 'MySche Personal Schedule API is running smoothly',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/schedules', scheduleRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/notes', noteRoutes);

// Global Error Handler
app.use(errorHandler);

export default app;
