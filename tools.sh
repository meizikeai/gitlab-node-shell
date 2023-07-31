#!/bin/bash
# tools for gitlab ci output

function handleEcho() {
  echo -e "→ $1"
}

function handleCommand() {
  local host="$1"
  local command="$2"

  ssh -o StrictHostKeyChecking=no $host "$command"
}

function handleCallback() {
  if [ $? -eq 0 ]; then
    handleEcho "$1"
    sendNotice "Successful operation\nProject: $CI_PROJECT_NAME\nEnv: $CI_ENVIRONMENT_NAME\nStage: $CI_JOB_STAGE\nCreated By: $GITLAB_USER_NAME\nStatus: deploy success\nLink: $CI_PIPELINE_URL\nMessage: $CI_COMMIT_MESSAGE"
  else
    handleEcho "$2"
    sendNotice "Errors and Warnings\nProject: $CI_PROJECT_NAME\nEnv: $CI_ENVIRONMENT_NAME\nStage: $CI_JOB_STAGE\nCreated By: $GITLAB_USER_NAME\nStatus: catching error\nLink: $CI_PIPELINE_URL\nMessage: $CI_COMMIT_MESSAGE"
    exit 1
  fi
}

function sendNotice() {
  local dingtalkText="$1"
  local feishuText=$(echo $1)

  # handleEcho "$1"
  # handleEcho "$feishuText"

  if [ $dingtalk ]; then
    curl -X POST "$dingtalk" \
      -H 'Content-Type: application/json' \
      -d '{
      "msgtype": "text",
      "text": {
          "content": "'"$dingtalkText"'"
      }
    }'
  fi

  if [ $feishu ]; then
    curl -X POST "$feishu" \
      -H 'Content-Type: application/json' \
      -d '{
      "title": "GitLab CI/CD notice",
      "text": "'"$feishuText"'"
    }'
  fi
}

function quickUpdate() {
  handleEcho $CI_COMMIT_TITLE

  local count=$(echo $CI_COMMIT_TITLE | grep -E "deploy." | wc -l)

  if [ $count -eq 0 ]; then
    return 0
  else
    return 1
  fi
}
