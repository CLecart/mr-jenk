// Minimal, well-formed declarative Jenkinsfile used to validate the controller
// behaviour. Keep this file intentionally small while we stabilise the pipeline.
pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        timeout(time: 30, unit: 'MINUTES')
        ansiColor('xterm')
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn -B -DskipTests package'
                    } else {
                        echo 'No pom.xml: skipping build'
                    }
                }
            }
        }
        stage('Smoke') {
            steps { echo 'pipeline minimal smoke test' }
        }
    }
    post {
        success { echo 'OK' }
        failure { echo 'KO' }
        always { archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true }
    }
}

/**
 * Send a Slack notification
 *
 * @param status the build status
 */
def sendSlackNotification(String status) {
    def color = [
        'SUCCESS': 'good',
        'FAILURE': 'danger',
        'UNSTABLE': 'warning',
        'ABORTED': '#808080',
        'ROLLBACK': '#FFA500'
    ][status] ?: '#808080'
    
    def emoji = [
        'SUCCESS': ':white_check_mark:',
        'FAILURE': ':x:',
        'UNSTABLE': ':warning:',
        'ABORTED': ':stop_sign:',
        'ROLLBACK': ':rewind:'
    ][status] ?: ':question:'
    
    def message = [
        'SUCCESS': 'Build succeeded!',
        'FAILURE': 'Build failed!',
        'UNSTABLE': 'Build unstable',
        'ABORTED': 'Build aborted',
        'ROLLBACK': 'Rollback executed!'
    ][status] ?: 'Unknown status'
    
    slackSend(
        tokenCredentialId: 'slack-webhook',
        channel: '#ci-notifications',
        color: color,
        message: """
            ${emoji} *${message}*
            
            *Job:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
            *Branch:* ${env.BRANCH_NAME}
            *Commit:* ${env.GIT_COMMIT_SHORT} by ${env.GIT_AUTHOR}
            *Environment:* ${params.ENVIRONMENT}
            
            <${env.BUILD_URL}|View build>
        """.stripIndent()
    )
}
