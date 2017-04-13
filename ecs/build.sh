#!/usr/bin/env bash
echo -n "$CODEBUILD_BUILD_ID" | sed "s/.*:\([[:xdigit:]]\{7\}\).*/\1/" > build.id
if [ "$DEPLOY_ENVIRONMENT" = "development" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "feature" ] || \
   [ "$DEPLOY_ENVIRONMENT" = "hotfix" ]; then    
    echo -n "$TAG_NAME-$BUILD_SCOPE-$(cat ./build.id)" > docker.tag
    docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$(cat docker.tag) .
    TAG=$(cat docker.tag)
elif [ "$DEPLOY_ENVIRONMENT" = "staging" ] ; then
    echo -n "${RELEASE_PLAN}-$BUILD_SCOPE-$(cat ./build.id)" > docker.tag
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
    git push origin master-test
    API_JSON=$(printf '{"tag_name": "v%s","target_commitish": "master",
    "name": "v%s","body": "Release of version %s",
    "draft": false,"prerelease": false}' $RELEASE_PLAN $RELEASE_PLAN $RELEASE_PLAN)
    echo $API_JSON
    curl --data "$API_JSON" https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases?access_token=${GITHUB_TOKEN}

else
    GITHUB_TOKEN=${GITHUB_TOKEN}
    git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}
    cd ${GITHUB_REPO}
    git checkout staging
    TAG=$(git describe --tags --abbrev=0)
fi

sed -i "s@TAG@$TAG@g" ecs/service.yaml
sed -i "s#EMAIL#$EMAIL#g" ecs/service.yaml
sed -i "s@ENVIRONMENT_NAME@$ENVIRONMENT_NAME@g" ecs/service.yaml
sed -i "s@DOCKER_IMAGE_URI@$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$TAG@g" ecs/service.yaml
sed -i "s@BUILD_SCOPE@$BUILD_SCOPE@g" ecs/service.yaml
sed -i "s@ECS_REPOSITORY_NAME@$ECR_NAME@g" ecs/service.yaml
sed -i "s@RELEASE_VERSION@$RELEASE_VERSION@g" ecs/service.yaml