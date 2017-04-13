#!/usr/bin/env bash
if [ "$DEPLOY_ENVIRONMENT" = "development" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "staging" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "feature" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "hotfix" ]; then
    docker images
    export AWS_DEFAULT_REGION=$AWS_REGION
    $(aws ecr get-login --region $AWS_REGION)
    echo ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
    # docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
elif [ "$DEPLOY_ENVIRONMENT" = "development" ]; then
    $(aws ecr get-login --registry-ids "$SOURCE_AWS_ACCOUNT_ID" --region $SOURCE_AWS_REGION)
    docker pull ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${ECR_NAME}:candidate
    docker tag ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${ECR_NAME}:candidate ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat docker.tag)
    $(aws ecr get-login --registry-ids "${AWS_ACCOUNT_ID}" --region $AWS_REGION)
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat docker.tag)

else
    echo "NO POST BUILD ACTIONS IN RELEASE"
fi
