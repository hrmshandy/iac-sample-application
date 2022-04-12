#!/usr/bin/env bash

DEPLOY_ENV="nah"

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "branch/main" ]]; then
    DEPLOY_ENV="staging"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "tag/"* ]]; then
    DEPLOY_ENV="production"
fi

if [[ "$DEPLOY_ENV" != "nah" ]]; then
    # Deploy queues
    aws --region ap-southeast-3 deploy create-deployment \
        --application-name seven8-$DEPLOY_ENV-deploy-app \
        --deployment-group-name "seven8-$DEPLOY_ENV-queue-deploy-group" \
        --description "Deploying trigger $CODEBUILD_WEBHOOK_TRIGGER" \
        --s3-location "bucket=seven8-artifacts,bundleType=zip,key=$CODEBUILD_RESOLVED_SOURCE_VERSION.zip"

    # Deploy web servers
    aws --region ap-southeast-3 deploy create-deployment \
        --application-name seven8-$DEPLOY_ENV-deploy-app \
        --deployment-group-name "seven8-$DEPLOY_ENV-http-deploy-group" \
        --description "Deploying trigger $CODEBUILD_WEBHOOK_TRIGGER" \
        --s3-location "bucket=seven8-artifacts,bundleType=zip,key=$CODEBUILD_RESOLVED_SOURCE_VERSION.zip"
fi
