const request = require("supertest");
const express = require("express");

// Import your app logic (you might need to refactor index.js to export the app)
// For now, we'll create a simple test app
const createApp = () => {
  const app = express();
  app.use(express.json());

  app.get("/", (req, res) => {
    res.send(`
      <h2>🚀 ${process.env.APP_NAME || 'Node Docker App'} v${process.env.APP_VERSION || '1.0.0'}</h2>
      <p>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></p>
      <p>Volume mounting is working! ✨</p>
      <p>Port: ${process.env.PORT || 3000}</p>
    `);
  });

  app.get("/health", (req, res) => {
    res.json({
      status: "OK",
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      version: process.env.APP_VERSION || '1.0.0'
    });
  });

  return app;
};

describe("API Integration Tests", () => {
  let app;

  beforeAll(() => {
    app = createApp();
  });

  describe("GET /", () => {
    it("should return the main page", async () => {
      const response = await request(app).get("/");
      
      expect(response.status).toBe(200);
      expect(response.text).toContain("App"); // Should contain App in the title
      expect(response.text).toContain("test"); // NODE_ENV should be test
    });
  });

  describe("GET /health", () => {
    it("should return health status", async () => {
      const response = await request(app).get("/health");
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("status", "OK");
      expect(response.body).toHaveProperty("timestamp");
      expect(response.body).toHaveProperty("environment", "test");
      expect(response.body).toHaveProperty("version");
    });

    it("should return JSON content type", async () => {
      const response = await request(app).get("/health");
      
      expect(response.headers["content-type"]).toMatch(/json/);
    });
  });

  describe("Error handling", () => {
    it("should return 404 for unknown routes", async () => {
      const response = await request(app).get("/nonexistent");
      
      expect(response.status).toBe(404);
    });
  });
});
