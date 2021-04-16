#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

quickUpdate

if [ $? -eq 0 ]; then
  handleEcho "start eslint"
  npx eslint --cache --ext .ts,.js,.jsx,.vue .
  handleCallback "runing eslint success" "runing eslint failed"
else
  handleEcho "urgent deployment"
fi
