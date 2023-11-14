#!/bin/bash

curl -O https://www.antlr.org/download/antlr-4.13.0-complete.jar

mkdir build

cd build

cmake ../

make