import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { ScheduleService } from './schedule.service';
import { sendSuccess, sendError } from '../../utils/response.util';

export class ScheduleController {
  static async getSchedules(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        sendError(res, 'Vui lòng cung cấp startDate và endDate (YYYY-MM-DD)', 400);
        return;
      }

      const schedules = await ScheduleService.getSchedulesByRange(
        req.userId!,
        String(startDate),
        String(endDate)
      );

      sendSuccess(res, schedules, 'Lấy danh sách lịch trình thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi lấy danh sách lịch', 400);
    }
  }

  static async createSchedule(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { title, startDate, startTime, endTime } = req.body;
      if (!title || !startDate || !startTime || !endTime) {
        sendError(res, 'Vui lòng điền đủ Tên lịch, Ngày, Giờ bắt đầu và Giờ kết thúc', 400);
        return;
      }

      const schedule = await ScheduleService.createSchedule(req.userId!, req.body);
      sendSuccess(res, schedule, 'Tạo lịch trình thành công', 201);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi tạo lịch trình', 400);
    }
  }

  static async getScheduleById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const schedule = await ScheduleService.getScheduleById(req.userId!, id);
      sendSuccess(res, schedule, 'Lấy chi tiết lịch trình thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Không tìm thấy lịch trình', 404);
    }
  }

  static async updateSchedule(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const schedule = await ScheduleService.updateSchedule(req.userId!, id, req.body);
      sendSuccess(res, schedule, 'Cập nhật lịch trình thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi cập nhật lịch', 400);
    }
  }

  // PATCH /api/schedules/:id/occurrence (Only this event)
  static async updateOccurrence(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const { targetDate, updateData } = req.body;
      if (!targetDate) {
        sendError(res, 'Vui lòng cung cấp targetDate (YYYY-MM-DD)', 400);
        return;
      }

      const result = await ScheduleService.updateOccurrence(
        req.userId!,
        id,
        targetDate,
        updateData || {}
      );
      sendSuccess(res, result, result.message);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi cập nhật lịch đơn lẻ', 400);
    }
  }

  // PATCH /api/schedules/:id/future (This and future)
  static async updateFuture(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const { targetDate, updateData } = req.body;
      if (!targetDate) {
        sendError(res, 'Vui lòng cung cấp targetDate (YYYY-MM-DD)', 400);
        return;
      }

      const result = await ScheduleService.updateFutureOccurrences(
        req.userId!,
        id,
        targetDate,
        updateData || {}
      );
      sendSuccess(res, result, result.message);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi cập nhật chuỗi lịch tương lai', 400);
    }
  }

  // PATCH /api/schedules/:id/series (Entire series)
  static async updateSeries(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const schedule = await ScheduleService.updateEntireSeries(
        req.userId!,
        id,
        req.body
      );
      sendSuccess(res, schedule, 'Cập nhật toàn bộ chuỗi lịch thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi cập nhật toàn bộ chuỗi lịch', 400);
    }
  }

  // DELETE /api/schedules/:id
  static async deleteSchedule(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const { scope, targetDate } = req.query;
      const result = await ScheduleService.deleteSchedule(
        req.userId!,
        id,
        scope as any,
        targetDate ? String(targetDate) : undefined
      );
      sendSuccess(res, result, result.message);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi xóa lịch trình', 400);
    }
  }
}
