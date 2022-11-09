#!/bin/bash

echo "----------------------STARTING SCRIPT-----------------------------------"
cd ..
ls -la
USER_PASS=$(cat user_pass)
SERVER_IPf1=$(cat server_ipf1)
USER_NAME=$(cat user_name)

cd frontOne/
BUILD_DIR=build/
ls -la

echo "----------------------DIRECTORY VERIFICATION---------------------------"

if [ -d $BUILD_DIR ]
then
  rm -r build/
  echo "----------------BUILD DIRECTORY HAS BEEN SUCCESFULLY DELETED------------"
else
  echo "-------------------DIRECTORY DOES NOT EXISTS-------------------------"
fi

echo "-------------------STARTING AUTENTICATION PROCESS------------------------"

#apk update && apk add openssh-client bash
mkdir -p ~/.ssh
eval $(ssh-agent -s)
echo $USER_PASS > /dev/null 2>&1
echo "$USER_PASS" | tr -d '\r' | ssh-add - > /dev/null 
touch ~/.ssh/config
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
ssh-keyscan -H $SERVER_IPf1 >> ~/.ssh/known_host

echo "-------------------------BUILDING FRONT 1----------------------------------"

npm install
CI=false npm run build 
ls

echo "------------------------DEPLOYING FRONT 1---------------------------------"
ssh-add <(echo "$USER_PASS")
scp -v -r build/ $USER_NAME@$SERVER_IPf1:/var/www/html
