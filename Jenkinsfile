/**
 * Jenkinsfile — CI/CD Pipeline for E-commerce Microservices
 *
 * Features:
 *   - Parameterized builds (environment selection)
 *   - Automated tests (JUnit backend, Karma/Jasmine frontend)
 *   - Pipeline fails on test failure
 *   - Deployment with rollback strategy
 *   - Email/Slack notifications
 *   - Distributed builds support (agent labels)
 */
pipeline {
    agent any

    // =========================================================================
    // PARAMETERIZED BUILDS (Bonus)
    // =========================================================================
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Deployment target environment'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip tests (use with caution)'
        )
        booleanParam(
            name: 'FORCE_DEPLOY',
            defaultValue: false,
            description: 'Deploy even if no changes detected'
        )
    }

    // =========================================================================
    // BUILD TRIGGERS — Auto-trigger on push (webhook)
    // =========================================================================
    triggers {
        githubPush()  // Triggered by GitHub webhook on push
        pollSCM('H/5 * * * *')  // Fallback: poll every 5 min if webhook fails
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        timeout(time: 30, unit: 'MINUTES')
        ansiColor('xterm')
        timestamps()
    }

    environment {
        // Credentials (stored in Jenkins Credentials)
        DEPLOY_CREDS = credentials('deploy-credentials')
        DOCKER_REGISTRY = 'docker.io'
        APP_NAME = 'ecommerce-app'
    }

    stages {
        // =====================================================================
        // STAGE 1: Checkout source code from Git
        // =====================================================================
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.GIT_AUTHOR = sh(script: 'git log -1 --format=%an', returnStdout: true).trim()
                }
            }
        }

        // =====================================================================
        // STAGE 2: Build Backend (Java/Maven)
        // =====================================================================
        stage('Build Backend') {
            when { expression { fileExists('pom.xml') || fileExists('backend/pom.xml') } }
            steps {
                script {
                    def pomPath = fileExists('pom.xml') ? '.' : 'backend'
                    dir(pomPath) {
                        sh 'mvn -B -DskipTests clean package'
                    }
                }
            }
        }

        // =====================================================================
        // STAGE 3: Build Frontend (Angular/Node)
        // =====================================================================
        stage('Build Frontend') {
            when { expression { fileExists('package.json') || fileExists('frontend/package.json') } }
            steps {
                script {
                    def frontendPath = fileExists('package.json') ? '.' : 'frontend'
                    dir(frontendPath) {
                        sh 'npm ci'
                        sh 'npm run build --if-present'
                    }
                }
            }
        }

        // =====================================================================
        // STAGE 4: Automated Tests — Backend (JUnit)
        // =====================================================================
        stage('Test Backend') {
            agent { label 'jenkins-agent-pro || built-in' }  // Distributed builds
            when {
                allOf {
                    expression { !params.SKIP_TESTS }
                    expression { fileExists('pom.xml') || fileExists('backend/pom.xml') }
                }
            }
            steps {
                script {
                    def pomPath = fileExists('pom.xml') ? '.' : 'backend'
                    dir(pomPath) {
                        sh 'mvn -B test'
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }

        // =====================================================================
        // STAGE 5: Automated Tests — Frontend (Karma/Jasmine)
        // =====================================================================
        stage('Test Frontend') {
            agent { label 'jenkins-agent-pro || built-in' }  // Distributed builds
            when {
                allOf {
                    expression { !params.SKIP_TESTS }
                    expression { fileExists('package.json') || fileExists('frontend/package.json') }
                }
            }
            steps {
                script {
                    def frontendPath = fileExists('package.json') ? '.' : 'frontend'
                    dir(frontendPath) {
                        sh 'npm test -- --watch=false --browsers=ChromeHeadless'
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/test-results/**/*.xml'
                }
            }
        }

        // =====================================================================
        // STAGE 6: Deployment with Rollback Strategy
        // =====================================================================
        stage('Deploy') {
            when {
                anyOf {
                    expression { params.FORCE_DEPLOY }
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    def targetEnv = params.ENVIRONMENT ?: 'dev'
                    echo "Deploying to ${targetEnv} environment..."

                    // Save current version for rollback
                    env.PREVIOUS_VERSION = sh(
                        script: "cat VERSION 2>/dev/null || echo '0.0.0'",
                        returnStdout: true
                    ).trim()

                    try {
                        deploy(targetEnv)
                        echo "Deployment to ${targetEnv} succeeded"
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.message}"
                        echo "Initiating rollback to version ${env.PREVIOUS_VERSION}..."
                        rollback(targetEnv, env.PREVIOUS_VERSION)
                        error("Deployment failed, rollback executed")
                    }
                }
            }
        }
    }

    // =========================================================================
    // POST-BUILD: Notifications (Email + Slack)
    // =========================================================================
    post {
        success {
            echo 'Build succeeded!'
            sendNotifications('SUCCESS')
        }
        failure {
            echo 'Build failed!'
            sendNotifications('FAILURE')
        }
        unstable {
            echo 'Build unstable (test failures)'
            sendNotifications('UNSTABLE')
        }
        always {
            archiveArtifacts artifacts: '**/target/*.jar, **/dist/**', allowEmptyArchive: true
            cleanWs()
        }
    }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Deploy application to the specified environment
 */
def deploy(String environment) {
    echo "Deploying to ${environment}..."
    switch(environment) {
        case 'dev':
            sh '''
                echo "Deploying to DEV server..."
                # Example: docker-compose -f docker-compose.dev.yml up -d
            '''
            break
        case 'staging':
            sh '''
                echo "Deploying to STAGING server..."
                # Example: kubectl apply -f k8s/staging/
            '''
            break
        case 'prod':
            // Production requires manual approval
            input message: 'Deploy to PRODUCTION?', ok: 'Deploy'
            sh '''
                echo "Deploying to PRODUCTION server..."
                # Example: kubectl apply -f k8s/prod/
            '''
            break
        default:
            error "Unknown environment: ${environment}"
    }
}

/**
 * Rollback to a previous version
 */
def rollback(String environment, String version) {
    echo "Rolling back ${environment} to version ${version}..."
    sh """
        echo "Rollback initiated for ${environment} to version ${version}"
        # Example: kubectl rollout undo deployment/app -n ${environment}
        # Or: docker-compose -f docker-compose.${environment}.yml down
        #     docker tag ${APP_NAME}:${version} ${APP_NAME}:latest
        #     docker-compose -f docker-compose.${environment}.yml up -d
    """
}

/**
 * Send notifications (Email + Slack)
 */
def sendNotifications(String status) {
    def color = [
        'SUCCESS': 'good',
        'FAILURE': 'danger',
        'UNSTABLE': 'warning'
    ][status] ?: '#808080'

    def emoji = [
        'SUCCESS': ':white_check_mark:',
        'FAILURE': ':x:',
        'UNSTABLE': ':warning:'
    ][status] ?: ':question:'

    def subject = "${emoji} Jenkins: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${status}"
    def body = """
        Build: ${env.JOB_NAME} #${env.BUILD_NUMBER}
        Status: ${status}
        Commit: ${env.GIT_COMMIT_SHORT} by ${env.GIT_AUTHOR}
        Environment: ${params.ENVIRONMENT ?: 'N/A'}
        URL: ${env.BUILD_URL}
    """.stripIndent()

    // Email notification
    emailext(
        subject: subject,
        body: body,
        to: '${DEFAULT_RECIPIENTS}',
        recipientProviders: [developers(), requestor()]
    )

    // Slack notification (if configured)
    try {
        slackSend(
            tokenCredentialId: 'slack-webhook',
            channel: '#ci-notifications',
            color: color,
            message: "${emoji} *${status}* - ${env.JOB_NAME} #${env.BUILD_NUMBER}\n" +
                     "Commit: ${env.GIT_COMMIT_SHORT} by ${env.GIT_AUTHOR}\n" +
                     "<${env.BUILD_URL}|View Build>"
        )
    } catch (Exception e) {
        echo "Slack notification skipped: ${e.message}"
    }
}
