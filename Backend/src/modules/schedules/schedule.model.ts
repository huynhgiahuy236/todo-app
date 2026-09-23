import mongoose, { Document, Schema, Types } from 'mongoose';

export interface IRecurrence {
  type: 'none' | 'daily' | 'weekly' | 'custom';
  daysOfWeek: number[]; // 1 = Thứ 2 (Mon), 2 = Thứ 3 (Tue), ..., 7 = Chủ nhật (Sun)
  until: string | null; // YYYY-MM-DD or null
}

export interface ISchedule extends Document {
  userId: Types.ObjectId;
  title: string;
  type: string; // 'study' | 'work' | 'personal' | 'project' | 'meeting' | 'other'
  startDate: string; // YYYY-MM-DD
  endDate: string; // YYYY-MM-DD
  startTime: string; // HH:mm
  endTime: string; // HH:mm
  color: string; // e.g. '#1677E8'
  note?: string;
  location?: string;
  seriesId?: string;
  recurrence?: IRecurrence;
  exceptionDates?: string[]; // YYYY-MM-DD list
  createdAt: Date;
  updatedAt: Date;
}

const RecurrenceSchema = new Schema<IRecurrence>(
  {
    type: {
      type: String,
      enum: ['none', 'daily', 'weekly', 'custom'],
      default: 'none',
    },
    daysOfWeek: { type: [Number], default: [] },
    until: { type: String, default: null },
  },
  { _id: false }
);

const ScheduleSchema = new Schema<ISchedule>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    type: { type: String, default: 'other', trim: true },
    startDate: { type: String, required: true, index: true },
    endDate: { type: String, required: true },
    startTime: { type: String, required: true },
    endTime: { type: String, required: false, default: '' },
    color: { type: String, default: '#1677E8' },
    note: { type: String, default: '' },
    location: { type: String, default: '' },
    seriesId: { type: String, index: true },
    recurrence: { type: RecurrenceSchema, default: () => ({ type: 'none', daysOfWeek: [], until: null }) },
    exceptionDates: { type: [String], default: [] },
  },
  {
    timestamps: true,
  }
);

export const ScheduleModel = mongoose.model<ISchedule>('Schedule', ScheduleSchema);
