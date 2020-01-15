#!/bin/sh
set -e
cd `dirname $0`/..

docker run --name some-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=database_test_user \
  -e POSTGRES_PASSWORD=database_test_password \
  -e POSTGRES_DB=test \
  -d postgres