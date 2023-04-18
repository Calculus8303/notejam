# Use an appropriate base image
FROM node:latest

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install npm packages
RUN npm install

# Copy the rest of the application files to the container
COPY . .

# Run the database migration script
RUN node db.js

# Expose the port that the application listens on
EXPOSE 3000

# Start the application
CMD ["./bin/www"]
