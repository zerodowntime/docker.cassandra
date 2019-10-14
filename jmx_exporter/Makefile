##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

CASSANDRA_VERSION ?= 3.11.4

IMAGE_NAME ?= zerodowntime/cassandra
IMAGE_TAG  ?= ${CASSANDRA_VERSION}-jmx_exporter

build: Dockerfile
	docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" \
		--build-arg "CASSANDRA_VERSION=${CASSANDRA_VERSION}" \
		.

push: build
	docker push "${IMAGE_NAME}:${IMAGE_TAG}"

clean:
	docker image rm "${IMAGE_NAME}:${IMAGE_TAG}"

runit: build
	docker run -it --rm "${IMAGE_NAME}:${IMAGE_TAG}"

inspect: build
	docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}"
