#!/usr/bin/env bash

DO_BUILD="nah"


if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "branch/main" ]]; then
    DO_BUILD="yes"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "tag/"* ]]; then
    DO_BUILD="yes"
fi


if [[ "$DO_BUILD" == "yes" ]]; then
    # Production assets/dependencies
    npm install
    npm run production
    composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

    # Create our build artifact
    git archive -o builds/seven8.zip --worktree-attributes HEAD
    zip -qur builds/seven8.zip vendor
    zip -qur builds/seven8.zip public

    # Upload artifact to s3
    aws s3 cp builds/seven8.zip s3://seven8-artifacts/$CODEBUILD_RESOLVED_SOURCE_VERSION.zip
fi
