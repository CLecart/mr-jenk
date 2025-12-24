# Audit — mr-jenk

Date : 2025-12-18

## Résumé

Nettoyage et consolidation effectués. Le dépôt a été consolidé sur la branche `main`.

## Actions réalisées

- Consolidation des branches : suppression des branches non nécessaires, `main` est la branche active.
- Nettoyage des sauvegardes temporaires et des clones/miroirs locaux (répertoires `/tmp/*mr-jenk*`).
- Mise à jour du dépôt principal pour refléter l'état consolidé.

## Recommandation courte

- Recloner le dépôt depuis l'URL officielle :

```bash
git clone https://zone01normandie.org/git/clecart/mr-jenk.git
```

- Pour toute opération sensible, exécuter les actions depuis la console Jenkins par un administrateur.

## Archivage des preuves

Les preuves collectées lors des exécutions (configuration du job, JSON de build, consoleText, queue, crumb) sont stockées dans le répertoire `evidence/`.

- Archives chiffrées : `evidence/archives/evidence-YYYYMMDDTHHMMSS.tar.gz.gpg` (nom avec timestamp UTC).
- Si GPG n'est pas disponible, le script peut utiliser OpenSSL et produire un fichier `*.enc`.

Procédure courte pour restaurer une archive :

- Avec GPG (fichier `.gpg`) :

```bash
gpg --batch --yes --output evidence.tar.gz --decrypt evidence-YYYYMMDDTHHMMSS.tar.gz.gpg
tar -xzf evidence.tar.gz
```

- Avec OpenSSL (fichier `.enc`) :

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"<PASSPHRASE>" -in file.tar.gz.enc -out file.tar.gz
tar -xzf file.tar.gz
```

Remarques de sécurité :

- La passphrase utilisée doit être conservée en sécurité (ne pas la stocker dans le dépôt). Le script `scripts/clean_evidence.sh` accepte une passphrase via `.env.local` (fichier temporaire) ou par saisie interactive.
- Par défaut, les archives sont conservées dans `evidence/archives` et les fichiers bruts peuvent être supprimés via l'option `--prune-days` pour réduire l'exposition des artefacts sensibles.

Fin du rapport.

````markdown
# Audit — mr-jenk

Date: 2025-12-18

## Résumé

Nettoyage et consolidation effectués. Le dépôt a été consolidé sur la branche `main`.

## Actions réalisées

- Consolidation des branches : toutes les branches non nécessaires ont été supprimées et `main` est la branche active.
- Suppression des sauvegardes temporaires et des clones/miroirs locaux (répertoires `/tmp/*mr-jenk*`).
- Mise à jour du dépôt principal pour refléter l'état consolidé.

## Recommandation courte

- Recloner le dépôt à partir de l'URL officielle :

```bash
git clone https://zone01normandie.org/git/clecart/mr-jenk.git
```
````

- Pour toute opération sensible, exécuter les actions depuis la console Jenkins par un administrateur.

Fin du rapport.

```

```
