# MR-Jenk — CI/CD Pipeline with Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> Complete CI/CD pipeline for the `buy-01` e-commerce project using Jenkins, Docker, Maven and Angular.

---

## Table of Contents

- [Goals](#goals)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Audit & Compliance](#audit--compliance)
- [Troubleshooting](#troubleshooting)

---

Or manually:
docker compose build

_MR-Jenk project — CI/CD with Jenkins for Zone01 module_

Or run the provisioning script in the Script Console:

```groovy
// Jenkins > Manage Jenkins > Script Console
// Paste the contents of scripts/setup-credentials.groovy
```

### Configure tools

In Jenkins > Manage Jenkins > Global Tool Configuration:

- Maven: name `Maven-3.9`, install automatically
- NodeJS: name `NodeJS-20`, install automatically

### Create the Pipeline job

1. New Item > Name: `buy-01-pipeline` > Type: Pipeline
2. Build Triggers: Check `GitHub hook trigger for GITScm polling`
3. Pipeline:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/your-username/buy-01.git`
   - Credentials: `github-token`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

---

## Usage

### Trigger a manual build

Jenkins > `buy-01-pipeline` > Build with Parameters

Select options:

- `ENVIRONMENT`: dev / staging / prod
- `RUN_TESTS`: true / false
- `DEPLOY`: true / false

### Useful Docker commands

```bash
docker logs -f jenkins
docker compose restart jenkins
docker compose down
docker compose --profile distributed up -d
```

---

## Project structure

```
mr-jenk/
├── Jenkinsfile
├── docker-compose.yml
├── Dockerfile.jenkins
├── plugins.txt
├── .env.example
├── .gitignore
├── README.md
├── CONVERSATION_SUMMARY.md
└── scripts/
    ├── start-jenkins.sh
    ├── configure-security.groovy
    └── setup-credentials.groovy
```

---

## Audit & Compliance

### Functional checklist

| Test          | Action/Command         | Expected result            |
| ------------- | ---------------------- | -------------------------- |
| Full pipeline | Build with Parameters  | All stages succeed ✅      |
| Build failure | Introduce a Java error | Pipeline fails at Build ❌ |
| Test failure  | Fail a test            | Pipeline fails at Test ❌  |

### Security checklist

| Item        | Verification                                    |
| ----------- | ----------------------------------------------- |
| Permissions | Users have appropriate roles (Admin/Dev/Viewer) |
| Secrets     | All secrets stored in Jenkins Credentials       |
| Logs        | No secrets visible in console logs              |
| CSRF        | Protection enabled                              |

---

## Troubleshooting

### Jenkins won't start

```bash
docker logs jenkins
docker stats jenkins
docker compose down -v
docker compose up -d
```

### Docker permissions

```bash
docker exec -u root jenkins usermod -aG docker jenkins
docker compose restart jenkins
```

### Webhook not working

Use ngrok to expose localhost if required:

```bash
ngrok http 8080
```

---

                    │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼

Or start manually:

## 📁 Project structure

mr-jenk/

# MR-Jenk — CI/CD Pipeline with Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> Complete CI/CD pipeline for the `buy-01` e-commerce project using Jenkins, Docker, Maven and Angular.

---

## Table of Contents

- [Goals](#goals)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Audit & Compliance](#audit--compliance)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Goals

This project implements a complete CI/CD pipeline with the following features:

| Feature                 | Status   | Description                                           |
| ----------------------- | -------- | ----------------------------------------------------- |
| ✅ Jenkins setup        | Complete | Docker-based installation with pre-configured plugins |
| ✅ CI/CD pipeline       | Complete | Declarative `Jenkinsfile` with multiple stages        |
| ✅ Automated tests      | Complete | JUnit (backend) + Karma (frontend)                    |
| ✅ Auto-trigger         | Complete | GitHub webhook + SCM polling                          |
| ✅ Deployment           | Complete | Multi-environment (dev/staging/prod)                  |
| ✅ Rollback             | Complete | Automatic rollback strategy on failure                |
| ✅ Notifications        | Complete | Email + Slack                                         |
| ✅ Security             | Complete | Encrypted credentials, RBAC, CSRF                     |
| ✅ Parameterized Builds | Bonus    | Environment selection and build options               |
| ✅ Distributed Builds   | Bonus    | Multi-agent support                                   |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              JENKINS SERVER                                     │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │                             Pipeline Stages                                 │ │
│  │                                                                            │ │
│  │  ┌──────────┐  ┌───────┐  ┌──────┐  ┌────────┐  ┌────────┐  ┌────────┐      │ │
│  │  │ Checkout │→ │ Build │→ │ Test │→ │ Docker │→ │ Deploy │→ │ Notify │      │ │
│  │  └──────────┘  └───────┘  └──────┘  └────────┘  └────────┘  └────────┘      │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                                     │
│  │ Agent 1  │   │ Agent 2  │   │ Agent N  │   (optional distributed agents)      │
│  └──────────┘   └──────────┘   └──────────┘                                     │
└─────────────────────────────────────────────────────────────────────────────────┘
                           │
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
          ┌──────────┐   ┌──────────┐   ┌──────────┐
          │   DEV    │   │ STAGING  │   │   PROD   │
          └──────────┘   └──────────┘   └──────────┘
```

---

## 📦 Prerequisites

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Git**
- **8 GB RAM** minimum (Jenkins + builds)
- **Open ports**: 8080 (Jenkins), 50000 (Agents)

### Check prerequisites

```bash
# Docker
3. Use the ngrok URL for the GitHub webhook

# Docker Compose


# Git
### ChromeHeadless test failures
```

---

## 🚀 Quick Start

### 1. Clone the repository

```bash

cd mr-jenk
```

### 2. Configure environment variables

```bash
cp .env.example .env
nano .env  # Edit with your values
```

### 3. Start Jenkins

```bash
./scripts/start-jenkins.sh
```

Or manually:

````bash
```bash
````

---

## Configuration

Run the provisioning script in the Jenkins Script Console to create credentials from controller environment variables (idempotent):

```groovy
// Jenkins > Manage Jenkins > Script Console
// Paste the contents of scripts/setup-credentials.groovy
```

Also configure global tools in Jenkins > Manage Jenkins > Global Tool Configuration:

- Maven: name `Maven-3.9`, install automatically
- NodeJS: name `NodeJS-20`, install automatically

---

## Usage

### Trigger a manual build

Jenkins > `buy-01-pipeline` > Build with Parameters

Select options:

- `ENVIRONMENT`: dev / staging / prod
- `RUN_TESTS`: true / false
- `DEPLOY`: true / false

---

## Project structure

```
mr-jenk/
├── Jenkinsfile
├── docker-compose.yml
├── Dockerfile.jenkins
├── plugins.txt
├── .env.example
├── .gitignore
├── README.md
├── CONVERSATION_SUMMARY.md
└── scripts/
   ├── start-jenkins.sh
   ├── configure-security.groovy
   └── setup-credentials.groovy
```

---

## Audit & Compliance

### Functional checklist

| Test          | Action/Command         | Expected result            |
| ------------- | ---------------------- | -------------------------- |
| Full pipeline | Build with Parameters  | All stages succeed ✅      |
| Build failure | Introduce a Java error | Pipeline fails at Build ❌ |
| Test failure  | Fail a test            | Pipeline fails at Test ❌  |

### Security checklist

| Item        | Verification                                    |
| ----------- | ----------------------------------------------- |
| Permissions | Users have appropriate roles (Admin/Dev/Viewer) |
| Secrets     | All secrets stored in Jenkins Credentials       |
| Logs        | No secrets visible in console logs              |
| CSRF        | Protection enabled                              |

---

## Troubleshooting

### Jenkins won't start

```bash
# Ensure Chrome is installed in the image
docker exec jenkins google-chrome --version
```

````

### Docker permissions

```bash
---

````

### Webhook not working

Use ngrok to expose localhost if required:

```bash
ngrok http 8080
```

---

## Resources

- https://www.jenkins.io/doc/
- https://www.jenkins.io/doc/book/pipeline/syntax/
- https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/

---

## License

MIT License - See LICENSE for details.

## 📚 Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)
- [CONVERSATION_SUMMARY.md](CONVERSATION_SUMMARY.md) — Detailed project notes

---

## 📝 License

MIT License - See [LICENSE](LICENSE) for details.

---

_MR-Jenk project — CI/CD with Jenkins for Zone01 module_

````

# MR-Jenk — CI/CD Pipeline avec Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> Pipeline CI/CD complet pour le projet e-commerce **buy-01** utilisant Jenkins, Docker, Maven et Angular.

---

## 📋 Table des matières

- [Objectifs](#-objectifs)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation rapide](#-installation-rapide)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Structure du projet](#-structure-du-projet)
- [Audit & Conformité](#-audit--conformité)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Objectifs

Ce projet implémente un pipeline CI/CD complet avec les fonctionnalités suivantes :

| Fonctionnalité          | Status  | Description                                         |
| ----------------------- | ------- | --------------------------------------------------- |
| ✅ Setup Jenkins        | Complet | Installation via Docker avec plugins pré-configurés |
| ✅ Pipeline CI/CD       | Complet | Jenkinsfile déclaratif avec stages multiples        |
| ✅ Tests automatisés    | Complet | JUnit (backend) + Karma (frontend)                  |
| ✅ Auto-trigger         | Complet | Webhook GitHub + polling SCM                        |
| ✅ Déploiement          | Complet | Multi-environnements (dev/staging/prod)             |
| ✅ Rollback             | Complet | Stratégie automatique en cas d'échec                |
| ✅ Notifications        | Complet | Email + Slack                                       |
| ✅ Sécurité             | Complet | Credentials chiffrés, RBAC, CSRF                    |
| ✅ Parameterized Builds | Bonus   | Choix d'environnement et options                    |
| ✅ Distributed Builds   | Bonus   | Support multi-agents                                |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              JENKINS SERVER                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                         Pipeline Stages                                  │ │
│  │                                                                          │ │
│  │  ┌──────────┐  ┌───────┐  ┌──────┐  ┌────────┐  ┌────────┐  ┌────────┐ │ │
│  │  │ Checkout │→ │ Build │→ │ Test │→ │ Docker │→ │ Deploy │→ │ Notify │ │ │
│  │  │   (Git)  │  │(Maven │  │(JUnit│  │ Build  │  │        │  │(Email/ │ │ │
│  │  │          │  │ /npm) │  │Karma)│  │        │  │        │  │ Slack) │ │ │
│  │  └──────────┘  └───────┘  └──────┘  └────────┘  └────────┘  └────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                 │
│  │    Agent 1     │  │    Agent 2     │  │    Agent N     │  (Bonus)        │
│  └────────────────┘  └────────────────┘  └────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              ┌──────────┐   ┌──────────┐   ┌──────────┐
              │   DEV    │   │ STAGING  │   │   PROD   │
              └──────────┘   └──────────┘   └──────────┘
```

---

## 📦 Prérequis

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Git**
- **8 GB RAM** minimum (Jenkins + builds)
- **Ports libres** : 8080 (Jenkins), 50000 (Agents)

### Vérifier les prérequis

```bash
# Docker
docker --version

# Docker Compose
docker compose version

# Git
git --version
```

---

## 🚀 Installation rapide

### 1. Cloner le projet

```bash
git clone https://github.com/your-username/mr-jenk.git
cd mr-jenk
```

### 2. Configurer les variables d'environnement

```bash
cp .env.example .env
nano .env  # Éditer avec vos valeurs
```

### 3. Démarrer Jenkins

```bash
./scripts/start-jenkins.sh
```

Ou manuellement :

```bash
docker compose build
docker compose up -d
```

### 4. Récupérer le mot de passe initial

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 5. Accéder à Jenkins

Ouvrir http://localhost:8080 et suivre l'assistant de configuration.

---

## ⚙️ Configuration

### Étape 1 : Setup initial Jenkins

1. Entrer le mot de passe initial
2. Installer les plugins suggérés
3. Créer le compte administrateur
4. Configurer l'URL Jenkins (http://localhost:8080)

### Étape 2 : Configurer les credentials

Dans **Jenkins > Manage Jenkins > Credentials**, créer :

| ID                   | Type              | Description                  |
| -------------------- | ----------------- | ---------------------------- |
| `github-token`       | Secret text       | Personal Access Token GitHub |
| `docker-credentials` | Username/Password | Docker Registry              |
| `smtp-credentials`   | Username/Password | SMTP pour emails             |
| `slack-webhook`      | Secret text       | Webhook URL Slack            |
| `deploy-ssh-key`     | SSH Private Key   | Clé SSH déploiement          |

Ou exécuter le script dans **Script Console** :

```groovy
// Jenkins > Manage Jenkins > Script Console
// Coller le contenu de scripts/setup-credentials.groovy
```

### Étape 3 : Configurer les outils

Dans **Jenkins > Manage Jenkins > Global Tool Configuration** :

- **Maven** : Nom `Maven-3.9`, installer automatiquement
- **NodeJS** : Nom `NodeJS-20`, installer automatiquement

### Étape 4 : Créer le job Pipeline

1. **New Item** > Nom: `buy-01-pipeline` > Type: **Pipeline**
2. **Build Triggers** : Cocher `GitHub hook trigger for GITScm polling`
3. **Pipeline** :
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/your-username/buy-01.git`
   - Credentials: `github-token`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

### Étape 5 : Configurer le webhook GitHub

1. GitHub Repository > **Settings** > **Webhooks** > **Add webhook**
2. Payload URL: `http://your-jenkins-url/github-webhook/`
3. Content type: `application/json`
4. Events: `Just the push event`

---

## 🔧 Utilisation

### Lancer un build manuel

1. Jenkins > `buy-01-pipeline` > **Build with Parameters**
2. Sélectionner les options :
   - `ENVIRONMENT`: dev / staging / prod
   - `RUN_TESTS`: true / false
   - `DEPLOY`: true / false

### Commandes Docker utiles

```bash
# Voir les logs Jenkins
docker logs -f jenkins

# Redémarrer Jenkins
docker compose restart jenkins

# Arrêter Jenkins
docker compose down

# Avec l'agent distribué (bonus)
docker compose --profile distributed up -d
```

### Structure des paramètres de build

| Paramètre               | Défaut  | Description             |
| ----------------------- | ------- | ----------------------- |
| `ENVIRONMENT`           | `dev`   | Environnement cible     |
| `RUN_TESTS`             | `true`  | Exécuter les tests      |
| `RUN_INTEGRATION_TESTS` | `false` | Tests d'intégration     |
| `DEPLOY`                | `true`  | Déployer après build    |
| `SKIP_DOCKER_BUILD`     | `false` | Ignorer le build Docker |

---

## 📁 Structure du projet

````

mr-jenk/
├── Jenkinsfile # Pipeline CI/CD principal
├── docker-compose.yml # Configuration Docker Jenkins
├── Dockerfile.jenkins # Image Jenkins custom
├── plugins.txt # Plugins Jenkins pré-installés
├── .env.example # Template variables d'environnement
├── .gitignore # Fichiers exclus de Git
├── README.md # Ce fichier
├── CONVERSATION_SUMMARY.md # Documentation détaillée
│

```markdown
# MR-Jenk — CI/CD Pipeline with Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> Complete CI/CD pipeline for the `buy-01` e-commerce project using Jenkins, Docker, Maven and Angular.

---

## 📋 Table of Contents

- [Goals](#-goals)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Audit & Compliance](#-audit--compliance)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Goals

This project implements a complete CI/CD pipeline with the following features:

| Feature                 | Status   | Description                                           |
| ----------------------- | -------- | ----------------------------------------------------- |
| ✅ Jenkins setup        | Complete | Docker-based installation with pre-configured plugins |
| ✅ CI/CD pipeline       | Complete | Declarative `Jenkinsfile` with multiple stages        |
| ✅ Automated tests      | Complete | JUnit (backend) + Karma (frontend)                    |
| ✅ Auto-trigger         | Complete | GitHub webhook + SCM polling                          |
| ✅ Deployment           | Complete | Multi-environment (dev/staging/prod)                  |
| ✅ Rollback             | Complete | Automatic rollback strategy on failure                |
| ✅ Notifications        | Complete | Email + Slack                                         |
| ✅ Security             | Complete | Encrypted credentials, RBAC, CSRF                     |
| ✅ Parameterized Builds | Bonus    | Environment selection and build options               |
| ✅ Distributed Builds   | Bonus    | Multi-agent support                                   |

---

## 🏗 Architecture
```

┌────────────────────────────────────────────────────────────────────────────┐
│ JENKINS SERVER │
│ ┌────────────────────────────────────────────────────────────────────────┐ │
│ │ Pipeline Stages │ │
│ │ │ │
│ │ ┌──────────┐ ┌───────┐ ┌──────┐ ┌────────┐ ┌────────┐ ┌────────┐ │ │
│ │ │ Checkout │→│ Build │→│ Test │→│ Docker │→│ Deploy │→│ Notify │ │ │
│ │ └──────────┘ └───────┘ └──────┘ └────────┘ └────────┘ └────────┘ │ │
│ └────────────────────────────────────────────────────────────────────────┘ │
│ │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│ │ Agent 1 │ │ Agent 2 │ │ Agent N │ (optional) │
│ └──────────┘ └──────────┘ └──────────┘ │
└────────────────────────────────────────────────────────────────────────────┘
│
┌───────────────┼───────────────┐
▼ ▼ ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ DEV │ │ STAGING │ │ PROD │
└──────────┘ └──────────┘ └──────────┘

````

---

## 📦 Prerequisites

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Git**
- **8 GB RAM** minimum (Jenkins + builds)
- **Open ports**: 8080 (Jenkins), 50000 (Agents)

### Check prerequisites

```bash
# Docker
docker --version

# Docker Compose
docker compose version

# Git
git --version
````

---

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/your-username/mr-jenk.git
cd mr-jenk
```

### 2. Configure environment variables

```bash
cp .env.example .env
nano .env  # Edit with your values
```

### 3. Start Jenkins

```bash
./scripts/start-jenkins.sh
```

Or start manually:

```bash
docker compose build
docker compose up -d
```

### 4. Retrieve the initial admin password

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 5. Access Jenkins

Open http://localhost:8080 and follow the setup wizard.

---

## ⚙️ Configuration

### Step 1: Initial Jenkins setup

1. Enter the initial admin password
2. Install the suggested plugins
3. Create the administrator account
4. Configure the Jenkins URL (http://localhost:8080)

### Step 2: Configure credentials

In **Jenkins > Manage Jenkins > Credentials**, create the following:

| ID                   | Type              | Description                  |
| -------------------- | ----------------- | ---------------------------- |
| `github-token`       | Secret text       | GitHub Personal Access Token |
| `docker-credentials` | Username/Password | Docker Registry credentials  |
| `smtp-credentials`   | Username/Password | SMTP credentials for emails  |
| `slack-webhook`      | Secret text       | Slack webhook URL            |
| `deploy-ssh-key`     | SSH Private Key   | SSH key for deployments      |

Or run the provisioning script in the **Script Console**:

```groovy
// Jenkins > Manage Jenkins > Script Console
// Paste the contents of scripts/setup-credentials.groovy
```

### Step 3: Configure tools

In **Jenkins > Manage Jenkins > Global Tool Configuration**:

- **Maven** : Name `Maven-3.9`, install automatically
- **NodeJS** : Name `NodeJS-20`, install automatically

### Step 4: Create the Pipeline job

1. **New Item** > Name: `buy-01-pipeline` > Type: **Pipeline**
2. **Build Triggers** : Check `GitHub hook trigger for GITScm polling`
3. **Pipeline** :
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/your-username/buy-01.git`
   - Credentials: `github-token`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

### Step 5: Configure the GitHub webhook

1. GitHub Repository > **Settings** > **Webhooks** > **Add webhook**
2. Payload URL: `http://your-jenkins-url/github-webhook/`
3. Content type: `application/json`
4. Events: `Just the push event`

---

## 🔧 Usage

### Trigger a manual build

1. Jenkins > `buy-01-pipeline` > **Build with Parameters**
2. Select options:
   - `ENVIRONMENT`: dev / staging / prod
   - `RUN_TESTS`: true / false
   - `DEPLOY`: true / false

### Useful Docker commands

```bash
# View Jenkins logs
docker logs -f jenkins

# Restart Jenkins
docker compose restart jenkins

# Stop Jenkins
docker compose down

# With distributed agent (optional)
docker compose --profile distributed up -d
```

### Build parameter defaults

| Parameter               | Default | Description             |
| ----------------------- | ------- | ----------------------- |
| `ENVIRONMENT`           | `dev`   | Target environment      |
| `RUN_TESTS`             | `true`  | Run tests               |
| `RUN_INTEGRATION_TESTS` | `false` | Run integration tests   |
| `DEPLOY`                | `true`  | Deploy after build      |
| `SKIP_DOCKER_BUILD`     | `false` | Skip Docker image build |

---

## 📁 Project structure

```
mr-jenk/
├── Jenkinsfile                 # Main CI/CD pipeline
├── docker-compose.yml          # Docker configuration for Jenkins
├── Dockerfile.jenkins          # Custom Jenkins image
├── plugins.txt                 # Pre-installed Jenkins plugins
├── .env.example                # Environment variables template
├── .gitignore                  # Files ignored by Git
├── README.md                   # This file
├── CONVERSATION_SUMMARY.md     # Detailed project notes
│
└── scripts/
    ├── start-jenkins.sh        # Start script
    ├── configure-security.groovy  # Security configuration (Script Console)
    └── setup-credentials.groovy   # Credentials provisioning (Script Console)
```

---

## ✅ Audit & Compliance

### Functional checklist

| Test          | Command/Action         | Expected result              |
| ------------- | ---------------------- | ---------------------------- |
| Full pipeline | Build with Parameters  | All stages succeed ✅        |
| Build failure | Introduce a Java error | Pipeline fails at "Build" ❌ |
| Test failure  | Fail a test            | Pipeline fails at "Test" ❌  |
| Auto-trigger  | Push to GitHub         | Build starts automatically   |
| Rollback      | Cause a deploy failure | Previous version restored    |

### Security checklist

| Item        | Verification                                    |
| ----------- | ----------------------------------------------- |
| Permissions | Users have appropriate roles (Admin/Dev/Viewer) |
| Secrets     | All secrets stored in Jenkins Credentials       |
| Logs        | No secrets visible in console logs              |
| CSRF        | Protection enabled                              |

### Code quality checklist

| Item          | Verification                            |
| ------------- | --------------------------------------- |
| Jenkinsfile   | Documented and structured               |
| Test reports  | JUnit reports archived and accessible   |
| Notifications | Email/Slack sent on success and failure |

---

## 🐛 Troubleshooting

### Jenkins won't start

```bash
# Check logs
docker logs jenkins

# Check resources
docker stats jenkins

# Full restart
docker compose down -v
docker compose up -d
```

### Docker permission issues

```bash
# Add jenkins to docker group
docker exec -u root jenkins usermod -aG docker jenkins
docker compose restart jenkins
```

### Webhook not working

1. Ensure Jenkins is reachable from GitHub
2. Use [ngrok](https://ngrok.com/) to expose localhost if needed:
   ```bash
   ngrok http 8080
   ```
3. Use the ngrok URL for the GitHub webhook

### ChromeHeadless test failures

```bash
# Ensure Chrome is installed in the image
docker exec jenkins google-chrome --version
```

---

## 📚 Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)
- [CONVERSATION_SUMMARY.md](CONVERSATION_SUMMARY.md) — Detailed project notes

---

## 📝 License

MIT License - See [LICENSE](LICENSE) for details.

---

_MR-Jenk project — CI/CD with Jenkins for Zone01 module_

```

```
