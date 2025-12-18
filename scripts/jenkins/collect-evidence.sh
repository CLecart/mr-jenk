#!/usr/bin/env bash
set -euo pipefail

# Collect minimal evidence for audit: configs, node/tool outputs, recent logs
# Usage: ./scripts/jenkins/collect-evidence.sh

TS=$(date -u +%Y%m%dT%H%M%SZ)
OUT_DIR="artifacts/evidence-${TS}"
mkdir -p "$OUT_DIR"

echo "Collecting evidence into $OUT_DIR"

# 1) Jenkins config
echo "- copying Jenkins config.xml"
docker cp jenkins:/var/jenkins_home/config.xml "$OUT_DIR/config.xml" 2>/dev/null || echo "config.xml not available"

# 2) e2e job build log (if present)
echo "- copying e2e build log (if present)"
docker exec jenkins bash -lc 'if [ -f /var/jenkins_home/jobs/e2e-test-pipeline/builds/1/log ]; then cat /var/jenkins_home/jobs/e2e-test-pipeline/builds/1/log; fi' > "$OUT_DIR/e2e-build-1.log" || true

# 3) container list
docker ps --format '{{.Names}} {{.Image}}' > "$OUT_DIR/docker-containers.txt"

# 4) probe known agent containers
echo "- probing agent containers (java/node/docker)"
grep -E 'jenkins-agent' "$OUT_DIR/docker-containers.txt" | awk '{print $1}' | while read -r C; do
  echo "-- $C" > "$OUT_DIR/${C}.txt"
  docker exec "$C" bash -lc 'echo "whoami:"; whoami; echo "java:"; java -version 2>&1 || true; echo "node:"; node -v 2>&1 || true; echo "docker:"; docker --version 2>&1 || true' >> "$OUT_DIR/${C}.txt" || true
done || true

# 5) recent Jenkins logs (last 1 hour)
echo "- collecting Jenkins logs (last 1h)"
docker logs --since 1h jenkins > "$OUT_DIR/jenkins-logs-1h.log" 2>&1 || true

# 6) system info
uname -a > "$OUT_DIR/host-uname.txt" || true
date -u > "$OUT_DIR/collected-at.txt"

# 7) create archive (do not add archive to git)
ARCHIVE="artifacts/evidence-${TS}.tar.gz"
mkdir -p artifacts
tar -C artifacts -czf "$ARCHIVE" "evidence-${TS}"

echo "Evidence archive created: $ARCHIVE"
ls -lh "$ARCHIVE"

echo "Collected files:" && ls -l "$OUT_DIR" || true

echo "Done. Please store the archive in a secure artifact store (S3, Nexus, Artifactory) for audit retention."
