#!/bin/bash

# Script to restore git repo from prasheen graveyard
# Based on https://gist.github.com/philippb/1988919

# Setup repository to $1
REPOSITORY=$1

echo "Removing any old unfinished restores of $REPOSITORY"
rm -rf ../$REPOSITORY

echo "Restoring $REPOSITORY"
echo "tar -xf $REPOSITORY.*.git.tar.gz -C ../$REPOSITORY"
mkdir ../$REPOSITORY && tar -xf $REPOSITORY.*.git.tar.gz -C ../$REPOSITORY
if [ $? -ne 0 ]; then
  echo "Error Restoring $REPOSITORY"
  exit 1
fi

if [ -z $GITHUB_TOKEN ]; then
  echo "Sorry cannot restore the repo to prasheen's github. GITHUB_TOKEN must be set"
  echo "Succesfully restored $REPOSITORY to $(dirname $PWD)/$REPOSITORY"
else 
  curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/orgs/prasheen/repos \
  -d "{\"name\":\"$REPOSITORY\", \"private\": true}" > /dev/null
  git -C $(dirname $PWD)/$REPOSITORY push --mirror
fi
