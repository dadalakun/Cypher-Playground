package main

import (
	"github.com/neo4j/neo4j-go-driver/v4/neo4j"
	"github.com/pp-tc35859/project/server/app"
	"github.com/pp-tc35859/project/server/routes"
	"github.com/sirupsen/logrus"
	"net/http"
	"os"
)

// Try to fetch env variables from dockerfile, otherwise use the
// default value
func getEnvWithDefault(key string, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

func main() {
	// Initialize the Logger
	log := logrus.New()
	log.SetFormatter(&logrus.JSONFormatter{}) // Output as JSON
	log.SetLevel(logrus.InfoLevel)            // Set log level to Info

	// Initialize the Neo4j driver
	neo4jURI := getEnvWithDefault("NEO4J_URI", "bolt://localhost:7687")
	neo4jUser := getEnvWithDefault("NEO4J_USER", "neo4j")
	neo4jPassword := getEnvWithDefault("NEO4J_PASSWORD", "dadalakun25")
	driver, err := neo4j.NewDriver(neo4jURI, neo4j.BasicAuth(neo4jUser, neo4jPassword, ""))
	if err != nil {
		log.Fatal("Error connecting to Neo4j:", err)
	}
	defer driver.Close()

	// Global instances
	app := &app.App{
		Driver: driver,
		Log:    log,
	}

	setupRoutes(app)

	app.Log.Info("Server is up on port 8080..")
	http.ListenAndServe(":8080", nil)
}

func setupRoutes(app *app.App) {
	http.HandleFunc("/api/execute-query", func(w http.ResponseWriter, r *http.Request) {
		routes.ExecuteQueryHandler(w, r, app)
	})
	http.HandleFunc("/api/graph/all", func(w http.ResponseWriter, r *http.Request) {
		routes.FetchDataHandler(w, r, app)
	})
	http.HandleFunc("/api/graph/clear", func(w http.ResponseWriter, r *http.Request) {
		routes.ClearDbHandler(w, r, app)
	})
	http.HandleFunc("/api/graph/populate-test-data", func(w http.ResponseWriter, r *http.Request) {
		routes.GenerateTestDataHandler(w, r, app)
	})
}
