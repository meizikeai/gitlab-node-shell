#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

ssr="$1"

# check git version for rebuild typescripts build
# because gitlab-ci retry just trigger `deploy` stage, without `build` stage.

currentVersion=$(
  git rev-parse --short HEAD
)

tagVersion=$(
  touch version
  cat version
)

if [ "$currentVersion" = "$tagVersion" ]; then
  handleEcho "git version match"
else
  if [ "$ssr" = "ssr" ]; then
    handleEcho "git version not match, set flag"
    bash $scripts/ssr.sh
  else
    handleEcho "git version not match, rebuild build"
    bash $scripts/install.sh
    bash $scripts/build.sh
  fi
fi
