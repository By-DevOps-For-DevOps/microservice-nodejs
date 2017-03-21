#!/usr/bin/env bash
if [ "$DEPLOY_ENVIRONMENT" != 'production' ]; then
    docker images
    export AWS_DEFAULT_REGION=$AWS_REGION
    $(aws ecr get-login --region $AWS_REGION)
    echo ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:$(cat ./docker.tag)
else
    $(aws ecr get-login --registry-ids "$SOURCE_AWS_ACCOUNT_ID" --region $SOURCE_AWS_REGION)
    docker pull ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${ECR_NAME}:${SOURCE_TAG}
    docker tag ${SOURCE_AWS_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${ECR_NAME}:${SOURCE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:${RELEASE_VERSION}
    $(aws ecr get-login --registry-ids "${AWS_ACCOUNT_ID}" --region $AWS_REGION)
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_NAME}:${RELEASE_VERSION}
fi
