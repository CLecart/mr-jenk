# Conversation & Audit Summary — MR-Jenk

Date: 2025-12-12

This document collects the full brief, audit constraints, current project state, and roadmap for the MR-Jenk CI/CD effort (Jenkins).

---

## 1. Executive summary

Objective: Implement a Jenkins CI/CD pipeline to automate build, test, and deployment for a microservices e-commerce project.

### Expected deliverables

1. **Jenkins setup**: Install and configure Jenkins (Docker recommended or native install)
2. **CI/CD pipeline**: Jenkins job connected to Git with automatic triggers
3. **Automated tests**: JUnit integration (backend) and Jasmine/Karma (Angular frontend)
4. **Deployment**: Automated deployment with rollback strategy
5. **Notifications**: Email/Slack alerts on build status

### Bonus

- **Parameterized builds**: Customizable builds (environment choice, etc.)
- **Distributed builds**: Use multiple agents for parallel builds

---

## 2. Audit constraints (strict)

### Functional

| Criterion           | Description                                                  | Status  |
| ------------------- | ------------------------------------------------------------ | ------- |
| Pipeline initiation | Pipeline runs end-to-end without errors                      | ⬜ TODO |
| Error handling      | Jenkins responds correctly to build failures                 | ⬜ TODO |
| Automated tests     | Tests run automatically; pipeline fails on test failures     | ⬜ TODO |
| Auto-trigger        | New commits/pushes automatically trigger the pipeline        | ⬜ TODO |
| Deployment          | Automated deployment on successful build + rollback strategy | ⬜ TODO |

### Security

| Criterion          | Description                                                                      | Status  |
| ------------------ | -------------------------------------------------------------------------------- | ------- |
| Permissions        | Jenkins permissions configured to prevent unauthorized access                    | ⬜ TODO |
| Secrets management | Sensitive data (API keys, passwords) secured via Jenkins credentials or env vars | ⬜ TODO |

### Code quality & standards

| Criterion           | Description                                                    | Status  |
| ------------------- | -------------------------------------------------------------- | ------- |
| Jenkinsfile quality | Well-structured, readable Jenkinsfile following best practices | ⬜ TODO |
| Test reports        | Clear, complete, archived test reports                         | ⬜ TODO |
| Notifications       | Informative notifications on build/deploy                      | ⬜ TODO |

### Bonus

| Criterion            | Description                      | Status  |
| -------------------- | -------------------------------- | ------- |
| Parameterized builds | Build customization options      | ⬜ TODO |
| Distributed builds   | Efficient use of multiple agents | ⬜ TODO |

---

## 3. Target architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         JENKINS SERVER                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Agent 1   │  │   Agent 2   │  │   Agent N   │  (Bonus)    │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PIPELINE STAGES                            │
├─────────────────────────────────────────────────────────────────┤
│  1. Checkout  →  2. Build  →  3. Test  →  4. Deploy  →  5. Notify│
│      (Git)       (Maven)     (JUnit/    (AWS/Heroku/   (Email/  │
│                              Karma)      Local)        Slack)   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Ordered checklist (TODO)

### Phase 1 — Jenkins setup

- [ ] 1.1 Install Jenkins (Docker recommended)
- [ ] 1.2 Configure Jenkins (essential plugins)
- [ ] 1.3 Configure credentials (Git, deployment, notifications)
- [ ] 1.4 Create build agents if required

### Phase 2 — Base pipeline

- [ ] 2.1 Add a `Jenkinsfile` at the project root
- [ ] 2.2 Configure the Jenkins job (Pipeline from SCM)
- [ ] 2.3 Configure the GitHub/GitLab webhook for auto-trigger
- [ ] 2.4 Test the pipeline manually

### Phase 3 — Automated tests

- [ ] 3.1 Integrate JUnit tests (Java/Spring backend)
- [ ] 3.2 Integrate Jasmine/Karma tests (Angular frontend)
- [ ] 3.3 Configure pipeline to fail on test failures
- [ ] 3.4 Archive test reports (JUnit XML, coverage)

### Phase 4 — Deployment

- [ ] 4.1 Choose deployment platform (AWS/Heroku/local)
- [ ] 4.2 Implement deploy stage
- [ ] 4.3 Implement rollback strategy
- [ ] 4.4 Test automated deployment

