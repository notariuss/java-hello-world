def branch
def revision
def currentSlot
def tagVar

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
  - name: helm
    image: alpine/helm
    command: ["cat"]
    tty: true
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
        registryIp = "818353068367.dkr.ecr.eu-central-1.amazonaws.com/andrew"
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
                    sh 'mvn -B compile'
                }
            }
        }
        stage ('build artifact') {
            steps {
                container('maven') {
                    sh "mvn -B package -Dmaven.test.skip -Drevision=${revision}"
                }
                container('docker') {
                    script {
                        sh "docker login -u AWS -p ${ECR_PASS} ${registryIp}"
                        sh "docker build . -t ${registryIp}:${revision}"
                        sh "docker push ${registryIp}:${revision}"
                    }
                }
            }
        }
        stage ('Deploy') {
            steps {
                container('helm') {
                    script {
                        sh "helm get values --all hello"
                        currentSlot = sh(script: "helm get values --all hello | grep 'productionSlot:' | cut -d ' ' -f2 | tr -d '[:space:]'", returnStdout: true).trim()
                        if (currentSlot == "blue") {
                                newSlot="green"
                                tagVar="greenImage"
                        } else {
                                newSlot="blue"
                                tagVar="blueImage"
                        }
                        sh "helm upgrade hello java-hello-world --set ${tagVar}.tag=${revision},${newSlot}.enabled=true,productionSlot=${newSlot} --reuse-values"
                    }
                }
            }
        }
    }
}