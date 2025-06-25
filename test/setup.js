// Test setup file
// This file runs before all tests

// Set test environment variables
process.env.NODE_ENV = "test";
process.env.PORT = "3001";
process.env.APP_NAME = "Test App";
process.env.APP_VERSION = "1.0.0-test";

// Global test timeout
jest.setTimeout(10000);

// Mock console.log in tests to reduce noise
global.console = {
  ...console,
  log: jest.fn(),
};
