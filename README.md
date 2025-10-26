# Docker Image: Linter

Build locally:

```bash
make build
```

Lint code locally:

```bash
docker run \
  --volume "$(pwd)":/app \
  hmcvlab/lint
```
