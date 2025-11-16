FROM ubuntu:latest

ARG RUNNER_VERSION="2.329.0"
ARG EPHEMERAL=false

ENV DEBIAN_FRONTEND=noninteractive
ENV EPHEMERAL=${EPHEMERAL}

RUN apt update -y \
  && apt upgrade -y \
  && useradd -m docker \
  && chown -R docker ~docker \
  && apt install -y --no-install-recommends \
  build-essential ca-certificates curl iptables jq \
  libffi-dev libicu74 libicu-dev libkrb5-3 libssl-dev libssl3 \
  python3 python3-dev python3-pip python3-venv sudo uidmap wget \
  && echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && rm -rf /var/lib/apt/lists/*

USER docker
WORKDIR /home/docker

RUN ARCH="" \
 && case "$(uname -m)" in \
    x86_64) ARCH="x64" ;; \
    aarch64) ARCH="arm64" ;; \
    *) echo "Unsupport OS Architecture" ; exit 1 ;; \
  esac \
  && mkdir actions-runner && cd actions-runner \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && rm ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz

COPY start.sh start.sh

ENTRYPOINT [ "./start.sh" ]