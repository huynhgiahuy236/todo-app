import app from './app';
import { connectDB } from './config/db';
import { ENV } from './config/env';

const startServer = async () => {
  await connectDB();

  app.listen(ENV.PORT, () => {
    console.log(`=========================================`);
    console.log(`🚀 MySche Backend Server is running!`);
    console.log(`📡 URL: http://localhost:${ENV.PORT}`);
    console.log(`🩺 Health check: http://localhost:${ENV.PORT}/api/health`);
    console.log(`=========================================`);
  });
};

startServer();
