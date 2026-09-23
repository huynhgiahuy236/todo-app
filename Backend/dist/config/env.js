"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ENV = void 0;
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
exports.ENV = {
    PORT: process.env.PORT || '5000',
    MONGODB_URI: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/mysche',
    JWT_SECRET: process.env.JWT_SECRET || 'mysche_super_secret_jwt_key_2026_modern_personal_calendar',
    NODE_ENV: process.env.NODE_ENV || 'development',
};
