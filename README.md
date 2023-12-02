# Cypher Playground

<img src='https://i.imgur.com/CNNU4zD.png' width='60%'>

## Introduction
Cypher Playground is a tool to access a remote Neo4j Graph database. After receiving query from the user (React, Node.js), it checks the query (C++), sends to the remote server (GO), executes it and gives back the response in JSON format. The system also provides two kinds of visulaizer (OCaml, Smalltalk) that display the result in a more readable way.

Client on AWS:
[**Cypher playground**](http://3.18.178.249/)

## Components

This section describes components of the system.

```
 ---------        -------------
| client  |----->| visualizer  |
 ---------        -------------
   ^
   |
   v
 ---------
| server  |
 ---------
   ^
   |
   v
 ----------
| database |
 ----------
```

* client - client application that has API for sending
  queries/requests to server
  * Frontend: Web page that receives Cypher queries
  * Backen: Validate the query and send request to server

* server - server dealing with requests and manipulating db

* database - graph database

* visualizer - (in a way part of the client) to visualize the result

**For more information about each component, check out the README.md file under each component.**

## Languages and tools

#### Client: React, Node.js, C++, ANTLR (lexer and parser), SQLite (For caching)
#### Server: Go, Neo4j
#### Visualizer: OCaml, Smalltalk
#### Deployment: Docker, AWS EC2
#### Test: Shell Script (chech out benchmark/), Postman