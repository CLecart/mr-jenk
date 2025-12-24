# Audit — mr-jenk

Date: 2025-12-18

## Summary

Cleanup and consolidation performed. The repository has been consolidated on the `main` branch.

## Actions performed

- Branch consolidation: removed unnecessary branches; `main` is the active branch.
- Cleaned temporary backups and local mirrors/clones (directories matching `/tmp/*mr-jenk*`).
- Updated the main repository to reflect the consolidated state.

## Short recommendation

- Re-clone the repository from the official URL:

```bash
git clone https://zone01normandie.org/git/clecart/mr-jenk.git
```

- For any sensitive operation, perform actions from the Jenkins Script Console as an administrator (so the action is logged).

## Evidence archival

Collected evidence from runs (job configuration, build JSON, consoleText, queue items, crumb) is stored under the `evidence/` directory.

- Encrypted archives: `evidence/archives/evidence-YYYYMMDDTHHMMSS.tar.gz.gpg` (UTC timestamp in filename).
- If GPG is not available, the script falls back to OpenSSL and produces a `*.enc` file.

Short procedure to restore an archive:

- With GPG (file ending `.gpg`):

```bash
gpg --batch --yes --output evidence.tar.gz --decrypt evidence-YYYYMMDDTHHMMSS.tar.gz.gpg
tar -xzf evidence.tar.gz
```

- With OpenSSL (file ending `.enc`):

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"<PASSPHRASE>" -in file.tar.gz.enc -out file.tar.gz
tar -xzf file.tar.gz
```

Security notes:

- Keep the passphrase secure (do not store it in the repository). The script `scripts/clean_evidence.sh` accepts a single-line passphrase from `.env.local` or can prompt interactively.
- By default archives are kept in `evidence/archives`. Use `--prune-days` to remove raw evidence files older than N days to reduce exposure of sensitive artifacts.

End of report.
