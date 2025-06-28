const express = require("express");
const mongoose = require("mongoose");
const Redis = require("ioredis");
const User = require("./models/User");

const app = express();
app.use(express.json());

// --- MongoDB connection with retry logic ---
const mongoUrl = process.env.MONGODB_URL || "mongodb://localhost:27017/nodeapp_dev";
let mongoConnected = false;
let mongoRetries = 0;
const MAX_MONGO_RETRIES = 5;

function connectToMongo() {
  console.log(`📡 Attempting MongoDB connection to ${mongoUrl.replace(/\/\/([^:]+):[^@]+@/, '//***:***@')}`);
  
  mongoose.connect(mongoUrl, {
    serverSelectionTimeoutMS: 5000, // Timeout for server selection
    socketTimeoutMS: 45000, // Close socket if not active for 45 sec
  })
  .then(() => {
    console.log("✅ Connected to MongoDB successfully");
    mongoConnected = true;
    mongoRetries = 0; // Reset retry counter on success
  })
  .catch(err => {
    mongoRetries++;
    console.error(`❌ MongoDB connection error (Attempt ${mongoRetries}/${MAX_MONGO_RETRIES}):`, err.message);
    
    if (mongoRetries < MAX_MONGO_RETRIES) {
      const retryDelay = Math.min(1000 * Math.pow(2, mongoRetries - 1), 10000); // Exponential backoff with max 10s
      console.log(`⏱️ Retrying MongoDB connection in ${retryDelay/1000} seconds...`);
      setTimeout(connectToMongo, retryDelay);
    } else {
      console.log("⚠️ Maximum MongoDB connection attempts reached. Running in limited mode.");
      console.log("⚠️ API endpoints will return mock data or limited functionality");
    }
  });
}

// --- Redis connection with retry logic ---
const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";
let redisClient = null;
let redisConnected = false;
let redisRetries = 0;
const MAX_REDIS_RETRIES = 5;

function connectToRedis() {
  console.log(`📡 Attempting Redis connection to ${redisUrl.replace(/\/\/([^:]+):[^@]+@/, '//***:***@')}`);
  
  try {
    // Close any existing connection before creating a new one
    if (redisClient) {
      try {
        redisClient.disconnect();
      } catch (e) {
        // Ignore disconnect errors
      }
    }
    
    // Create new Redis client with better error handling
    redisClient = new Redis(redisUrl, {
      connectTimeout: 5000,
      maxRetriesPerRequest: 1,
      retryStrategy: (times) => {
        return null; // We'll handle retries manually
      }
    });
    
    redisClient.on("connect", () => {
      console.log("✅ Connected to Redis successfully");
      redisConnected = true;
      redisRetries = 0; // Reset retry counter on success
    });
    
    redisClient.on("error", (err) => {
      // Only log and retry if we haven't connected yet
      if (!redisConnected) {
        redisRetries++;
        console.error(`❌ Redis connection error (Attempt ${redisRetries}/${MAX_REDIS_RETRIES}):`, err.message);
        
        if (redisRetries < MAX_REDIS_RETRIES) {
          const retryDelay = Math.min(1000 * Math.pow(2, redisRetries - 1), 10000); // Exponential backoff with max 10s
          console.log(`⏱️ Retrying Redis connection in ${retryDelay/1000} seconds...`);
          setTimeout(connectToRedis, retryDelay);
        } else {
          console.log("⚠️ Maximum Redis connection attempts reached. Running without Redis.");
          console.log("⚠️ Caching functionality will be disabled");
          redisClient = null;
        }
      }
    });
  } catch (err) {
    console.error("❌ Redis client initialization error:", err.message);
    console.log("⚠️ Running without Redis - caching functionality will be disabled");
    redisClient = null;
  }
}

// Start connection attempts
connectToMongo();
connectToRedis();

// --- Root endpoint ---
app.get("/", (req, res) => {
  res.send(`
    <h1>🐳 Node.js Docker App</h1>
    <p>MongoDB: ${mongoConnected ? '✅ Connected' : '❌ Not Connected'}</p>
    <p>Redis: ${redisConnected ? '✅ Connected' : '❌ Not Connected'}</p>
    <h2>API Endpoints:</h2>
    <ul>
      <li>GET /api/users - List all users</li>
      <li>GET /api/users/:id - Get user by ID</li>
      <li>POST /api/users - Create new user</li>
      <li>PUT /api/users/:id - Update user</li>
      <li>DELETE /api/users/:id - Delete user</li>
    </ul>
    <p><a href="/health">View Health Status</a></p>
  `);
});

// --- Health check ---
app.get("/health", async (req, res) => {
  let isRedisConnected = false;
  
  if (redisClient) {
    try {
      await redisClient.ping();
      isRedisConnected = true;
    } catch (err) {
      console.log("❌ Redis health check failed:", err.message);
    }
  }
  
  const health = {
    status: mongoConnected || redisConnected ? "ok" : "degraded",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    services: {
      mongodb: {
        status: mongoConnected ? "up" : "down",
        url: mongoUrl.replace(/\/\/([^:]+):[^@]+@/, '//***:***@')
      },
      redis: {
        status: isRedisConnected ? "up" : "down",
        url: redisUrl.replace(/\/\/([^:]+):[^@]+@/, '//***:***@')
      }
    }
  };
  
  const statusCode = mongoConnected && isRedisConnected ? 200 : 
                     (mongoConnected || isRedisConnected) ? 200 : 503;
  
  res.status(statusCode).json(health);
});

// --- CRUD Endpoints ---
// Create user
app.post("/api/users", async (req, res) => {
  if (!mongoConnected) {
    return res.status(503).json({ error: "MongoDB not available", message: "Service is starting up" });
  }

  try {
    const user = new User(req.body);
    await user.save();
    res.status(201).json(user);
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ error: "Email already exists" });
    }
    res.status(400).json({ error: err.message });
  }
});

// Read all users
app.get("/api/users", async (req, res) => {
  if (!mongoConnected) {
    return res.status(200).json([
      { _id: "mock1", username: "demo_user", email: "demo@example.com", name: "Demo User", isActive: true },
      { _id: "mock2", username: "test_user", email: "test@example.com", name: "Test User", isActive: true }
    ]);
  }

  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Read user by ID
app.get("/api/users/:id", async (req, res) => {
  if (!mongoConnected) {
    return res.status(200).json({ 
      _id: req.params.id, 
      username: "mock_user", 
      email: "mock@example.com", 
      name: "Mock User", 
      isActive: true 
    });
  }

  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: "Invalid user ID" });
  }
});

// Update user
app.put("/api/users/:id", async (req, res) => {
  if (!mongoConnected) {
    return res.status(503).json({ error: "MongoDB not available", message: "Service is starting up" });
  }

  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete user
app.delete("/api/users/:id", async (req, res) => {
  if (!mongoConnected) {
    return res.status(503).json({ error: "MongoDB not available", message: "Service is starting up" });
  }

  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(400).json({ error: "Invalid user ID" });
  }
});

// --- Start server ---
const port = process.env.PORT || 3000;
const host = process.env.HOST || "0.0.0.0";
app.listen(port, host, () => {
  console.log(`🚀 Server running on http://${host}:${port}`);
});
