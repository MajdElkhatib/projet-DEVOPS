pipeline {
    agent any
    stages {
        stage('Check yaml syntax') {
            agent {
                docker {
                    image 'sdesbure/yamllint'
                }
            }
            steps {
                sh 'yamllint --version'
                sh 'yamllint ${WORKSPACE} > report_yml.log || true'
            }
            post {
                always {
                    archiveArtifacts 'report_yml.log'
                }
            }
        }
        stage('Check markdown syntax') {
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
    }
}
