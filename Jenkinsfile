pipeline {

  environment{
    IMAGE_NAME = "ic-webapp"
    TAG = ""
    CONTAINER_NAME = "ic-webapp"
    USER_NAME = "sh0t1m3"
    DOCKERHUB_PASSWORD = "dckr_pat_mp7W160KkogvJB6nUqW3nsAmsxM"
  }

  agent none

  stages {
    stage('Check yaml syntax') {
      agent { docker { image 'sdesbure/yamllint' } }
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
            '''
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

      stage ('Login and Push Image on docker hub') {
        agent any
        environment {
          DOCKERHUB_PASSWORD  = credentials('dockerhub')
        }
          steps {
            script {
              sh '''
                echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
                docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
              '''
            }
          }
      }

    }

  }
