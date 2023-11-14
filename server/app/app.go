package app

import (
	"github.com/neo4j/neo4j-go-driver/v4/neo4j"
	"github.com/sirupsen/logrus"
)

type App struct {
	Driver neo4j.Driver
	Log    *logrus.Logger
}
