---
marp: true
theme: uncover
header: 'PROJET FINAL DEVOPS - Jenkins'
footer: 'Groupe 3'
paginate: true
---

# Jenkins

---

## Infrastructure

- Serveur 1 : **192.168.99.12** Jenkins
    https://github.com/sadofrazer/jenkins-frazer.git
- Serveur 2 : **192.168.99.20** Applications web site vitrine + pgadmin4
- Serveur 3 : **192.168.99.21** Application Odoo

---

Serveurs 2 et 3 - boucle

```ruby
Vagrant.configure("2") do |config|
  array = ["odoo", "pgadmin-icwebapp"]
  # Boucle pour créer les 2
  array.each_with_index do |val, index|
        config.vm.define "docker-#{val}" do |docker|
             docker.vm.box = "geerlingguy/centos7"
                if OS.linux?
                    # Sous linux, il FAUT préciser le nom du réseau hôte
                    # https://www.vagrantup.com/docs/providers/virtualbox/networking
                    # Dans Virtualbox > Fichier > Gestionnaire de réseau hôte (CTRL + H):
                    # - Vérifier la présence de vboxnet0, sinon le créer
                    # - Vérifier l'adresse IPv4 et le masque, sinon les modifier (à faire 2 fois pour être pris en compte)
                    #
                    # Vérifier avec "ip -a" le nom, l'IP et le masque
                    docker.vm.network "private_network",  type: "static", ip: "192.168.99.2#{index}", name: "vboxnet0"
                elsif OS.windows?
                        docker.vm.network "private_network",  type: "static", ip: "192.168.99.2#{index}"
                else
                        puts 'OS not managed'
                end
                docker.vm.hostname = "docker-#{val}"
                docker.vm.provider "virtualbox" do |v|
                        v.name = "docker-#{val}"
                        v.memory = 1024
                        v.cpus = 1
                end
                docker.vm.provision :shell do |shell|
                        shell.path = "install_docker.sh"
                        shell.env = { 'ENABLE_ZSH' => ENV['ENABLE_ZSH'] }
                end
        end
  end
end
# Fin
```

---

## Serveur 1 - Script d'installation

```bash
#!/bin/bash
# Script d'installation de Jenkins fourni par Dirane
yum -y update
yum -y install epel-release
# install ansible
yum -y install ansible
# retrieve ansible code
yum -y install git
git clone https://github.com/diranetafen/cursus-devops.git
cd cursus-devops/ansible
ansible-galaxy install -r roles/requirements.yml
ansible-playbook install_docker.yml
sudo usermod -aG docker vagrant
cd ../jenkins
/usr/local/bin/docker-compose up -d
echo "For this Stack, you will use $(ip -f inet addr show enp0s8 | \
sed -En -e 's/.*inet ([0-9.]+).*/\1/p') IP Address"
```

---

## Serveur 1 - Interface

---

## Serveur 1 - Inconvénients

- Version datée
- Interface web laide et non ergonomique
- Installation ne partageant pas:
    - Comptes
    - Plugins
    - Jobs
    - Secrets
    - Configuration globale

---

## Serveur 1 - Automatisation de l'installation



---

```docker
FROM jenkins/jenkins:lts-jdk11
USER root
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins.casc.yml
# Installation
RUN apt-get update && \
    apt-get install -qy curl python3 python3-pip sshpass shellcheck && \
    pip3 install ansible && \
    curl -sSL https://get.docker.com/ | sh

USER jenkins
# Plugins Jenkins
COPY jenkins.plugins.txt /usr/share/jenkins/ref/jenkins.plugins.txt
RUN jenkins-plugin-cli --list && \
    jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/jenkins.plugins.txt && \
    jenkins-plugin-cli --list
# Configuration as code Jenkins
COPY jenkins.casc.yml /var/jenkins_home/jenkins.casc.yml
```

---

## Plugins Jenkins par défaut

```text
antisamy-markup-formatter:latest
build-timeout:latest
cloudbees-folder:latest
credentials-binding:latest
email-ext:latest
git:latest
github-branch-source:latest
mailer:latest
pam-auth:latest
pipeline-github-lib:latest
pipeline-stage-view:latest
ssh-slaves:latest
timestamper:latest
workflow-aggregator:latest
ws-cleanup:latest
```

---

## Plugins Jenkins supplémentaires

```text
ansible:latest
authorize-project:latest
configuration-as-code:latest
docker-plugin:latest
docker-workflow:latest
matrix-auth:latest
```

---

Image UI Jenkins récent...

---

## jenkins-cli

https://www.jenkins.io/doc/book/managing/cli/

---

