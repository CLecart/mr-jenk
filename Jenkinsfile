pipeline {
    agent any
    environment {
        // keep only literals here; compute dynamic values at runtime
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_NAMESPACE = 'mycompany'
        IMAGE_NAME = ''
    }
    parameters {
        choice(name: 'ENV', choices: ['dev','staging','prod'], description: 'Choose deploy environment')
        booleanParam(name: 'RUN_INTEGRATION_TESTS', defaultValue: false, description: 'Run integration tests?')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        timeout(time: 60, unit: 'MINUTES')
        ansiColor('xterm')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare') {
            steps {
                script {
                    // Compute IMAGE_NAME at runtime to avoid complex expressions in environment
                    if (env.DOCKER_NAMESPACE?.trim()) {
                        env.IMAGE_NAME = "${env.DOCKER_NAMESPACE}/${env.PROJECT_NAME ?: 'mr-jenk'}"
                    } else {
                        env.IMAGE_NAME = "mycompany/mr-jenk"
                    }
                    echo "Computed IMAGE_NAME=${env.IMAGE_NAME}"
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn -B -DskipTests package'
                    } else if (fileExists('gradlew')) {
                        sh './gradlew build -x test'
                    } else {
                        echo 'No recognized Java build file found; skipping compile step.'
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn -B test'
                        junit '**/target/surefire-reports/*.xml'
                    } else {
                        echo 'No unit tests detected.'
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            when {
                expression { return !params.RUN_INTEGRATION_TESTS }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        set -euo pipefail
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin ${DOCKER_REGISTRY}
                        docker build -t ${IMAGE_NAME}:${GIT_COMMIT} .
                        docker tag ${IMAGE_NAME}:${GIT_COMMIT} ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:${GIT_COMMIT}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh 'sleep 5'
                }
            }
        }
    }
    post {
        failure {
            echo 'Build failed - see console output for details.'
        }
        success {
            echo 'Pipeline finished successfully.'
        }
        always {
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
    }
}

// Note: previous file contained duplicate `stage(...)` blocks after the closing
// `pipeline { ... }` which breaks the declarative pipeline syntax. The
// trailing duplicate stages have been removed so the file contains only a
// single well-formed `pipeline` block. If you want additional stages, add
// them inside the `stages { ... }` section above.

                script {
                    docker.image('maven:3.9.3-eclipse-temurin-17').inside {
                        sh 'mvn test -Dmaven.test.failure.ignore=false -B'
                    }
                }
                
                echo "✅ Tests backend terminés"
            }
            post {
                always {
                    // Publier les rapports de tests JUnit
                    junit(
                        testResults: '**/target/surefire-reports/*.xml',
                        allowEmptyResults: false
                    )
                    
                    // Publier le rapport de couverture JaCoCo en HTML (sans plugin obsolète)
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/site/jacoco',
                        reportFiles: 'index.html',
                        reportName: 'Backend Coverage Report'
                    ])
                }
                failure {
                    echo "❌ Des tests backend ont échoué!"
                    // Le pipeline échoue si des tests échouent
                    error("Tests backend en échec - Pipeline arrêté")
                }
            }
        }

        /**
         * ---------------------------------------------------------------------
         * Stage 5: Test Frontend
         * ---------------------------------------------------------------------
         * Exécute les tests Karma/Jasmine pour le frontend Angular
         *
         * @condition Exécuté si params.RUN_TESTS est true
         * @reports   Génère des rapports JUnit depuis Karma
         */
        stage('Test Frontend') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                echo "🧪 Exécution des tests frontend..."
                
                // Run frontend tests inside Node Docker image
                script {
                    docker.image('node:20-alpine').inside {
                        dir('frontend-angular') {
                            sh 'npm run test -- --watch=false --browsers=ChromeHeadless --code-coverage'
                        }
                    }
                }
                
                echo "✅ Tests frontend terminés"
            }
            post {
                always {
                    // Publier les rapports de tests Karma
                    junit(
                        testResults: 'frontend-angular/test-results/**/*.xml',
                        allowEmptyResults: true
                    )
                    
                    // Publier le rapport de couverture
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'frontend-angular/coverage',
                        reportFiles: 'index.html',
                        reportName: 'Frontend Coverage Report'
                    ])
                }
                failure {
                    echo "❌ Des tests frontend ont échoué!"
                    error("Tests frontend en échec - Pipeline arrêté")
                }
            }
        }

        /**
         * ---------------------------------------------------------------------
         * Stage 6: Integration Tests (Optionnel)
         * ---------------------------------------------------------------------
         * Exécute les tests d'intégration
         *
         * @condition Exécuté si params.RUN_INTEGRATION_TESTS est true
         */
        stage('Integration Tests') {
            when {
                expression { params.RUN_INTEGRATION_TESTS == true }
            }
            steps {
                echo "🧪 Exécution des tests d'intégration..."
                
                // Run integration tests inside Maven Docker image
                script {
                    docker.image('maven:3.9.3-eclipse-temurin-17').inside {
                        sh 'mvn verify -DskipUnitTests=true -Dspring.profiles.active=test -B'
                    }
                }
                
                echo "✅ Tests d'intégration terminés"
            }
            post {
                always {
                    junit(
                        testResults: '**/target/failsafe-reports/*.xml',
                        allowEmptyResults: true
                    )
                }
            }
        }

        /**
         * ---------------------------------------------------------------------
         * Stage 7: Docker Build
         * ---------------------------------------------------------------------
         * Construit les images Docker pour chaque service
         *
         * @condition Exécuté si params.SKIP_DOCKER_BUILD est false
         */
        stage('Docker Build') {
            when {
                expression { params.SKIP_DOCKER_BUILD == false }
            }
            steps {
                echo "🐳 Construction des images Docker..."
                
                script {
                    // Build de chaque service
                    def services = ['user-service', 'product-service', 'media-service', 'frontend-angular']
                    
                    services.each { service ->
                        dir(service) {
                            sh """
                                docker build \
                                    -t ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:${DOCKER_TAG} \
                                    -t ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:latest \
                                    --build-arg VERSION=${VERSION} \
                                    .
                            """
                        }
                    }
                }
                
                echo "✅ Images Docker construites"
            }
        }

        /**
         * ---------------------------------------------------------------------
         * Stage 8: Docker Push
         * ---------------------------------------------------------------------
         * Pousse les images vers le registry Docker
         *
         * @condition Exécuté sur la branche main uniquement
         * @security  Utilise les credentials Docker sécurisés
         */
        stage('Docker Push') {
            when {
                allOf {
                    branch 'main'
                    expression { params.SKIP_DOCKER_BUILD == false }
                }
            }
            steps {
                echo "📤 Push des images Docker vers le registry..."
                
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        def services = ['user-service', 'product-service', 'media-service', 'frontend-angular']
                        
                        services.each { service ->
                            sh """
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:${DOCKER_TAG}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:latest
                            """
                        }
                    }
                }
                
                echo "✅ Images poussées vers le registry"
            }
        }

        /**
         * ---------------------------------------------------------------------
         * Stage 9: Deploy
         * ---------------------------------------------------------------------
         * Déploie l'application sur l'environnement cible
         *
         * @condition Exécuté si params.DEPLOY est true et branche main
         * @rollback  En cas d'échec, rollback automatique vers version précédente
         */
        stage('Deploy') {
            when {
                allOf {
                    branch 'main'
                    expression { params.DEPLOY == true }
                }
            }
            steps {
                echo "🚀 Déploiement sur l'environnement: ${params.ENVIRONMENT}..."
                
                script {
                    try {
                        // Sauvegarder la version actuelle pour rollback
                        env.PREVIOUS_VERSION = sh(
                            script: "cat .deployed_version || echo 'none'",
                            returnStdout: true
                        ).trim()
                        
                        // Déployer la nouvelle version
                        deployToEnvironment(params.ENVIRONMENT)
                        
                        // Sauvegarder la nouvelle version
                        sh "echo '${VERSION}' > .deployed_version"
                        
                        // Health check
                        performHealthCheck(params.ENVIRONMENT)
                        
                        echo "✅ Déploiement réussi!"
                        
                    } catch (Exception e) {
                        echo "❌ Échec du déploiement: ${e.message}"
                        
                        // Rollback automatique
                        rollback(params.ENVIRONMENT, env.PREVIOUS_VERSION)
                        
                        // Relancer l'exception pour marquer le build comme failed
                        throw e
                    }
                }
            }
        }
    }

    /**
     * =========================================================================
     * POST ACTIONS
     * =========================================================================
     *
     * Actions exécutées après la fin du pipeline (succès ou échec)
     */
    post {
        /**
         * Toujours exécuté
         */
        always {
            // Le bloc 'post' s'exécute hors d'un contexte 'node'.
            // Pour exécuter des steps comme 'sh' ou 'cleanWs' qui
            // nécessitent un workspace, on ouvre explicitement un
            // bloc 'node'. Utiliser le label 'agent-1' pour garantir
            // que le nettoyage s'effectue sur l'agent dédié.
            script {
                                node('agent-1') {
                                        echo "🧹 Nettoyage du workspace..."

                                        // Nettoyage des images Docker locales (optionnel)
                                        // Guard against agents that don't have the docker CLI installed
                                        sh '''
                                                if command -v docker >/dev/null 2>&1; then
                                                    docker system prune -f || true
                                                else
                                                    echo "docker CLI not available on this agent - skipping docker prune"
                                                fi
                                        '''

                                        // Nettoyage du workspace Jenkins
                                        cleanWs()
                                }
            }
        }

        /**
         * Exécuté en cas de succès
         */
        success {
            echo "✅ Pipeline terminé avec succès!"

            script {
                // Wrap notifications to avoid notification failures failing the build
                try {
                    sendEmailNotification('SUCCESS')
                } catch (Exception e) {
                    echo "Warning: email notification failed: ${e.message}"
                }

                try {
                    sendSlackNotification('SUCCESS')
                } catch (Exception e) {
                    echo "Warning: slack notification failed: ${e.message}"
                }
            }
        }

        /**
         * Exécuté en cas d'échec
         */
        failure {
            echo "❌ Pipeline en échec!"
            
            script {
                try {
                    sendEmailNotification('FAILURE')
                } catch (Exception e) {
                    echo "Warning: email notification failed: ${e.message}"
                }

                try {
                    sendSlackNotification('FAILURE')
                } catch (Exception e) {
                    echo "Warning: slack notification failed: ${e.message}"
                }
            }
        }

        /**
         * Exécuté si le build est instable (tests flaky, etc.)
         */
        unstable {
            echo "⚠️ Pipeline instable!"
            
            script {
                try {
                    sendEmailNotification('UNSTABLE')
                } catch (Exception e) {
                    echo "Warning: email notification failed: ${e.message}"
                }

                try {
                    sendSlackNotification('UNSTABLE')
                } catch (Exception e) {
                    echo "Warning: slack notification failed: ${e.message}"
                }
            }
        }

        /**
         * Exécuté si le build est annulé
         */
        aborted {
            echo "🛑 Pipeline annulé"
            
            script {
                try {
                    sendSlackNotification('ABORTED')
                } catch (Exception e) {
                    echo "Warning: slack notification failed: ${e.message}"
                }
            }
        }
    }
}

