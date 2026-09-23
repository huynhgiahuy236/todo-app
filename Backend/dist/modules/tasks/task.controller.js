"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TaskController = void 0;
const task_service_1 = require("./task.service");
const response_util_1 = require("../../utils/response.util");
class TaskController {
    static async getTasks(req, res) {
        try {
            const { date, completed } = req.query;
            const tasks = await task_service_1.TaskService.getTasks(req.userId, date ? String(date) : undefined, completed !== undefined ? completed === 'true' : undefined);
            (0, response_util_1.sendSuccess)(res, tasks, 'Lấy danh sách công việc thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi lấy danh sách công việc', 400);
        }
    }
    static async createTask(req, res) {
        try {
            const { title } = req.body;
            if (!title) {
                (0, response_util_1.sendError)(res, 'Tiêu đề công việc không được để trống', 400);
                return;
            }
            const task = await task_service_1.TaskService.createTask(req.userId, req.body);
            (0, response_util_1.sendSuccess)(res, task, 'Tạo công việc thành công', 201);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi tạo công việc', 400);
        }
    }
    static async updateTask(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const task = await task_service_1.TaskService.updateTask(req.userId, id, req.body);
            (0, response_util_1.sendSuccess)(res, task, 'Cập nhật công việc thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi cập nhật công việc', 400);
        }
    }
    static async toggleTask(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            const task = await task_service_1.TaskService.toggleTask(req.userId, id);
            (0, response_util_1.sendSuccess)(res, task, 'Đã thay đổi trạng thái hoàn thành');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi thay đổi trạng thái công việc', 400);
        }
    }
    static async deleteTask(req, res) {
        try {
            const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
            await task_service_1.TaskService.deleteTask(req.userId, id);
            (0, response_util_1.sendSuccess)(res, null, 'Xóa công việc thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi xóa công việc', 400);
        }
    }
}
exports.TaskController = TaskController;
