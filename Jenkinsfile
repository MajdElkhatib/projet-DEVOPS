pipeline {

  environment{
    IMAGE_NAME = "ic-webapp"
    TAG = ""
    CONTAINER_NAME = "ic-webapp"
    USER_NAME = "sh0t1m3"
  }

  agent none

  stages {
    stage('Check yaml syntax') {
      agent { docker { image 'sdesbure/yamllint } }
      steps {
        sh 'yamllint --version'
        sh 'yamllint \${WORKSPACE}'
      }
    }
    stage('Check markdown syntax') {
      agent { docker { image 'ruby:alpine'} }
      steps {
        sh 'apk --no-cache add git'
        sh 'gem install mdl'
        sh 'mdl --version'
        sh 'mdl --style all --warnings --git-recurse \${WORKSPACE}'

      }
    }

    stage('Prepare ansible environment') {
      agent any
      environment {
        VAULTKEY = credentials('valtkey')
      }
      steps {
        sh 'echo \$VAULTKEY > vault.key'
      }
    }
    stage('test and deploy the application'){
      environment {
        SUDOPASS = credentials('sudopass')
      }
      agent { docker { image 'registry.gitlab.com/robconnolly/docker-ansible:latest' } }
      stages {
        stage("verify ansible playbook syntax") {
          steps {
            sh 'ansible-lint play.yml'
          }
        }
        stage("Deploy app in production") {
          when {
            expression { GIT_BRANCH == 'origin/master' }
          }
          steps {
            sh '''
            apt-get update
            apt-get install -y sshpass
            ansible-playbook -i prods.yml --vault-password-file vault.key --extra-vars "ansible_sudo_pass=$SUDOPASS" play.yml
          }
        }
      }

      stage ('Build Image'){
        steps{
          script{
              sh '''
                  docker build -t ${USER_NAME}/${IMAGE_NAME}:${TAG} .
              '''
          }
        }
      }

      stage ('Test Image'){
        steps{
          script{
            sh '''
                docker run -d --name ${CONTAINER_NAME} -p 9090:8080 ${USER_NAME}/${IMAGE_NAME}:${TAG}
                sleep 3
                curl http://localhost:9090 | grep -q "IC GROUP"
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
            '''
          }
        }
      }

    }

  }
