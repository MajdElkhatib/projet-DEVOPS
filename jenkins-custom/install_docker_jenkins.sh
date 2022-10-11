#!/bin/bash

# Script final

PROJECT_NAME="ajc-projet-final-2";

if [[ -d "${PROJECT_NAME}" ]]; then
    git clone "https://github.com/Romain-Revel/${PROJECT_NAME}";
fi

pwd
cd "${PROJECT_NAME}";
pwd

git pull

ls -la
git checkout dev
ls -la

pwd
cd "jenkins-custom"
pwd
ls -la

docker pull jenkins/jenkins:latest
echo "Fin du docker pull"
sleep 5

docker build -t jenkins:jcasc .
echo "Fin du docker build"
sleep 5

docker run --name jenkins -dit -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
echo "Fin du docker run"
sleep 5

# Import des jobs
JENKINS_USERNAME="admin";
JENKINS_PASSWORD="password";

bash jenkins-import-jobs.sh
echo "Fin de l'import des jobs"
sleep 5

# Ngrok
cd ../ngrok
bash install_ngrok.sh
echo "Fin de ngrok"
sleep 5
