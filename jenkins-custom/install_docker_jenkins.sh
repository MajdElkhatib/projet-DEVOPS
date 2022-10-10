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

# install-plugin.sh n'existe plus, il faut utiliser jenkins-plugin-cli

docker run --name jenkins -dit -p 8080:8080 jenkins:jcasc

docker exec -it jenkins /bin/bash

# Partie 3
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code#step-3-specifying-the-jenkins-url
git pull
docker build -t jenkins:jcasc .
docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc

# Partie 4
# https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code#step-4-creating-a-user
git pull
docker build -t jenkins:jcasc .
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc

# Nettoyage
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

docker rmi jenkins:jcasc

docker images