### Phase 5 — Notifications

- [ ] 5.1 Configure email notifications (SMTP)
- [ ] 5.2 (Optional) Configure Slack notifications
- [ ] 5.3 Customize messages (success/failure/rollback)

### Phase 6 — Security

- [ ] 6.1 Configure Jenkins user permissions
- [ ] 6.2 Secure secrets (Jenkins credentials)
- [ ] 6.3 Verify logs do not expose secrets

### Phase 7 — Bonus

- [ ] 7.1 Implement parameterized builds (environment selection)
- [ ] 7.2 Configure distributed builds (multiple agents)

### Phase 8 — Documentation & validation

- [ ] 8.1 Document the Jenkinsfile (clear comments)
- [ ] 8.2 Create a README with setup instructions
- [ ] 8.3 Test all audit scenarios
- [ ] 8.4 Final validation

---

## 5. Plugins Jenkins requis

| Plugin              | Usage                          |
| ------------------- | ------------------------------ |
| Git                 | Repository cloning             |
| Pipeline            | Jenkinsfile support            |
| Blue Ocean          | Modern UI (optional)           |
| JUnit               | Test reports parsing           |
| Email Extension     | Email notifications            |
| Slack Notification  | Slack notifications (optional) |
| Credentials Binding | Secure secret management       |
| Docker Pipeline     | Build/deploy with Docker       |
| NodeJS              | Build Angular frontend         |
| Maven Integration   | Build Java backend             |

---

## 6. Recommended Jenkinsfile structure

```groovy
pipeline {
    agent any  // or agent { label 'agent-name' } for distributed builds

    // Bonus: Parameterized builds
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests')
    }

    environment {
        // Credentials via Jenkins secrets
        DEPLOY_CREDENTIALS = credentials('deploy-creds-id')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend-angular') {
                    sh 'npm ci'
                    sh 'npm run build --prod'
                }
            }
        }

        stage('Test Backend') {
            when {
                expression { params.RUN_TESTS }
            }
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Test Frontend') {
            when {
                expression { params.RUN_TESTS }
            }
            steps {
                dir('frontend-angular') {
                    sh 'npm run test -- --watch=false --browsers=ChromeHeadless'
                }
            }
            post {
                always {
                    junit 'frontend-angular/test-results/*.xml'
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        // Deploy logic here
                        deployToEnvironment(params.ENVIRONMENT)
                    } catch (Exception e) {
                        // Rollback strategy
                        rollback()
                        throw e
                    }
                }
            }
        }
    }

    post {
        success {
            // Email/Slack notification on success
            emailext (
                subject: "✅ Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build completed successfully.",
                to: 'team@example.com'
            )
        }
        failure {
            // Email/Slack notification on failure
            emailext (
                subject: "❌ Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed. Check console output.",
                to: 'team@example.com'
            )
        }
    }
}

def deployToEnvironment(String env) {
    echo "Deploying to ${env}..."
    // Implementation selon la plateforme choisie
}

def rollback() {
    echo "Rolling back deployment..."
    // Implementation du rollback
}
```

---

## 7. Docker Jenkins configuration (recommended)

### docker-compose.yml

```yaml
version: "3.8"
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=true
    restart: unless-stopped

volumes:
  jenkins_home:
```

### Useful commands

```bash
# Start Jenkins
docker-compose up -d

# Retrieve the initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# View logs
docker logs -f jenkins

# Stop Jenkins
docker-compose down
```

---

## 8. Rollback strategy

### Option 1 — Blue/Green Deployment

- Maintain two environments (blue/green)
- Switch traffic to the new environment
- On failure, switch back to the previous environment

### Option 2 — Versioned Deployments

- Keep the last N deployed versions
- Provide a rollback script to redeploy version N-1

### Option 3 — Docker tags

- Tag each Docker image with the build number
- Rollback = redeploy the previous image

---

## 9. Secret management (security audit)

### To do

- [ ] Create Jenkins credentials for:
  - Git (SSH key or token)
  - Deployment platform (AWS keys, Heroku token, etc.)
  - SMTP (email password)
  - Slack webhook URL
- [ ] Use `credentials()` in the Jenkinsfile
- [ ] NEVER hardcode secrets
- [ ] Verify logs do not contain secrets (automatic masking)

