"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const auth_service_1 = require("./auth.service");
const response_util_1 = require("../../utils/response.util");
class AuthController {
    static async register(req, res) {
        try {
            const { name, email, password } = req.body;
            if (!name || !email || !password) {
                (0, response_util_1.sendError)(res, 'Vui lòng cung cấp đầy đủ tên, email và mật khẩu', 400);
                return;
            }
            if (password.length < 6) {
                (0, response_util_1.sendError)(res, 'Mật khẩu phải có ít nhất 6 ký tự', 400);
                return;
            }
            const result = await auth_service_1.AuthService.register(name, email, password);
            (0, response_util_1.sendSuccess)(res, result, 'Đăng ký tài khoản thành công', 201);
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi đăng ký', 400);
        }
    }
    static async login(req, res) {
        try {
            const { email, password } = req.body;
            if (!email || !password) {
                (0, response_util_1.sendError)(res, 'Vui lòng cung cấp email và mật khẩu', 400);
                return;
            }
            const result = await auth_service_1.AuthService.login(email, password);
            (0, response_util_1.sendSuccess)(res, result, 'Đăng nhập thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi đăng nhập', 400);
        }
    }
    static async getMe(req, res) {
        try {
            const user = await auth_service_1.AuthService.getMe(req.userId);
            (0, response_util_1.sendSuccess)(res, user, 'Lấy thông tin người dùng thành công');
        }
        catch (error) {
            (0, response_util_1.sendError)(res, error.message || 'Lỗi khi lấy thông tin người dùng', 400);
        }
    }
}
exports.AuthController = AuthController;
