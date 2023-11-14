Class {
	#name : #GraphVisualizer,
	#superclass : #Object,
	#instVars : [
		'graph',
		'canvas',
		'nodeDict'
	],
	#category : #Visualizer
}

{ #category : #initialization }
GraphVisualizer >> initialize [
	super initialize.
	nodeDict := Dictionary new.
]

{ #category : #'as yet unclassified' }
GraphVisualizer >> visualizeGraph: aGraph [
	| nodeElements edgeElements |
	"Take a graph, render it on the canvas"
	graph := aGraph.
	canvas := RSCanvas new.
	nodeDict := Dictionary new.
	
	"Visualize nodes"
	nodeElements := graph nodes collect: [ :node |
		| element infoStr labelStr propStr |
		"Build a label (string) from the information"
		labelStr := ',' join: node labels.
		propStr := OrderedCollection new.
		node properties associationsDo: [ :assoc |
			propStr add:assoc key, ': ', assoc value asString
		].
		infoStr := 'NODE { ID: ', node id asString,
						' Labels: [', labelStr, ']',
						' Props: {', (', ' join: propStr), '} }'.
		element := RSEllipse new color: Color lightBrown; model: infoStr.
		"Attach a label"
		element @ (RSLabeled new fontSize: 3; text: ('ID: ', node id asString)).
		"Store element into dictionary for linking the relationship later"
		nodeDict at: node id put: element.
		element.
    ] as: RSGroup.
	nodeElements @ RSPopup.
	RSCircleLayout on: nodeElements.

	"Visualize relationships"
	edgeElements := graph relationships collect: [ :relationship |
		| element startNode infoStr  propStr endNode |
		startNode := nodeDict at: relationship startId ifAbsent: [ nil ].
		endNode := nodeDict at: relationship endId ifAbsent: [ nil ].
		"Skip this edge if either startNode or endNode is nil"
		(startNode isNil or: [ endNode isNil ]) ifTrue: [ ^nil ].
		
		propStr := OrderedCollection new.
		relationship properties associationsDo: [ :assoc |
			propStr add:assoc key, ': ', assoc value asString
		].
		infoStr := 'EDGE { ID: ', relationship id asString,
						' Start: ', relationship startId asString,
						' End: ', relationship endId asString,
						' Type: ', relationship type,
						' Props: {', (', ' join: propStr), '} }'.
		element := RSArrowedLine new width: 2; from: startNode; to: endNode; model: infoStr.
		element.
	] as: RSGroup.
	edgeElements @ RSPopup.
	
	canvas addAll: nodeElements.
	canvas addAll: edgeElements.
	canvas @ RSCanvasController.
	canvas open.

]
