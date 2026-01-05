# mr-jenk — Jenkins CI/CD Pipeline

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins)](https://www.jenkins.io/)

Hardened, auditable Jenkins CI/CD scaffold for e-commerce microservices.

## Features

- ✅ Declarative `Jenkinsfile` pipeline (build, test, deploy)
- ✅ Automated tests (JUnit backend, Karma/Jasmine frontend)
- ✅ Auto-trigger on push (GitHub webhook + SCM polling)
- ✅ Deployment with rollback strategy
- ✅ Email/Slack notifications
- ✅ Security configuration (Matrix-based permissions)
- ✅ Parameterized builds (environment selection)
- ✅ Distributed builds support (multiple agents)

---

## Prerequisites

- Docker >= 20.10
- Docker Compose >= 2.0
- Git
- ~8 GB RAM recommended

```bash
docker --version
docker compose version
git --version
```

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/CLecart/mr-jenk.git
cd mr-jenk

# 2. Configure environment
cp .env.example .env
# Edit .env with your values (DO NOT commit)

# 3. Start Jenkins
./scripts/start-jenkins.sh
# Or: docker-compose up -d

# 4. (Optional) Start distributed agents
docker-compose --profile distributed up -d
```

Open Jenkins: http://localhost:8080

Get initial admin password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## Project Structure

```
mr-jenk/
├── Jenkinsfile                      # CI/CD pipeline
├── docker-compose.yml               # Jenkins + agents setup
├── Dockerfile.jenkins               # Custom Jenkins image
├── Dockerfile.agent                 # Custom agent image
├── plugins.txt                      # Jenkins plugins
├── .env.example                     # Environment template
├── AUDIT_CHECKLIST.md               # Audit validation guide
├── scripts/
│   ├── start-jenkins.sh             # Startup helper
│   ├── configure-security.groovy    # Security configuration
│   ├── harden-controller.groovy     # Controller hardening
│   ├── trigger_and_collect.sh       # Build trigger + evidence
│   └── clean_evidence.sh            # Archive evidence
└── evidence/                        # Build artifacts & logs
    └── archives/                    # Encrypted evidence archives
```

---

## Configuration

### 1. Initial Setup

1. Open http://localhost:8080
2. Enter initial admin password
3. Install suggested plugins
4. Create admin account
5. Configure Jenkins URL

### 2. Create Pipeline Job

1. **New Item** → Name: `mr-jenk-pipeline` → Type: **Pipeline**
2. Definition: **Pipeline script from SCM**
3. SCM: Git → Repository URL: `https://github.com/CLecart/mr-jenk.git`
4. Branch: `*/main`
5. Script Path: `Jenkinsfile`

### 3. Configure Credentials

In **Manage Jenkins → Credentials**, add:

| ID | Type | Description |
|----|------|-------------|
| `github-token` | Username/Password | GitHub PAT |
| `deploy-credentials` | Username/Password | Deployment credentials |
| `slack-webhook` | Secret text | Slack webhook URL |

### 4. Configure Security

Run `scripts/configure-security.groovy` in **Manage Jenkins → Script Console**.

Default users created:
- `admin` — Full administrator
- `developer` — Build + read access
- `viewer` — Read-only

⚠️ **Change default passwords immediately!**

---

## Usage

### Trigger a Build

```bash
# Via Jenkins UI
# Build with Parameters → Select environment → Build

# Via API
source .env
curl -X POST -u "$JENKINS_ADMIN:$JENKINS_API_TOKEN" \
  "http://localhost:8080/job/mr-jenk-pipeline/build"
```

### Collect Evidence

```bash
./scripts/trigger_and_collect.sh mr-jenk-pipeline
```

### Archive Evidence

```bash
./scripts/clean_evidence.sh
# Uses passphrase from .env.local or prompts
```

### Decrypt Archive

```bash
# GPG (.gpg files)
gpg --batch --yes --passphrase-file .env.local \
  -o evidence.tar.gz -d evidence/archives/evidence-*.tar.gz.gpg
tar -xzf evidence.tar.gz

# OpenSSL (.enc files)
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass file:.env.local -in archive.enc -out evidence.tar.gz
tar -xzf evidence.tar.gz
```

---

## Pipeline Stages

1. **Checkout** — Fetch source code from Git
2. **Build Backend** — Maven build (if `pom.xml` exists)
3. **Build Frontend** — npm build (if `package.json` exists)
4. **Test Backend** — JUnit tests
5. **Test Frontend** — Karma/Jasmine tests
6. **Deploy** — Deploy to selected environment (dev/staging/prod)
7. **Notifications** — Email + Slack on success/failure

---

## Troubleshooting

```bash
# View logs
docker logs -f jenkins

# Restart Jenkins
docker-compose restart jenkins

# Check agent status
docker-compose --profile distributed ps
```

---

## Audit

See **[AUDIT_CHECKLIST.md](AUDIT_CHECKLIST.md)** for step-by-step validation.

---

## License

MIT
