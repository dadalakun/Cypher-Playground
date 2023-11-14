Class {
	#name : #Relationship,
	#superclass : #Object,
	#instVars : [
		'id',
		'startId',
		'endId',
		'type',
		'properties'
	],
	#category : #Visualizer
}

{ #category : #accessing }
Relationship >> endId [
	 ^ endId
]

{ #category : #accessing }
Relationship >> endId: anId [
	endId := anId.
]

{ #category : #accessing }
Relationship >> getProperty: aKey [
	^ properties at: aKey ifAbsent: [ nil ]
]

{ #category : #accessing }
Relationship >> id [
	^ id
]

{ #category : #accessing }
Relationship >> id: anId [
	id := anId.
]

{ #category : #initialization }
Relationship >> initialize [
	super initialize.
	properties := Dictionary new.
]

{ #category : #accessing }
Relationship >> properties [
	^ properties
]

{ #category : #accessing }
Relationship >> properties: aDictionary [
	properties := aDictionary.
]

{ #category : #initialization }
Relationship >> setProperty: aKey to: aValue [
	properties at: aKey put: aValue.
]

{ #category : #accessing }
Relationship >> startId [
	^ startId
]

{ #category : #accessing }
Relationship >> startId: anId [
	startId := anId.
]

{ #category : #accessing }
Relationship >> type [
	^ type
]

{ #category : #accessing }
Relationship >> type: aType [
	type := aType.
]
