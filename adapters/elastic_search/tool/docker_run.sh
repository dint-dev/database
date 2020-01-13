#!/bin/sh
echo "------------------------"
echo "Starting ElasticSearch  "
echo "(this will take a while)"
echo "------------------------"
docker run \
  --name elastic_test \
  -p 9200:9200 \
  -p 9300:9300 \
  -e discovery.type=single-node \
  docker.elastic.co/elasticsearch/elasticsearch:7.5.1