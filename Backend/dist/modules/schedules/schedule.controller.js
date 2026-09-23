"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ScheduleController = void 0;
const schedule_service_1 = require("./schedule.service");
const response_util_1 = require("../../utils/response.util");
class ScheduleController {
    static async getSchedules(req, res) {
        try {
            const { startDate, endDate } = req.query;
            if (!startDate || !endDate) {
                (0, response_util_1.sendError)(res, 'Vui lòng cung cấp startDate và endDate (YYYY-MM-DD)', 400);
                return;
            }
            const schedules = await schedule_service_1.ScheduleService.getSchedulesByRange(req.userId, String(startDate), String(endDate));
            (0, response_util_1.sendSuccess)(res, schedules, 'Lấy danh sách lịch trình thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi lấy danh sách lịch', 400);
        }
    }
    static async createSchedule(req, res) {
        try {
            const { title, startDate, startTime, endTime } = req.body;
            if (!title || !startDate || !startTime || !endTime) {
                (0, response_util_1.sendError)(res, 'Vui lòng điền đủ Tên lịch, Ngày, Giờ bắt đầu và Giờ kết thúc', 400);
                return;
            }
            const schedule = await schedule_service_1.ScheduleService.createSchedule(req.userId, req.body);
            (0, response_util_1.sendSuccess)(res, schedule, 'Tạo lịch trình thành công', 201);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi tạo lịch trình', 400);
        }
    }
    static async getScheduleById(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const schedule = await schedule_service_1.ScheduleService.getScheduleById(req.userId, id);
            (0, response_util_1.sendSuccess)(res, schedule, 'Lấy chi tiết lịch trình thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Không tìm thấy lịch trình', 404);
        }
    }
    static async updateSchedule(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const schedule = await schedule_service_1.ScheduleService.updateSchedule(req.userId, id, req.body);
            (0, response_util_1.sendSuccess)(res, schedule, 'Cập nhật lịch trình thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi cập nhật lịch', 400);
        }
    }
    // PATCH /api/schedules/:id/occurrence (Only this event)
    static async updateOccurrence(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const { targetDate, updateData } = req.body;
            if (!targetDate) {
                (0, response_util_1.sendError)(res, 'Vui lòng cung cấp targetDate (YYYY-MM-DD)', 400);
                return;
            }
            const result = await schedule_service_1.ScheduleService.updateOccurrence(req.userId, id, targetDate, updateData || {});
            (0, response_util_1.sendSuccess)(res, result, result.message);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi cập nhật lịch đơn lẻ', 400);
        }
    }
    // PATCH /api/schedules/:id/future (This and future)
    static async updateFuture(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const { targetDate, updateData } = req.body;
            if (!targetDate) {
                (0, response_util_1.sendError)(res, 'Vui lòng cung cấp targetDate (YYYY-MM-DD)', 400);
                return;
            }
            const result = await schedule_service_1.ScheduleService.updateFutureOccurrences(req.userId, id, targetDate, updateData || {});
            (0, response_util_1.sendSuccess)(res, result, result.message);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi cập nhật chuỗi lịch tương lai', 400);
        }
    }
    // PATCH /api/schedules/:id/series (Entire series)
    static async updateSeries(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const schedule = await schedule_service_1.ScheduleService.updateEntireSeries(req.userId, id, req.body);
            (0, response_util_1.sendSuccess)(res, schedule, 'Cập nhật toàn bộ chuỗi lịch thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi cập nhật toàn bộ chuỗi lịch', 400);
        }
    }
    // DELETE /api/schedules/:id
    static async deleteSchedule(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const { scope, targetDate } = req.query;
            const result = await schedule_service_1.ScheduleService.deleteSchedule(req.userId, id, scope, targetDate ? String(targetDate) : undefined);
            (0, response_util_1.sendSuccess)(res, result, result.message);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi xóa lịch trình', 400);
        }
    }
}
exports.ScheduleController = ScheduleController;
