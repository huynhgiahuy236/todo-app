import mongoose, { Document, Schema, Types } from 'mongoose';

export interface ITask extends Document {
  userId: Types.ObjectId;
  title: string;
  dueDate?: string; // YYYY-MM-DD
  dueTime?: string; // HH:mm
  priority: 'low' | 'medium' | 'high';
  completed: boolean;
  note?: string;
  category?: string;
  createdAt: Date;
  updatedAt: Date;
}

const TaskSchema = new Schema<ITask>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    dueDate: { type: String, default: null, index: true },
    dueTime: { type: String, default: null },
    priority: { type: String, enum: ['low', 'medium', 'high'], default: 'medium' },
    completed: { type: Boolean, default: false, index: true },
    note: { type: String, default: '' },
    category: { type: String, default: 'General' },
  },
  {
    timestamps: true,
  }
);

export const TaskModel = mongoose.model<ITask>('Task', TaskSchema);
