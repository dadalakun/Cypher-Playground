Class {
	#name : #JsonParser,
	#superclass : #Object,
	#category : #Visualizer
}

{ #category : #parsing }
JsonParser >> parseJson: jsonData [
	"Take JSON data as input, return a graph"
	| graph nodesData relationshipsData |
	graph := Graph new.
	nodesData := jsonData at: 'nodes'.
	nodesData ifNil: [ nodesData := #() ].
	relationshipsData := jsonData at: 'relationships'.
	relationshipsData ifNil: [ relationshipsData := #() ].
	
	"Parse nodes"
    nodesData do: [ :nodeData |
        | node |
        node := Node new.
        node id: (nodeData at: 'id').
        node labels: ((nodeData at: 'labels') ifNotNil: [ :labels | labels asOrderedCollection ]).
        (nodeData at: 'properties') keysAndValuesDo: [ :key :value |
            node setProperty: key to: value ].
        graph addNode: node
    ].

    "Parse relationships"
    relationshipsData do: [ :relationshipData |
        | relationship |
        relationship := Relationship new.
        relationship id: (relationshipData at: 'id').
        relationship startId: (relationshipData at: 'start_id').
        relationship endId: (relationshipData at: 'end_id').
        relationship type: (relationshipData at: 'type').
        (relationshipData at: 'properties') keysAndValuesDo: [ :key :value |
            relationship setProperty: key to: value ].
        graph addRelationship: relationship
    ].

	^ graph
	

]
