// MongoDB initialization script for development
// This script runs when the MongoDB container starts for the first time

// Switch to the application database
db = db.getSiblingDB('nodeapp_dev');

// Create application user with read/write permissions
db.createUser({
  user: 'appuser',
  pwd: 'apppass',
  roles: [
    {
      role: 'readWrite',
      db: 'nodeapp_dev'
    }
  ]
});

// Create some initial collections with indexes
db.createCollection('users');
db.createCollection('posts');
db.createCollection('sessions');

// Create indexes for better performance
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "username": 1 }, { unique: true });
db.users.createIndex({ "createdAt": 1 });

db.posts.createIndex({ "userId": 1 });
db.posts.createIndex({ "createdAt": -1 });
db.posts.createIndex({ "title": "text", "content": "text" });

db.sessions.createIndex({ "sessionId": 1 }, { unique: true });
db.sessions.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 });

// Insert some sample data for development
db.users.insertMany([
  {
    _id: ObjectId(),
    username: 'john_doe',
    email: 'john@example.com',
    name: 'John Doe',
    createdAt: new Date(),
    isActive: true
  },
  {
    _id: ObjectId(),
    username: 'jane_smith',
    email: 'jane@example.com',
    name: 'Jane Smith',
    createdAt: new Date(),
    isActive: true
  }
]);

print('✅ MongoDB initialization completed successfully!');
print('📊 Database: nodeapp_dev');
print('👤 App user: appuser (password: apppass)');
print('🗄️  Collections: users, posts, sessions');
print('📈 Indexes created for performance');
print('🔧 Sample data inserted');
