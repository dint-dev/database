#!/bin/sh
set -e
cd `dirname $0`/..
protoc -I protos/ protos/datastore.proto --dart_out=grpc:lib/src/adapters/internal/protos