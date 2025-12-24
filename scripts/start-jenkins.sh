#!/bin/bash
##############################################################################
# Jenkins Setup Script
#
# @description Script to build, start and provide basic instructions for Jenkins
# @usage       ./scripts/start-jenkins.sh
# @author      MR-Jenk Team
##############################################################################

set -e

# Colors for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display helper functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

##############################################################################
# Pre-flight checks
##############################################################################

info "Checking prerequisites..."

# Check Docker
success "Docker and Docker Compose are installed"
if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install: https://docs.docker.com/get-docker/"
fi

# Check for Docker Compose (supports both 'docker compose' and 'docker-compose')
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    error "Docker Compose is not installed. Install Docker Compose or use Docker CLI v2+ (docker compose)."
fi

success "Docker and Docker Compose are available"

##############################################################################
# Start Jenkins
##############################################################################

info "Starting Jenkins..."

# Change to project dir
cd "$(dirname "$0")/.."

# Build custom image
info "Building custom Jenkins image..."
$COMPOSE_CMD build --no-cache jenkins

$COMPOSE_CMD up -d jenkins

# Start Jenkins
info "Starting Jenkins container..."
$COMPOSE_CMD up -d jenkins

##############################################################################
# Wait for startup
##############################################################################

info "Waiting for Jenkins to become available (this can take 1-2 minutes)..."

MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login || echo "000")
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "403" ]; then
        success "Jenkins is up and responding (HTTP $STATUS)"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo -n "."
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    warning "Jenkins is taking a long time to start. Check logs with: docker logs jenkins"
fi

##############################################################################
# Retrieve initial admin password
##############################################################################

echo ""
info "Retrieving initial admin password..."

sleep 5  # small wait for file creation

if docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo ""
    success "Initial admin password displayed above"
else
    warning "Initial admin password is not yet available."
    info "Run: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi

##############################################################################
# Final instructions
##############################################################################

echo ""
echo "=============================================================================="
echo -e "${GREEN}Jenkins is ready!${NC}"
echo "=============================================================================="
echo ""
echo "🌐 URL:      http://localhost:8080"
echo ""
echo "📋 Next steps:"
echo "   1. Open http://localhost:8080 in your browser"
echo "   2. Enter the initial admin password printed above"
echo "   3. Install the suggested plugins"
echo "   4. Create an administrator account"
echo "   5. Configure the Jenkins URL and security settings"
echo ""
echo "📚 Documentation: CONVERSATION_SUMMARY.md"
echo ""
echo "🛠️  Useful commands:"
echo "   - View logs:        docker logs -f jenkins"
echo "   - Stop Jenkins:     $COMPOSE_CMD down"
echo "   - Restart Jenkins:  $COMPOSE_CMD restart jenkins"
echo ""
echo "=============================================================================="
