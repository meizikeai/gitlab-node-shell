#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

handleEcho "start remove build"
rm -rf build
handleCallback "remove build success" "remove build failed"

handleEcho "start build TypeScript"
npx tsc
handleCallback "build TypeScript success" "build TypeScript failed"

handleEcho "start remove node_modules"
rm -rf node_modules
handleCallback "remove node_modules success" "remove node_modules failed"

# set flag for build version
git rev-parse --short HEAD >version
