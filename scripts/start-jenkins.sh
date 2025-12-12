#!/bin/bash
##############################################################################
# Jenkins Setup Script
#
# @description Script pour démarrer et configurer Jenkins
# @usage       ./scripts/start-jenkins.sh
# @author      MR-Jenk Team
##############################################################################

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

##############################################################################
# Vérifications préalables
##############################################################################

info "Vérification des prérequis..."

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    error "Docker n'est pas installé. Veuillez l'installer: https://docs.docker.com/get-docker/"
fi

# Vérifier Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    error "Docker Compose n'est pas installé."
fi

# Déterminer la commande docker-compose
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

success "Docker et Docker Compose sont installés"

##############################################################################
# Démarrage de Jenkins
##############################################################################

info "Démarrage de Jenkins..."

# Se placer dans le répertoire du projet
cd "$(dirname "$0")/.."

# Builder l'image custom
info "Construction de l'image Jenkins custom..."
$COMPOSE_CMD build --no-cache jenkins

# Démarrer Jenkins
info "Lancement du conteneur Jenkins..."
$COMPOSE_CMD up -d jenkins

##############################################################################
# Attente du démarrage
##############################################################################

info "Attente du démarrage de Jenkins (peut prendre 1-2 minutes)..."

MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login | grep -q "200\|403"; then
        success "Jenkins est démarré!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo -n "."
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    warning "Jenkins met du temps à démarrer. Vérifiez les logs avec: docker logs jenkins"
fi

##############################################################################
# Récupération du mot de passe initial
##############################################################################

echo ""
info "Récupération du mot de passe administrateur initial..."

sleep 5  # Attendre que le fichier soit créé

if docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo ""
    success "Mot de passe récupéré ci-dessus"
else
    warning "Le mot de passe n'est pas encore disponible."
    info "Exécutez: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi

##############################################################################
# Instructions finales
##############################################################################

echo ""
echo "=============================================================================="
echo -e "${GREEN}Jenkins est prêt!${NC}"
echo "=============================================================================="
echo ""
echo "🌐 URL:      http://localhost:8080"
echo ""
echo "📋 Étapes suivantes:"
echo "   1. Ouvrez http://localhost:8080 dans votre navigateur"
echo "   2. Entrez le mot de passe initial affiché ci-dessus"
echo "   3. Installez les plugins suggérés"
echo "   4. Créez votre compte administrateur"
echo "   5. Configurez l'URL Jenkins"
echo ""
echo "📚 Documentation: CONVERSATION_SUMMARY.md"
echo ""
echo "🛠️  Commandes utiles:"
echo "   - Voir les logs:    docker logs -f jenkins"
echo "   - Arrêter Jenkins:  $COMPOSE_CMD down"
echo "   - Redémarrer:       $COMPOSE_CMD restart jenkins"
echo ""
echo "=============================================================================="
