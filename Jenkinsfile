pipeline {
    agent any
    stages {
        stage('check_scripts') {
            agent any
            steps {
                sh '''
                SHELLSCRIPT_PATH="$(which shellcheck)"; if [ $SHELLSCRIPT_PATH == "" ]; then yum -y install epel-release;  yum -y install ShellCheck; fi
                '''
                sh 'find . -name "*.sh" -exec shellcheck {} \\; -print'
            }
        }
        stage('ansible playbook'){
            agent any
            steps{
                sh 'cd ansible'
                ansiblePlaybook{
                    inventory: "prod.yml",
                    installation: "ansible",
                    limite: "",
                    playbook: "./play.yml",
                    extras: ""
                }
            }
        }
    }
}