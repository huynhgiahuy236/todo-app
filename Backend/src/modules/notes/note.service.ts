import { Types } from 'mongoose';
import { NoteModel, INote } from './note.model';

export class NoteService {
  static async getNotes(userId: string, category?: string, search?: string): Promise<INote[]> {
    const filter: any = { userId: new Types.ObjectId(userId) };

    if (category && category !== 'all') {
      if (category === 'schedule') {
        filter.scheduleId = { $ne: null };
      } else if (category === 'task') {
        filter.taskId = { $ne: null };
      } else {
        filter.category = category;
      }
    }

    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
      ];
    }

    return await NoteModel.find(filter).sort({ isPinned: -1, updatedAt: -1 });
  }

  static async createNote(userId: string, data: Partial<INote>): Promise<INote> {
    return await NoteModel.create({
      ...data,
      userId: new Types.ObjectId(userId),
    });
  }

  static async updateNote(userId: string, id: string, data: Partial<INote>): Promise<INote> {
    const note = await NoteModel.findOneAndUpdate(
      { _id: new Types.ObjectId(id), userId: new Types.ObjectId(userId) },
      { $set: data },
      { new: true }
    );
    if (!note) {
      throw new Error('Không tìm thấy ghi chú');
    }
    return note;
  }

  static async togglePinNote(userId: string, id: string): Promise<INote> {
    const note = await NoteModel.findOne({
      _id: new Types.ObjectId(id),
      userId: new Types.ObjectId(userId),
    });
    if (!note) {
      throw new Error('Không tìm thấy ghi chú');
    }
    note.isPinned = !note.isPinned;
    await note.save();
    return note;
  }

  static async deleteNote(userId: string, id: string): Promise<void> {
    const result = await NoteModel.findOneAndDelete({
      _id: new Types.ObjectId(id),
      userId: new Types.ObjectId(userId),
    });
    if (!result) {
      throw new Error('Không tìm thấy ghi chú để xóa');
    }
  }
}
