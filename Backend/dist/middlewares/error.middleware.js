"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const response_util_1 = require("../utils/response.util");
const errorHandler = (err, req, res, next) => {
    console.error('[Error Handler]', err);
    const statusCode = err.statusCode || 500;
    const message = err.message || 'Đã xảy ra lỗi máy chủ nội bộ';
    (0, response_util_1.sendError)(res, message, statusCode, err.errors);
};
exports.errorHandler = errorHandler;
