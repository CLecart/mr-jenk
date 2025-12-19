# Exécution sécurisée de `scripts/provision-credentials.groovy`

Ce document décrit, en français, les étapes sûres pour exécuter le script Groovy `scripts/provision-credentials.groovy` depuis la *Script Console* de Jenkins. Ne collez JAMAIS de secrets réels dans le dépôt — utilisez la console Jenkins pour insérer les valeurs sensibles au moment de l'exécution.

Préparations (avant exécution)
- Connectez‑vous à l'interface Jenkins avec un compte administrateur.
- Sauvegardez la configuration Jenkins si possible (export JCasC ou sauvegarde de `JENKINS_HOME`).
- Ouvrez la Script Console : `Manage Jenkins` → `Script Console`.

Étapes pas‑à‑pas
1. Ouvrir le fichier `scripts/provision-credentials.groovy` dans l'éditeur (ou dans VS Code) pour vérifier le contenu. Le script est idempotent : il ne créera pas de duplicata si l'identifiant existe déjà.
2. Dans la Script Console, coller le contenu du fichier, MAIS AVANT d'exécuter : remplacer les placeholders ci‑dessous par les vraies valeurs **dans la console** (ne pas modifier le fichier dans le dépôt) :

   - `REPLACE_WITH_SECRET_TEXT` → valeur du secret text (ex : token API)
   - `REPLACE_USER` / `REPLACE_PASSWORD` → identifiants user/password pour un service
   - `REPLACE_PRIVATE_KEY` → clé privée (si nécessaire) ; si vous utilisez une clé SSH, collez l'entière clé private key entre les balises BEGIN/END

3. (Optionnel mais recommandé) Avant d'exécuter, faites une exécution de test en commentaire sur la section de création pour valider la syntaxe (ou exécuter une version qui imprime uniquement les actions). Exemple : commentez `store.addCredentials(...)` et faites un `println` pour vérifier.
4. Exécutez le script dans la Script Console (bouton `Run`).

Vérifications post‑exécution
- Allez dans `Manage Jenkins` → `Credentials` → `System` → `Global credentials (unrestricted)` et vérifiez que les identifiants avec les IDs indiqués (`ci-api-token-chris`, `docker-registry-creds`, `deploy-ssh-key`) existent.
- Vérifiez que les descriptions correspondent et que les valeurs sensibles n'apparaissent pas en clair (les secrets s'affichent masqués dans l'UI).

Bonnes pratiques et sécurité
- N'insérez JAMAIS de secrets réels dans le dépôt Git.
- Préférez la saisie manuelle des secrets dans la Script Console ou la création via l'UI Jenkins lorsque c'est possible.
- Après vérification, supprimez toute copie de secret temporaire (dans `/tmp`, presse‑papier, éditeur, etc.).
- Documentez dans un journal d'audit (externe) qui a exécuté l'opération et à quelle heure.

Rollback (si besoin)
- Si une credential a été créée incorrectement, supprimez‑la depuis l'UI Jenkins (`Manage Jenkins` → `Credentials`) et recréez la correctement.
- Si une opération a eu des effets plus larges, restaurez depuis la sauvegarde JCasC / `JENKINS_HOME` précédemment réalisée.

Notes
- Le script `scripts/provision-credentials.groovy` dans le dépôt contient des placeholders. Remplacez les placeholders uniquement dans la Script Console avant d'exécuter.
- Si vous voulez que j'exécute ce script côté serveur (requiert accès CLI/SSH et droits), dites‑le explicitement ; sinon, suivez les étapes ci‑dessus.

---
Fichier ajouté pour la branche d'audit `audit/phase-1-hardening`.
