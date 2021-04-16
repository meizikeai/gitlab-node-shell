#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

handleEcho "start remove node_modules"
rm -rf node_modules
handleCallback "remove node_modules success" "remove node_modules failed"

# set flag for ssr version
git rev-parse --short HEAD >version
