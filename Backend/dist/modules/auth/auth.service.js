"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const user_model_1 = require("./user.model");
const env_1 = require("../../config/env");
class AuthService {
    static async register(name, email, password) {
        const existing = await user_model_1.UserModel.findOne({ email: email.toLowerCase() });
        if (existing) {
            throw new Error('Email này đã được sử dụng');
        }
        const salt = await bcryptjs_1.default.genSalt(10);
        const passwordHash = await bcryptjs_1.default.hash(password, salt);
        const user = await user_model_1.UserModel.create({
            name,
            email: email.toLowerCase(),
            passwordHash,
        });
        const token = jsonwebtoken_1.default.sign({ userId: user._id.toString(), email: user.email }, env_1.ENV.JWT_SECRET, {
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
    static async login(email, password) {
        const user = await user_model_1.UserModel.findOne({ email: email.toLowerCase() });
        if (!user) {
            throw new Error('Email hoặc mật khẩu không chính xác');
        }
        const isMatch = await bcryptjs_1.default.compare(password, user.passwordHash);
        if (!isMatch) {
            throw new Error('Email hoặc mật khẩu không chính xác');
        }
        const token = jsonwebtoken_1.default.sign({ userId: user._id.toString(), email: user.email }, env_1.ENV.JWT_SECRET, {
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
    static async getMe(userId) {
        const user = await user_model_1.UserModel.findById(userId).select('-passwordHash');
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
exports.AuthService = AuthService;
