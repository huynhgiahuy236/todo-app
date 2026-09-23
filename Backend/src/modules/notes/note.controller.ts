import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { NoteService } from './note.service';
import { sendSuccess, sendError } from '../../utils/response.util';

export class NoteController {
  static async getNotes(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { category, search } = req.query;
      const notes = await NoteService.getNotes(
        req.userId!,
        category ? String(category) : undefined,
        search ? String(search) : undefined
      );
      sendSuccess(res, notes, 'Lấy danh sách ghi chú thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi lấy danh sách ghi chú', 400);
    }
  }

  static async createNote(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { title, date } = req.body;
      if (!title || !date) {
        sendError(res, 'Vui lòng cung cấp Tiêu đề và Ngày ghi chú', 400);
        return;
      }
      const note = await NoteService.createNote(req.userId!, req.body);
      sendSuccess(res, note, 'Tạo ghi chú thành công', 201);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi tạo ghi chú', 400);
    }
  }

  static async updateNote(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const note = await NoteService.updateNote(req.userId!, id, req.body);
      sendSuccess(res, note, 'Cập nhật ghi chú thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi cập nhật ghi chú', 400);
    }
  }

  static async togglePin(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      const note = await NoteService.togglePinNote(req.userId!, id);
      sendSuccess(res, note, note.isPinned ? 'Đã ghim ghi chú' : 'Đã bỏ ghim ghi chú');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi thay đổi trạng thái ghim', 400);
    }
  }

  static async deleteNote(req: AuthRequest, res: Response): Promise<void> {
    try {
      const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
      await NoteService.deleteNote(req.userId!, id);
      sendSuccess(res, null, 'Xóa ghi chú thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi xóa ghi chú', 400);
    }
  }
}
