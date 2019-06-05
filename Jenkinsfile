/*

Set up Jenkins container
docker run -t --rm -u root -p 8080:8080 -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME":/home --network mynet --name jenkins jenkinsci/blueocean

Set up DV8 container
docker run -it --rm -p 8000:8080 -v jenkins-data:/var/jenkins_home --network mynet --name dv8-console dv8-console java -jar gs-rest-service-0.1.0.jar

See the containers ip address
docker network inspect mynet

ServiceComponentRuntime

*/
pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    environment {
        WORKING_DIR='/var/jenkins_home/workspace/ServiceComponentRuntime@2'
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }  
        
        /*
        stage('Sonarqube analysis') {
            environment {
                SONAR_SCANNER_OPTS = "-Xmx2g -Dsonar.projectKey=Test -Dsonar.login=202b6aef450f839353fc0f087248c4a8a566c9e1 -Dsonar.java.binaries=/var/jenkins_home/workspace/JenkinsSonarqube@2/target/classes"
            } 
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "/var/jenkins_home/sonar-scanner/sonar-scanner-3.3.0.1492-linux/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
                }
            }
        }
        */
        
        

        stage('DV8 analysis') {
            steps {
                sh 'curl http://172.18.0.2:8080/preprocessor?directory=${WORKING_DIR}'

                sh 'curl http://172.18.0.2:8080/arch-report?directory=${WORKING_DIR}'

            }
        }


    }
}
