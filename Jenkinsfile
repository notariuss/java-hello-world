pipeline {
    agent any
    tools {
        maven 'maven360'
        jdk 'javaJDK8u201'
    }
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }

        stage ('Build') {
            steps {
                sh 'mvn compile' 
            }
        }
    }
}