#!/bin/bash

# This script filters static files from a project.

# Get the parameters from the CircleCI environment.
when_changeset=$CIRCLECI_PARAMETER_when_changeset
filter_branch=$CIRCLECI_PARAMETER_filter_branch

# Set the default values for the parameters.
if [ -z "$when_changeset" ]; then
  when_changeset='**/*'
fi

if [ -z "$filter_branch" ]; then
  filter_branch='main'
fi

# Filter the static files.
git filter-branch --tree-filter '
  find . -type f -exec sh -c "
    if [[ ! $1 =~ $when_changeset ]]; then
      echo "Excluding $1"
      continue
    fi

    if [[ $filter_branch = main ]]; then
      echo "Including $1"
      continue
    fi

    if [[ $filter_branch = $1 ]]; then
      echo "Including $1"
      continue
    fi

    echo "Excluding $1"
  " {} +' HEAD

# Exit with the exit code of the git filter-branch command.
exit $?