### Permissions configuration

- [ ] Configure Matrix-based Security or Role-Based Strategy
- [ ] Create roles: Admin, Developer, Viewer
- [ ] Restrict access to job configuration
- [ ] Enable CSRF protection
- [ ] Configure the Security Realm (LDAP, GitHub OAuth, etc.)

---

## 10. GitHub webhooks (auto-trigger)

### GitHub configuration

1. Go to the repository Settings > Webhooks
2. Add a webhook: `http://<jenkins-url>/github-webhook/`
3. Content type: `application/json`
4. Events: `Just the push event` or `Pull requests`

### Jenkins configuration

1. In the job, check "GitHub hook trigger for GITScm polling"
2. Or use `triggers { githubPush() }` in the Jenkinsfile

---

## 11. Test reports

### Backend (JUnit/Surefire)

```groovy
post {
    always {
        junit '**/target/surefire-reports/*.xml'
        // Optionnel: coverage avec JaCoCo
        jacoco execPattern: '**/target/jacoco.exec'
    }
}
```

### Frontend (Karma)

Configure `karma.conf.js` to generate JUnit reports:

```javascript
reporters: ['progress', 'junit'],
junitReporter: {
    outputDir: 'test-results',
    outputFile: 'junit.xml'
}
```

---

## 12. Current project state

| Item                      | Status  | Notes |
| ------------------------- | ------- | ----- |
| Jenkins installed         | ⬜ TODO |       |
| Plugins configured        | ⬜ TODO |       |
| Jenkinsfile present       | ⬜ TODO |       |
| GitHub webhook            | ⬜ TODO |       |
| Backend tests integrated  | ⬜ TODO |       |
| Frontend tests integrated | ⬜ TODO |       |
| Automated deployment      | ⬜ TODO |       |
| Rollback strategy         | ⬜ TODO |       |
| Notifications             | ⬜ TODO |       |
| Secrets secured           | ⬜ TODO |       |
| Permissions configured    | ⬜ TODO |       |
| Parameterized builds      | ⬜ TODO | Bonus |
| Distributed builds        | ⬜ TODO | Bonus |

---

## 13. Code & documentation conventions

### General principles

- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **DRY**: Don't Repeat Yourself — factorize duplicated code
- **KISS**: Keep It Simple, Stupid — avoid unnecessary complexity
- **Clean Code**: Explicit names, small functions, no magic numbers

### Javadoc (Backend Java/Spring)

All public classes, public methods and DTOs must be documented with proper Javadoc.

```java
/**
 * Service responsible for user authentication and authorization.
 *
 * <p>This service handles JWT token generation, validation, and user
 * credential verification using BCrypt password encoding.</p>
 *
 * @author Team Buy-01
 * @version 1.0
 * @since 2025-12-01
 */
@Service
public class AuthService {

    /**
     * Authenticates a user and generates a JWT token.
     *
     * @param credentials the user's login credentials (email and password)
     * @return a valid JWT token string
     * @throws AuthenticationException if credentials are invalid
     * @throws IllegalArgumentException if credentials are null or malformed
     */
    public String authenticate(LoginCredentials credentials) {
        // implementation
    }
}
```

#### Javadoc checklist

- [ ] All public classes have a class description
- [ ] All public methods include `@param`, `@return`, `@throws` where applicable
- [ ] DTOs include field descriptions
- [ ] Avoid trivial Javadoc (e.g. `/** Gets the name. */` for `getName()`)
- [ ] Use `{@code}` for inline code references
- [ ] Use `{@link}` for cross-references to other classes/methods

### TSDoc (Frontend Angular)

All public Angular classes, services, and methods must be documented with TSDoc.

````typescript
/**
 * Service for managing product-related API calls.
 *
 * @remarks
 * This service communicates with the product-service backend
 * and handles caching of product data.
 *
 * @example
 * ```typescript
 * const products = await this.productService.getAll().toPromise();
 * ```
 */
@Injectable({ providedIn: "root" })
export class ProductService {
  /**
   * Retrieves all products with optional pagination.
   *
   * @param page - The page number (0-indexed)
   * @param size - Number of items per page
   * @returns An observable of paginated product response
   * @throws HttpErrorResponse when the API call fails
   */
  getAll(page: number = 0, size: number = 20): Observable<Page<Product>> {
    // implementation
  }
}
````

