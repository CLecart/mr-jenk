#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# load local env if present
if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi
JENKINS_URL="http://localhost:${JENKINS_PORT:-8080}"
if [ ! -f evidence/crumb.json ]; then
  echo "crumb missing: please fetch /crumbIssuer/api/json first"
  exit 1
fi
CRUMB=$(jq -r .crumb evidence/crumb.json)
CRUMB_FIELD=$(jq -r .crumbRequestField evidence/crumb.json)
AUTH_USER=${JENKINS_ADMIN}
AUTH_TOKEN=${JENKINS_API_TOKEN}

# trigger a job and collect queue/build/console
trigger_job_simple() {
  local job="$1"
  echo "\n--- Triggering job: $job ---"
  hdr="evidence/${job}-build-response-headers.txt"
  httpcode="evidence/${job}-build-http-code.txt"
  curl -s -u "${AUTH_USER}:${AUTH_TOKEN}" -H "${CRUMB_FIELD}:${CRUMB}" -X POST "${JENKINS_URL}/job/${job}/build" -D "${hdr}" -o /dev/null -w "%{http_code}" > "${httpcode}" || true
  echo "HTTP code: $(cat "${httpcode}" 2>/dev/null || echo '')"
  loc=$(grep -i '^Location:' "${hdr}" 2>/dev/null | awk '{print $2}' | tr -d '\r' || true)
  if [ -z "${loc}" ]; then
    echo "No Location header for ${job}; job may not exist or require parameters. See ${hdr}"
    return 1
  fi
  qid=$(basename "${loc}" | tr -d '/')
  echo "Queue id: ${qid}"
  # poll queue for executable (2 minutes)
  buildnum=''
    for i in $(seq 1 24); do
    sleep 5
    qjson=$(curl -s -u "${AUTH_USER}:${AUTH_TOKEN}" "${JENKINS_URL}/queue/item/${qid}/api/json")
    echo "${qjson}" > "evidence/${job}-queue-${qid}.json"
    	exe=$(echo "${qjson}" | jq -r '.executable.number // empty')
    if [ -n "${exe}" ] && [ "${exe}" != "null" ]; then
      buildnum=${exe}
      echo "Found executable: ${buildnum}"
      break
    fi
  done
  if [ -z "${buildnum}" ]; then
    echo "No executable for ${job} within timeout"
    return 2
  fi
  # poll build until finished (5 minutes)
    for i in $(seq 1 60); do
    sleep 5
    bjson=$(curl -s -u "${AUTH_USER}:${AUTH_TOKEN}" "${JENKINS_URL}/job/${job}/${buildnum}/api/json")
    echo "${bjson}" > "evidence/${job}-build-${buildnum}.json"
    	building=$(echo "${bjson}" | jq -r '.building')
    if [ "${building}" = "false" ]; then
      echo "Build ${buildnum} finished"
      curl -s -u "${AUTH_USER}:${AUTH_TOKEN}" "${JENKINS_URL}/job/${job}/${buildnum}/consoleText" > "evidence/${job}-console-${buildnum}.txt"
      return 0
    fi
  done
  echo "Build ${buildnum} did not finish within timeout"
  return 3
}

jobs=("mr-jenk-pipeline" "mr-jenk")
for job in "${jobs[@]}"; do
  trigger_job_simple "${job}" || true
done

echo "\nListing collected files (matching job names):"
ls -la evidence/*mr-jenk* 2>/dev/null || true
