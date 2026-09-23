import mongoose from 'mongoose';
import dns from 'dns';
import { ENV } from './env';

// Configure reliable DNS servers to avoid SRV ECONNREFUSED on some local ISPs/Windows networks
try {
  dns.setServers(['8.8.8.8', '1.1.1.1']);
} catch (e) {
  // Ignore if not permitted
}

export const connectDB = async (): Promise<void> => {
  try {
    const conn = await mongoose.connect(ENV.MONGODB_URI);
    console.log(`[Database] MongoDB Connected Successfully to: ${conn.connection.host}`);
  } catch (error) {
    console.error(`[Database] Connection Error:`, error);
  }
};
