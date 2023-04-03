properties([
    disableConcurrentBuilds()
])

timestamps {
    ansiColor('xterm') {
        node {
            try {
                notifyBuild('STARTED')
                node {
                    stage('Build') {
                        if (env.BRANCH_NAME == 'master') {
                            // Build and deploy the project if master branch
                            node('main') {
                                checkout scm
                                sh '''
                                    npm install
                                    node db.js
                                    rm -rf node_modules/ package-lock.json
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
                                    rm package-lock.json
                                    rm -rf node_modules
                                '''.stripIndent()

                                // Stash the built artifacts
                                stash includes: '**/*', name: 'notejam-artifacts'
                            }
                        }
                    }

                    stage('Clean') {
                        node(
                             label 'main'
                            ) {
                                sh '''
                                rm -rf /home/ubuntu/notejam || true
                                mkdir /home/ubuntu/notejam
                                pm2 stop 0 || true
                                pm2 delete www || true
                                '''.stripIndent()
                        }
                    }
                    node('main') {
                        workspace = '/home/ubuntu/notejam'
                            stage('Unstash and Run') {
                                {
                                
                                unstash 'notejam-artifacts'

                                sh '''
                                pm2 ./bin/www > /dev/null 2>&1 --watch &&  pm2 save
                                lsof -i :3000
                                '''.stripIndent()
                            }
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
    buildStatus =  buildStatus ?: 'SUCCESS'

    def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = "${subject} (${env.BUILD_URL})"

    def color, colorCode

    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFF00'
    } else if (buildStatus == 'SUCCESS') {
        color = 'GREEN'
        colorCode = '#00FF00'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
    }
    discordSend description: "Automated alert" , footer: "Signature", link: env.BUILD_URL, result: buildStatus, title: subject, webhookURL: "https://discord.com/api/webhooks/1091073718933000302/Z2OaJfjE9q-_KTbUxohhGrU_uzpwVuLynuYmXqh9m3gDgWGifgrv2fYysMXRxiJeFXKo"
}
