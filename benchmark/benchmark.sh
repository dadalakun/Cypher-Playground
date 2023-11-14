#!/bin/bash

# Check if an arguments (iteration) is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 iterations"
    exit 1
fi
iterations=$1

# Array of queries
queries=(
    "MATCH (n) RETURN n"
    "MATCH (p:Person {name: 'Frank'}) SET p.age = 50 RETURN p"
)

# API endpoint
# API_ENDPOINT="http://localhost:4000/api/check-query"
API_ENDPOINT="http://3.18.178.249/api/check-query"

# Variables for overall average
total_avg_time=0
total_time=0

# Perform the iterations
for i in $(seq 1 $iterations); do
    iteration_total_time=0
    query_sent=0

    # Loop through queries until we sent 100 queries
    while [ $query_sent -lt 100 ]; do
        for query in "${queries[@]}"; do
            if [ $query_sent -ge 100 ]; then
                break
            fi
            time_taken=$(curl -o /dev/null -s -w '%{time_total}\n' -X POST -H "Content-Type: application/json" -d "{\"query\":\"$query\"}" "$API_ENDPOINT")
            iteration_total_time=$(echo "$iteration_total_time + $time_taken" | bc)
            ((query_sent++))
        done
    done

    # Calculate average for this iteration
    iteration_avg_time=$(echo "scale=4; $iteration_total_time / 100" | bc)
    echo "Total time for iteration $i: $iteration_total_time seconds"
    echo "Average time for queries in iteration $i: $iteration_avg_time seconds"

    total_avg_time=$(echo "$total_avg_time + $iteration_avg_time" | bc)
    total_time=$(echo "$total_time + $iteration_total_time" | bc)
done

# Calculate overall average time
overall_avg_time=$(echo "scale=4; $total_avg_time / $iterations" | bc)
echo "##############################"
echo "Total time: $total_time seconds"
echo "Overall average time for one query: $overall_avg_time seconds"
