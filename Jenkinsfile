pipeline {
    agent any
    stages {
        stage('check_scripts') {
            agent any
            steps {
                sh 'find . -name "*.sh" -exec shellcheck {} \\; -print'
            }
        }
    }
}