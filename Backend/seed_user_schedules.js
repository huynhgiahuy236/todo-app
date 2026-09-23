const dns = require('dns');
dns.setServers(['8.8.8.8', '1.1.1.1']);
require('dotenv').config();
const mongoose = require('mongoose');

const schedulesToAdd = [
  // 1. Học Java (Thứ 6: 09:00 - 11:30, kéo dài 2 tháng)
  {
    title: 'Học Java',
    type: 'study',
    color: '#3B82F6',
    startDate: '2026-09-25',
    endDate: '2026-09-25',
    startTime: '09:00',
    endTime: '11:30',
    recurrence: { type: 'weekly', daysOfWeek: [5], until: '2026-11-25' },
    note: 'Lịch học kéo dài 2 tháng (Thứ 6 hàng tuần)',
    location: '',
    exceptionDates: [],
  },

  // 2. Thực tập T4 (08:30 - 17:30)
  {
    title: 'Thực tập',
    type: 'work',
    color: '#10B981',
    startDate: '2026-09-23',
    endDate: '2026-09-23',
    startTime: '08:30',
    endTime: '17:30',
    recurrence: { type: 'weekly', daysOfWeek: [3], until: '2026-10-18' },
    note: 'Thực tập Thứ 4 hàng tuần',
    location: 'Công ty',
    exceptionDates: [],
  },

  // 3. Thực tập T5 (08:30 - 17:30)
  {
    title: 'Thực tập',
    type: 'work',
    color: '#10B981',
    startDate: '2026-09-24',
    endDate: '2026-09-24',
    startTime: '08:30',
    endTime: '17:30',
    recurrence: { type: 'weekly', daysOfWeek: [4], until: '2026-10-18' },
    note: 'Thực tập Thứ 5 hàng tuần',
    location: 'Công ty',
    exceptionDates: [],
  },

  // 4. Thực tập T6 (13:30 - 17:30)
  {
    title: 'Thực tập',
    type: 'work',
    color: '#10B981',
    startDate: '2026-09-25',
    endDate: '2026-09-25',
    startTime: '13:30',
    endTime: '17:30',
    recurrence: { type: 'weekly', daysOfWeek: [5], until: '2026-10-18' },
    note: 'Thực tập Thứ 6 hàng tuần',
    location: 'Công ty',
    exceptionDates: [],
  },

  // 5. Thực tập T7 (09:00 - 12:00)
  {
    title: 'Thực tập',
    type: 'work',
    color: '#10B981',
    startDate: '2026-09-26',
    endDate: '2026-09-26',
    startTime: '09:00',
    endTime: '12:00',
    recurrence: { type: 'weekly', daysOfWeek: [6], until: '2026-10-18' },
    note: 'Thực tập Thứ 7 hàng tuần',
    location: 'Công ty',
    exceptionDates: [],
  },

  // 6. Backend — 8 buổi (Lý thuyết / Thực hành)
  {
    title: 'Backend — Lý thuyết',
    type: 'work',
    color: '#10B981',
    startDate: '2026-09-25',
    endDate: '2026-09-25',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 1: Lý thuyết',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Thực hành',
    type: 'work',
    color: '#10B981',
    startDate: '2026-09-26',
    endDate: '2026-09-26',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 2: Thực hành',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Lý thuyết',
    type: 'work',
    color: '#10B981',
    startDate: '2026-10-02',
    endDate: '2026-10-02',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 3: Lý thuyết',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Thực hành',
    type: 'work',
    color: '#10B981',
    startDate: '2026-10-03',
    endDate: '2026-10-03',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 4: Thực hành',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Lý thuyết',
    type: 'work',
    color: '#10B981',
    startDate: '2026-10-09',
    endDate: '2026-10-09',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 5: Lý thuyết',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Thực hành',
    type: 'work',
    color: '#10B981',
    startDate: '2026-10-10',
    endDate: '2026-10-10',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 6: Thực hành',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Lý thuyết',
    type: 'work',
    color: '#10B981',
    startDate: '2026-10-16',
    endDate: '2026-10-16',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 7: Lý thuyết',
    location: '',
    exceptionDates: [],
  },
  {
    title: 'Backend — Thực hành',
    type: 'work',
    color: '#10B981',
    startDate: '2026-10-17',
    endDate: '2026-10-17',
    startTime: '18:00',
    endTime: '20:30',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Buổi 8: Thực hành',
    location: '',
    exceptionDates: [],
  },

  // 7. Thực hành Thứ 7 (06:30 - 09:00, kéo dài 2 tháng)
  {
    title: 'Thực hành',
    type: 'study',
    color: '#3B82F6',
    startDate: '2026-09-26',
    endDate: '2026-09-26',
    startTime: '06:30',
    endTime: '09:00',
    recurrence: { type: 'weekly', daysOfWeek: [6], until: '2026-11-26' },
    note: 'Thực hành Thứ 7 hàng tuần (06:30 - 09:00)',
    location: 'Phòng Lab',
    exceptionDates: ['2026-10-24'],
  },

  // 8. Thi giữa kỳ (Riêng ngày 24/10/2026)
  {
    title: 'Thi giữa kỳ',
    type: 'important',
    color: '#EF4444',
    startDate: '2026-10-24',
    endDate: '2026-10-24',
    startTime: '06:30',
    endTime: '09:00',
    recurrence: { type: 'none', daysOfWeek: [], until: null },
    note: 'Thi giữa kỳ thay cho buổi Thực hành ngày 24/10/2026',
    location: 'Phòng Thi',
    exceptionDates: [],
  },
];

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB');

  const users = await mongoose.connection.db.collection('users').find({}).toArray();

  for (const user of users) {
    // Delete old test 'java' items
    await mongoose.connection.db.collection('schedules').deleteMany({
      userId: user._id,
      title: { $in: ['java', 'Java', 'Học Java'] },
    });

    for (const item of schedulesToAdd) {
      const doc = {
        ...item,
        userId: user._id,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      await mongoose.connection.db.collection('schedules').insertOne(doc);
    }
    console.log('Inserted schedules for user:', user.name, user.email);
  }

  console.log('ALL SCHEDULES SEEDED SUCCESSFULLY!');
  process.exit(0);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
