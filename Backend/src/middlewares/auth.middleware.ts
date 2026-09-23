import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { ENV } from '../config/env';
import { sendError } from '../utils/response.util';

export interface AuthRequest extends Request {
  userId?: string;
  userEmail?: string;
}

export const authenticateJWT = (req: AuthRequest, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    sendError(res, 'Vui lòng đăng nhập để tiếp tục (Thiếu Token)', 401);
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, ENV.JWT_SECRET) as { userId: string; email: string };
    req.userId = decoded.userId;
    req.userEmail = decoded.email;
    next();
  } catch (error) {
    sendError(res, 'Phiên đăng nhập đã hết hạn hoặc không hợp lệ', 401);
  }
};
