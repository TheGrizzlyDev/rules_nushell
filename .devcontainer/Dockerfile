FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64
RUN chmod +x bazelisk-linux-amd64
RUN mv bazelisk-linux-amd64 /usr/local/bin/bazel

RUN apt update && apt install -y --no-install-recommends \
    python3-setuptools \
    python3-pip \
    python3-dev \
    python3-venv

RUN pip install --break-system-packages pre-commit