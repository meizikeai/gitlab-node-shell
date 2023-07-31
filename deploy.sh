#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

folderPath=$(dirname "${BASH_SOURCE[0]}")
hostList="$1"
ssr="$2"
flags="--only=production"

if [ "$ssr" = "ssr" ]; then
  flags=""
else
  flags="--only=production"
fi

function handleDeploy() {
  for host in $hostList; do
    deployService "$host" &
  done
  wait
  handleCallback "deploy $hostList success" "deploy $hostList failed"
  handleEcho "Calling dingtalk success"
}

function deployService() {
  local host=$1
  handleEcho "start deploy to $host:$deploys"
  rsync -e "ssh -o StrictHostKeyChecking=no" -arc --exclude-from="${folderPath}/exclude.list" --delete . $host:$deploys
  handleCallback "rsync success" "rsync failed"

  handleEcho "start install dependencies"
  handleCommand "$host" "cd $deploys; npm i $flags"
  handleCallback "install dependencies success" "install dependencies failed"

  handleEcho "start service"
  handleCommand "$host" "pm2 restart $deploys/pm2/$CI_ENVIRONMENT_NAME.json;"
  handleCallback "service started success" "service startup failed"
}

if [ $CI_ENVIRONMENT_NAME = "development" ] || [ $CI_ENVIRONMENT_NAME = "production" ]; then
  handleDeploy
else
  handleEcho "invalidate env: $CI_ENVIRONMENT_NAME"
  exit 1
fi
