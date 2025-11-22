#!/bin/bash
source /home/charles/.bashrc

for NODE in $(echo "$NODES" | jq -r '.[] | @base64'); do
  _jq() {
    echo "${row}" | base64 --decode | jq -r ${1}
  }
	echo "--- Running on $NODE ==="
	(
		ssh "$(_jq '.username')"@"$(_jq '.host')" "GHCR_USERNAME=$GH_USERNAME GHCR_TOKEN=$GHCR_TOKEN bash -s" < ./prepull-latest.sh
	) &
done

wait