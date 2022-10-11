FROM jenkins/jenkins:latest

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins.casc.yml

RUN curl -fsSL https://get.docker.com/ -o /tmp/get-docker.sh && \
    bash /tmp/get-docker.sh

COPY jenkins.plugins.txt /usr/share/jenkins/ref/jenkins.plugins.txt

RUN jenkins-plugin-cli --list && \
    jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/jenkins.plugins.txt && \
    jenkins-plugin-cli --list

COPY jenkins.casc.yml /var/jenkins_home/jenkins.casc.yml
