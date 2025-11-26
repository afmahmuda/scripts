#!/bin/bash
# Get the CodeArtifact token
TOKEN=$(aws codeartifact get-authorization-token --domain edukita --domain-owner 742158775918 --region ap-southeast-1 --query authorizationToken --output text)

# Create or update .npmrc with both registries
cat > ~/.npmrc << EOL
@bitdev:registry=https://node-registry.bit.cloud
@teambit:registry=https://node-registry.bit.cloud
@learnbit:registry=https://node-registry.bit.cloud
@learnbit-react:registry=https://node-registry.bit.cloud
@frontend:registry=https://node-registry.bit.cloud

# CodeArtifact configuration
@edukita-bit:registry=https://edukita-742158775918.d.codeartifact.ap-southeast-1.amazonaws.com/npm/edukita-bit/
//edukita-742158775918.d.codeartifact.ap-southeast-1.amazonaws.com/npm/edukita-bit/:_authToken=${TOKEN}

# Fallback to npm registry
registry=https://registry.npmjs.org/
EOL

echo "npm configuration updated successfully!"