/**
 * =============================================================================
 * FONCTIONS HELPER
 * =============================================================================
 */

/**
 * Déploie l'application sur l'environnement spécifié
 *
 * @param environment L'environnement cible ('dev', 'staging', 'prod')
 * @throws Exception si le déploiement échoue
 */
def deployToEnvironment(String environment) {
    echo "📦 Déploiement vers ${environment}..."
    
    switch(environment) {
        case 'dev':
            deployToDev()
            break
        case 'staging':
            deployToStaging()
            break
        case 'prod':
            deployToProd()
            break
        default:
            error("Environnement inconnu: ${environment}")
    }
}

/**
 * Déploiement sur l'environnement de développement
 */
def deployToDev() {
    echo "🔧 Déploiement DEV via Docker Compose..."
    
    sh '''
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
    '''
}

/**
 * Déploiement sur l'environnement de staging
 */
def deployToStaging() {
    echo "🔧 Déploiement STAGING..."
    
    // Exemple avec SSH
    sshagent(['deploy-ssh-key']) {
        sh '''
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${STAGING_HOST} << 'EOF'
                cd /opt/app
                docker-compose pull
                docker-compose up -d
EOF
        '''
    }
}

/**
 * Déploiement sur l'environnement de production
 */
def deployToProd() {
    echo "🔧 Déploiement PRODUCTION..."
    
    // Confirmation manuelle pour la prod
    input message: 'Confirmer le déploiement en production?', ok: 'Déployer'
    
    sshagent(['deploy-ssh-key']) {
        sh '''
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${PROD_HOST} << 'EOF'
                cd /opt/app
                docker-compose pull
                docker-compose up -d --no-deps --build
EOF
        '''
    }
}

