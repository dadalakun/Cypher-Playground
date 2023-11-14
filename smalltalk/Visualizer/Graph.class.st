Class {
	#name : #Graph,
	#superclass : #Object,
	#instVars : [
		'nodes',
		'relationships'
	],
	#category : #Visualizer
}

{ #category : #adding }
Graph >> addNode: aNode [
	"Add a node into the graph"
	nodes add: aNode.
]

{ #category : #adding }
Graph >> addRelationship: aRelationship [
	"Add an edge to the graph"
	relationships add: aRelationship.
]

{ #category : #initialization }
Graph >> initialize [
	super initialize.
	nodes := OrderedCollection new.
	relationships := OrderedCollection new.
]

{ #category : #accessing }
Graph >> nodes [
	^ nodes
]

{ #category : #accessing }
Graph >> relationships [
	^ relationships
]
