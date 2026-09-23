import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UserModel, IUser } from './user.model';
import { ENV } from '../../config/env';

export class AuthService {
  static async register(name: string, email: string, password: string):Promise<{ user: any; token: string }> {
    const existing = await UserModel.findOne({ email: email.toLowerCase() });
    if (existing) {
      throw new Error('Email này đã được sử dụng');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await UserModel.create({
      name,
      email: email.toLowerCase(),
      passwordHash,
    });

    const token = jwt.sign({ userId: user._id.toString(), email: user.email }, ENV.JWT_SECRET, {
      expiresIn: '30d',
    });

    return {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
      },
      token,
    };
  }

  static async login(email: string, password: string): Promise<{ user: any; token: string }> {
    const user = await UserModel.findOne({ email: email.toLowerCase() });
    if (!user) {
      throw new Error('Email hoặc mật khẩu không chính xác');
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      throw new Error('Email hoặc mật khẩu không chính xác');
    }

    const token = jwt.sign({ userId: user._id.toString(), email: user.email }, ENV.JWT_SECRET, {
      expiresIn: '30d',
    });

    return {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
      },
      token,
    };
  }

  static async getMe(userId: string) {
    const user = await UserModel.findById(userId).select('-passwordHash');
    if (!user) {
      throw new Error('Không tìm thấy người dùng');
    }
    return {
      id: user._id,
      name: user.name,
      email: user.email,
    };
  }
}
