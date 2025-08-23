FROM ubuntu:latest

ARG RUNNER_VERSION="2.328.0"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
  curl jq build-essential libssl-dev libffi-dev \
  python3 python3-venv python3-dev python3-pip \
  libicu74 libicu-dev libssl3  libkrb5-3

RUN ARCH="" \
case "$(uname -m)" in \
  "x86_64") \
    ARCH="x64" \
    ;; \
  "aarch64") \
    ARCH="arm64" \
    ;; \
  *) \
    echo "Unsupport OS Architecture" \
    exit 1 \
    ;; \
esac \
cd /home/docker && mkdir actions-runner && cd actions-runner \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker
COPY start.sh start.sh

RUN chmod +x start.sh

USER docker

ENTRYPOINT [ "./start.sh" ]