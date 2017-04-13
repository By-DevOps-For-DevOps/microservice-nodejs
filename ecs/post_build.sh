#!/usr/bin/env bash
if [ "$DEPLOY_ENVIRONMENT" = "development" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "staging" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "feature" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "hotfix" ]; then
    $(aws ecr get-login --registry-ids "${AWS_ACCOUNT_ID}" --region $AWS_REGION)
    echo ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
elif [ "$DEPLOY_ENVIRONMENT" = "production" ]; then
    PROD_TAG=$(curl https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/latest?access_token=${GITHUB_TOKEN} | grep -Eo "([0-9]\.*)+")
    $(aws ecr get-login --registry-ids "$SOURCE_AWS_ACCOUNT_ID" --region $SOURCE_AWS_REGION)
    docker pull ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
    docker tag ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag) ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$PROD_TAG
    $(aws ecr get-login --registry-ids "${AWS_ACCOUNT_ID}" --region $AWS_REGION)
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat docker.tag)

else
    echo "NO POST BUILD ACTIONS IN RELEASE"
fi
