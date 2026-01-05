# MR-Jenk — Audit Checklist

This document provides step-by-step instructions to validate all audit criteria.

---

## Prerequisites

Before starting the audit:

```bash
# 1. Clone the repository
git clone https://github.com/CLecart/mr-jenk.git
cd mr-jenk

# 2. Copy environment file
cp .env.example .env
# Edit .env with your values (secrets, tokens)

# 3. Start Jenkins
docker-compose up -d

# 4. (Optional) Start distributed agents
docker-compose --profile distributed up -d
```

Wait for Jenkins to be available at http://localhost:8080

---

## Part 1: Functional Tests

### 1.1 Pipeline Initiation

**Question:** Does the pipeline initiate and run successfully from start to finish?

**Steps:**

1. Open Jenkins: http://localhost:8080
2. Navigate to job `mr-jenk-pipeline`
3. Click **Build with Parameters**
4. Select environment: `dev`
5. Click **Build**
6. Observe the pipeline stages executing

**Expected:** Pipeline completes all stages (Checkout → Build → Test → Deploy)

---

### 1.2 Build Error Handling

**Question:** Does Jenkins respond appropriately to build errors?

**Steps:**

1. Introduce an intentional error in `Jenkinsfile` (e.g., typo in a command)
2. Commit and push the change
3. Trigger a build
4. Observe Jenkins response

**Expected:**

- Pipeline fails gracefully
- Error is logged clearly
- Notification is sent (check email/Slack)
- Post-failure actions execute

---

### 1.3 Automated Testing

**Question:** Are tests run automatically? Does the pipeline halt on test failure?

**Steps:**

1. If you have a backend with `pom.xml`:
   - Add a failing test
   - Push and trigger build
2. If you have a frontend with `package.json`:
   - Add a failing test
   - Push and trigger build

**Expected:**

- Tests run automatically during pipeline execution
- Pipeline fails when tests fail
- JUnit reports are published (check **Test Result** in build page)

---

### 1.4 Auto-Trigger on Push

**Question:** Does a new commit automatically trigger the pipeline?

**Steps:**

1. Make a minor change in the repository
2. Commit and push:
   ```bash
   echo "# test" >> README.md
   git add README.md
   git commit -m "test: trigger build"
   git push
   ```
3. Check Jenkins immediately

**Expected:** A new build is triggered automatically within 1-2 minutes

**Note:** If webhook is not configured, polling (`H/5 * * * *`) triggers within 5 minutes.

---

### 1.5 Deployment & Rollback

**Question:** Is there automatic deployment and rollback strategy?

**Steps:**

1. Run a build with **ENVIRONMENT = staging**
2. Check the Deploy stage logs
3. To test rollback: modify the `deploy()` function to fail intentionally

**Expected:**

- Deployment executes for the selected environment
- On failure, `rollback()` function is called
- Production deployment requires manual approval (`input` step)

---

## Part 2: Security

### 2.1 Permissions

**Question:** Are permissions set appropriately?

**Steps:**

1. Log in as `admin` — should have full access
2. Log in as `developer` — should be able to build but not configure
3. Log in as `viewer` — should only be able to view

**Default credentials (change immediately!):**

- admin / CHANGE_ME_IMMEDIATELY
- developer / CHANGE_ME_IMMEDIATELY
- viewer / CHANGE_ME_IMMEDIATELY

**Expected:** Each role has appropriate access levels

---

### 2.2 Secrets Management

**Question:** Is sensitive data secured?

**Steps:**

1. Check `.gitignore` — should include `.env`, `secrets/`, `credentials/`
2. Check Jenkinsfile — uses `credentials('...')` for secrets
3. Check Jenkins: **Manage Jenkins → Credentials**

**Expected:**

- No secrets in repository history
- Secrets stored in Jenkins Credentials
- Environment variables used for sensitive data

---

## Part 3: Code Quality

### 3.1 Jenkinsfile Organization

**Question:** Is the Jenkinsfile well-organized?

**Check:**

- [ ] Clear stage names
- [ ] Comments explaining each section
- [ ] Helper functions for reusable code
- [ ] Parameterized builds documented
- [ ] Error handling in place

**File:** `Jenkinsfile`

---

### 3.2 Test Reports

**Question:** Are test reports clear and stored?

**Steps:**

1. Run a build with tests
2. Go to build page
3. Check **Test Result** section

**Expected:**

- JUnit reports visible
- Test history preserved
- Clear pass/fail indicators

---

### 3.3 Notifications

**Question:** Are notifications triggered and informative?

**Steps:**

1. Check `post { }` block in Jenkinsfile
2. Run a successful build — check notification
3. Run a failing build — check notification

**Expected:**

- Email sent on success/failure
- Slack message sent (if configured)
- Notification includes: job name, build number, status, commit info

---

## Part 4: Bonus Features

### 4.1 Parameterized Builds

**Question:** Can builds be customized with parameters?

**Steps:**

1. Click **Build with Parameters**
2. Available parameters:
   - `ENVIRONMENT`: dev / staging / prod
   - `SKIP_TESTS`: true / false
   - `FORCE_DEPLOY`: true / false

**Expected:** Parameters affect build behavior as expected

---

### 4.2 Distributed Builds

**Question:** Are multiple agents used effectively?

**Steps:**

1. Start agents:
   ```bash
   docker-compose --profile distributed up -d
   ```
2. Check Jenkins: **Manage Jenkins → Nodes**
3. Run a build and observe which agent executes which stage

**Expected:**

- Multiple agents available
- Test stages can run on dedicated agents
- Jenkinsfile uses `agent { label '...' }` for distribution

---

## Quick Commands Reference

```bash
# Start Jenkins only
docker-compose up -d

# Start with distributed agents
docker-compose --profile distributed up -d

# View logs
docker-compose logs -f jenkins

# Stop everything
docker-compose down

# Trigger build via API
source .env
curl -X POST -u "$JENKINS_ADMIN:$JENKINS_API_TOKEN" \
  "http://localhost:8080/job/mr-jenk-pipeline/build"
```

---

## Files Overview

| File                                | Purpose                |
| ----------------------------------- | ---------------------- |
| `Jenkinsfile`                       | Pipeline definition    |
| `docker-compose.yml`                | Jenkins + agents setup |
| `Dockerfile.jenkins`                | Custom Jenkins image   |
| `Dockerfile.agent`                  | Custom agent image     |
| `scripts/configure-security.groovy` | Security configuration |
| `scripts/start-jenkins.sh`          | Startup helper         |
| `plugins.txt`                       | Jenkins plugins list   |

---

## Audit Summary

| Category         | Criterion                  | Status |
| ---------------- | -------------------------- | ------ |
| **Functional**   | Pipeline runs successfully | ⬜     |
|                  | Error handling works       | ⬜     |
|                  | Tests run automatically    | ⬜     |
|                  | Auto-trigger on push       | ⬜     |
|                  | Deployment + rollback      | ⬜     |
| **Security**     | Permissions configured     | ⬜     |
|                  | Secrets secured            | ⬜     |
| **Code Quality** | Jenkinsfile organized      | ⬜     |
|                  | Test reports clear         | ⬜     |
|                  | Notifications work         | ⬜     |
| **Bonus**        | Parameterized builds       | ⬜     |
|                  | Distributed builds         | ⬜     |

---

**Good luck with your audit!**
