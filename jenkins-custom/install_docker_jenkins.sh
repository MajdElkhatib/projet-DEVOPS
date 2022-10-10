#!/bin/bash
# Script contenant les commandes du didacticiel:
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code

# Partie 1
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code#step-1-disabling-the-setup-wizard
# 
PROJECT_NAME="ajc-projet-final-2";

git clone "https://github.com/Romain-Revel/${PROJECT_NAME}"
cd "${PROJECT_NAME}"

git checkout jenkins

cd "jenkins-custom"

docker build -t jenkins:jcasc .

docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc

# CTRL+C

# Partie 2
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code#step-2-installing-jenkins-plugins
# 
git pull

docker build -t jenkins:jcasc .

docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc