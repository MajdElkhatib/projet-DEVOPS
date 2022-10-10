FROM jenkins/jenkins:latest

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY jenkins.plugins.list /usr/share/jenkins/ref/jenkins.plugins.txt

RUN jenkins-plugin-cli --list  \
    jenkins-plugin-cli  /usr/share/jenkins/ref/jenkins.plugins.txt \
    jenkins-plugin-cli --list