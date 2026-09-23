"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = __importDefault(require("./app"));
const db_1 = require("./config/db");
const env_1 = require("./config/env");
const startServer = async () => {
    await (0, db_1.connectDB)();
    app_1.default.listen(env_1.ENV.PORT, () => {
        console.log(`=========================================`);
        console.log(`🚀 MySche Backend Server is running!`);
        console.log(`📡 URL: http://localhost:${env_1.ENV.PORT}`);
        console.log(`🩺 Health check: http://localhost:${env_1.ENV.PORT}/api/health`);
        console.log(`=========================================`);
    });
};
startServer();