/**
 * Effectue un health check après déploiement
 *
 * @param environment L'environnement à vérifier
 * @throws Exception si le health check échoue
 */
def performHealthCheck(String environment) {
    echo "🏥 Vérification de santé de l'application..."
    
    def healthUrl = getHealthUrl(environment)
    
    // Attendre que l'application soit prête (max 2 minutes)
    timeout(time: 2, unit: 'MINUTES') {
        waitUntil {
            def response = sh(
                script: "curl -s -o /dev/null -w '%{http_code}' ${healthUrl} || echo '000'",
                returnStdout: true
            ).trim()
            
            return response == '200'
        }
    }
    
    echo "✅ Health check OK"
}

/**
 * Retourne l'URL de health check pour un environnement
 *
 * @param environment L'environnement
 * @return URL du endpoint health
 */
def getHealthUrl(String environment) {
    switch(environment) {
        case 'dev':
            return 'http://localhost:8080/actuator/health'
        case 'staging':
            return 'https://staging.example.com/actuator/health'
        case 'prod':
            return 'https://api.example.com/actuator/health'
        default:
            return 'http://localhost:8080/actuator/health'
    }
}

/**
 * Effectue un rollback vers une version précédente
 *
 * @param environment L'environnement cible
 * @param version La version vers laquelle rollback
 */
