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
                    echo "${PATH}"
                '''
            }
        }

        stage ('Build') {
            steps {
                sh 'ls /home/jenkins/tools/hudson.model.JDK/javaJDK8u201/bin'
                sh 'sleep 90'
                sh 'mvn compile'
            }
        }
    }
}