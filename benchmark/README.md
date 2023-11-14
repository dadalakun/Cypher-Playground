# Benchmark
(Graduate version only)
A bash script that sends queries to the API and collects response times.

## 1. Execution
The IP address 3.18.178.249 is the remote server where I deployed the client component. You can choose to test on a local version.
``` bash
#!/bin/bash
...
# API endpoint
API_ENDPOINT="http://localhost:4000/api/check-query"
# API_ENDPOINT="http://3.18.178.249/api/check-query"
...
```

Place the queries you want to test in the queries array. At the start of each iteration, the script will send the 1st query, followed by the 2nd one, and then the 3rd. If it reaches the end of the array, it will loop back to send the 1st query again, continuing in this manner until it has sent 100 queryies.

The iteration number provided by the user indicates how many times this step should be performed.
``` bash
#!/bin/bash
...
queries=(
    "MATCH (n) RETURN n"
    "MATCH (p:Person {name: 'Frank'}) SET p.age = 50 RETURN p"
    "query3"
    "query4"
    ...
)
...
```

Make sure to launch both the client Node.js server and the backend Go server, then run the script.

``` bash
bash benchmark.sh 5
```

## 2. Demo
1. Test local server with a same query

    ``` bash
    #!/bin/bash
    ...
    queries=("MATCH (n) RETURN n")
    ...
    ```
    <img src='https://i.imgur.com/1uSzc3O.png'>

2. Test local server with different queries (Invalidate the cache every time)
    ``` bash
    #!/bin/bash
    ...
    # Since the 2nd query change the Neo4j db state, the client will invalidate the cache
    queries=(
        "MATCH (n) RETURN n"
        "MATCH (p:Person {name: 'Frank'}) SET p.age = 50 RETURN p"
    )
    ...
    ```
    <img src='https://i.imgur.com/JQIXN03.png'>

3. Test remote server

    <img src='https://i.imgur.com/wQexUAx.png'>

4. Test remote server (Invalidate the cache every time)

    <img src='https://i.imgur.com/OGBnvQQ.png'>

In conclusion, when we send a query to the remote client server, it needs to send the query to the actual Go server on another remote server, making it more time-consuming than the local case.
