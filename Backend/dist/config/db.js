"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.connectDB = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const dns_1 = __importDefault(require("dns"));
const env_1 = require("./env");
// Configure reliable DNS servers to avoid SRV ECONNREFUSED on some local ISPs/Windows networks
try {
    dns_1.default.setServers(['8.8.8.8', '1.1.1.1']);
}
catch (e) {
    // Ignore if not permitted
}
const connectDB = async () => {
    try {
        const conn = await mongoose_1.default.connect(env_1.ENV.MONGODB_URI);
        console.log(`[Database] MongoDB Connected Successfully to: ${conn.connection.host}`);
    }
    catch (error) {
        console.error(`[Database] Connection Error:`, error);
    }
};
exports.connectDB = connectDB;
