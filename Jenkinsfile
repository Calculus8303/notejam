timestamps {
    ansiColor('xterm') {
        try {
            notifyBuild('STARTED')
            stage('Build') {
                if (env.BRANCH_NAME == 'master') {
                    // Build and deploy the project if master branch
                    node('regular') {
                        checkout scm
                        sh '''
                            npm install
                            node db.js
                            rm package-lock.json notejam.db
                        '''.stripIndent()

                        // Stash the built artifacts
                        stash includes: '**/*', name: 'notejam-artifacts'
                    }
                } else {
                    println 'Skip to build on Spot due to branch not master'
                }
            }

            stage('Build and stash on other branches') {
                if (env.BRANCH_NAME != 'master') {
                    node('spot') {
                        checkout scm
                        sh '''
                            npm install
                            node db.js
                            rm package-lock.json notejam.db
                        '''.stripIndent()

                        // Stash the built artifacts
                        stash includes: '**/*', name: 'notejam-artifacts'
                    }
                }
            }
            
            node('main') {
                stage('Clean') {
                    sh '''
                        find /home/ubuntu/notejam ! -name 'notejam.db' -delete
                    '''.stripIndent()
                }

                stage('Unstash and Move') {
                    // Retrieve the built artifacts
                    unstash 'notejam-artifacts'
                    // Move the built artifacts to the desired location
                    sh '''
                        rsync -avzH . /home/ubuntu/notejam/
                        systemctl restart notejam
                        '''.stripIndent()
                }
            }
        } catch (e) {
            currentBuild.result = 'FAILED'
            throw e
        } finally {
            notifyBuild(currentBuild.result)
        }
    }
}