#### TSDoc checklist

- [ ] All services include a class description with `@remarks`
- [ ] All public methods have `@param` and `@returns`
- [ ] Components include a description of their responsibility
- [ ] Use `@example` for non-trivial usage scenarios
- [ ] Interfaces/types include property descriptions

### Groovydoc (Jenkinsfile)

The Jenkinsfile must be documented with clear Groovy comments.

```groovy
/**
 * CI/CD Pipeline for Buy-01 E-commerce Platform
 *
 * This pipeline handles:
 * - Source code checkout from Git
 * - Backend build (Maven) and Frontend build (npm)
 * - Automated testing (JUnit + Karma)
 * - Deployment to target environment
 * - Notifications on build status
 *
 * @author Team Buy-01
 * @version 1.0
 * @see https://github.com/team/buy-01
 */
pipeline {
    // Pipeline stages...
}

/**
 * Deploys the application to the specified environment.
 *
 * @param env The target environment ('dev', 'staging', 'prod')
 * @throws Exception if deployment fails
 */
def deployToEnvironment(String env) {
    // implementation
}

/**
 * Rolls back to the previous stable deployment.
 * Uses Docker image tags to restore the last working version.
 */
def rollback() {
    // implementation
}
```

---

## 14. Bonnes pratiques professionnelles

### Architecture & Design

| Practice              | Description                                           | Required |
| --------------------- | ----------------------------------------------------- | -------- |
| Layered Architecture  | Controller → Service → Repository                     | ✅       |
| Constructor Injection | No `@Autowired` on fields (use constructor injection) | ✅       |
| Final fields          | Immutability when possible                            | ✅       |
| DTOs for API          | Never expose entities directly                        | ✅       |
| Interface segregation | Small, focused interfaces                             | ✅       |

### Code Quality

| Practice               | Description                                       | Required |
| ---------------------- | ------------------------------------------------- | -------- |
| No `!important` in CSS | Use specificity correctly                         | ✅       |
| CSS Variables          | Use `--color-primary` instead of hardcoded values | ✅       |
| No magic numbers       | Use named constants                               | ✅       |
| Error handling         | Try-catch explicites, pas de swallow              | ✅       |
| Proper logging         | No sensitive information in logs                  | ✅       |

### Security

| Practice               | Description                        | Required |
| ---------------------- | ---------------------------------- | -------- |
| No secrets in code     | Use env vars / Jenkins credentials | ✅       |
| Server-side validation | Jakarta Validation on all DTOs     | ✅       |
| BCrypt for passwords   | Cost factor >= 10                  | ✅       |
| JWT secret >= 256 bits | For HS256                          | ✅       |
| HTTPS in production    | TLS mandatory                      | ✅       |

### Tests

| Practice          | Description                 | Required       |
| ----------------- | --------------------------- | -------------- |
| Tests unitaires   | JUnit 5 + Mockito (backend) | ✅             |
| Integration tests | Testcontainers for MongoDB  | ✅             |
| Tests frontend    | Jasmine/Karma               | ✅             |
| Coverage minimum  | 70%+ recommended            | ⚠️ Recommended |
| Regression tests  | Before each release         | ✅             |

### Git & Versioning

| Practice              | Description                           | Required |
| --------------------- | ------------------------------------- | -------- |
| Atomic commits        | One commit = one feature/fix          | ✅       |
| Messages explicites   | `feat:`, `fix:`, `docs:`, `refactor:` | ✅       |
| Branches feature      | `feature/`, `bugfix/`, `hotfix/`      | ✅       |
| Code review           | PR before merging into `main`         | ✅       |
| No force push on main | Never                                 | ✅       |

### CI/CD Specifics

| Practice             | Description                      | Required |
| -------------------- | -------------------------------- | -------- |
| Pipeline as Code     | Jenkinsfile versioned in Git     | ✅       |
| Fail fast            | Stop immediately on error        | ✅       |
| Archived artifacts   | Test reports, builds             | ✅       |
| Automatable rollback | Scripted or documented procedure | ✅       |
| Notifications        | On success AND failure           | ✅       |

---

## 15. Fichiers et structure attendus

