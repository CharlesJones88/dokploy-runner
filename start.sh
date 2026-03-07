#!/bin/bash

REPO=${REPO}
ACCESS_TOKEN=${TOKEN}
RUNNER_TYPE=${RUNNER_TYPE:-repos}
ADDITIONAL_LABELS=${ADDITIONAL_LABELS}
ARCH=""

case "$(uname -m)" in
  x86_64) ARCH="x64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported OS Architecture"
    exit 1
    ;;
esac

[[ -n "$ADDITIONAL_LABELS" && "$ADDITIONAL_LABELS" != ,* ]] && ADDITIONAL_LABELS=",${ADDITIONAL_LABELS}"
LABELS="dokploy,${ARCH},dokploy-${ARCH}${ADDITIONAL_LABELS}"

cd /home/docker/actions-runner

JIT_CONFIG=$(curl -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -d "{\"name\":\"${NAME}\",\"runner_group_id\":1,\"labels\":$(echo ${LABELS} | jq -R -c 'split(",")')}" \
  "https://api.github.com/${RUNNER_TYPE}/${REPO}/actions/runners/generate-jitconfig" \
  | jq .encoded_jit_config --raw-output)

exec ./run.sh --jitconfig "${JIT_CONFIG}"
