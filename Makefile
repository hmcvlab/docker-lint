URL = hmcvlab
NAME = lint
TAG = $(shell git tag --sort=committerdate | tail -1)

format:
	docker run --rm -v .:/app \
		${URL}/format:latest

lint:
	docker run --rm -v .:/app \
		${URL}/lint:latest

build:
	docker buildx create --use --name tmp-builder && \
	docker buildx build \
		-t ${URL}/${NAME}:${TAG} \
		-t ${URL}/${NAME}:latest \
		--push \
		--platform linux/amd64,linux/arm64 \
		--file Dockerfile . && \
	docker buildx rm tmp-builder

test:
	docker run --rm  \
		-v .:/app \
		${URL}/${NAME}:${TAG} \
		sh -c "pytest"

install_hooks:
	@echo "make format && make lint" > .git/hooks/pre-commit
	@echo "make test" > .git/hooks/pre-push
	chmod +x .git/hooks/pre-*
