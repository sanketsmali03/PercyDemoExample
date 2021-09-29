#!/bin/bash

set -e

if ! [ -x "$(command -v hub)" ]; then
  echo 'Error: hub is not installed (https://hub.github.com/). Please run "brew install hub".' >&2
  exit 1
fi


NOW=`date +%d%H%M%S`
BASE_BRANCH="master-$NOW"
BRANCH="update-button-$NOW"

# cd to current directory as root of script
cd "$(dirname "$0")"

# Create a "master-123123" branch for the PR's baseline.
# This allows demo PRs to be merged without fear of breaking the actual master.
#git checkout master
#git checkout -b $BASE_BRANCH
#git push origin $BASE_BRANCH


git push origin master

# Create the update-button-123123 PR. It is always a fork of the update-button-base branch.

git checkout update-button-base
git checkout -b $BRANCH
git commit --amend -m 'Change Sign Up button style.'
git push origin $BRANCH
PR_NUM=$(GITHUB_USER=sanketsmali GITHUB_PASSWORD=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 hub pull-request -b master -m 'Change Sign Up button style.' | egrep -o '/pull/\d+' | grep -oE '[0-9]+')

export PERCY_PULL_REQUEST=$PR_NUM
export PERCY_TARGET_BRANCH=master
# Token for https://percy.io/percy/demo-dashboardter
export PERCY_TOKEN=60489572ed8fe8a4f1c6b18234c197f1663139f0b75a868a5f6a7584df5b8580
npm test  

# Create the fake "ci/service: Tests passed" notification on the PR.
# Uses a personal access token (https://github.com/settings/tokens) which has scope "repo:status".
curl \
  -u sanketsmali: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 \
  -d '{"state": "success", "target_url": "https://example.com/build/status", "description": "Tests passed", "context": "ci/service"}' \
  "https://api.github.com/repos/sanketsmali//statuses/$(git rev-parse --verify HEAD)"

git checkout master
#git branch -D $BASE_BRANCH
git branch -D $BRANCH



