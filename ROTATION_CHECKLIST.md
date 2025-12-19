Checklist prioritaire de rotation

1. Révoquer toutes les clés SSH/deploy keys créées localement si elles existaient (vérifier serveurs et Git hosting).
2. Révoquer/rotater tout token GitHub/Gitea, PAT ou tokens CI visibles.
3. Regénérer clés d'accès pour services liés (si SSH deploy keys utilisées).
4. Mettre à jour les secrets dans Jenkins Credentials et valider l'accès via pipeline.
5. Vérifier journaux d'accès récents pour détecter toute activité anormale.

