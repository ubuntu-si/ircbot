#!/bin/bash
eval "$(ssh-agent -s)" #start the ssh agent
echo "$FUNNY_CAT" > .travis/deploy_key.pem
chmod 600 .travis/deploy_key.pem # this key should have push access
ssh-add .travis/deploy_key.pem
git remote add dokku dokku@$APP_HOSTNAME:$APP
git push --force dokku HEAD:master
