"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.ScheduleModel = void 0;
const mongoose_1 = __importStar(require("mongoose"));
const RecurrenceSchema = new mongoose_1.Schema({
    type: {
        type: String,
        enum: ['none', 'daily', 'weekly', 'custom'],
        default: 'none',
    },
    daysOfWeek: { type: [Number], default: [] },
    until: { type: String, default: null },
}, { _id: false });
const ScheduleSchema = new mongoose_1.Schema({
    userId: { type: mongoose_1.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    type: { type: String, default: 'other', trim: true },
    startDate: { type: String, required: true, index: true },
    endDate: { type: String, required: true },
    startTime: { type: String, required: true },
    endTime: { type: String, required: true },
    color: { type: String, default: '#1677E8' },
    note: { type: String, default: '' },
    location: { type: String, default: '' },
    seriesId: { type: String, index: true },
    recurrence: { type: RecurrenceSchema, default: () => ({ type: 'none', daysOfWeek: [], until: null }) },
    exceptionDates: { type: [String], default: [] },
}, {
    timestamps: true,
});
exports.ScheduleModel = mongoose_1.default.model('Schedule', ScheduleSchema);
