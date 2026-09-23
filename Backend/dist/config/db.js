"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.connectDB = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const env_1 = require("./env");
const connectDB = async () => {
    try {
        const conn = await mongoose_1.default.connect(env_1.ENV.MONGODB_URI);
        console.log(`[Database] MongoDB Connected: ${conn.connection.host}`);
    }
    catch (error) {
        console.error(`[Database] Connection Error:`, error);
        // Allow app to still run or retry if in dev mode
    }
};
exports.connectDB = connectDB;
