FROM ubuntu:latest

ARG RUNNER_VERSION="2.329.0"
ARG EPHEMERAL=false

ENV DEBIAN_FRONTEND=noninteractive
ENV EPHEMERAL=${EPHEMERAL}

RUN apt-get update \
  && apt-get install -y ca-certificates curl gnupg lsb-release \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl docker-ce-cli jq \
    libffi-dev libicu74 libicu-dev libkrb5-3 libssl-dev libssl3 \
    python3 python3-dev python3-pip python3-venv unzip \
  && apt-get remove -y ca-certificates gnupg lsb-release \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd -g 988 docker \
  && useradd -m -g docker docker \
  && chown -R docker ~docker

WORKDIR /home/docker
USER docker

RUN ARCH="" \
  && case "$(uname -m)" in \
    x86_64) ARCH="x64" ;; \
    aarch64) ARCH="arm64" ;; \
    *) echo "Unsupport OS Architecture" ; exit 1 ;; \
  esac \
  && mkdir actions-runner && cd actions-runner \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && rm -rf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && curl -o- https://fnm.vercel.app/install | bash \
  && fnm install --lts

COPY start.sh start.sh

ENTRYPOINT [ "./start.sh" ]
