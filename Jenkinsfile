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
            when { changeset "**/*.sh" }
            agent any
            steps {
                sh 'shellcheck */*.sh >shellcheck.log || true'
            }
            post {
                always {
                    archiveArtifacts 'shellcheck.log'
                }
            }
        }

        stage('Lint shell script files - checkstyle') {
            when { changeset "**/*.sh" }
            agent any
            steps {
                catchError(buildResult: 'SUCCESS') {
                    sh """#!/bin/bash
                        # The null command `:` only returns exit code 0 to ensure following task executions.
                        shellcheck -f checkstyle */*.sh > shellcheck.xml || true
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

        stage('Trivy Scan Project') {
            agent {
                docker {
                    image 'aquasec/trivy:latest'
                }
            }
        }

        stage ('Build docker image') {
            when { changeset "ic-webapp/releases.txt" }
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

        // https://vijetareigns.medium.com/securing-container-image-using-trivy-in-cicd-pipeline-fe445e18fb9a
        stage('Trivy Scan Image') {
            agent {
                docker {
                    image 'aquasec/trivy:latest'
                }
            }
            steps {
                script {
                    sh """
                        trivy image --format template --template \"@/home/vijeta1/contrib/html.tpl\" --output trivy_report.html sh0t1m3/ic-webapp
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "trivy_report.html", fingerprint: true
                        
                    publishHTML (target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'trivy_report.html',
                        reportName: 'Trivy Scan',
                    ])
                }
            }
        }

        stage('Scan') {
            steps {
                // Install trivy
                sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.18.3'
                sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl > html.tpl'

                // Scan all vuln levels
                sh 'mkdir -p reports'
                sh 'trivy filesystem --ignore-unfixed --vuln-type os,library --format template --template "@html.tpl" -o reports/nodjs-scan.html ./nodejs'
                publishHTML target : [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'reports',
                    reportFiles: 'nodjs-scan.html',
                    reportName: 'Trivy Scan',
                    reportTitles: 'Trivy Scan'
                ]

                // Scan again and fail on CRITICAL vulns
                sh 'trivy filesystem --ignore-unfixed --vuln-type os,library --exit-code 1 --severity CRITICAL ./nodejs'
            }
        }

        stage ('Deploy to prod with Ansible') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'ansible_user_credentials', usernameVariable: 'ansible_user', passwordVariable: 'ansible_user_pass'),
                    usernamePassword(credentialsId: 'pgadmin_credentials', usernameVariable: 'pgadmin_user', passwordVariable: 'pgadmin_pass'),
                    usernamePassword(credentialsId: 'pgsql_credentials', usernameVariable: 'pgsql_user', passwordVariable: 'pgsql_pass'),
                    string(credentialsId: 'ansible_sudo_pass', variable: 'ansible_sudo_pass')
                ])
                {
                    ansiblePlaybook (
                        disableHostKeyChecking: true,
                        installation: 'ansible',
                        inventory: 'ansible/prods.yml',
                        playbook: 'ansible/play.yml',
                        extras: '--extra-vars "NETWORK_NAME=network \
                                IMAGE_TAG=${IMAGE_TAG} \
                                ansible_user=${ansible_user} \
                                ansible_ssh_pass=${ansible_user_pass} \
                                ansible_sudo_pass=${ansible_sudo_pass} \
                                PGADMIN_EMAIL=${pgadmin_user} \
                                PGADMIN_PASS=${pgadmin_pass} \
                                DB_USER=${pgsql_user} \
                                DB_PASS=${pgsql_pass}"'
                    )
                }
            }
        }

        stage ('Test full deployment') {
            steps {
                sh '''
                    sleep 10;

                    curl -LI http://192.168.99.21 | grep "200";
                    curl -L http://192.168.99.21 | grep "IC GROUP";

                    curl -LI http://192.168.99.20:8081 | grep "200";
                    curl -L http://192.168.99.20:8081 | grep "Odoo";

                    curl -LI http://192.168.99.21:8082 | grep "200";
                    curl -L http://192.168.99.21:8082 | grep "pgAdmin 4";
                '''
            }
        }
    }
}
