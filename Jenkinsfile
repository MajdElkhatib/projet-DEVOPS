pipeline {
    agent any
    stages {
        stage('check_scripts') {
            agent any
            steps {
                sh '''
                SHELLSCRIPT_PATH="$(which shellscript)"
                if [ $SHELLSCRIPT_PATH == "" ]; then
                    yum -y install epel-release
                    yum -y install ShellCheck
                fi
                '''
                sh 'find . -name "*.sh" -exec shellcheck {} \\; -print'
            }
        }
    }
}