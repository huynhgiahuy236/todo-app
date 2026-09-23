"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.ScheduleController = void 0;
const schedule_service_1 = require("./schedule.service");
const response_util_1 = require("../../utils/response.util");
class ScheduleController {
    static async seedUserSchedules(req, res) {
        try {
            const { UserModel } = await Promise.resolve().then(() => __importStar(require('../auth/user.model')));
            const { ScheduleModel } = await Promise.resolve().then(() => __importStar(require('./schedule.model')));
            const schedulesToAdd = [
                // 1. Học Java (Thứ 6: 09:00 - 11:30, kéo dài 2 tháng)
                {
                    title: 'Học Java',
                    type: 'study',
                    color: '#3B82F6',
                    startDate: '2026-09-25',
                    endDate: '2026-09-25',
                    startTime: '09:00',
                    endTime: '11:30',
                    recurrence: { type: 'weekly', daysOfWeek: [5], until: '2026-11-25' },
                    note: 'Lịch học kéo dài 2 tháng (Thứ 6 hàng tuần)',
                    location: '',
                    exceptionDates: [],
                },
                // 2. Thực tập T4 (08:30 - 17:30)
                {
                    title: 'Thực tập',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-09-23',
                    endDate: '2026-09-23',
                    startTime: '08:30',
                    endTime: '17:30',
                    recurrence: { type: 'weekly', daysOfWeek: [3], until: '2026-10-18' },
                    note: 'Thực tập Thứ 4 hàng tuần',
                    location: 'Công ty',
                    exceptionDates: [],
                },
                // 3. Thực tập T5 (08:30 - 17:30)
                {
                    title: 'Thực tập',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-09-24',
                    endDate: '2026-09-24',
                    startTime: '08:30',
                    endTime: '17:30',
                    recurrence: { type: 'weekly', daysOfWeek: [4], until: '2026-10-18' },
                    note: 'Thực tập Thứ 5 hàng tuần',
                    location: 'Công ty',
                    exceptionDates: [],
                },
                // 4. Thực tập T6 (13:30 - 17:30)
                {
                    title: 'Thực tập',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-09-25',
                    endDate: '2026-09-25',
                    startTime: '13:30',
                    endTime: '17:30',
                    recurrence: { type: 'weekly', daysOfWeek: [5], until: '2026-10-18' },
                    note: 'Thực tập Thứ 6 hàng tuần',
                    location: 'Công ty',
                    exceptionDates: [],
                },
                // 5. Thực tập T7 (09:00 - 12:00)
                {
                    title: 'Thực tập',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-09-26',
                    endDate: '2026-09-26',
                    startTime: '09:00',
                    endTime: '12:00',
                    recurrence: { type: 'weekly', daysOfWeek: [6], until: '2026-10-18' },
                    note: 'Thực tập Thứ 7 hàng tuần',
                    location: 'Công ty',
                    exceptionDates: [],
                },
                // 6. Backend — 8 buổi (Lý thuyết / Thực hành)
                {
                    title: 'Backend — Lý thuyết',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-09-25',
                    endDate: '2026-09-25',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 1: Lý thuyết',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Thực hành',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-09-26',
                    endDate: '2026-09-26',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 2: Thực hành',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Lý thuyết',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-10-02',
                    endDate: '2026-10-02',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 3: Lý thuyết',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Thực hành',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-10-03',
                    endDate: '2026-10-03',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 4: Thực hành',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Lý thuyết',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-10-09',
                    endDate: '2026-10-09',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 5: Lý thuyết',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Thực hành',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-10-10',
                    endDate: '2026-10-10',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 6: Thực hành',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Lý thuyết',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-10-16',
                    endDate: '2026-10-16',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 7: Lý thuyết',
                    location: '',
                    exceptionDates: [],
                },
                {
                    title: 'Backend — Thực hành',
                    type: 'work',
                    color: '#10B981',
                    startDate: '2026-10-17',
                    endDate: '2026-10-17',
                    startTime: '18:00',
                    endTime: '20:30',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Buổi 8: Thực hành',
                    location: '',
                    exceptionDates: [],
                },
                // 7. Thực hành Thứ 7 (06:30 - 09:00, kéo dài 2 tháng)
                {
                    title: 'Thực hành',
                    type: 'study',
                    color: '#3B82F6',
                    startDate: '2026-09-26',
                    endDate: '2026-09-26',
                    startTime: '06:30',
                    endTime: '09:00',
                    recurrence: { type: 'weekly', daysOfWeek: [6], until: '2026-11-26' },
                    note: 'Thực hành Thứ 7 hàng tuần (06:30 - 09:00)',
                    location: 'Phòng Lab',
                    exceptionDates: ['2026-10-24'],
                },
                // 8. Thi giữa kỳ (Riêng ngày 24/10/2026)
                {
                    title: 'Thi giữa kỳ',
                    type: 'important',
                    color: '#EF4444',
                    startDate: '2026-10-24',
                    endDate: '2026-10-24',
                    startTime: '06:30',
                    endTime: '09:00',
                    recurrence: { type: 'none', daysOfWeek: [], until: null },
                    note: 'Thi giữa kỳ thay cho buổi Thực hành ngày 24/10/2026',
                    location: 'Phòng Thi',
                    exceptionDates: [],
                },
            ];
            const users = await UserModel.find({});
            for (const user of users) {
                await ScheduleModel.deleteMany({
                    userId: user._id,
                    title: { $in: ['java', 'Java', 'Học Java'] },
                });
                for (const item of schedulesToAdd) {
                    await ScheduleModel.create({
                        ...item,
                        userId: user._id,
                    });
                }
            }
            (0, response_util_1.sendSuccess)(res, { count: schedulesToAdd.length }, 'Đã tạo xong toàn bộ lịch học và thực tập!');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi tạo lịch', 500);
        }
    }
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
            if (!title || !startDate || !startTime) {
                (0, response_util_1.sendError)(res, 'Vui lòng điền đủ Tên lịch, Ngày và Giờ bắt đầu', 400);
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
