# OCaml Visualizer

## 1. Prerequisite
- OCaml installed *OR*
- Docker

## 2. Running the program
### Compile and run the binary
1. Set necessary environment varaibles before using OCaml tools like ocamlfind and ocamlopt
    ``` bash
    eval $(opam env)
    ```
2. Install yojson (used to parse json file)

    ``` bash
    opam install yojson.2.1.0
    ```
3. Find the path of yojson library
    ``` bash
    ocamlfind query yojson
    ```
4. Put a valid source file path (The default output json file of client component is at project/backend/output/result.json)
    ``` ocaml
    ...
    let () =
        (* Read and parse the JSON file *)
        let json = Yojson.Basic.from_file "../client/backend/output/result.json" in
    ...
    ```
5. Compile the program with proper library linking
    ``` bash
    ocamlopt -o visualize -I <output of step three> yojson.cmxa visualize.ml
    ```
6. Execute the binary
    ``` bash
    ./visualize
    ```
    <img src='https://i.imgur.com/QmAuJhn.png'>

### Use Docker
1. Change the source file directory
    ``` ocaml
    ...
    let () =
        (* Read and parse the JSON file *)
        let json = Yojson.Basic.from_file "./data/result.json" in
    ...
    ```

2. Build image (Will take some time)

    ``` bash
    docker build -t visualize-ocaml .
    ```

3. Run the container and attach it to the shell. Replace `/home/ec2-user/pp-tc35859/project/client/backend/output` with the absolute path on the host machine which has the output file (should be named result.json).
    ``` bash
    docker run -it -v /home/ec2-user/pp-tc35859/project/client/backend/output:/app/data visualize-ocaml
    ```

4. Execute the binary
    ``` bash
    ./visualize
    ```
    <img src='https://i.imgur.com/Lh842nw.png'>

5. Leave the container using ctrl-d

6. If you want to run the container again
    ``` bash
    docker start [CONTAINER_ID_OR_NAME]
    docker exec -it [CONTAINER_ID_OR_NAME] sh
    ```

## Reference
YoJSON
* https://dev.realworldocaml.org/json.html