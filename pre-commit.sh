#!/bin/sh
#This script will run on every commit. Goals are to run coffeelint
#and test-suite to control code quality
#http://codeinthehole.com/writing/tips-for-using-a-git-pre-commit-hook/
#ln -s ../../pre-commit.sh .git/hooks/pre-commit


coffeelint -r ./main/app
RESULT=$?

if [ ${RESULT} != 0 ]; then
  echo 'Coffeelint failed, aborting commit'
  exit 1
else 
  echo 'Coffeelint Passed.'
  exit 0
fi
