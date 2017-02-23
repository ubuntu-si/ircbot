#!/bin/bash

echo -e "Host $APP_HOSTNAME\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
eval "$(ssh-agent -s)" #start the ssh agent
chmod 600 .travis/deploy_key.pem # this key should have push access
ssh-add .travis/deploy_key.pem
rm -rf .travis/deploy_key.pem
git remote add dokku dokku@$APP_HOSTNAME:$APP
git push --force dokku HEAD:master
