#!/bin/bash

# Get current user and group IDs
export UID=$(id -u)
export GID=$(id -g)

# Print the IDs for verification
echo "Setting user IDs for Docker development:"
echo "UID=$UID"
echo "GID=$GID"

# Update .env file with current user IDs
sed -i "s/^UID=.*/UID=$UID/" .env
sed -i "s/^GID=.*/GID=$GID/" .env

echo "Updated .env file with current user IDs"
echo "You can now run: ./manage.sh dev start"
