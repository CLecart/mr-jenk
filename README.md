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

```
mr-jenk/
├── Jenkinsfile                 # Pipeline CI/CD principal
├── docker-compose.yml          # Configuration Docker Jenkins
├── Dockerfile.jenkins          # Image Jenkins custom
├── plugins.txt                 # Plugins Jenkins pré-installés
├── .env.example                # Template variables d'environnement
├── .gitignore                  # Fichiers exclus de Git
├── README.md                   # Ce fichier
├── CONVERSATION_SUMMARY.md     # Documentation détaillée
│
└── scripts/
    ├── start-jenkins.sh        # Script de démarrage
    ├── configure-security.groovy  # Config sécurité (Script Console)
    └── setup-credentials.groovy   # Setup credentials (Script Console)
```

---

## ✅ Audit & Conformité

### Checklist Functional

| Test             | Commande/Action            | Résultat attendu               |
| ---------------- | -------------------------- | ------------------------------ |
| Pipeline complet | Build with Parameters      | Toutes les étapes passent ✅   |
| Erreur de build  | Introduire une erreur Java | Pipeline échoue à "Build" ❌   |
| Erreur de test   | Faire échouer un test      | Pipeline échoue à "Test" ❌    |
| Auto-trigger     | Push sur GitHub            | Build se lance automatiquement |
| Rollback         | Faire échouer le deploy    | Version précédente restaurée   |

### Checklist Security

| Élément     | Vérification                                      |
| ----------- | ------------------------------------------------- |
| Permissions | Users ont des rôles appropriés (Admin/Dev/Viewer) |
| Secrets     | Tous les secrets dans Jenkins Credentials         |
| Logs        | Pas de secrets visibles dans la console           |
| CSRF        | Protection activée                                |

### Checklist Code Quality

| Élément       | Vérification                             |
| ------------- | ---------------------------------------- |
| Jenkinsfile   | Commenté, documenté, structuré           |
| Test reports  | Rapports JUnit archivés et accessibles   |
| Notifications | Emails/Slack envoyés sur succès ET échec |

---

## 🐛 Troubleshooting

### Jenkins ne démarre pas

```bash
# Vérifier les logs
docker logs jenkins

# Vérifier les ressources
docker stats jenkins

# Redémarrer complètement
docker compose down -v
docker compose up -d
```

### Problème de permissions Docker

```bash
# Ajouter jenkins au groupe docker
docker exec -u root jenkins usermod -aG docker jenkins
docker compose restart jenkins
```

### Webhook ne fonctionne pas

1. Vérifier que Jenkins est accessible publiquement
2. Utiliser [ngrok](https://ngrok.com/) pour exposer localhost :
   ```bash
   ngrok http 8080
   ```
3. Utiliser l'URL ngrok dans le webhook GitHub

### Tests échouent avec ChromeHeadless

```bash
# S'assurer que Chrome est installé dans l'image
docker exec jenkins google-chrome --version
```

---

## 📚 Ressources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)
- [CONVERSATION_SUMMARY.md](CONVERSATION_SUMMARY.md) — Documentation détaillée du projet

---

## 📝 License

MIT License - Voir [LICENSE](LICENSE) pour plus de détails.

---

_Projet MR-Jenk — CI/CD avec Jenkins pour le module Zone01_
