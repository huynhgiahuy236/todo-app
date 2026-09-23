import { ISchedule } from './schedule.model';

export interface ScheduleOccurrence {
  _id: string;
  userId: string;
  title: string;
  type: string;
  startDate: string; // The specific occurrence date YYYY-MM-DD
  endDate: string;
  startTime: string;
  endTime: string;
  color: string;
  note?: string;
  location?: string;
  seriesId?: string;
  isRecurring: boolean;
  recurrence?: any;
  originalScheduleId: string;
}

// Convert Date to YYYY-MM-DD in local context
export const formatDateString = (date: Date): string => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

// Parse YYYY-MM-DD into a local Date object (setting hours to 0,0,0,0)
export const parseDateString = (dateStr: string): Date => {
  const [year, month, day] = dateStr.split('-').map(Number);
  return new Date(year, month - 1, day, 0, 0, 0, 0);
};

// ISO weekday: 1 = Mon, ..., 7 = Sun
export const getIsoWeekday = (date: Date): number => {
  const day = date.getDay();
  return day === 0 ? 7 : day;
};

// Expand recurring schedule instances into a date range
export const expandRecurringSchedule = (
  schedule: ISchedule,
  rangeStartStr: string,
  rangeEndStr: string
): ScheduleOccurrence[] => {
  const occurrences: ScheduleOccurrence[] = [];
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

  const rangeStart = parseDateString(rangeStartStr);
  const rangeEnd = parseDateString(rangeEndStr);
  const scheduleStart = parseDateString(schedule.startDate);
  const untilDate = recurrence.until ? parseDateString(recurrence.until) : null;
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
    const currentStr = formatDateString(current);

    if (current >= scheduleStart && (!untilDate || current <= untilDate)) {
      let isMatch = false;

      if (recurrence.type === 'daily') {
        isMatch = true;
      } else if (recurrence.type === 'weekly') {
        // If daysOfWeek is provided, check if current weekday is included
        // Otherwise repeat on the same weekday as the schedule's startDate
        const currentWeekday = getIsoWeekday(current);
        if (recurrence.daysOfWeek && recurrence.daysOfWeek.length > 0) {
          isMatch = recurrence.daysOfWeek.includes(currentWeekday);
        } else {
          isMatch = currentWeekday === getIsoWeekday(scheduleStart);
        }
      } else if (recurrence.type === 'custom') {
        const currentWeekday = getIsoWeekday(current);
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
