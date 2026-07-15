#!/usr/bin/env bash

# Get the commit message
commit_msg=$(cat $1)

# Define a regex pattern to match the conventional commit message format
pattern='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-z]+\))?!?: .+$'

# Test if the commit message matches the pattern
if ! [[ $commit_msg =~ $pattern ]]; then
  echo "ERROR: The commit message does not match the Conventional Commits format."
  echo "       Please use the format: type(scope)?: subject"
  echo "       Where 'type' is one of: build, chore, ci, docs, feat, fix,
               perf, refactor, revert, style, test."
  exit 1
fi

# If the commit message matches the pattern, exit successfully
exit 0