TAG = $(shell git tag --sort=committerdate | tail -1)
URL = gitlab.lrz.de:5005/messtechnik-labor/docker

format:
	docker run --pull=always --rm -v "${PWD}:/app" -e UID="$(shell id -u)" \
		${URL}/format:latest

lint:
	docker run --pull=always --rm -v "${PWD}:/app" \
		${URL}/lint:latest

create-builder:
	docker buildx rm tmp-builder
	docker buildx create --use --name=tmp-builder --platform linux/arm64,linux/amd64

build-dockerhub: create-builder
	docker buildx build --push --platform linux/arm64,linux/amd64 \
		--tag behretv/lint:latest \
		--tag behretv/lint:${TAG} \
		.
	docker buildx rm tmp-builder

build-gitlab: create-builder
	docker buildx build --push --platform linux/arm64,linux/amd64 \
		--provenance=false \
		--tag ${URL}/lint:latest \
		--tag ${URL}/lint:${TAG} \
		.
	docker buildx rm tmp-builder

