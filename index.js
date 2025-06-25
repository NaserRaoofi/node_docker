const express = require("express");

const app = express();

// Middleware to parse JSON
app.use(express.json());

app.get("/", (req, res) => {
  res.send(`
    <h2>🚀 ${process.env.APP_NAME || 'Node Docker App'} v${process.env.APP_VERSION || '1.0.0'}</h2>
    <p>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></p>
    <p>Volume mounting is working! ✨</p>
    <p>Port: ${process.env.PORT || 3000}</p>
  `);
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || '1.0.0'
  });
});

const port = process.env.PORT || 3000;
const host = process.env.HOST || "0.0.0.0";

app.listen(port, host, () => {
  console.log(`🚀 ${process.env.APP_NAME || 'App'} running on ${host}:${port}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🏥 Health check: http://${host}:${port}/health`);
});
