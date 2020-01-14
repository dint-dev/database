#!/bin/sh
set -e
cd `dirname $0`/..
protoc -I protos/ protos/database.proto --dart_out=grpc:lib/src/generated/