pipeline {

  environment {
    IMAGE_NAME = "ic-webapp"
    IMAGE_TAG = "1.0"
    CONTAINER_NAME = "ic-webapp"
    USER_NAME = "sh0t1m3"
  }

  agent any

  stages {

    stage('Lint yaml files') {
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
        environment {
            IMAGE_TAG = "${sh(returnStdout: true, script: 'cat ic-webapp/releases.txt |grep version | cut -d\\: -f2|xargs')}"
        }
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
  }
}
