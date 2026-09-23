"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NoteService = void 0;
const mongoose_1 = require("mongoose");
const note_model_1 = require("./note.model");
class NoteService {
    static async getNotes(userId, category, search) {
        const filter = { userId: new mongoose_1.Types.ObjectId(userId) };
        if (category && category !== 'all') {
            if (category === 'schedule') {
                filter.scheduleId = { $ne: null };
            }
            else if (category === 'task') {
                filter.taskId = { $ne: null };
            }
            else {
                filter.category = category;
            }
        }
        if (search) {
            filter.$or = [
                { title: { $regex: search, $options: 'i' } },
                { content: { $regex: search, $options: 'i' } },
            ];
        }
        return await note_model_1.NoteModel.find(filter).sort({ isPinned: -1, updatedAt: -1 });
    }
    static async createNote(userId, data) {
        return await note_model_1.NoteModel.create({
            ...data,
            userId: new mongoose_1.Types.ObjectId(userId),
        });
    }
    static async updateNote(userId, id, data) {
        const note = await note_model_1.NoteModel.findOneAndUpdate({ _id: new mongoose_1.Types.ObjectId(id), userId: new mongoose_1.Types.ObjectId(userId) }, { $set: data }, { new: true });
        if (!note) {
            throw new Error('Không tìm thấy ghi chú');
        }
        return note;
    }
    static async togglePinNote(userId, id) {
        const note = await note_model_1.NoteModel.findOne({
            _id: new mongoose_1.Types.ObjectId(id),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!note) {
            throw new Error('Không tìm thấy ghi chú');
        }
        note.isPinned = !note.isPinned;
        await note.save();
        return note;
    }
    static async deleteNote(userId, id) {
        const result = await note_model_1.NoteModel.findOneAndDelete({
            _id: new mongoose_1.Types.ObjectId(id),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!result) {
            throw new Error('Không tìm thấy ghi chú để xóa');
        }
    }
}
exports.NoteService = NoteService;
