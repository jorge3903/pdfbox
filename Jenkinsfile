import groovy.json.JsonSlurper 

/*
*This method recive a String with petition http, and obtain http code and http body
*/
def getStatusAndBody(petition){
	http_status = petition.toString()[9..11] // we obtain http code
	echo http_status // we display http code
	if (http_status.toInteger() !=200 && http_status.toInteger() !=201){ //if http code isn't 200 or 201 then there was error in petition
		http_body = petition.toString().substring(128) // we obtain http body with error
		echo http_body // we display error
		unstable("ERROR - petition status "+http_status) // we mark the pipeline as unstable
		//error("No se pudo realizar bien la operacion en la peticion de los issues")
	}else{          // if http code is 200 or 201 then the petition was success
		http_body = petition.toString().substring(128)  // we obtain http body
		echo http_body //we display http body
	}
}

pipeline {
    environment {
        DV8_CONSOLE_IP='dv8-console:8080'
        PROJECT_LANGUAGE='java'
    }
    agent none
    stages {
    
        stage('Build') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                //sh 'mvn -f originalData/pdfbox/pdfbox -B -DskipTests clean package'
                script {
	        		env.WORKSPACE="${WORKSPACE}"
	        	}
            }
        }     
        
        stage('DV8 analysis') {
        	agent any
            steps {
 		script{

		echo "preprocessing files:"
		request_proccesor= sh(returnStdout: true, script: "curl -i -o - --silent -X GET --header 'Accept: application/json' http://\${DV8_CONSOLE_IP}/preprocessor?directory=\${WORKSPACE}'&sourceCodePath=originalData/pdfbox/pdfbox'"); // we make the preprocessor request
		//echo request_proccesor
		getStatusAndBody(request_proccesor) // we analyze the preprocessor request 

                echo "generating arch-report:"
		request_arch_report=sh(returnStdout: true, script: "curl -i -o - --silent -X GET --header 'Accept: application/json' http://\${DV8_CONSOLE_IP}/arch-report?directory=\${WORKSPACE}"); // we make the arch report request
		//echo request_arch_report 
		getStatusAndBody(request_arch_report) // we analyze the arch report request

                echo "Propagation cost ="
		request_pc=sh(returnStdout: true, script: "curl -i -o - --silent -X GET --header 'Accept: application/json' http://\${DV8_CONSOLE_IP}/metrics?directory=\${WORKSPACE}'&metric=pc'"); // we make the propagation cost request
		//echo request_pc
		getStatusAndBody(request_pc) // we analyze the propagation cost request
                
                echo "Decoupling level ="
		request_dl=sh(returnStdout: true, script: "curl -i -o - --silent -X GET --header 'Accept: application/json' http://\${DV8_CONSOLE_IP}/metrics?directory=\${WORKSPACE}"); // we make the decoupling level request
		//echo request_dl
		getStatusAndBody(request_dl) // we analyze the decoupling level request

		echo "ArchIssues-Summary="
		request_issues = sh(returnStdout: true, script: "curl -i -o - --silent -X GET --header 'Accept: application/json' http://\${DV8_CONSOLE_IP}/issues?directory=\${WORKSPACE}");  // we make the issues request
		//echo request_issues
		getStatusAndBody(request_issues) // we analyze the issues request


		echo "root-debt="
		request_roots=sh(returnStdout: true, script: "curl -i -o - --silent -X GET --header 'Accept: application/json' http://\${DV8_CONSOLE_IP}/roots?directory=\${WORKSPACE}");  // we make the roots request
		// echo request_roots
		getStatusAndBody(request_roots) // we analyze the roots request
			
		}
            }
        }
        
       /* stage('Sonarqube analysis') {
            
            agent any
            environment {
                SONAR_SCANNER_OPTS = "-Xmx2g -Dsonar.projectKey=ServiceComponentRuntime -Dsonar.login=d0b15c920b2fef2f001a73b3812927ccf4baa910 -Dsonar.language=${PROJECT_LANGUAGE} -Dsonar.java.binaries=${WORKSPACE}/originalData/pdfbox/pdfbox/target/classes -Dsonar.projectBaseDir=${WORKSPACE} -Dsonar.dv8address=${DV8_CONSOLE_IP}"

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
        }*/
    } 
    post { // these methods are executed at the end of the pipeline, depending on the state in which it ends
	success{ // This method is executed if the pipe is successfully completed.
		echo "All the pipeline steps were performed correctly" 
	}
	failure{ // this method is executed if the pipeline ended with failure
		error "Pipeline failed"
	}
	unstable{ // this method is executed if the pipe ended with unestable
		unstable("Error was found in one of the pipeline steps, please check it")
	}
	always{ // this method always is executed
		echo "Pipeline finished"
	}
    }
}

