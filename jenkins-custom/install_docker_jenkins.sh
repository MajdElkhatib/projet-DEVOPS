#!/bin/bash

# Script final
cd

PROJECT_NAME="ajc-projet-final-2";

if [[ ! -d "${PROJECT_NAME}" ]]; then
    git clone "https://github.com/Romain-Revel/${PROJECT_NAME}";
fi

pwd
cd "${PROJECT_NAME}";
pwd

git pull

git checkout dev

pwd
cd "jenkins-custom"
pwd

docker pull jenkins/jenkins:latest
echo "Fin du docker pull"
sleep 5

docker build -t jenkins:jcasc .
echo "Fin du docker build"
sleep 5

docker stop jenkins
docker rm jenkins
docker run --name jenkins --privileged -dit -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
echo "Fin du docker run"
sleep 5

# Import des jobs
export JENKINS_USERNAME="admin";
export JENKINS_PASSWORD="password";

sleep 30

bash jenkins-import-jobs.sh
echo "Fin de l'import des jobs"
sleep 5

# Ngrok
cd ../ngrok
bash install_ngrok.sh
echo "Fin de ngrok"
