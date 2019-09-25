pipeline {
    environment {
        DV8_CONSOLE_IP='dv8-console:8080'
        PROJECT_LANGUAGE='java'
        
    }
    agent none
    options {
        skipStagesAfterUnstable()
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
                script {
	        		env.WORKSPACE="${WORKSPACE}"
	        	}
            }
        } 

        
        
        stage('DV8 analysis') {
        	agent any
            steps {
                /* sh 'curl http://${DV8_CONSOLE_IP}:8080/test-connection 2>/dev/null|jq -r .result' */

                echo "preprocessing files:"
                sh 'curl http://${DV8_CONSOLE_IP}/preprocessor?directory=${WORKSPACE}'
                

                echo "generating arch-report:"
                sh 'curl http://${DV8_CONSOLE_IP}/arch-report?directory=${WORKSPACE}'

                echo "Propagation cost ="
                echo sh(returnStdout: true, script: 'curl -X POST http://${DV8_CONSOLE_IP}/metrics -d "directory=${WORKSPACE}&metric=pc" 2>/dev/null')
                
                echo "Decoupling level ="
                echo sh(returnStdout: true, script: 'curl -X POST http://${DV8_CONSOLE_IP}/metrics -d "directory=${WORKSPACE}&metric=dl" 2>/dev/null')

		echo "ArchIssues-Summary="
		sh 'curl http://${DV8_CONSOLE_IP}/archIssues-sumary?directory=${WORKSPACE}'		
            }
        }
       
        
        stage('Sonarqube analysis') {
            
            agent any
            environment {
                SONAR_SCANNER_OPTS = "-Xmx2g -Dsonar.projectKey=ServiceComponentRuntime -Dsonar.login=REPLACE_TOKEN_HERE -Dsonar.language=${PROJECT_LANGUAGE} -Dsonar.java.binaries=${WORKSPACE}/target/classes -Dsonar.projectBaseDir=${WORKSPACE} -Dsonar.dv8address=${DV8_CONSOLE_IP}"

        		scannerHome = tool 'SonarQubeScanner'
    		}
    		steps {
        		withSonarQubeEnv('SonarQube') {
            		sh "${scannerHome}/bin/sonar-scanner"
        		}

        		timeout(time: 10, unit: 'MINUTES') {
            		waitForQualityGate abortPipeline: true
            	}
            }
        }
    }
}