```
buy-01/                          # Project root (e-commerce)
├── Jenkinsfile                  # Pipeline CI/CD (documented)
├── README.md                    # Instructions build/run/deploy
├── docker-compose.yml           # Orchestration des services
├── docker-compose.dev.yml       # Dev configuration
├── .env.example                 # Template variables d'environnement
├── .gitignore                   # Files excluded from Git
├── .dockerignore                # Files excluded from Docker
│
├── shared-lib/                  # Shared library
│   ├── src/main/java/
│   │   └── com/example/shared/
│   │       ├── security/        # JwtService, JwtAuthenticationFilter
│   │       ├── dto/             # Shared DTOs
│   │       ├── exception/       # Exceptions custom
│   │       └── web/             # ErrorResponse, ApiExceptionHandler
│   └── src/test/java/           # Tests unitaires
│
├── user-service/                # Service utilisateurs
│   ├── Dockerfile
│   ├── src/main/java/
│   │   └── com/example/user/
│   │       ├── controller/      # AuthController, UserController
│   │       ├── service/         # AuthService, UserService
│   │       ├── repository/      # UserRepository
│   │       ├── model/           # User entity
│   │       └── dto/             # LoginRequest, SignupRequest, etc.
│   └── src/test/java/           # Unit + integration tests
│
├── product-service/             # Service produits
│   ├── Dockerfile
│   ├── src/main/java/
│   │   └── com/example/product/
│   │       ├── controller/      # ProductController
│   │       ├── service/         # ProductService (ownership enforcement)
│   │       ├── repository/      # ProductRepository
│   │       ├── model/           # Product entity
│   │       └── dto/             # ProductRequest, ProductResponse
│   └── src/test/java/           # Unit + integration tests
│
├── media-service/               # Media service
│   ├── Dockerfile
│   ├── src/main/java/
│   │   └── com/example/media/
│   │       ├── controller/      # MediaController
│   │       ├── service/         # MediaService, StorageService
│   │       ├── repository/      # MediaRepository
│   │       ├── model/           # MediaFile entity
│   │       └── validation/      # Tika MIME validation
│   └── src/test/java/           # Unit + integration tests
│
└── frontend-angular/            # Frontend Angular
    ├── Dockerfile
    ├── karma.conf.js            # Config tests Karma (JUnit reporter)
    ├── src/
    │   ├── app/
    │   │   ├── components/      # Angular components (documented with TSDoc)
    │   │   ├── services/        # HTTP services (documented with TSDoc)
    │   │   ├── models/          # Interfaces TypeScript
    │   │   └── guards/          # Auth guards
    │   └── styles/
    │       └── _variables.scss  # CSS variables (--color-*)
    └── src/test/                # Tests Jasmine/Karma
```

---

## 16. Ressources

- [Jenkins Official Documentation](https://www.jenkins.io/doc/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Angular Testing Guide](https://angular.io/guide/testing)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins Credentials Plugin](https://plugins.jenkins.io/credentials/)
- [Javadoc Guide](https://www.oracle.com/technical-resources/articles/java/javadoc-tool.html)
- [TSDoc Reference](https://tsdoc.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## 17. Notes pour l'audit

### Test scenarios

1. **Full pipeline**: Run a manual build and verify all stages
2. **Build error**: Introduce a compile error and verify the pipeline fails
3. **Test failure**: Make a test fail and verify the pipeline stops
4. **Auto-trigger**: Commit/push and verify the build is triggered automatically
5. **Deployment**: Verify the application is deployed after a successful build
6. **Rollback**: Simulate a failed deployment and verify rollback works
7. **Notifications**: Verify email/Slack notifications on success and failure
8. **Security**: Verify secrets are not visible in logs
9. **Permissions**: Verify a non-admin user cannot modify jobs

### Documentation checklist (audit — code quality)

- [ ] Jenkinsfile documented with a Groovydoc header
- [ ] All helper functions documented (`deployToEnvironment`, `rollback`)
- [ ] Java classes have complete Javadoc
- [ ] Angular services documented with TSDoc
- [ ] README.md up to date with clear instructions

---

## 18. Contact / Notes

This document must be kept up to date throughout the project. Any architectural decision must be recorded here for audit purposes.

---

_Generated file for the MR-Jenk project; contains no secrets._
