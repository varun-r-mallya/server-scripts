#!/bin/bash

# List your service directories here (full paths or relative paths)
services=(
  "/home/xeon/management/monitoring"
  "/home/xeon/management/seanime"
  "/home/xeon/management/gitea"
)

#echo "Reducing brightness"
#/home/xeon/control/brightness.py 0

echo "🚀 Starting selected Docker Compose stacks..."

for dir in "${services[@]}"; do
  if [ -d "$dir" ] && [ -f "$dir/docker-compose.yml" ]; then
    echo "➡️  Starting stack in $dir"
    (cd "$dir" && docker compose up -d)
  else
    echo "⚠️  Skipping $dir — not a valid Docker Compose directory"
  fi
done

echo "✅ All listed stacks processed."

