pipeline {
    agent any
	
	stages {
		parallel{
			stage('front11_build_deploy') {
				steps {
					build(job: "/front11/Jenkinsfile")
				}
			}
			stage('ffront22_build_deploy') {
				steps {
					build(job: "/front22/Jenkinsfile")
				}
			}
		}
	}
}
