#!/usr/bin/env bash

# This is a bash utility to test the script in docker container
# Version:1.0
# Author: Prasad Tengse
# Licence: GPLv3
# Github Repository: https://github.com/tprasadtp/after-effects-ubuntu

set -o pipefail
branch=master
case "${TRAVIS_EVENT_TYPE}" in
  pull_request )           branch="${TRAVIS_PULL_REQUEST_BRANCH}";;
  push | cron | api )      branch="${TRAVIS_BRANCH}";;
  * )                      branch="${TRAVIS_BRANCH}";;
esac

function main()
{
  dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
  #shellcheck disable=SC2116
  dir=$(echo "${dir/tests/}")
  log_file="$dir"/logs/after-effects.log
  # set eo on script.
  sed -i 's/set -o pipefail/set -eo pipefail/g' "$dir"/after-effects
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Building Xenial Docker Image"
  docker build -t  ubuntu:ae-xenial ./dockerfiles/xenial
  echo "Running in Docker Xenial"
  docker run -it -e TRAVIS="$TRAVIS" \
  --hostname=Docker-Xenial \
  -v "$(pwd)":/shared \
  ubuntu:ae-xenial \
  ./after-effects --simulate --yes --yaml --api-endpoint https://"${branch}"--ubuntu-post-install.netlify.com/api

  exit_code_from_container="$?"
  echo "Exit code from docker run is: $exit_code_from_container"
  echo "Print Logs is set to: $PRINT_LOGS"
  if [ "$PRINT_LOGS" == "true" ] || [[ "$exit_code_from_container" -gt 0 ]]; then
    echo " "
    echo " "
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    cat "$log_file"
  fi
  exit $exit_code_from_container
}

main "$@"
