```markdown
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

- Pour toute opération sensible, exécuter les actions depuis la console Jenkins par un administrateur.

Fin du rapport.

```
