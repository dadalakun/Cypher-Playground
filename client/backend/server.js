import express from 'express';
import cors from 'cors';
import {} from 'dotenv/config';
import queryRoute from './routes/queries.js';
import pino from 'pino';
import sqlite3 from 'sqlite3';

// Load environment variables from .env into process.env


const logger = pino({
    level: 'info'
});

const app = express();

const db = new sqlite3.Database('./db/database.db');

// Create the table if it doesn't exist
db.run("CREATE TABLE IF NOT EXISTS cache (query TEXT, result TEXT)");

// Handle request from different origins
app.use(cors());
// Parse JSON requests into Javascript object
app.use(express.json());
// Create a middleware function to attach the logger and db instance
app.use((req, res, next) => {
    req.logger = logger;
    req.db = db;
    next();
});

// Define routes
app.use('/api', queryRoute);

// Global error handling
app.use((err, req, res, next) => {
    logger.error(err.stack)
    res.status(500).send('Something went wrong...')
});

const port = process.env.PORT || 4000;

app.listen(port, () => {
    logger.info(`Server is up on port ${port}.`)
});