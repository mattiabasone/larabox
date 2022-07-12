#!/usr/bin/env bash

for PHP_VERSION in 5.6 7.0 7.1 7.2 7.4 8.0 8.1
do
	docker build . -f Dockerfile \
  --build-arg PHP_VERSION=${PHP_VERSION} \
  -t mattiabasone/larabox:${PHP_VERSION}

  docker push mattiabasone/larabox:${PHP_VERSION}
done