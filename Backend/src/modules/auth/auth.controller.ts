import { Request, Response } from 'express';
import { AuthService } from './auth.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthRequest } from '../../middlewares/auth.middleware';

export class AuthController {
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const { name, email, password } = req.body;
      if (!name || !email || !password) {
        sendError(res, 'Vui lòng cung cấp đầy đủ tên, email và mật khẩu', 400);
        return;
      }
      if (password.length < 6) {
        sendError(res, 'Mật khẩu phải có ít nhất 6 ký tự', 400);
        return;
      }

      const result = await AuthService.register(name, email, password);
      sendSuccess(res, result, 'Đăng ký tài khoản thành công', 201);
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi đăng ký', 400);
    }
  }

  static async login(req: Request, res: Response): Promise<void> {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        sendError(res, 'Vui lòng cung cấp email và mật khẩu', 400);
        return;
      }

      const result = await AuthService.login(email, password);
      sendSuccess(res, result, 'Đăng nhập thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi đăng nhập', 400);
    }
  }

  static async getMe(req: AuthRequest, res: Response): Promise<void> {
    try {
      const user = await AuthService.getMe(req.userId!);
      sendSuccess(res, user, 'Lấy thông tin người dùng thành công');
    } catch (error: any) {
      sendError(res, error.message || 'Lỗi khi lấy thông tin người dùng', 400);
    }
  }
}
