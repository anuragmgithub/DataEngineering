#!/bin/bash

docker build -t pyspark-scheduled-job:latest .
docker images | grep pyspark-scheduled-job
