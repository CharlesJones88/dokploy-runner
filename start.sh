#!/bin/bash

REPO=$REPO
ACCESS_TOKEN=$TOKEN
RUNNER_TYPE=${RUNNER_TYPE:-repos}
ADDITIONAL_ARGS=""
ADDITIONAL_LABELS=${ADDITIONAL_LABELS}
ARCH=""

if [[ "$EPHEMERAL" = "true" ]]; then
  ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --ephemeral"
  ADDITIONAL_ARGS="${ADDITIONAL_ARGS##*( )}"
  ADDITIONAL_ARGS="${ADDITIONAL_ARGS%%*( )}"
  ADDITIONAL_LABELS="$ADDITIONAL_LABELS,ephemeral"
fi

[[ -n "$ADDITIONAL_LABELS" && "$ADDITIONAL_LABELS" != ,* ]] && ADDITIONAL_LABELS=",${ADDITIONAL_LABELS}"

case "$(uname -m)" in
  "x86_64")
    ARCH="x64"
    ;;
  "aarch64")
    ARCH="arm64"
    ;;
  *)
    echo "Unsupported OS Architecture"
    exit 1
    ;;
esac

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/${RUNNER_TYPE}/${REPO}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${REPO} \
  --token ${REG_TOKEN} ${ADDITIONAL_ARGS} \
  --labels dokploy,${ARCH},dokploy-${ARCH}${ADDITIONAL_LABELS}

cleanup() {
  echo "Removing runner ..."
  ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

exec ./run.sh
