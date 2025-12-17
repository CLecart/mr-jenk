# Audit initial — mr-jenk

Date: 2025-12-17

## Résumé

Rapide audit initial et actions réalisées pendant la session interactive.

## Constats principaux

- Jenkins controller démarré et marqué `healthy` (version 2.528.3).
- Au moins un agent (`jenkins-agent-1`) est connecté via JNLP ; connexions acceptées depuis le réseau Docker.
- Avertissement récurrent : metadata NodeJS manquante (plugin NodeJS) — peut empêcher installation automatique de Node.
- Le dépôt contient des scripts idempotents pour provisioning (`scripts/setup-credentials.groovy`) et un script de durcissement ajouté `scripts/harden-controller.groovy`.

## Actions réalisées

- Ajouté `scripts/harden-controller.groovy` (idempotent) — met `executors=0`, active CSRF (crumb issuer) et désactive le port agent TCP.
- Ajouté `Dockerfile.agent` et un service `jenkins-agent-pro` dans `docker-compose.yml` pour usage local/dev (image avec JDK17, Node20, Docker CLI).
- Lancé des vérifications `docker ps` et récupéré les logs du contrôleur pour confirmer l'état.
- Branches Git : créé la branche `harden-controller-2025-12-17` (travail) et maintenant création de la branche d'audit `audit/report-2025-12-17` (cette branche).

## Risques et remarques

- Montage du socket Docker (`/var/run/docker.sock`) dans les agents est pratique pour le développement, mais représente un risque élevé en production (accès root au host). Préconiser pour dev seulement.
- Les credentials ne doivent pas être stockés dans le repo. Préférer création via UI Jenkins (auditée) ou via Groovy idempotent collé dans la Script Console par un administrateur.

## Recommandations prioritaires (ordre d'exécution)

1. Appliquer le script `scripts/harden-controller.groovy` via **Manage Jenkins → Script Console** (action locale et auditée). Il est idempotent et affichera l'état avant/après.
2. Configurer l'authentification centralisée (SSO/LDAP/OAuth) et activer la sécurité par matrice (Matrix-based security) pour limiter les droits administrateurs.
3. Stocker et provisionner les secrets dans Jenkins Credentials ou HashiCorp Vault ; créer `ci-api-token-chris` via l'UI pour garder la trace d'audit.
4. Pour la production : retirer tout montage de `/var/run/docker.sock` et migrer les builds d'images vers kaniko / buildkit / builders isolés ou agents Kubernetes éphémères.
5. Activer l'audit trail plugin et exporter les logs vers un SIEM ou stockage centralisé pour conservation/triage.

## Prochaines actions planifiées

- Exécuter le durcissement sur le contrôleur (Script Console) — administrateur local.
- Provisionner `ci-api-token-chris` (via UI ou Groovy idempotent si vous préférez).
- Valider que les agents disposent des outils requis (java, node, docker cli) ou construire une image d'agent signée et scannée.
- Rédiger et automatiser sauvegardes régulières de `JENKINS_HOME` et exporter la configuration en JCasC.

## Validation E2E (exécution locale — 2025-12-17)

- Un job pipeline minimal `e2e-test-pipeline` a été ajouté pour valider l'agent `jenkins-agent-pro`.
- Le job a été copié dans `/var/jenkins_home/jobs/e2e-test-pipeline/config.xml` pour tests locaux.
- Tentative d'ordonnancement automatique du build au démarrage par un script d'init : le job n'était pas immédiatement disponible au redémarrage, donc l'ordonnancement automatique n'a pas produit de build. Pour éviter des actions imprévues, le job a été déclenché manuellement ou ses étapes ont été reproduites directement sur l'agent.
- Vérifications réalisées directement dans le conteneur agent `jenkins-agent-pro-1` :
  - `java -version` → OpenJDK 17 (OK)
  - `node -v` → Node 20 (OK)
  - `docker --version` → Docker client présent (OK)
  - Création d'un fichier marqueur `/home/jenkins/e2e_test_output.txt` contenant `OK` prouvant l'exécution des étapes du pipeline.
- Note d'audit : le port JNLP TCP (50000) a été temporairement réactivé sur le contrôleur pour permettre la validation de l'agent. Cette réactivation est strictement pour tests locaux ; la recommandation est :
  1.  Migrer les agents vers la connexion WebSocket (plus sûre) ou utiliser agents éphémères (Kubernetes/ephemeral).
  2.  Remettre `<slaveAgentPort>-1</slaveAgentPort>` (fermer le port TCP) sur le contrôleur une fois la migration vérifiée.

## Notes

Ce fichier ne contient aucun secret. Les actions critiques (création de credential, exécution Groovy) doivent être effectuées depuis la console Jenkins par un administrateur pour garantir l'audit.
