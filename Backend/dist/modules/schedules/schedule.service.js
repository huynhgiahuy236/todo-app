"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ScheduleService = void 0;
const mongoose_1 = require("mongoose");
const schedule_model_1 = require("./schedule.model");
const recurrence_util_1 = require("./recurrence.util");
class ScheduleService {
    static async getSchedulesByRange(userId, startDate, endDate) {
        const userObjectId = new mongoose_1.Types.ObjectId(userId);
        // 1. Fetch non-recurring schedules within the range
        const singleSchedules = await schedule_model_1.ScheduleModel.find({
            userId: userObjectId,
            'recurrence.type': 'none',
            startDate: { $gte: startDate, $lte: endDate },
        });
        // 2. Fetch recurring schedules that started on or before the range end
        const recurringSchedules = await schedule_model_1.ScheduleModel.find({
            userId: userObjectId,
            'recurrence.type': { $ne: 'none' },
            startDate: { $lte: endDate },
        });
        let allOccurrences = [];
        // Expand non-recurring
        for (const s of singleSchedules) {
            allOccurrences.push(...(0, recurrence_util_1.expandRecurringSchedule)(s, startDate, endDate));
        }
        // Expand recurring
        for (const r of recurringSchedules) {
            allOccurrences.push(...(0, recurrence_util_1.expandRecurringSchedule)(r, startDate, endDate));
        }
        // Sort by startDate asc, then startTime asc
        allOccurrences.sort((a, b) => {
            if (a.startDate !== b.startDate) {
                return a.startDate.localeCompare(b.startDate);
            }
            return a.startTime.localeCompare(b.startTime);
        });
        return allOccurrences;
    }
    static async createSchedule(userId, data) {
        const isRecurring = data.recurrence && data.recurrence.type !== 'none';
        const seriesId = isRecurring ? `series_${Date.now()}_${Math.random().toString(36).substring(2, 7)}` : undefined;
        const schedule = await schedule_model_1.ScheduleModel.create({
            ...data,
            userId: new mongoose_1.Types.ObjectId(userId),
            seriesId: data.seriesId || seriesId,
            exceptionDates: [],
        });
        return schedule;
    }
    static async getScheduleById(userId, id) {
        // If id has format _id_YYYY-MM-DD, extract original ID
        const actualId = id.includes('_') ? id.split('_')[0] : id;
        const schedule = await schedule_model_1.ScheduleModel.findOne({
            _id: new mongoose_1.Types.ObjectId(actualId),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!schedule) {
            throw new Error('Không tìm thấy lịch trình');
        }
        return schedule;
    }
    static async updateSchedule(userId, id, data) {
        const actualId = id.includes('_') ? id.split('_')[0] : id;
        const schedule = await schedule_model_1.ScheduleModel.findOneAndUpdate({ _id: new mongoose_1.Types.ObjectId(actualId), userId: new mongoose_1.Types.ObjectId(userId) }, { $set: data }, { new: true });
        if (!schedule) {
            throw new Error('Không tìm thấy lịch trình');
        }
        return schedule;
    }
    // 1. Thay đổi chỉ 1 sự kiện này trong chuỗi lặp (Only this event)
    static async updateOccurrence(userId, originalScheduleId, targetDate, updateData) {
        const actualId = originalScheduleId.includes('_') ? originalScheduleId.split('_')[0] : originalScheduleId;
        const original = await schedule_model_1.ScheduleModel.findOne({
            _id: new mongoose_1.Types.ObjectId(actualId),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!original) {
            throw new Error('Không tìm thấy lịch trình gốc');
        }
        // Add targetDate to exceptionDates of original schedule
        if (!original.exceptionDates)
            original.exceptionDates = [];
        if (!original.exceptionDates.includes(targetDate)) {
            original.exceptionDates.push(targetDate);
            await original.save();
        }
        // Create a new single schedule for this occurrence
        const newSingleSchedule = await schedule_model_1.ScheduleModel.create({
            userId: new mongoose_1.Types.ObjectId(userId),
            title: updateData.title || original.title,
            type: updateData.type || original.type,
            startDate: targetDate,
            endDate: targetDate,
            startTime: updateData.startTime || original.startTime,
            endTime: updateData.endTime || original.endTime,
            color: updateData.color || original.color,
            note: updateData.note !== undefined ? updateData.note : original.note,
            location: updateData.location !== undefined ? updateData.location : original.location,
            recurrence: { type: 'none', daysOfWeek: [], until: null },
            exceptionDates: [],
        });
        return {
            message: `Đã cập nhật riêng cho lịch ngày ${targetDate}`,
            newSchedule: newSingleSchedule,
        };
    }
    // 2. Thay đổi sự kiện này và các sự kiện sau (This and future events)
    static async updateFutureOccurrences(userId, originalScheduleId, targetDate, updateData) {
        const actualId = originalScheduleId.includes('_') ? originalScheduleId.split('_')[0] : originalScheduleId;
        const original = await schedule_model_1.ScheduleModel.findOne({
            _id: new mongoose_1.Types.ObjectId(actualId),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!original) {
            throw new Error('Không tìm thấy lịch trình gốc');
        }
        // Calculate the day before targetDate
        const targetDateObj = (0, recurrence_util_1.parseDateString)(targetDate);
        const dayBefore = new Date(targetDateObj.getTime());
        dayBefore.setDate(dayBefore.getDate() - 1);
        const dayBeforeStr = (0, recurrence_util_1.formatDateString)(dayBefore);
        // If targetDate is the start date of the original, just update the whole series
        if (original.startDate === targetDate) {
            const updated = await schedule_model_1.ScheduleModel.findByIdAndUpdate(original._id, { $set: updateData }, { new: true });
            return { message: 'Đã cập nhật toàn bộ chuỗi lịch', newSeries: updated };
        }
        // End the original series on the day before targetDate
        if (original.recurrence) {
            original.recurrence.until = dayBeforeStr;
            await original.save();
        }
        // Create a new recurring series starting from targetDate
        const newSeriesId = `series_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
        const newSeries = await schedule_model_1.ScheduleModel.create({
            userId: new mongoose_1.Types.ObjectId(userId),
            title: updateData.title || original.title,
            type: updateData.type || original.type,
            startDate: targetDate,
            endDate: targetDate,
            startTime: updateData.startTime || original.startTime,
            endTime: updateData.endTime || original.endTime,
            color: updateData.color || original.color,
            note: updateData.note !== undefined ? updateData.note : original.note,
            location: updateData.location !== undefined ? updateData.location : original.location,
            seriesId: newSeriesId,
            recurrence: updateData.recurrence || original.recurrence,
            exceptionDates: [],
        });
        return {
            message: `Đã áp dụng thay đổi từ ngày ${targetDate} trở đi`,
            newSeries,
        };
    }
    // 3. Thay đổi toàn bộ chuỗi (Entire series)
    static async updateEntireSeries(userId, originalScheduleId, updateData) {
        const actualId = originalScheduleId.includes('_') ? originalScheduleId.split('_')[0] : originalScheduleId;
        const schedule = await schedule_model_1.ScheduleModel.findOneAndUpdate({ _id: new mongoose_1.Types.ObjectId(actualId), userId: new mongoose_1.Types.ObjectId(userId) }, { $set: updateData }, { new: true });
        if (!schedule) {
            throw new Error('Không tìm thấy lịch trình');
        }
        return schedule;
    }
    // Xóa lịch (hỗ trợ xóa đơn, xóa 1 ngày trong chuỗi, xóa tương lai, hoặc xóa toàn bộ)
    static async deleteSchedule(userId, id, scope, targetDate) {
        const actualId = id.includes('_') ? id.split('_')[0] : id;
        const schedule = await schedule_model_1.ScheduleModel.findOne({
            _id: new mongoose_1.Types.ObjectId(actualId),
            userId: new mongoose_1.Types.ObjectId(userId),
        });
        if (!schedule) {
            throw new Error('Không tìm thấy lịch trình');
        }
        const isRecurring = schedule.recurrence && schedule.recurrence.type !== 'none';
        if (!isRecurring || scope === 'series' || !scope) {
            // Delete the entire document
            await schedule_model_1.ScheduleModel.findByIdAndDelete(schedule._id);
            return { message: 'Đã xóa toàn bộ lịch trình' };
        }
        if (scope === 'single' && targetDate) {
            if (!schedule.exceptionDates)
                schedule.exceptionDates = [];
            if (!schedule.exceptionDates.includes(targetDate)) {
                schedule.exceptionDates.push(targetDate);
                await schedule.save();
            }
            return { message: `Đã xóa lịch ngày ${targetDate}` };
        }
        if (scope === 'future' && targetDate) {
            const targetDateObj = (0, recurrence_util_1.parseDateString)(targetDate);
            const dayBefore = new Date(targetDateObj.getTime());
            dayBefore.setDate(dayBefore.getDate() - 1);
            const dayBeforeStr = (0, recurrence_util_1.formatDateString)(dayBefore);
            if (schedule.startDate >= targetDate) {
                await schedule_model_1.ScheduleModel.findByIdAndDelete(schedule._id);
                return { message: 'Đã xóa toàn bộ chuỗi lịch' };
            }
            if (schedule.recurrence) {
                schedule.recurrence.until = dayBeforeStr;
                await schedule.save();
            }
            return { message: `Đã xóa các lịch từ ngày ${targetDate} trở đi` };
        }
        await schedule_model_1.ScheduleModel.findByIdAndDelete(schedule._id);
        return { message: 'Đã xóa lịch trình thành công' };
    }
}
exports.ScheduleService = ScheduleService;
