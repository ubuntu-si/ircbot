#!/bin/bash

echo -e "Host $APP_HOSTNAME\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
eval "$(ssh-agent -s)" #start the ssh agent
openssl aes-256-cbc -K $encrypted_8b6bbaa2f436_key -iv $encrypted_8b6bbaa2f436_iv -in .travis/key.enc -out .travis/deploy_key.pem -d
chmod 600 .travis/deploy_key.pem # this key should have push access
ssh-add .travis/deploy_key.pem
rm -rf .travis/deploy_key.pem
git remote add dokku dokku@$APP_HOSTNAME:$APP
git push --force dokku HEAD:master