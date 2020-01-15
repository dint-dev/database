#!/bin/sh
set -e
cd `dirname $0`/..
docker stop some-postgres
docker rm some-postgres