#!/bin/bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Source nvm
. ~/.nvm/nvm.sh

# Use nvm to install node
nvm install v18.18.0

# Use npm to install yarn
npm install --global yarn

# Use yarn to install packages
cd backend
yarn install

cd ../frontend
yarn install