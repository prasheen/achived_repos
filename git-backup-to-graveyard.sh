#!/bin/bash

# Script to backup git repo to prasheen graveyard repo
# Based on https://gist.github.com/philippb/1988919

# Setup repository to $1
repository=$1

date=`date '+%Y%m%d%H%M%S'`

echo "Removing any old backups of $repository"
rm -f $repository.*.gz

echo "Backing up $repository"
echo "git clone --mirror git@github.com:prasheen/$repository.git $repository.git"
git clone --mirror git@github.com:prasheen/$repository.git $repository.git
if [ $? -ne 0 ]; then
  echo "Error cloning $repository"
  exit 1
fi
echo "Compressing $repository"
echo "tar cpzf $repository.$date.git.tar.gz $repository.git"
tar czf $repository.$date.git.tar.gz $repository.git
if [ $? -ne 0 ]; then
  echo "Error compressing $repository"
  exit 1
fi

/bin/rm -rf $repository.git

echo "Adding $repository to backups repo"
git add . && git commit -a -m "Backing up $repository" && git push

echo "Succesfully backed up $repository"

if [ -z $GITHUB_TOKEN ]; then
  echo "Sorry cannot delete the repo from prasheen's github. GITHUB_TOKEN must be set. $GITHUB_TOKEN"
else
  read -p "Do you want to delete the repo on github.com?" -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi
  read -p "Are you sure? " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi
  curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/prasheen/$repository
fi