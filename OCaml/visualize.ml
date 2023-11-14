open Yojson.Basic.Util;;

(* Define types to represent nodes, relationships and paths *)
type node = {
  id: int;
  labels: string list;
  properties: Yojson.Basic.t;
}

type relationship = {
  id: int;
  start_id: int;
  end_id: int;
  rtype: string;
  properties: Yojson.Basic.t;
}

type path = {
  nodes: node list;
  relationships: relationship list;
}

(* Convert JSON to node type *)
let json_to_node json =
  {
    id = json |> member "id" |> to_int;
    labels = json |> member "labels" |> to_list |> filter_string;
    properties = json |> member "properties";
  }

(* Convert JSON to relationship type *)
let json_to_relationship json =
  {
    id = json |> member "id" |> to_int;
    start_id = json |> member "start_id" |> to_int;
    end_id = json |> member "end_id" |> to_int;
    rtype = json |> member "type" |> to_string;
    properties = json |> member "properties";
  }

(* Convert JSON to path type *)
let json_to_path json =
  {
    nodes = json |> member "nodes" |> to_list |> List.map json_to_node;
    relationships = json |> member "relationships" |> to_list |> List.map json_to_relationship;
  }

(* Convert JSON to node list *)
let json_to_node_list json =
  let nodes_json = json |> member "nodes" in
  if nodes_json = `Null then []
  else nodes_json |> to_list |> List.map json_to_node

(* Convert JSON to relationship list *)
let json_to_relationship_list json =
  let relationships_json = json |> member "relationships" in
  if relationships_json = `Null then []
  else relationships_json |> to_list |> List.map json_to_relationship

(* Convert JSON to path list *)
let json_to_path_list json =
  let paths_json = json |> member "paths" in
  if paths_json = `Null then []
  else paths_json |> to_list |> List.map json_to_path

(* Convert a node to string for printing *)
let node_to_string (n: node) =
  Printf.sprintf "Node ID: %d, Labels: [%s], Properties: %s"
  n.id
  (String.concat "; " n.labels)
  (Yojson.Basic.pretty_to_string n.properties)

(* Convert a relationship to string for printing *)
let relationship_to_string (r: relationship) =
  Printf.sprintf "Relationship ID: %d, Start ID: %d, End ID: %d, Type: %s, Properties: %s"
    r.id
    r.start_id
    r.end_id
    r.rtype
    (Yojson.Basic.pretty_to_string r.properties)

(* Convert a path to string for printing *)
let path_to_string (p: path) =
  let nodes_str = 
    p.nodes 
    |> List.map node_to_string 
    |> String.concat "\n" 
  in
  let relationships_str = 
    p.relationships 
    |> List.map relationship_to_string 
    |> String.concat "\n" 
  in
  Printf.sprintf "Nodes:\n%s\nRelationships:\n%s\n" nodes_str relationships_str

let () =
  (* Read and parse the JSON file *)
  let json = Yojson.Basic.from_file "../client/backend/output/result.json" in

  let nodes = json_to_node_list json in
  let relationships = json_to_relationship_list json in
  let paths = json_to_path_list json in

  (* Print each node *)
  Printf.printf "Number of nodes: %d\n" (List.length nodes);
  List.iter (fun n -> print_endline (node_to_string n)) nodes;
  print_endline "";
  (* Print each relationship *)
  Printf.printf "Number of relationships: %d\n" (List.length relationships);
  List.iter (fun r -> print_endline (relationship_to_string r)) relationships;
  print_endline "";
  (* Print each path *)
  Printf.printf "Number of paths: %d\n" (List.length paths);
  List.iter (fun p -> print_endline (path_to_string p)) paths;
