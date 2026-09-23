import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/response.util';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction): void => {
  console.error('[Error Handler]', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Đã xảy ra lỗi máy chủ nội bộ';

  sendError(res, message, statusCode, err.errors);
};
