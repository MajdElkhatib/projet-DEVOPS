#!/bin/bash

# Script final
newgrp docker

PROJECT_NAME="ajc-projet-final-2";

git clone "https://github.com/Romain-Revel/${PROJECT_NAME}";
pwd
cd "${PROJECT_NAME}";
pwd

ls -la
git checkout dev
ls -la

pwd
cd "jenkins-custom"
pwd
ls -la

docker build -t jenkins:jcasc .
docker run --name jenkins -dit -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc

# Import des jobs
bash jenkins-import-jobs.sh

# Ngrok
cd ../ngrok
bash install_ngrok.sh
