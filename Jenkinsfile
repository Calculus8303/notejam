properties([
    disableConcurrentBuilds()
])

timestamps {
    ansiColor('xterm') {
        node('master') {
            try {
                notifyBuild('STARTED')
                stage('Checkout') {
                    checkout scm
                }
                node {
                    stage('Build') {
                        if (env.BRANCH_NAME == 'master') {
                            // Build and deploy the project if master branch
                            sh '''
                                pm2 stop 0 || true
                                pm2 delete www || true
                                npm install
                                node db.js
                                pm2 start ./bin/www
                            '''.stripIndent()
                        } else {
                            println 'Skip to build on Spot due to branch not master'
                        }
                    }

                    stage('Build and stash on other branches') {
                        if (env.BRANCH_NAME != 'master') {
                            node('spot') {
                                sh '''
                                    npm install
                                    node db.js
                                '''.stripIndent()

                                // Stash the built artifacts
                                stash includes: '**/*', name: 'notejam-artifacts'
                            }
                        }
                    }

                    stage('Unstash and Run') {
                        if (env.BRANCH_NAME != 'master') {
                            node('main') {
                                unstash 'notejam-artifacts'

                                sh '''
                                    pm2 stop 0 || true
                                    pm2 delete www || true
                                    pm2 start ./bin/www
                                '''.stripIndent()
                            }
                        }
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
}

def notifyBuild(String buildStatus = 'STARTED') {
    // build status of null means successful
    buildStatus =  buildStatus ?: 'SUCCESSFUL'

    def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = "${subject} (${env.BUILD_URL})"

    def color, colorCode

    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFF00'
    } else if (buildStatus == 'SUCCESSFUL') {
        color = 'GREEN'
        colorCode = '#00FF00'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
    }

    slackSend(color: colorCode, message: summary)
}