```bash
#/bin/bash
# Téléchargement de jenkins-cli
if [[ -z "${JENKINS_USERNAME}" ]]; then
    echo "La variable JENKINS_USERNAME n'existe pas. Veuillez l'exporter.";
    exit 1;
fi
if [[ -z "${JENKINS_PASSWORD}" ]]; then
    echo "La variable JENKINS_PASSWORD n'existe pas. Veuillez l'exporter.";
    exit 1;
fi
# Valeurs par défaut
[[ ! -z "${JENKINS_IP}" ]] || JENKINS_IP="192.168.99.13";
[[ ! -z "${JENKINS_PORT}" ]] || JENKINS_PORT="8080";
URL="http://${JENKINS_IP}:${JENKINS_PORT}";
JOB_NAME="TEST";
# Téléchargement de la cli jenkins
if [[ ! -f "jenkins-cli.jar" ]]; then
    wget "${URL}/jnlpJars/jenkins-cli.jar";
fi
```

---

```bash
# Pour lister les jobs
java -jar jenkins-cli.jar -s "${URL}" -auth "${JENKINS_USERNAME}":"${JENKINS_PASSWORD}" list-jobs;

# Récupérer la liste de tous les jobs et les exporter
JOBS=$(java -jar jenkins-cli.jar -s "${URL}" -auth "${JENKINS_USERNAME}":"${JENKINS_PASSWORD}" list-jobs);
mkdir -p "jobs";
for JOB_NAME in $JOBS
do
    java -jar jenkins-cli.jar -s "${URL}" -auth "${JENKINS_USERNAME}":"${JENKINS_PASSWORD}" get-job "${JOB_NAME}" > "jobs/${JOB_NAME}.xml";
done
```

---

## Job ic-webapp-pipeline
```xml
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@1189.va_d37a_e9e4eda_">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition@2.2114.v2654ca_721309"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition@2.2114.v2654ca_721309">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <com.coravy.hudson.plugins.github.GithubProjectProperty plugin="github@1.34.3.1">
      <projectUrl>https://github.com/Romain-Revel/ajc-projet-final-2.git/</projectUrl>
      <displayName></displayName>
    </com.coravy.hudson.plugins.github.GithubProjectProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <com.cloudbees.jenkins.GitHubPushTrigger plugin="github@1.34.3.1">
          <spec></spec>
        </com.cloudbees.jenkins.GitHubPushTrigger>
        <hudson.triggers.SCMTrigger>
          <spec>*/10 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2729.vea_17b_79ed57a_">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.12.1">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/Romain-Revel/ajc-projet-final-2.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/dev</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
```

---

```bash
# Restaurer tous les jobs
for JOB_FILE in $(cd "jobs"; ls *.xml)
do
    # echo $JOB_FILE
    # echo ${JOB_FILE%%.xml}
    java -jar jenkins-cli.jar -s "${URL}" -auth "${JENKINS_USERNAME}":"${JENKINS_PASSWORD}" create-job "${JOB_FILE%%.xml}" < "jobs/${JOB_FILE}"
done
```

---

Image jobs ?

---

## Configuration de Jenkins

Plugin [Configuration as code](https://plugins.jenkins.io/configuration-as-code/)
- Compte(s) admin
- URL
- Credentials
- Security (bonus)

---

```groovy
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      enableCaptcha: false
      users:
        - id: admin
          password: password
          properties:
          - "apiToken"
          - mailer:
              emailAddress: "admin@hotmail.fr"
          - preferredProvider:
              providerId: "default"
```

---

```groovy
unclassified:
  location:
    url: http://192.168.99.13:8080/
```

---

```groovy
credentials:
  system:
    domainCredentials:
    - credentials:
      - string:
          description: "Token dockerhub"
          id: "dockerhub"
          scope: GLOBAL
          secret: "{AQAAABAAAAAw632BD8V0u3jO0s90yYiMwllBr6OzIrtmGMqWAEvtIDcqXa2XCyH2WBJPrmSdH9fPnShuX2v4AMjjUbicqwo2Ag==}"
      - usernamePassword:
          id: "ansible_user_credentials"
          password: "vagrant"
          scope: GLOBAL
          username: "vagrant"
          usernameSecret: true
      - usernamePassword:
          id: "pgadmin_credentials"
          password: "pgadmin"
          scope: GLOBAL
          username: "pgadmin@local.domain" // @ Très important
          usernameSecret: true
```

---

```groovy
jenkins:
  //...
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "USER:Overall/Administer:admin"
        - "GROUP:Overall/Read:authenticated"
  remotingSecurity:
      enabled: true

security:
  queueItemAuthenticator:
    authenticators:
    - global:
        strategy: triggeringUsersAuthorizationStrategy
```

---

## Pipeline(s)

```groovy
// Jenkinsfile
pipeline {

    environment {
        IMAGE_NAME = "ic-webapp"
        IMAGE_TAG = "${sh(returnStdout: true, script: 'cat ic-webapp/releases.txt |grep version | cut -d\\: -f2|xargs')}"
        CONTAINER_NAME = "ic-webapp"
        USER_NAME = "sh0t1m3"
    }

    agent any

    stages {
        // stage 1...
    }
}
```

---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



---



