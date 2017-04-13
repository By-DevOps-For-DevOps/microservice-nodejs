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
    docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$(cat docker.tag) .
    TAG=$(cat docker.tag)
elif [ "$DEPLOY_ENVIRONMENT" = "release" ] ; then
    GITHUB_TOKEN=${GITHUB_TOKEN}
    git config --global user.email ${GITHUB_EMAIL}
    git config --global user.name ${GITHUB_USERNAME}
    git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}
    cd ${GITHUB_REPO}
    git checkout staging
    printf %q "$(git log `git describe --tags --abbrev=0`..HEAD --pretty=format:"- %s%n%b\n")"> ./commits
    git tag $(cat ../docker.tag)
    git push --tags
    git checkout master
    git merge staging
    git push origin master
    API_JSON=$(printf '{"tag_name": "%s","target_commitish": "master",
    "name": "%s","body": "%s",
    "draft": false,"prerelease": false}' $RELEASE_PLAN $RELEASE_PLAN $RELEASE_PLAN $(cat ./commits))
    echo $API_JSON
    curl --data "$API_JSON" https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases?access_token=${GITHUB_TOKEN}

else
    echo "Entering Production Build"
    GITHUB_TOKEN=${GITHUB_TOKEN}
    git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}
    cd ${GITHUB_REPO}
    git checkout staging
    STAGE_TAG=$(git describe --tags --abbrev=0)
    TAG=$(curl https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases/latest?access_token=${GITHUB_TOKEN} | grep tag_name | grep -Eo "([0-9]\.*)+")
    echo $STAGE_TAG > ../stage.tag
    echo $TAG > ../prod.tag
    cat ../stage.tag
    cat ../prod.tag
    cd ..
fi

sed -i "s@TAG@$TAG@g" ecs/service.yaml
sed -i "s#EMAIL#$EMAIL#g" ecs/service.yaml
sed -i "s@ENVIRONMENT_NAME@$ENVIRONMENT_NAME@g" ecs/service.yaml
sed -i "s@DOCKER_IMAGE_URI@$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_NAME:$TAG@g" ecs/service.yaml
sed -i "s@BUILD_SCOPE@$BUILD_SCOPE@g" ecs/service.yaml
sed -i "s@ECS_REPOSITORY_NAME@$ECR_NAME@g" ecs/service.yaml
sed -i "s@RELEASE_VERSION@$RELEASE_VERSION@g" ecs/service.yaml


if [ ! -z $ENV_VARIABLES_S3_BUCKET ] && [ ! -z $ENV_VARIABLES_S3_KEY ]; then
    echo "Downloading ${ENV_VARIABLES_S3_KEY} form  ${ENV_VARIABLES_S3_BUCKET} ..."
    aws s3 cp s3://${ENV_VARIABLES_S3_BUCKET}/${ENV_VARIABLES_S3_KEY} env.yaml
    if [ $? == 1 ]; then
        exit 1;
    fi
    perl -i -pe 's/ENVIRONMENT_VARIABLES/`cat env.yaml`/e' ecs/service.yaml
else
    perl -i -pe 's/ENVIRONMENT_VARIABLES//e' ecs/service.yaml
fi
