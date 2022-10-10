#!/bin/bash

PROJECT_NAME="ajc-projet-final-2";

git clone "https://github.com/Romain-Revel/${PROJECT_NAME}"
cd "${PROJECT_NAME}"

git checkout jenkins

cd "jenkins-custom"

docker build -t jenkins:jcasc .

docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc
