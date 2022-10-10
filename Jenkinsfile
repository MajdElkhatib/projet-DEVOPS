pipeline {

  environment {
    IMAGE_NAME = "ic-webapp"
    IMAGE_TAG = "${sh(returnStdout: true, script: 'cat ic-webapp/releases.txt |grep version | cut -d\\: -f2|xargs')}"
    CONTAINER_NAME = "ic-webapp"
    USER_NAME = "sh0t1m3"
  }

  agent any

  stages {

    stage('Lint yaml files') {
        when { changeset "**/*.yml"}
        agent {
            docker {
                image 'sdesbure/yamllint'
            }
        }
        steps {
            sh 'yamllint --version'
            sh 'yamllint ${WORKSPACE} >report_yml.log || true'
        }
        post {
            always {
                archiveArtifacts 'report_yml.log'
            }
        }
    }

    stage('Lint markdown files') {
        when { changeset "**/*.md"}
        agent {
            docker {
                image 'ruby:alpine'
            }
        }
        steps {
            sh 'apk --no-cache add git'
            sh 'gem install mdl'
            sh 'mdl --version'
            sh 'mdl --style all --warnings --git-recurse ${WORKSPACE} > md_lint.log || true'
        }
        post {
            always {
                archiveArtifacts 'md_lint.log'
            }
        }
    }

    stage("Lint ansible playbook files") {
        when { changeset "ansible/**/*.yml"}
        agent {
            docker {
                image 'registry.gitlab.com/robconnolly/docker-ansible:latest'
            }
        }
        steps {
        sh '''
            cd "${WORKSPACE}/ansible/"
            ansible-lint play.yml > "${WORKSPACE}/ansible-lint.log" || true
        '''
        }
        post {
            always {
                archiveArtifacts "ansible-lint.log"
            }
        }
    }

    stage('Lint shell script files') {
        when { changeset "**/*.sh"}
        agent any
        steps {
            sh 'yum -y clean all && yum -y install epel-release && yum -y install ShellCheck'
            sh 'shellcheck */*.sh >shellcheck.log'
        }
        post {
            always {
                archiveArtifacts 'shellcheck.log'
            }
        }
    }

    stage('Lint shell script files - checkstyle') {
        when { changeset "**/*.sh"}
        agent any
        steps {
            catchError(buildResult: 'SUCCESS') {
                sh """#!/bin/bash
                    # The null command `:` only returns exit code 0 to ensure following task executions.
                    shellcheck -f checkstyle */*.sh > shellcheck.xml || :
                """
            }
        }
        post {
            always {
                archiveArtifacts 'shellcheck.xml'
            }
        }
    }

    stage ("Lint docker files") {
        when { changeset "**/Dockerfile"}
        agent {
            docker {
                image 'hadolint/hadolint:latest-debian'
            }
        }
        steps {
            sh 'hadolint $PWD/**/Dockerfile | tee -a hadolint_lint.log'
        }
        post {
            always {
                archiveArtifacts 'hadolint_lint.log'
            }
        }
    }

    stage ('Build docker image') {
        when { changeset "ic-webapp/releases.txt"}
        steps{
            script{
                sh '''
                cd 'ic-webapp';
                docker build -t ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .;
                '''
            }
        }
    }

    stage ('Test docker image') {
        when { changeset "ic-webapp/releases.txt"}
        steps{
            script{
            sh '''
                docker stop ${CONTAINER_NAME} || true;
                docker rm ${CONTAINER_NAME} || true;
                docker run -d --name ${CONTAINER_NAME} -p 9090:8080 ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG};
                sleep 3;
                curl http://192.168.99.12:9090 | grep -q "IC GROUP";
                docker stop ${CONTAINER_NAME};
                docker rm ${CONTAINER_NAME};
            '''
            }
        }
    }

    stage ('Login and push docker image') {
        when { changeset "ic-webapp/releases.txt"}
        agent any
        environment {
            DOCKERHUB_PASSWORD  = credentials('dockerhub')
        }
        steps {
            script {
            sh '''
                echo "${DOCKERHUB_PASSWORD}" | docker login -u ${USER_NAME} --password-stdin;
                docker push ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG};
            '''
            }
        }
    }

    stage ('Deploy to prod with Ansible') {
        steps {
            sh 'yum -y clean all && yum -y install epel-release && yum -y install ansible-2.9.27'
            ansiblePlaybook disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible/prods.yml', playbook: 'ansible/play.yml'
        }
    }

    stage ('Test full deployment') {
        steps {
            sh '''
                curl -LI http://192.168.99.21 | grep "200";
                curl -L http://192.168.99.21 | grep "IC GROUP";
                
                curl -LI http://192.168.99.20:8081 | grep "200";
                curl -L http://192.168.99.20:8081 | grep "Database Name";

                curl -LI http://192.168.99.21:8082 | grep "200";
                curl -L http://192.168.99.21:8082 | grep "pgAdmin 4";
            '''
        }
    }
  }
}
