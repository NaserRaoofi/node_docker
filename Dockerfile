# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy app source code (for production, but we'll mount for development)
COPY . ./

# Expose port
EXPOSE 3000

# Run the app
CMD ["npm", "run", "dev"]
