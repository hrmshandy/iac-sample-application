#!/usr/bin/env bash

# Generate .env
cd /home/seven8/seven8
aws --region ap-southeast-3 ssm get-parameter \
    --with-decryption \
    --name /seven8/staging/env \
    --output text \
    --query 'Parameter.Value' > .env

# Set permissions
chown -R seven8:seven8 /home/seven8/seven8

# Below conditional syntax from here:
# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash

# Env var available for appspec hooks:
# https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#reference-appspec-file-structure-environment-variable-availability

# Reload php-fpm (clear opcache) if a web server
if [[ "$DEPLOYMENT_GROUP_NAME" == *"http"* ]]; then
    service php8.0-fpm reload
fi

# Start supervisor jobs (if supervisor is used)
if [[ "$DEPLOYMENT_GROUP_NAME" == *"queue"* ]]; then
    supervisorctl start all
fi

# Optionally, depending on your needs
# sudo -u seven8 php artisan migrate --force
