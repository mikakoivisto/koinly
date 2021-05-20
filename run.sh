#!/bin/sh

docker run -t --rm -v "$(PWD):/app" -w /app koinly-ruby:latest "$@"