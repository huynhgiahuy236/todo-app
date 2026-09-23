"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.expandRecurringSchedule = exports.getIsoWeekday = exports.parseDateString = exports.formatDateString = void 0;
// Convert Date to YYYY-MM-DD in local context
const formatDateString = (date) => {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
};
exports.formatDateString = formatDateString;
// Parse YYYY-MM-DD into a local Date object (setting hours to 0,0,0,0)
const parseDateString = (dateStr) => {
    const [year, month, day] = dateStr.split('-').map(Number);
    return new Date(year, month - 1, day, 0, 0, 0, 0);
};
exports.parseDateString = parseDateString;
// ISO weekday: 1 = Mon, ..., 7 = Sun
const getIsoWeekday = (date) => {
    const day = date.getDay();
    return day === 0 ? 7 : day;
};
exports.getIsoWeekday = getIsoWeekday;
// Expand recurring schedule instances into a date range
const expandRecurringSchedule = (schedule, rangeStartStr, rangeEndStr) => {
    const occurrences = [];
    const recurrence = schedule.recurrence;
    if (!recurrence || recurrence.type === 'none') {
        // Single event
        if (schedule.startDate >= rangeStartStr && schedule.startDate <= rangeEndStr) {
            occurrences.push({
                _id: schedule._id.toString(),
                userId: schedule.userId.toString(),
                title: schedule.title,
                type: schedule.type,
                startDate: schedule.startDate,
                endDate: schedule.endDate || schedule.startDate,
                startTime: schedule.startTime,
                endTime: schedule.endTime,
                color: schedule.color,
                note: schedule.note,
                location: schedule.location,
                seriesId: schedule.seriesId,
                isRecurring: false,
                recurrence: schedule.recurrence,
                originalScheduleId: schedule._id.toString(),
            });
        }
        return occurrences;
    }
    const rangeStart = (0, exports.parseDateString)(rangeStartStr);
    const rangeEnd = (0, exports.parseDateString)(rangeEndStr);
    const scheduleStart = (0, exports.parseDateString)(schedule.startDate);
    const untilDate = recurrence.until ? (0, exports.parseDateString)(recurrence.until) : null;
    const exceptionDatesSet = new Set(schedule.exceptionDates || []);
    // Determine starting point for iteration
    let current = new Date(scheduleStart.getTime());
    // We iterate day by day up to rangeEnd or untilDate
    const maxLimitDate = untilDate && untilDate < rangeEnd ? untilDate : rangeEnd;
    // Safeguard: Limit maximum iteration steps to 366 days
    let steps = 0;
    const maxSteps = 400;
    while (current <= maxLimitDate && steps < maxSteps) {
        steps++;
        const currentStr = (0, exports.formatDateString)(current);
        if (current >= scheduleStart && (!untilDate || current <= untilDate)) {
            let isMatch = false;
            if (recurrence.type === 'daily') {
                isMatch = true;
            }
            else if (recurrence.type === 'weekly') {
                // If daysOfWeek is provided, check if current weekday is included
                // Otherwise repeat on the same weekday as the schedule's startDate
                const currentWeekday = (0, exports.getIsoWeekday)(current);
                if (recurrence.daysOfWeek && recurrence.daysOfWeek.length > 0) {
                    isMatch = recurrence.daysOfWeek.includes(currentWeekday);
                }
                else {
                    isMatch = currentWeekday === (0, exports.getIsoWeekday)(scheduleStart);
                }
            }
            else if (recurrence.type === 'custom') {
                const currentWeekday = (0, exports.getIsoWeekday)(current);
                isMatch = (recurrence.daysOfWeek || []).includes(currentWeekday);
            }
            if (isMatch && currentStr >= rangeStartStr && currentStr <= rangeEndStr) {
                if (!exceptionDatesSet.has(currentStr)) {
                    occurrences.push({
                        _id: `${schedule._id}_${currentStr}`,
                        userId: schedule.userId.toString(),
                        title: schedule.title,
                        type: schedule.type,
                        startDate: currentStr,
                        endDate: currentStr,
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        color: schedule.color,
                        note: schedule.note,
                        location: schedule.location,
                        seriesId: schedule.seriesId,
                        isRecurring: true,
                        recurrence: schedule.recurrence,
                        originalScheduleId: schedule._id.toString(),
                    });
                }
            }
        }
        // Advance 1 day
        current.setDate(current.getDate() + 1);
    }
    return occurrences;
};
exports.expandRecurringSchedule = expandRecurringSchedule;
