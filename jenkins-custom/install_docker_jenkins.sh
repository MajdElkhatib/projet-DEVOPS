#!/bin/bash

# Script final

PROJECT_NAME="ajc-projet-final-2";

git clone "https://github.com/Romain-Revel/${PROJECT_NAME}";

cd "${PROJECT_NAME}";

git checkout dev

cd "jenkins-custom"

docker build -t jenkins:jcasc .
docker run --name jenkins -dit -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc

# Import des jobs
yum install -y java
bash jenkins-import-jobs.sh

# Ngrok
cd ../ngrok
bash install_ngrok.sh
