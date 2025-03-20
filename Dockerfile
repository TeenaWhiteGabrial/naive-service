# Use the specified Node.js image from the Alibaba Cloud registry as the base image
FROM registry.cn-hangzhou.aliyuncs.com/misaka-images/node:20.8.1

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json (if available) to the working directory
COPY package*.json ./

# Install PM2 globally
RUN npm install -g pm2

# Install project dependencies
RUN npm install

# Copy the rest of the application files to the working directory
COPY . .

# Build the project
RUN npm run build

# Expose the port that the app runs on (optional, change if necessary)
EXPOSE 3000

# Start the application using PM2
CMD ["pm2-runtime", "start", "dist/app.js"]

# cd /usr/src/code/easy-mock
# docker pull registry.cn-hangzhou.aliyuncs.com/misaka-images/node:20.8.1
# docker run -it --name mynodeapp -v $(pwd):/usr/src/app registry.cn-hangzhou.aliyuncs.com/misaka-images/node:20.8.1 /bin/bash
# npm i pm2 -g
# npm i
# npm run build
# pm2-runtime start dist/app.js