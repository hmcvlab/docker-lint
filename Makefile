URL = hmcvlab
NAME = lint
TAG = $(shell git tag --sort=committerdate | tail -1)

format:
	docker run --rm -v "${PWD}":/app \
		-e UID="$(shell id -u)" \
		${URL}/format:latest

lint:
	docker run --rm -v "${PWD}":/app \
		${URL}/lint:latest

build:
	docker buildx create --use && \
	docker buildx build \
		-t ${URL}/${NAME}:${TAG} \
		--push \
		--platform linux/amd64,linux/arm64 \
		--file Dockerfile .

test:
	docker run --rm  \
		-v ${PWD}:/app \
		${URL}/${NAME}:${TAG} \
		sh -c "pytest"

install_hooks:
	@echo "make format && make lint" > .git/hooks/pre-commit
	@echo "make test" > .git/hooks/pre-push
