"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TaskService = void 0;
const mongoose_1 = require("mongoose");
const task_model_1 = require("./task.model");
class TaskService {
    static async getTasks(userId, date, completed) {
        const filter = { userId: new mongoose_1.Types.ObjectId(userId) };
        if (date) {
            filter.dueDate = date;
        }
        if (completed !== undefined) {
            filter.completed = completed;
        }
        return await task_model_1.TaskModel.find(filter).sort({ completed: 1, dueDate: 1, priority: -1, createdAt: -1 });
    }
    static async createTask(userId, data) {
        return await task_model_1.TaskModel.create({
            ...data,
            userId: new mongoose_1.Types.ObjectId(userId),
        });
    }
    static async updateTask(userId, id, data) {
        const task = await task_model_1.TaskModel.findOneAndUpdate({ _id: new mongoose_1.Types.ObjectId(id), userId: new mongoose_1.Types.ObjectId(userId) }, { $set: data }, { new: true });
        if (!task) {
            throw new Error('Không tìm thấy công việc');
        }
        return task;
    }
    static async toggleTask(userId, id) {
        const task = await task_model_1.TaskModel.findOne({
            _id: new mongoose_1.Types.ObjectId(id),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!task) {
            throw new Error('Không tìm thấy công việc');
        }
        task.completed = !task.completed;
        await task.save();
        return task;
    }
    static async deleteTask(userId, id) {
        const result = await task_model_1.TaskModel.findOneAndDelete({
            _id: new mongoose_1.Types.ObjectId(id),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!result) {
            throw new Error('Không tìm thấy công việc để xóa');
        }
    }
}
exports.TaskService = TaskService;
