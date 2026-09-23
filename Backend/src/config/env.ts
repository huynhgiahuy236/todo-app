import dotenv from 'dotenv';
dotenv.config();

export const ENV = {
  PORT: process.env.PORT || '5000',
  MONGODB_URI: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/mysche',
  JWT_SECRET: process.env.JWT_SECRET || 'mysche_super_secret_jwt_key_2026_modern_personal_calendar',
  NODE_ENV: process.env.NODE_ENV || 'development',
};
