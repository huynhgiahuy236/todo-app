import { Types } from 'mongoose';
import { TaskModel, ITask } from './task.model';

export class TaskService {
  static async getTasks(userId: string, date?: string, completed?: boolean): Promise<ITask[]> {
    const filter: any = { userId: new Types.ObjectId(userId) };
    if (date) {
      filter.dueDate = date;
    }
    if (completed !== undefined) {
      filter.completed = completed;
    }

    return await TaskModel.find(filter).sort({ completed: 1, dueDate: 1, priority: -1, createdAt: -1 });
  }

  static async createTask(userId: string, data: Partial<ITask>): Promise<ITask> {
    return await TaskModel.create({
      ...data,
      userId: new Types.ObjectId(userId),
    });
  }

  static async updateTask(userId: string, id: string, data: Partial<ITask>): Promise<ITask> {
    const task = await TaskModel.findOneAndUpdate(
      { _id: new Types.ObjectId(id), userId: new Types.ObjectId(userId) },
      { $set: data },
      { new: true }
    );
    if (!task) {
      throw new Error('Không tìm thấy công việc');
    }
    return task;
  }

  static async toggleTask(userId: string, id: string): Promise<ITask> {
    const task = await TaskModel.findOne({
      _id: new Types.ObjectId(id),
      userId: new Types.ObjectId(userId),
    });
    if (!task) {
      throw new Error('Không tìm thấy công việc');
    }

    task.completed = !task.completed;
    await task.save();
    return task;
  }

  static async deleteTask(userId: string, id: string): Promise<void> {
    const result = await TaskModel.findOneAndDelete({
      _id: new Types.ObjectId(id),
      userId: new Types.ObjectId(userId),
    });
    if (!result) {
      throw new Error('Không tìm thấy công việc để xóa');
    }
  }
}
