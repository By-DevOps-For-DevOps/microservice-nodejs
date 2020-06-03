#!/usr/bin/env bash
if [ "$DEPLOY_ENVIRONMENT" != "release" ]; then
  GITHUB_TOKEN=${GITHUB_TOKEN}
  git config --global user.email ${GITHUB_EMAIL}
  git config --global user.name ${GITHUB_USERNAME}
  # TODO: testing on pre-release branch
  git clone https://github.com/microservices-today/ecs-api ecs  --branch 2.0.0
fi
. ./ecs/build.sh
