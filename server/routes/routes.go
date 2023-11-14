package routes

import (
	"encoding/json"
	"fmt"
	"github.com/neo4j/neo4j-go-driver/v4/neo4j"
	"github.com/pp-tc35859/project/server/app"
	"net/http"
	"strings"
)

type QueryRequest struct {
	Query string `json:"query"`
}

// Define result type used to hold nodes and relationships
// (Support three types of data)
type ResultData struct {
	Nodes         []NodeData         `json:"nodes"`
	Relationships []RelationshipData `json:"relationships"`
	Paths         []PathData         `json:"paths"`
}

type NodeData struct {
	ID     int64                  `json:"id"`
	Labels []string               `json:"labels"`
	Props  map[string]interface{} `json:"properties"`
}

type RelationshipData struct {
	ID      int64                  `json:"id"`
	StartId int64                  `json:"start_id"`
	EndID   int64                  `json:"end_id"`
	Type    string                 `json:"type"`
	Props   map[string]interface{} `json:"properties"`
}

type PathData struct {
	Nodes         []NodeData         `json:"nodes"`
	Relationships []RelationshipData `json:"relationships"`
}

// Execute a Cypher query (POST /api/execute-query)
func ExecuteQueryHandler(w http.ResponseWriter, r *http.Request, app *app.App) {
	// Only handle POST request
	if r.Method != http.MethodPost {
		app.Log.Error("Not a POST request")
		http.Error(w, "Not a POST request", http.StatusMethodNotAllowed)
		return
	}

	decoder := json.NewDecoder(r.Body)
	var req QueryRequest
	// Request body cannot be parsed into QueryRequest struct
	err := decoder.Decode(&req)
	if err != nil {
		app.Log.Error("Bad request")
		http.Error(w, "Bad request", http.StatusBadRequest)
		return
	}
	// Check if query is empty
	if req.Query == "" || strings.TrimSpace(req.Query) == "" {
		app.Log.Error("Query field is missing or empty")
		http.Error(w, "Query field is missing or empty", http.StatusBadRequest)
		return
	}
	app.Log.Info("Received query: " + req.Query)

	// Used to store result (Nodes, Relationships and Paths)
	var resultData ResultData
	// Whether the db was changed
	var dbChanged bool

	// Execute query in neo4j
	session := app.Driver.NewSession(neo4j.SessionConfig{})
	defer session.Close()
	_, err = session.WriteTransaction(func(tx neo4j.Transaction) (interface{}, error) {
		result, err := tx.Run(req.Query, nil)
		if err != nil {
			return nil, err
		}

		for result.Next() {
			record := result.Record()
			for _, value := range record.Values {
				switch v := value.(type) {
				case neo4j.Node:
					nodeData := NodeData{
						ID:     v.Id,
						Labels: v.Labels,
						Props:  v.Props,
					}
					resultData.Nodes = append(resultData.Nodes, nodeData)
				case neo4j.Relationship:
					relationshipData := RelationshipData{
						ID:      v.Id,
						StartId: v.StartId,
						EndID:   v.EndId,
						Type:    v.Type,
						Props:   v.Props,
					}
					resultData.Relationships = append(resultData.Relationships, relationshipData)
				case neo4j.Path:
					var pathData PathData
					// Fetch nodes in the path
					for _, node := range v.Nodes {
						nodeData := NodeData{
							ID:     node.Id,
							Labels: node.Labels,
							Props:  node.Props,
						}
						pathData.Nodes = append(pathData.Nodes, nodeData)
					}
					// Fetch relationships in the path
					for _, rel := range v.Relationships {
						relationshipData := RelationshipData{
							ID:      rel.Id,
							StartId: rel.StartId,
							EndID:   rel.EndId,
							Type:    rel.Type,
							Props:   rel.Props,
						}
						pathData.Relationships = append(pathData.Relationships, relationshipData)
					}
					resultData.Paths = append(resultData.Paths, pathData)
				case []interface{}:
					// Match return value that contains slice of Nodes or Relationships
					for _, item := range v {
						switch itemType := item.(type) {
						case neo4j.Node:
							nodeData := NodeData{
								ID:     itemType.Id,
								Labels: itemType.Labels,
								Props:  itemType.Props,
							}
							resultData.Nodes = append(resultData.Nodes, nodeData)

						case neo4j.Relationship:
							relationshipData := RelationshipData{
								ID:      itemType.Id,
								StartId: itemType.StartId,
								EndID:   itemType.EndId,
								Type:    itemType.Type,
								Props:   itemType.Props,
							}
							resultData.Relationships = append(resultData.Relationships, relationshipData)
						}
					}
				default:
					app.Log.Warn("Does not support this type of return value")
				}
			}
		}
		// Get the summary of the result
		summary, err := result.Consume()
		// Get the counters from the summary
		counters := summary.Counters()
		// Check if any changes were made to the database
		dbChanged = counters.ContainsSystemUpdates() || counters.ContainsUpdates()

		if dbChanged {
			app.Log.Info("DB state changed")
		}
		return nil, result.Err()
	})

	if err != nil {
		app.Log.Error("Error executing query: ", err)
		http.Error(w, "Error executing query", http.StatusBadRequest)
		return
	}

	responseData := map[string]interface{}{
		"status":     "success",
		"message":    fmt.Sprintf("Executed query successfully: %s", req.Query),
		"data":       resultData,
		"db_changed": dbChanged,
	}
	jsonResponse, err := json.Marshal(responseData)

	if err != nil {
		app.Log.Error("Failed to generate JSON response")
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	app.Log.Info("Response: ", string(jsonResponse))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}

// Return nodes and relationships in the graph (GET /api/graph/all)
func FetchDataHandler(w http.ResponseWriter, r *http.Request, app *app.App) {
	// Only handle GET request
	if r.Method != http.MethodGet {
		app.Log.Error("Not a GET request")
		http.Error(w, "Not a GET request", http.StatusMethodNotAllowed)
		return
	}

	// Initialize new session
	session := app.Driver.NewSession(neo4j.SessionConfig{})
	defer session.Close()

	// Used to store result (Nodes, Relationships)
	var resultData ResultData
	// Fetch Nodes
	result, err := session.ReadTransaction(func(tx neo4j.Transaction) (interface{}, error) {
		result, err := tx.Run("MATCH (n) RETURN n", nil)
		if err != nil {
			return nil, err
		}
		var nodes []NodeData

		for result.Next() {
			node := result.Record().Values[0]
			if n, ok := node.(neo4j.Node); ok {
				nodeData := NodeData{
					ID:     n.Id,
					Labels: n.Labels,
					Props:  n.Props,
				}
				nodes = append(nodes, nodeData)
			}
		}
		return nodes, nil
	})
	if err != nil {
		app.Log.Error("Failed to fetch Nodes from db")
		http.Error(w, "Failed to fetch Nodes from database", http.StatusInternalServerError)
		return
	}
	resultData.Nodes = result.([]NodeData)

	// Fetch Relationships
	result, err = session.ReadTransaction(func(tx neo4j.Transaction) (interface{}, error) {
		result, err := tx.Run("MATCH ()-[r]->() RETURN r", map[string]interface{}{})
		if err != nil {
			return nil, err
		}

		var relationships []RelationshipData

		for result.Next() {
			relationship := result.Record().Values[0]
			if n, ok := relationship.(neo4j.Relationship); ok {
				relationshipData := RelationshipData{
					ID:      n.Id,
					StartId: n.StartId,
					EndID:   n.EndId,
					Type:    n.Type,
					Props:   n.Props,
				}
				relationships = append(relationships, relationshipData)
			}
		}
		return relationships, nil
	})
	if err != nil {
		app.Log.Error("Failed to fetch Relationships from db")
		http.Error(w, "Failed to fetch Relationships from database", http.StatusInternalServerError)
		return
	}
	resultData.Relationships = result.([]RelationshipData)

	app.Log.Info("Fetched data successfully")
	// Prepare the response data
	responseData := map[string]interface{}{
		"status":  "success",
		"message": fmt.Sprintf("Fetched %d nodes and %d relationships", len(resultData.Nodes), len(resultData.Relationships)),
		"data":    resultData,
	}
	jsonResponse, err := json.Marshal(responseData)

	if err != nil {
		app.Log.Error("Failed to generate JSON response")
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	app.Log.Info("Response: ", string(jsonResponse))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}

// Clear Neo4j db (POST /api/graph/clear)
func ClearDbHandler(w http.ResponseWriter, r *http.Request, app *app.App) {
	// Only handle POST request
	if r.Method != http.MethodPost {
		app.Log.Error("Not a POST request")
		http.Error(w, "Not a POST request", http.StatusMethodNotAllowed)
		return
	}

	// Initialize new session
	session := app.Driver.NewSession(neo4j.SessionConfig{})
	defer session.Close()

	// Execute a Cypher query to delete all nodes and relationships
	_, err := session.WriteTransaction(func(transaction neo4j.Transaction) (interface{}, error) {
		return transaction.Run("MATCH (n) DETACH DELETE n", nil)
	})
	if err != nil {
		app.Log.Error("Failed to clear database")
		http.Error(w, "Failed to clear database", http.StatusInternalServerError)
		return
	}
	app.Log.Info("Database cleared successfully")
	// Send a success response
	responseData := map[string]interface{}{
		"status":  "success",
		"message": "Database cleared successfully",
	}
	jsonResponse, err := json.Marshal(responseData)
	if err != nil {
		app.Log.Error("Failed to generate JSON response")
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	app.Log.Info("Response: ", string(jsonResponse))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}

// Clear the current data and generates test data in the Neo4j db
// (POST /api/graph/populate-test-data)
func GenerateTestDataHandler(w http.ResponseWriter, r *http.Request, app *app.App) {
	// Only handle POST request
	if r.Method != http.MethodPost {
		app.Log.Error("Not a POST request")
		http.Error(w, "Not a POST request", http.StatusMethodNotAllowed)
		return
	}

	// Initialize new session
	session := app.Driver.NewSession(neo4j.SessionConfig{})
	defer session.Close()

	// Execute a transaction to clear and create test data
	_, err := session.WriteTransaction(func(transaction neo4j.Transaction) (interface{}, error) {
		// Clear existing data
		_, err := transaction.Run("MATCH (n) DETACH DELETE n", nil)
		if err != nil {
			return nil, err
		}

		// Create test data
		createQuery := `
		CREATE (p1:Person {name: "Alice", age: 30})
		CREATE (p2:Person {name: "Bob", age: 24})
		CREATE (p3:Person {name: "Zaren", age: 24})
		CREATE (p4:Person {name: "David", age: 29})
		CREATE (p5:Person {name: "Amy", age: 35})
		CREATE (p6:Person {name: "Frank", age: 40})
		CREATE (p1)-[:Knows]->(p2)
		CREATE (p1)-[:Knows]->(p3)
		CREATE (p2)-[:Knows]->(p3)
		CREATE (p2)-[:Knows]->(p4)
		CREATE (p3)-[:Knows]->(p4)
		CREATE (p4)-[:Knows]->(p5)
		CREATE (p5)-[:Knows]->(p6)
		CREATE (p6)-[:Knows]->(p1)
		CREATE (p6)-[:Knows]->(p2)
		CREATE (p6)-[:Knows]->(p3)
		`
		_, err = transaction.Run(createQuery, nil)
		return nil, err
	})
	// Handle potential errors
	if err != nil {
		app.Log.Error("Failed to generate test data")
		http.Error(w, "Failed to generate test data", http.StatusInternalServerError)
		return
	}
	app.Log.Info("Test data generated successfully")

	// Send a success response
	responseData := map[string]interface{}{
		"status":  "success",
		"message": "Test data generated successfully",
	}
	jsonResponse, err := json.Marshal(responseData)
	if err != nil {
		app.Log.Error("Failed to generate JSON response")
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	app.Log.Info("Response: ", string(jsonResponse))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}
