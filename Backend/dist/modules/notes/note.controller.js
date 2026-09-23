"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NoteController = void 0;
const note_service_1 = require("./note.service");
const response_util_1 = require("../../utils/response.util");
class NoteController {
    static async getNotes(req, res) {
        try {
            const { category, search } = req.query;
            const notes = await note_service_1.NoteService.getNotes(req.userId, category ? String(category) : undefined, search ? String(search) : undefined);
            (0, response_util_1.sendSuccess)(res, notes, 'Lấy danh sách ghi chú thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi lấy danh sách ghi chú', 400);
        }
    }
    static async createNote(req, res) {
        try {
            const { title, date } = req.body;
            if (!title || !date) {
                (0, response_util_1.sendError)(res, 'Vui lòng cung cấp Tiêu đề và Ngày ghi chú', 400);
                return;
            }
            const note = await note_service_1.NoteService.createNote(req.userId, req.body);
            (0, response_util_1.sendSuccess)(res, note, 'Tạo ghi chú thành công', 201);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi tạo ghi chú', 400);
        }
    }
    static async updateNote(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const note = await note_service_1.NoteService.updateNote(req.userId, id, req.body);
            (0, response_util_1.sendSuccess)(res, note, 'Cập nhật ghi chú thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi cập nhật ghi chú', 400);
        }
    }
    static async togglePin(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const note = await note_service_1.NoteService.togglePinNote(req.userId, id);
            (0, response_util_1.sendSuccess)(res, note, note.isPinned ? 'Đã ghim ghi chú' : 'Đã bỏ ghim ghi chú');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi thay đổi trạng thái ghim', 400);
        }
    }
    static async deleteNote(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            await note_service_1.NoteService.deleteNote(req.userId, id);
            (0, response_util_1.sendSuccess)(res, null, 'Xóa ghi chú thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi xóa ghi chú', 400);
        }
    }
}
exports.NoteController = NoteController;
