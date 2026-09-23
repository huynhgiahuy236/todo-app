import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { TaskService } from './task.service';
import { sendSuccess, sendError } from '../../utils/response.util';

export class TaskController {
  static async getTasks(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { date, completed } = req.query;
      const tasks = await TaskService.getTasks(
        req.userId!,
        date ? String(date) : undefined,
        completed !== undefined ? completed === 'true' : undefined
      );
      sendSuccess(res, tasks, 'Lấy danh sách công việc thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi lấy danh sách công việc', 400);
    }
  }

  static async createTask(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { title } = req.body;
      if (!title) {
        sendError(res, 'Tiêu đề công việc không được để trống', 400);
        return;
      }
      const task = await TaskService.createTask(req.userId!, req.body);
      sendSuccess(res, task, 'Tạo công việc thành công', 201);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi tạo công việc', 400);
    }
  }

  static async updateTask(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const task = await TaskService.updateTask(req.userId!, id, req.body);
      sendSuccess(res, task, 'Cập nhật công việc thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi cập nhật công việc', 400);
    }
  }

  static async toggleTask(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const task = await TaskService.toggleTask(req.userId!, id);
      sendSuccess(res, task, 'Đã thay đổi trạng thái hoàn thành');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi thay đổi trạng thái công việc', 400);
    }
  }

  static async deleteTask(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      await TaskService.deleteTask(req.userId!, id);
      sendSuccess(res, null, 'Xóa công việc thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi xóa công việc', 400);
    }
  }
}
