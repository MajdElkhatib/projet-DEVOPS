pipeline {
    agent any
    stages {
        stage('Install tools'){
            agent any
            steps {
                sh 'yum -y install epel-release'
                sh 'yum -y install ShellCheck'
                sh 'yum -y install ansible-2.9.27'
            }
        }
        stage('check_scripts') {
            agent any
            steps {
                sh '''
                SHELLSCRIPT_PATH="$(which shellcheck)"; if [ $SHELLSCRIPT_PATH == "" ]; then yum -y install epel-release;  yum -y install ShellCheck; fi
                '''
                sh 'find . -name "*.sh" -exec shellcheck {} \\; -print'
            }
        }
        stage('Play Playbook'){
            agent any
            steps{
                ansiblePlaybook disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible/prods.yml', playbook: 'ansible/play.yml'
            }
        }
    }
}
