const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();

// MongoDB connection
let db;
const mongoUrl = process.env.MONGODB_URL || 'mongodb://localhost:27017/nodeapp_dev';

// Connect to MongoDB
MongoClient.connect(mongoUrl)
  .then((client) => {
    console.log('✅ Connected to MongoDB');
    db = client.db();
  })
  .catch((error) => {
    console.error('❌ MongoDB connection failed:', error.message);
  });

// Middleware to parse JSON
app.use(express.json());

app.get("/", (req, res) => {
  res.send(`
    <h2>🚀 ${process.env.APP_NAME || 'Node Docker App'} v${process.env.APP_VERSION || '1.0.0'}</h2>
    <p>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></p>
    <p>Volume mounting is working! ✨</p>
    <p>Port: ${process.env.PORT || 3000}</p>
    <p>MongoDB: <strong>${db ? '✅ Connected' : '❌ Not Connected'}</strong></p>
    <p>Redis URL: <strong>${process.env.REDIS_URL || 'Not configured'}</strong></p>
    <br>
    <p><a href="/api/users">👥 View Users</a> | <a href="/health">🏥 Health Check</a></p>
  `);
});

// API Routes
app.get("/api/users", async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: "Database not connected" });
    }
    
    const users = await db.collection('users').find({}).toArray();
    res.json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    res.status(500).json({ 
      error: "Failed to fetch users",
      message: error.message 
    });
  }
});

app.post("/api/users", async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: "Database not connected" });
    }
    
    const { username, email, name } = req.body;
    
    if (!username || !email || !name) {
      return res.status(400).json({ 
        error: "Missing required fields: username, email, name" 
      });
    }
    
    const user = {
      username,
      email,
      name,
      createdAt: new Date(),
      isActive: true
    };
    
    const result = await db.collection('users').insertOne(user);
    res.status(201).json({
      success: true,
      data: { ...user, _id: result.insertedId }
    });
  } catch (error) {
    res.status(500).json({ 
      error: "Failed to create user",
      message: error.message 
    });
  }
});

// Health check endpoint
app.get("/health", async (req, res) => {
  const health = {
    status: "OK",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || '1.0.0',
    services: {
      mongodb: db ? "connected" : "disconnected",
      redis: process.env.REDIS_URL ? "configured" : "not configured"
    }
  };
  
  // If MongoDB is not connected, return unhealthy status
  if (!db) {
    health.status = "UNHEALTHY";
    return res.status(503).json(health);
  }
  
  res.json(health);
});

const port = process.env.PORT || 3000;
const host = process.env.HOST || "0.0.0.0";

app.listen(port, host, () => {
  console.log(`🚀 ${process.env.APP_NAME || 'App'} running on ${host}:${port}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🏥 Health check: http://${host}:${port}/health`);
  console.log(`🗄️  MongoDB: ${mongoUrl}`);
  console.log(`🔗 Redis: ${process.env.REDIS_URL || 'Not configured'}`);
});
