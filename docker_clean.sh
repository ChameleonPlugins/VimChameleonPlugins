#!/bin/bash
echo "#### BEFORE:"
docker images
echo "#### REMOVING dangling images..."
docker rmi $(docker images -f "dangling=true" -q)
echo "#### AFTER:"
docker images
