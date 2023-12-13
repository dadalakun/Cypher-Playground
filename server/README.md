# Go Server

## 1. Introduction
A Go backend which receives Cypher queries, executes using Neo4j Go driver and returns the execution results in JSON format. This is a quick overview of the process:

1. The user enters a Cypher query (either valid or invalid) and presses 'QUERY' button
2. The frontend passes the query to the API at `/api/check-query` on the Node.js backend server (port 4000)
3. The backend server validates the query using ANTLR by calling a C++ binary
4. If it passes the validation, the backend checks whether the query is already in the SQLite cache
5. If not, the backend calls the API at `/api/execute-query` on the Go server (port 8080)
6. After execution, the response (in JSON format) will be returned to the Node.js backend server
7. The backend server caches the result if the query did not change the db state (determined by the `goServerResponse.data.db_changed` field provided by the Go server) **AND** the query does not contain any write operation e.g. `CREATE`, `DELETE`, `SET`, etc.
8. The result is sent back to the frontend page

### Server Structure
* `main.go` - Entry point, keep listening on a specific port. Set up db driver, logger and pass to the api handlers.
* `app/app.go` - Define a struct for storing the global instances like db driver and logger
* `routes/routes.go` - Define APIs. Interact with Neo4j server
* `Dockefile`, `docker-compose.yml` - Used to deploy Neo4j server and Go server

#### POST /api/execute-query
* req

    ``` json
    {
        "query": "Cypher query"
    }
    ```
* res

    ``` json
    {
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
                ... => List of nodes
            ],
            "relationships": null, => No relationship returned by this query
            "paths": null => No path returned by this query
        },
        "db_changed": false, => The query changed the graph in the db
        "message": "Executed query successfully: MATCH (a:Person)-[r:Knows]->(b:Person {name: \"Zaren\"}) RETURN a",
        "status": "success"
    }
    ```
* Note

    At this point, the server supports three kinds of data fields (nodes, relationships, paths) in the response JSON. A query that involves any other kinds of return data, for example, `match (p:Person) return p.name, p.age`, will be executed but will not return a result asked by the query.
    ``` json
    {
        "data": {
            "nodes": null,
            "relationships": null,
            "paths": null
        },
        "db_changed": false,
        "message": "Executed query successfully: match (p:Person) return p.name, p.age",
        "status": "success"
    }
    ```

## 2. Demo
Client on AWS:
[**Cypher playground**](http://3.17.72.43/)

## 3. Set up using docker-compose
1. Build images and run containers

    ``` bash
    docker-compose up --build -d
    ```
2. Stop and remove all containers
    ``` bash
    docker-compose down
    ```

## 4. Set up by yourself
1. Launch a Neo4j Server in the background

    ```bash
    wget --content-disposition https://neo4j.com/artifact.php\?name\=neo4j-community-4.4.25-unix.tar.gz

    tar xfz neo4j-community-4.4.25-unix.tar.gz

    ./neo4j-community-4.4.25/bin/neo4j start
    ```
2. Put your password in main.go
    ```go
	neo4jPassword := getEnvWithDefault("NEO4J_PASSWORD", "YOUR_PASSWORD")
    ```

3. Launch the Go backend
    ``` bash
    go run main.go
    ```
    <img src='https://i.imgur.com/sBfwYqJ.png'>

## 5. Test
To test the query using API, you can send POST request to: http://3.133.111.194:8080/api/execute-query, with "query" in the body (**in JSON format**):

<img src='https://i.imgur.com/4smwVlC.png'>

Just like client component, I also built a series of API tests using Postman for the Go server. In each test, it checks the response JSON data from the server using javascript. The test cases (in JSON format) are located under `server/test/`. Alternatively, you can check the online version I uploaded to [postman](https://cloudy-eclipse-520672.postman.co/workspace/Team-Workspace~8edbfb3a-e957-4683-8600-0af22addd11c/collection/21738163-21919543-57f5-42aa-bd1b-149077f01141?action=share&creator=21738163).

<img src='https://i.imgur.com/jh940ZM.png'>

<img src='https://i.imgur.com/malfjt0.png'>

## 6. Reference
Neo4j Go Driver Manual
* https://neo4j.com/docs/go-manual/4.4/

Neo4j source code
* https://github.com/neo4j/neo4j-go-driver/tree/4.4

Transaction Func vs Auto-commit Func
* https://community.neo4j.com/t/difference-between-session-run-and-session-readtransaction-or-session-writetransaction/14720/3

Create One Driver Instance Once and Hold Onto It
* https://neo4j.com/developer-blog/neo4j-driver-best-practices/

Neo4j Driver SummaryCounters
* https://neo4j.com/docs/api/java-driver/current/org.neo4j.driver/org/neo4j/driver/summary/SummaryCounters.html