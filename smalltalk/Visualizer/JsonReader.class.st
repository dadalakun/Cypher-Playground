Class {
	#name : #JsonReader,
	#superclass : #Object,
	#instVars : [
		'jsonData'
	],
	#category : #Visualizer
}

{ #category : #accessing }
JsonReader >> jsonData [
	"getter method for jsonData"
	^ jsonData
]

{ #category : #'as yet unclassified' }
JsonReader >> readFromFile: fileName [
	| jsonContent |
	jsonContent := fileName asFileReference readStream contents.
	jsonData := NeoJSONReader fromString: jsonContent asString.
]
