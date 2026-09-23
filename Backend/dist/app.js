"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const auth_routes_1 = require("./modules/auth/auth.routes");
const schedule_routes_1 = require("./modules/schedules/schedule.routes");
const task_routes_1 = require("./modules/tasks/task.routes");
const note_routes_1 = require("./modules/notes/note.routes");
const error_middleware_1 = require("./middlewares/error.middleware");
const app = (0, express_1.default)();
// Middlewares
app.use((0, cors_1.default)({ origin: '*' }));
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Health Check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        message: 'MySche Personal Schedule API is running smoothly',
        timestamp: new Date().toISOString(),
    });
});
// API Routes
app.use('/api/auth', auth_routes_1.authRoutes);
app.use('/api/schedules', schedule_routes_1.scheduleRoutes);
app.use('/api/tasks', task_routes_1.taskRoutes);
app.use('/api/notes', note_routes_1.noteRoutes);
// Global Error Handler
app.use(error_middleware_1.errorHandler);
exports.default = app;
