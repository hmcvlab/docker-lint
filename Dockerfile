FROM python:3.12

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive \
  BIN_HADOLINT=/usr/local/bin/hadolint \
  BIN_LINT=/usr/local/bin/lint

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  cppcheck \
  pylint \
  shellcheck \
  yamllint \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install packages that are only for pip
RUN python3 -m pip install --no-cache-dir --break-system-packages \
  flake8~=7.1.1 \
  flake8-pytest-style~=2.0.0 \
  pytest~=8.3.2

# Install hadolint
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/g')" && \
  wget -qO "${BIN_HADOLINT}" \
  "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-${ARCH/aarch64/arm64/}" \
  && chmod +x "${BIN_HADOLINT}"

# Entrypoint
COPY lint.sh ${BIN_LINT}
RUN chmod +x ${BIN_LINT}
WORKDIR /app
ENTRYPOINT ["bash", "-c", "${BIN_LINT}"]
