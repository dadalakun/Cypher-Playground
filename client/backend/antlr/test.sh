#!/bin/bash

echo "Simply pass some valid/invalid queries into the grammar-checking program."
echo "If it is a valid query, there will be no output. On the other hand, there will be standard error messages"

echo
echo "Test 1"
echo "Query(Valid): create (:Person {name: \"Alice\", age: 25});"
./build/grammarCheck "create (:Person {name: \"Alice\", age: 25});"

echo
echo "Test 2"
echo "Query(Valid): match (a :Person {name: \"Alice\"}) match (b: Person {name: \"Bob\"}) create (a)-[:knows {years: 3}]->(b);"
./build/grammarCheck "match (a :Person {name: \"Alice\"}) match (b: Person {name: \"Bob\"}) create (a)-[:knows {years: 3}]->(b);"

echo
echo "Test 3"
echo "Query(Valid): match ()-[e]-() return e;"
./build/grammarCheck "match ()-[e]-() return e;"

echo
echo "Test 4"
echo "Query(Invalid): Hello World!"
./build/grammarCheck "Hello World!"

echo
echo "Test 5"
echo "Query(Invalid): match (a :Person {name: \"Alice\"}) match (b: Person {name: \"Bob\"}) create (a -[:knows {years: 3}]->(b);"
./build/grammarCheck "match (a :Person {name: \"Alice\"}) match (b: Person {name: \"Bob\"}) create (a -[:knows {years: 3}]->(b);"

echo
echo "Test 6"
echo "Query(Invalid): match ()-[e]-() create;"
./build/grammarCheck "match ()-[e]-() create;"