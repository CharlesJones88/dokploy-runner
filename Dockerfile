FROM ubuntu:latest

ARG DOCKER_GROUP=3000
ARG RUNNER_VERSION="2.329.0"
ARG EPHEMERAL=false

ENV DEBIAN_FRONTEND=noninteractive
ENV EPHEMERAL=${EPHEMERAL}

RUN apt-get update \
  && apt-get install -y ca-certificates curl gnupg lsb-release \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential curl docker-ce-cli jq \
    libffi-dev libicu74 libicu-dev libkrb5-3 libssl-dev libssl3 \
    python3 python3-dev python3-pip python3-venv ssh unzip \
  && apt-get remove -y ca-certificates gnupg lsb-release \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${DOCKER_GROUP} docker \
  && useradd -m -g docker docker \
  && chown -R docker ~docker

WORKDIR /home/docker
USER docker
ENV FNM_DIR="/home/docker/.local/share/fnm"
ENV PATH="/home/docker/.local/share/fnm:$PATH"

RUN ARCH="" \
  && case "$(uname -m)" in \
    x86_64) ARCH="x64" ;; \
    aarch64) ARCH="arm64" ;; \
    *) echo "Unsupport OS Architecture" ; exit 1 ;; \
  esac \
  && mkdir actions-runner && cd actions-runner \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && rm -rf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz

RUN curl -o- https://fnm.vercel.app/install | bash -s -- --skip-shell \
  && eval "$(fnm env --shell bash)" \
  && fnm install --lts \
  && fnm default lts-latest \
  && fnm use lts-latest \
  && ls "$HOME/.local/share" \
  && NODE_DIR=$(ls -d "$HOME/.local/share/fnm/versions/node/"* | head -n1) cp "$NODE_DIR/bin/node" /usr/local/bin/ \
  && NODE_DIR=$(ls -d "$HOME/.local/share/fnm/versions/node/"* | head -n1) cp "$NODE_DIR/bin/npm" /usr/local/bin/ \
  && NODE_DIR=$(ls -d "$HOME/.local/share/fnm/versions/node/"* | head -n1) cp "$NODE_DIR/bin/npx" /usr/local/bin/

COPY start.sh start.sh

ENTRYPOINT [ "./start.sh" ]
