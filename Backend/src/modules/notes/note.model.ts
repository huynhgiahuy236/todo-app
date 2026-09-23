import mongoose, { Document, Schema, Types } from 'mongoose';

export interface INote extends Document {
  userId: Types.ObjectId;
  title: string;
  content: string;
  date: string; // YYYY-MM-DD
  scheduleId?: Types.ObjectId;
  scheduleTitle?: string;
  taskId?: Types.ObjectId;
  taskTitle?: string;
  isPinned: boolean;
  category: string; // 'all' | 'schedule' | 'task' | 'idea' | 'study'
  createdAt: Date;
  updatedAt: Date;
}

const NoteSchema = new Schema<INote>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    content: { type: String, default: '' },
    date: { type: String, required: true, index: true },
    scheduleId: { type: Schema.Types.ObjectId, ref: 'Schedule', default: null },
    scheduleTitle: { type: String, default: null },
    taskId: { type: Schema.Types.ObjectId, ref: 'Task', default: null },
    taskTitle: { type: String, default: null },
    isPinned: { type: Boolean, default: false, index: true },
    category: { type: String, default: 'idea' },
  },
  {
    timestamps: true,
  }
);

export const NoteModel = mongoose.model<INote>('Note', NoteSchema);
