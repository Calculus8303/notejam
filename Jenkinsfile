pipeline {
  agent none

  stages {
    stage('Build') {
      when {
        expression {
          BRANCH_NAME == 'master'
        }
      }

      agent {
        label 'main'
      }

      steps {
        // Build the project
		sh 'pm2 stop 0 || true'
		sh 'pm2 delete www || true'
		sh 'npm install'
                sh 'node db.js'
		sh 'pm2 start ./bin/www'
      }
    }


    stage('Deploy') {
      when {
        expression {
          BRANCH_NAME != 'master'
        }
      }

      agent {
        label 'spot'
      }

      steps {
	    sh 'npm install'
        sh 'node db.js'
        // Stash the built artifacts
        stash includes: '**/*', name: 'notejam-artifacts'
      }
    }

    stage('Unstash and Run') {
      when {
        expression {
          BRANCH_NAME != 'master'
        }
      }

      agent {
        label 'main'
      }

      steps {
        // Unstash the built artifacts and run the application
        unstash 'notejam-artifacts'
		sh 'pm2 stop 0 || true'
		sh 'pm2 delete www || true'
	        sh 'pm2 start ./bin/www'		
		}
    }
  }
}
