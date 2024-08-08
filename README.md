# Docker Image: Linter

Build locally:

```bash
make build
```

Run locally:

```bash
docker run \
  --volume "$(pwd):/app" \
  gitlab.lrz.de:5005/messtechnik-labor/docker/lint
```
