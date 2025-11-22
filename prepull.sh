#!/bin/bash

for node in $(echo "$NODES" | jq -r '.[] | @base64'); do
  _jq() {
    echo "${node}" | base64 --decode | jq -r ${1}
  }
	echo "--- Running on $node ---"
	(
		ssh -o StrictHostKeyChecking=no "$(_jq '.username')@$(_jq '.host')" "GHCR_USERNAME=$GH_USERNAME GHCR_TOKEN=$GHCR_TOKEN bash -s" < ./prepull-latest.sh
	) &
done

wait