Class {
	#name : #Node,
	#superclass : #Object,
	#instVars : [
		'id',
		'labels',
		'properties'
	],
	#category : #Visualizer
}

{ #category : #adding }
Node >> addLabel: aLabel [
	"Add a label to the labels list"
	labels add: aLabel.
]

{ #category : #accessing }
Node >> getProperty: aKey [
	"Return a value based on key"
	^ properties at: aKey ifAbsent: [ nil ]
]

{ #category : #accessing }
Node >> id [
	"Id getter"
	^ id
]

{ #category : #accessing }
Node >> id: anId [
	"Id setter"
	id := anId.
]

{ #category : #initialization }
Node >> initialize [
	super initialize.
	labels := OrderedCollection new.
	properties := Dictionary new.
]

{ #category : #accessing }
Node >> labels [
	"labels getter"
	^ labels
]

{ #category : #accessing }
Node >> labels: aCollection [
	"labels setter"
	labels := aCollection.
]

{ #category : #accessing }
Node >> properties [
	"properties getter"
	^ properties
]

{ #category : #accessing }
Node >> properties: aDictionary [
	"properties setter"
	properties := aDictionary.
]

{ #category : #initialization }
Node >> setProperty: aKey to: aValue [
	"Add a key-value pair to the props dictionary"
	properties at: aKey put: aValue.
]
