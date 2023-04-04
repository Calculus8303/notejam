
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
                        env.old = sh (
                                    script: 'date "+%Y%m%d-%H-%M"',
                                    returnStdout: true
                                     ).trim()
                        stage('Clean') {
                            sh '''
                                cp /home/ubuntu/notejam/notejam.db /home/ubuntu/notejam.db.${old}
                                find /home/ubuntu/notejam/* ! -name 'notejam.db' -delete
                            '''.stripIndent()
                        }
                        stage('Unstash and Move') {
                            // Retrieve the built artifacts
                            unstash 'notejam-artifacts'
                            // Move the built artifacts to the desired location
                            sh '''
                                cp -r * /home/ubuntu/notejam/
                                cmp /home/ubuntu/notejam/notejam.db /home/ubuntu/notejam.db.${old}
                                systemctl restart notejam
                                '''.stripIndent()
                        }
                    }
                }
            } catch (e) {
                currentBuild.result = 'FAILED'
                throw e
            } finally {
                cleanWs()
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
    discordSend description: "Automated alert" , footer: "Signature", link: env.BUILD_URL, result: buildStatus, title: subject, webhookURL: "https://discord.com/api/webhooks/1092779924923883560/Wq6nIfcxIbVK1cwCO9Eg24-b10_xNN9h4S6iF3V_LB3oDzWZy0WRQoAMX5mNXccexpUN"
}
