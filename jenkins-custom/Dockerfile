FROM jenkins/jenkins:latest

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY jenkins.plugins.list /usr/share/jenkins/ref/jenkins.plugins.list

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/jenkins.plugins.list