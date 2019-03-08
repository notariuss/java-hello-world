def branch
def revision
def registryIp = "818353068367.dkr.ecr.eu-central-1.amazonaws.com/andrew"

pipeline {

    agent {
        kubernetes {
            label 'build-service-pod'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: build-service
spec:
  containers:
  - name: maven
    image: maven:3.6.0-jdk-11-slim
    command: ["cat"]
    tty: true
  - name: docker
    image: docker:18.09.2
    command: ["cat"]
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    options {
        skipDefaultCheckout true
    }

    environment {
        ECR_PASS = credentials('ecr_password')
    }

    stages {
        stage ('checkout') {
            steps {
                script {
                    def repo = checkout scm
                    revision = sh(script: 'git log -1 --format=\'%h.%ad\' --date=format:%Y%m%d-%H%M | cat', returnStdout: true).trim()
                    branch = repo.GIT_BRANCH.take(20).replaceAll('/', '_')
                    if (branch != 'master') {
                        revision += "-${branch}"
                    }
                    sh "echo 'Building revision: ${revision}'"
                }
            }

        }
        stage ('compile') {
            steps {
                container('maven') {
                    sh 'mvn clean compile test-compile'
                }
            }
        }
        stage ('build artifact') {
            steps {
                container('maven') {
                    sh "mvn package -Dmaven.test.skip -Drevision=${revision}"
                }
                container('docker') {
                    script {
                        sh "echo $ECR_PASS"
                        sh "docker login -u AWS -p ${ECR_PASS} https://818353068367.dkr.ecr.eu-central-1.amazonaws.com"
                        sh "sleep 30"
                        registryIp = sh(script: 'getent hosts registry.kube-system | awk \'{ print $1 ; exit }\'', returnStdout: true).trim()
                        sh "docker build . --build-arg REVISION=${revision}"  // . -t ${registryIp}/demo/app:${revision}
                    }
                }
            }
        }
}
}