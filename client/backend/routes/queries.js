import express from 'express';
import axios from 'axios';
import fs from 'fs';
import { exec } from 'child_process';
import { promisify } from 'util';
const router = express.Router();
const execa = promisify(exec);
const grammarCheckPath = process.env.GRAMMAR_CHECK_PATH || './antlr/bin/grammarCheck';
const goServerURL = process.env.GO_SERVER_API || 'http://localhost:8080/api/execute-query';
const outputFilePath = process.env.JSON_FILE_PATH || './output/result.json'
const writeOperations = ['CREATE', 'MERGE', 'SET', 'DELETE', 'REMOVE'];

router.post('/check-query', async (req, res) => {
    // Check if the request body is valid
    if (!req.body || typeof req.body.query !== 'string' || req.body.query.trim() === '') {
        req.logger.error("Query field is missing or empty.");
        res.status(400).json({ status: 'error', message: "Query field is missing or empty." });
        return;
    }
    try {
        const db = req.db;
        const query = req.body.query;
        const escapedQuery = query.replace(/"/g, '\\"');
        req.logger.info({ query: escapedQuery }, 'Received Query');
        // Validate the grammar of the Cypher query
        const o = await execa(`${grammarCheckPath} \"${escapedQuery}\"`);
        if (o.stderr) {
            req.logger.error("Not a valid Cypher query.");
            res.status(400).json({ status: 'error', message: `Not a valid Cypher query:\n${o.stderr}` });
            return;
        }

        // Check if the result is already cached
        db.get("SELECT result FROM cache WHERE query = ?", query, async (err, row) => {
            // Handle database error
            if (err) {
                req.logger.error(`SQLite error: ${err}`);
                res.status(500).json({ status: 'error', message: 'SQLite error.' });
                return;
            }

            // Cached result found, send it to the frontend
            if (row) {
                req.logger.info("Result already in the cache.");
                res.status(200).json({ status: 'success', message: 'From Cache.' ,data: JSON.parse(row.result) });
                fs.writeFileSync(outputFilePath, row.result);
                req.logger.info("Update result.json");
                return;
            }

            // Result not cached, send the query to the Go server
            try {
                const goServerResponse = await axios.post(goServerURL, { query });
                req.logger.info({ Message: goServerResponse.data.message, Data: goServerResponse.data.data }, 'Received response from Go server:');

                // Check if db_changed is true and clear cache if necessary
                if (goServerResponse.data.db_changed) {
                    db.run("DELETE FROM cache", (err) => {
                        if (err) {
                            req.logger.error(`Database error: ${err}`);
                        } else {
                            req.logger.info('Clear the cache due to db state changed.');
                        }
                    });
                }

                // Convert the data object to a JSON string
                const dataString = JSON.stringify(goServerResponse.data.data, null, 2);

                // Cache the result if the query:
                // 1. Didn't change the Neo4j db state AND
                // 2. Does not contain any write operation
                if (!goServerResponse.data.db_changed &&
                    !writeOperations.some(op => query.toUpperCase().includes(op))) {
                    db.run("INSERT INTO cache (query, result) VALUES (?, ?)", query, dataString, (err) => {
                        if (err) {
                            req.logger.error(`Database error: ${err}`);
                        }
                    });
                }

                // Send the response to the frontend
                res.status(200).json({ status: 'success', message: 'From Go server.', data: goServerResponse.data.data });
                fs.writeFileSync(outputFilePath, dataString);
                req.logger.info("Update result.json");
            } catch (error) {
                req.logger.error(`Execution error: ${error}`);
                if (error.response) {
                    req.logger.error(`Error from Go server: ${error.response.data}`);
                    res.status(500).json({ status: 'error', message: `Go server error: ${error.response.data}` });
                    return;
                }
                res.status(500).json({ status: 'error', message: `Node.js server error: ${error}` });
            }
        });
    } catch (error) {
        req.logger.error(`Execution error: ${error}`);
        res.status(500).json({ status: 'error', message: `Node.js server error: ${error}` });
    }
});

router.get('/table-info', (req, res) => {
    const db = req.db;

    // Fetch the total number of rows in the table
    db.get('SELECT COUNT(*) as count FROM cache', (err, row) => {
        if (err) {
            req.logger.error(`SQLite error: ${err}`);
            res.status(500).json({ status: 'error', message: 'SQLite error.' });
            return;
        }

        const rowCount = row.count;

        // Fetch all query, result pairs from the table
        db.all('SELECT query, result FROM cache', (err, rows) => {
            if (err) {
                req.logger.error(`SQLite error: ${err}`);
                res.status(500).json({ status: 'error', message: 'SQLite error.' });
                return;
            }

            // Construct a string containing the requested information
            let infoString = "";
            rows.forEach((row, index) => {
                infoString += `Entry ${index + 1}: Query: ${row.query} #### `;
            });

            // Send the information string back to the client
            res.status(200).json({ status: 'success', rowCount: rowCount, content: infoString});
        });
    });
});

router.post('/clear-cache', (req, res) => {
    const db = req.db;

    db.run("DELETE FROM cache", function(err) {
        if (err) {
            req.logger.error(`SQLite error: ${err}`);
            res.status(500).json({ status: 'error', message: 'SQLite error.' });
            return;
        }
        
        req.logger.info('Cache cleared successfully.');
        res.status(200).json({ status: 'success', message: 'Cache cleared successfully.' });
    });
});

export default router;