#!/bin/bash

ACCESS_TOKEN=${TOKEN}
REPO=${REPO}
RUNNER_ID=${RUNNER_ID}
RUNNER_TYPE=${RUNNER_TYPE:-repos}

get_runner() {
  curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "X-GitHub-Api-Version: 2026-03-10" \
    https://api.github.com/${RUNNER_TYPE}/${REPO}/actions/runners/${RUNNER_ID}
}

max_checks=4
check=0
kill_job=true

while (( check < max_checks )); do
  sleep 15m
  response=$(get_runner)

  if [[ $(echo $response | jq -r '.status') == online && $(echo $response | jq -r '.busy') == true ]]; then
    kill_job=false
    break
  fi

  ((++check))
done

if [[ $kill_job ]]; then
 kill -SIGINT -${PARENT_PID}
fi