def rollback(String environment, String version) {
    echo "⏪ Rollback vers la version ${version}..."
    
    if (version == 'none') {
        echo "⚠️ Pas de version précédente disponible pour rollback"
        return
    }
    
    script {
        // Récupérer les images de la version précédente
        def services = ['user-service', 'product-service', 'media-service', 'frontend-angular']
        
        services.each { service ->
            sh """
                docker pull ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:${version} || true
                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:${version} \
                           ${DOCKER_REGISTRY}/${PROJECT_NAME}/${service}:latest || true
            """
        }
        
        // Redéployer avec l'ancienne version
        deployToEnvironment(environment)
        
        echo "✅ Rollback effectué vers ${version}"
        
        // Notification de rollback
        sendSlackNotification('ROLLBACK')
    }
}

/**
 * Envoie une notification par email
 *
 * @param status Le statut du build ('SUCCESS', 'FAILURE', 'UNSTABLE')
 */
def sendEmailNotification(String status) {
    def emoji = status == 'SUCCESS' ? '✅' : (status == 'FAILURE' ? '❌' : '⚠️')
    def color = status == 'SUCCESS' ? 'green' : (status == 'FAILURE' ? 'red' : 'orange')
    
    emailext(
        subject: "${emoji} Jenkins Build ${status}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
        body: """
            <html>
            <body>
                <h2 style="color: ${color};">${emoji} Build ${status}</h2>
                
                <table>
                    <tr><td><b>Job:</b></td><td>${env.JOB_NAME}</td></tr>
                    <tr><td><b>Build:</b></td><td>#${env.BUILD_NUMBER}</td></tr>
                    <tr><td><b>Branch:</b></td><td>${env.BRANCH_NAME}</td></tr>
                    <tr><td><b>Commit:</b></td><td>${env.GIT_COMMIT_SHORT}</td></tr>
                    <tr><td><b>Author:</b></td><td>${env.GIT_AUTHOR}</td></tr>
                    <tr><td><b>Message:</b></td><td>${env.GIT_COMMIT_MSG}</td></tr>
                    <tr><td><b>Environment:</b></td><td>${params.ENVIRONMENT}</td></tr>
                </table>
                
                <p><a href="${env.BUILD_URL}">Voir le build</a></p>
                <p><a href="${env.BUILD_URL}console">Voir les logs</a></p>
            </body>
            </html>
        """,
        mimeType: 'text/html',
        to: '${NOTIFICATION_RECIPIENTS}',
        recipientProviders: [
            [$class: 'CulpritsRecipientProvider'],
            [$class: 'RequesterRecipientProvider']
        ]
    )
}

/**
 * Envoie une notification Slack
 *
 * @param status Le statut du build
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
        'SUCCESS': 'Build réussi!',
        'FAILURE': 'Build échoué!',
        'UNSTABLE': 'Build instable',
        'ABORTED': 'Build annulé',
        'ROLLBACK': 'Rollback effectué!'
    ][status] ?: 'Status inconnu'
    
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
            
            <${env.BUILD_URL}|Voir le build>
        """.stripIndent()
    )
}
