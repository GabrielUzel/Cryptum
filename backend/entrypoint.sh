#!/bin/sh
set -e

echo "Waiting for MySQL to be ready..."

wait_for_mysql() {
  max_tries=30
  count=0

  while [ $count -lt $max_tries ]; do
    if nc -z ${MYSQL_HOST} ${MYSQL_PORT} 2>/dev/null; then
      echo "MySQL is ready!"
      return 0
    fi

    echo "MySQL is unavailable - sleeping (attempt $((count+1))/$max_tries)"
    sleep 2
    count=$((count+1))
  done

  echo "MySQL did not become ready in time"
  return 1
}

if ! wait_for_mysql; then
  exit 1
fi

echo "Starting application..."
exec "$@"
