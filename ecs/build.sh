#!/usr/bin/env bash
if [ "$DEPLOY_ENVIRONMENT" = "development" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "staging" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "feature" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "hotfix" ]; then
    echo -n "$CODEBUILD_BUILD_ID" | sed "s/.*:\([[:xdigit:]]\{7\}\).*/\1/" > build.id
    echo -n "$TAG_NAME-$BUILD_SCOPE-$(cat ./build.id)" > docker.tag
    # docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$(cat docker.tag) .
    TAG=$(cat docker.tag)
elif [ "$DEPLOY_ENVIRONMENT" = "release" ] ; then
    GITHUB_TOKEN=${GITHUB_TOKEN}
    git config --global user.email ${GITHUB_EMAIL}
    git config --global user.name ${GITHUB_USERNAME}
    git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}
    cd ${GITHUB_REPO}
    git checkout staging
    git tag ${RELEASE_PLAN}-$(cat ../docker.tag)-beta
    git push --tags
    git checkout master-test
    git merge staging
    git tag -a ${RELEASE_PLAN} -m ${RELEASE_PLAN}
    git push origin master-test --follow-tags
else
    curl https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/latest?access_token=${GITHUB_TOKEN} | grep -Eo "([0-9]\.*)+" > docker.tag
    TAG=$(cat docker.tag)
fi

sed -i "s@TAG@$TAG@g" ecs/service.yaml
sed -i "s#EMAIL#$EMAIL#g" ecs/service.yaml
sed -i "s@ENVIRONMENT_NAME@$ENVIRONMENT_NAME@g" ecs/service.yaml
sed -i "s@DOCKER_IMAGE_URI@$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$TAG@g" ecs/service.yaml
sed -i "s@BUILD_SCOPE@$BUILD_SCOPE@g" ecs/service.yaml
sed -i "s@ECS_REPOSITORY_NAME@$ECR_NAME@g" ecs/service.yaml
sed -i "s@RELEASE_VERSION@$RELEASE_VERSION@g" ecs/service.yaml