# Client

## 1. Introduction
A web application with a React frontend and a Node.js backend. This is a quick overview of the process:

1. The user enters a Cypher query (either valid or invalid) and presses 'QUERY' button
2. The frontend passes the query to the API at `/api/check-query` on the Node.js backend server (port 4000)
3. The backend server validates the query using ANTLR by calling a C++ binary
4. If it passes the validation, the backend checks whether the query is already in the SQLite cache
5. If not, the backend calls the API at `/api/execute-query` on the Go server (port 8080)
6. After execution, the response (in JSON format) will be returned to the Node.js backend server
7. The backend server caches the result if the query did not change the db state (determined by the `goServerResponse.data.db_changed` field provided by the Go server) **AND** the query does not contain any write operation e.g. `CREATE`, `DELETE`, `SET`, etc.
8. The result is sent back to the frontend page

#### Client Structure
* `client/frontend/` - React frontend
    * `src/index.js` - Render the root component App.js
    * `src/App.js` - Root component
    * `src/instance.js` - Create an axios instance for making HTTP requests to the Node.js backend
    * `Dockefile`, `nginx.conf` - Used for Docker

* `client/backend/` - Node.js backend
    * `server.js` - Entry point, keep listening on a specific port. Set up middleware, db driver, logger.
    * `routes/queries.js` - APIs
    * `output/` - After receiving the response from Go server, the server writes the response into file under this directory
    * `db/` - SQLite data (for caching response)
    * `antlr/` - C++ program, library, java tool, CMakeLists.txt used to compile the `checkGrammar` binary. Excecute `antlr/setup.sh` to compile the program. For more detail, see `antlr/README.md`.
    * `antlr/bin/grammarCheck` - A program used to check Cypher queries. Called withing API `/api/check-query`.
    * `Dockefile` - Used for Docker

#### POST /api/check-query
* req

    ``` json
    {
        "query": "Cypher query"
    }
    ```
* res (The "data" field will be stored in the cache, using the query as the key)
    ``` json
    {
        "status": "success",
        "message": "From Go server.",  => or "From Cache."
        "data": {
            "nodes": [
                {
                    "id": 17,
                    "labels": [
                        "Person"
                    ],
                    "properties": {
                        "age": 40,
                        "name": "Frank"
                    }
                },
                ... => List of nodes}
            ],
            "relationships": [
                {
                    "id": 29,
                    "start_id": 17,
                    "end_id": 14,
                    "type": "Knows",
                    "properties": {}
                },
                ... => List of relationships
            ],
            "paths": null => No path returned by this query
        }
    }
    ```

## 2. Demo
Client on AWS:
[**Cypher playground**](http://3.17.72.43/)

## 3. Set up using docker-compose
1. Create a `.env` file to store necessary env variables

    (Under `client/frontend/`, create a `.env` file like this)
    ```
    REACT_APP_API_ROOT=/api/
    ```
    (Under `client/backend/`, create a `.env` file like this)

    ```
    PORT=4000
    GRAMMAR_CHECK_PATH=bin/grammarCheck
    JSON_FILE_PATH=output/result.json
    GO_SERVER_API=http://<Go server IP>:8080/api/execute-query
    ```
2. Build images and run containers
    ``` bash
    docker-compose up --build -d
    ```
3. Stop and remove all containers
    ``` bash
    docker-compose down
    ```

p.s. Every time the client receives a JSON response from the Go server, it writes the resonse (JSON format) to the file: `client/backend/output/result.json`. The directory on the host machine is mounted into the backend container using the docker volume.

## 4. Set up by yourself
Make sure that you have generated the ANTLR C++ binary under `client/backend/antlr`
### 1. Execute setup.sh, it will:
    1. Install nvm, the Node Version Manager
    2. Install Node v18.18.0 using nvm
    3. Insatll yarn
    4. Install packages required by the web service
``` bash
bash ./setup.sh
```

### 2. Launch the web application
Under `client/`, launch the backend Node.js server
``` bash
yarn server
```
<img src='https://i.imgur.com/HaYSFME.png' width=70%>

On another terminal, under `client/`, launch the frontend React page
``` bash
yarn start
```
<img src='https://i.imgur.com/AxRIKlE.png' width=50%>

Open the web browser, go to `http://localhost:3000/`

<img src='https://i.imgur.com/oVyLsh8.png' width=80%>

## 5. Test
(Check `project/benchmark` to see the benchmark test)

To test the query using API, you can send POST request to: http://3.17.72.43/api/check-query, with "query" in the body (**in JSON format**):

<img src='https://i.imgur.com/a8v6pDS.png'>

I also built a series of API tests using Postman. In each test, it checks the response JSON data from the server using javascript. The test cases (in JSON format) are located under `client/test/`. Alternatively, you can check the online version I uploaded to [postman](https://cloudy-eclipse-520672.postman.co/workspace/Team-Workspace~8edbfb3a-e957-4683-8600-0af22addd11c/collection/21738163-5efc7074-5460-448b-afdf-f5a7f69bcb3a/overview?action=share&creator=21738163).

(The first and the last API call are executed to the Go server in order to initialize the test data.)

<img src='https://i.imgur.com/pFmmfV7.png'>

<img src='https://i.imgur.com/FVLVpta.png' width=80%>

## 6. Reference
Source NVM in shell script
* https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script