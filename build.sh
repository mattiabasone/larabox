#!/usr/bin/env bash

for PHP_VERSION in 7.4 8.0 8.1 8.2
do
	docker build . -f Dockerfile \
  --build-arg PHP_VERSION=${PHP_VERSION} \
  -t mattiabasone/larabox:${PHP_VERSION}

  docker push mattiabasone/larabox:${PHP_VERSION}
done