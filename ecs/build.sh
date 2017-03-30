#!/usr/bin/env bash
if [ "$DEPLOY_ENVIRONMENT" != "production" ]; then
    echo -n "$CODEBUILD_BUILD_ID" | sed "s/.*:\([[:xdigit:]]\{7\}\).*/\1/" > build.id
    echo -n "$RELEASE_VERSION-$BUILD_SCOPE-$(cat ./build.id)" > docker.tag
    docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$(cat docker.tag) .
    TAG=$(cat docker.tag)
else
    TAG=${RELEASE_VERSION}
fi

sed -i "s@TAG@$TAG@g" ecs/service.yaml
sed -i "s#EMAIL#$EMAIL#g" ecs/service.yaml
sed -i "s@ENVIRONMENT_NAME@$ENVIRONMENT_NAME@g" ecs/service.yaml
sed -i "s@DOCKER_IMAGE_URI@$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$TAG@g" ecs/service.yaml
sed -i "s@BUILD_SCOPE@$BUILD_SCOPE@g" ecs/service.yaml
sed -i "s@ECS_REPOSITORY_NAME@$ECR_NAME@g" ecs/service.yaml
sed -i "s@RELEASE_VERSION@$RELEASE_VERSION@g" ecs/service.yaml