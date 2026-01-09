FROM ubuntu:25.04

SHELL ["/bin/bash", "-c", "-o", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive \
  BIN_HADOLINT=/usr/local/bin/hadolint \
  BIN_LINT=/usr/local/bin/lint

USER root
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  chktex \
  cppcheck \
  cpplint \
  lacheck \
  pylint \
  python3-docformatter \
  python3-pip \
  python3-pytest \
  python3-flake8 \
  python3-flake8-black \
  python3-flake8-pytest \
  python3-toml \
  shellcheck \
  wget \
  yamllint \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install hadolint
RUN ARCH="$(uname -m | sed 's/aarch64/arm64/g')" && \
  wget -qO "${BIN_HADOLINT}" \
  "https://github.com/hadolint/hadolint/releases/download/v2.14.0/hadolint-Linux-${ARCH/aarch64/arm64/}" \
  && chmod +x "${BIN_HADOLINT}"

# Install lint script
COPY configs/* /etc/
COPY lint.sh ${BIN_LINT}
RUN chmod +x ${BIN_LINT}

# Install packages that are only for pip
USER ubuntu
WORKDIR /app
ENTRYPOINT ["bash", "-c", "${BIN_LINT}"]
