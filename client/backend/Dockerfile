# Fetch the ANTLR Java library
FROM alpine:latest as antlr-java-lib
# Install curl if it's not already in the base image
RUN apk add --no-cache curl
RUN curl -O https://www.antlr.org/download/antlr-4.13.0-complete.jar

# Build C++ binary with CMake
FROM alpine:latest as cpp-build

RUN apk add --no-cache cmake g++ make git openjdk11
# Copy the C++ source code and the ANTLR jar from the previous stage
COPY antlr/ /backend/antlr/
COPY --from=antlr-java-lib /antlr-4.13.0-complete.jar /backend/antlr/
WORKDIR /backend/antlr/build
RUN cmake ../ && make

# Setup the final image with Node.js and the C++ binary
FROM node:18.18.0-alpine
WORKDIR /usr/src/app
VOLUME /usr/src/app/output

# Copy the Node.js application files
COPY package.json yarn.lock server.js .env ./
COPY routes/ ./routes/
COPY output/ ./output
# Install dependencies for the Nodejs server
RUN yarn install --production
# Create a directory for the sqlite db
RUN mkdir -p db
# Copy the C++ binary from the cpp-build stage
COPY --from=cpp-build /backend/antlr/bin/grammarCheck ./bin/

# Expose the port the backend listens on
EXPOSE 4000

# Start the Node.js backend server
CMD ["node", "server.js"]