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

## Notes

Ce fichier ne contient aucun secret. Les actions critiques (création de credential, exécution Groovy) doivent être effectuées depuis la console Jenkins par un administrateur pour garantir l'audit.
