#!/bin/bash

# Script Bash pour lancer l'application Flask avec Docker
# Usage: ./docker-start.sh [OPTIONS]

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Variables par défaut
DEV_MODE=false
BUILD=false
REBUILD=false
LOGS=false
STOP=false
DOWN=false
CLEAN=false
STATUS=false
SHELL=false

# Fonction d'aide
show_help() {
    echo -e "${GREEN}Script Docker pour SMA AI REST Server${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./docker-start.sh [OPTIONS]${NC}"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}--dev               ${NC}Lance en mode développement avec hot-reload"
    echo -e "  ${CYAN}--build             ${NC}Build l'image avant de lancer"
    echo -e "  ${CYAN}--rebuild           ${NC}Rebuild complet (--no-cache)"
    echo -e "  ${CYAN}--logs              ${NC}Affiche les logs en continu"
    echo -e "  ${CYAN}--stop              ${NC}Arrête les conteneurs"
    echo -e "  ${CYAN}--down              ${NC}Arrête et supprime les conteneurs"
    echo -e "  ${CYAN}--clean             ${NC}Nettoyage complet (conteneurs, images, volumes)"
    echo -e "  ${CYAN}--status            ${NC}Affiche le statut des conteneurs"
    echo -e "  ${CYAN}--shell             ${NC}Ouvre un shell dans le conteneur"
    echo -e "  ${CYAN}--help              ${NC}Affiche cette aide"
    echo ""
    echo -e "${YELLOW}Exemples:${NC}"
    echo -e "  ${CYAN}./docker-start.sh                     ${NC}# Lance en production"
    echo -e "  ${CYAN}./docker-start.sh --dev               ${NC}# Lance en développement"
    echo -e "  ${CYAN}./docker-start.sh --build             ${NC}# Build et lance"
    echo -e "  ${CYAN}./docker-start.sh --logs              ${NC}# Affiche les logs"
    echo -e "  ${CYAN}./docker-start.sh --stop              ${NC}# Arrête les conteneurs"
}

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev)
            DEV_MODE=true
            shift
            ;;
        --build)
            BUILD=true
            shift
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        --logs)
            LOGS=true
            shift
            ;;
        --stop)
            STOP=true
            shift
            ;;
        --down)
            DOWN=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --status)
            STATUS=true
            shift
            ;;
        --shell)
            SHELL=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé ou pas accessible${NC}"
    echo -e "${YELLOW}   Installez Docker depuis https://www.docker.com/get-started${NC}"
    exit 1
fi

DOCKER_VERSION=$(docker --version 2>&1)
echo -e "${GREEN}🐳 Docker: ${DOCKER_VERSION}${NC}"

# Vérifier Docker Compose
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas disponible${NC}"
    exit 1
fi

COMPOSE_VERSION=$(docker compose version 2>&1)
echo -e "${GREEN}📦 Docker Compose: ${COMPOSE_VERSION}${NC}"

# Déterminer le fichier docker-compose à utiliser
if [[ "$DEV_MODE" == true ]]; then
    COMPOSE_FILE="docker-compose.dev.yml"
    MODE="développement"
    SERVICE_NAME="sma-ai-rest-dev"
else
    COMPOSE_FILE="docker-compose.yml"
    MODE="production"
    SERVICE_NAME="sma-ai-rest"
fi

# Vérifier que le fichier existe
if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo -e "${RED}❌ Fichier $COMPOSE_FILE introuvable${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🚀 SMA AI REST Server - Docker${NC}"
echo -e "${CYAN}📁 Répertoire: $(pwd)${NC}"
echo -e "${CYAN}🔧 Mode: ${MODE}${NC}"
echo -e "${CYAN}📄 Configuration: ${COMPOSE_FILE}${NC}"
echo ""

# Gestion des différentes actions
if [[ "$STATUS" == true ]]; then
    echo -e "${YELLOW}📊 Statut des conteneurs:${NC}"
    docker compose -f "$COMPOSE_FILE" ps
    echo ""
    echo -e "${YELLOW}📈 Statistiques:${NC}"
    docker stats --no-stream $(docker compose -f "$COMPOSE_FILE" ps -q) 2>/dev/null || echo "Aucun conteneur en cours d'exécution"
    exit 0
fi

if [[ "$SHELL" == true ]]; then
    echo -e "${YELLOW}🐚 Ouverture d'un shell dans le conteneur...${NC}"
    if ! docker compose -f "$COMPOSE_FILE" exec "$SERVICE_NAME" /bin/bash; then
        echo -e "${YELLOW}⚠️  Bash non disponible, tentative avec sh...${NC}"
        docker compose -f "$COMPOSE_FILE" exec "$SERVICE_NAME" /bin/sh
    fi
    exit 0
fi

if [[ "$STOP" == true ]]; then
    echo -e "${YELLOW}🛑 Arrêt des conteneurs...${NC}"
    docker compose -f "$COMPOSE_FILE" stop
    echo -e "${GREEN}✅ Conteneurs arrêtés${NC}"
    exit 0
fi

if [[ "$DOWN" == true ]]; then
    echo -e "${YELLOW}🗑️  Arrêt et suppression des conteneurs...${NC}"
    docker compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}✅ Conteneurs supprimés${NC}"
    exit 0
fi

if [[ "$CLEAN" == true ]]; then
    echo -e "${RED}⚠️  ATTENTION: Nettoyage complet!${NC}"
    echo -e "${YELLOW}   Cela supprimera:${NC}"
    echo -e "${YELLOW}   - Les conteneurs${NC}"
    echo -e "${YELLOW}   - Les images${NC}"
    echo -e "${YELLOW}   - Les volumes (base de données)${NC}"
    echo ""
    read -p "Êtes-vous sûr ? (yes pour confirmer): " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        echo -e "${YELLOW}🗑️  Nettoyage en cours...${NC}"
        docker compose -f docker-compose.yml down -v --rmi all 2>/dev/null
        docker compose -f docker-compose.dev.yml down -v --rmi all 2>/dev/null
        echo -e "${GREEN}✅ Nettoyage terminé${NC}"
    else
        echo -e "${YELLOW}🚫 Nettoyage annulé${NC}"
    fi
    exit 0
fi

if [[ "$LOGS" == true ]]; then
    echo -e "${YELLOW}📋 Affichage des logs (Ctrl+C pour quitter)...${NC}"
    docker compose -f "$COMPOSE_FILE" logs -f
    exit 0
fi

# Créer les répertoires nécessaires
if [[ ! -d "instance" ]]; then
    mkdir -p instance
    echo -e "${GREEN}📁 Répertoire instance créé${NC}"
fi

if [[ ! -d "logs" ]]; then
    mkdir -p logs
    echo -e "${GREEN}📁 Répertoire logs créé${NC}"
fi

# Build de l'image si nécessaire
if [[ "$REBUILD" == true ]]; then
    echo -e "${YELLOW}🔨 Rebuild complet de l'image (sans cache)...${NC}"
    if ! docker compose -f "$COMPOSE_FILE" build --no-cache; then
        echo -e "${RED}❌ Erreur lors du build${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Build terminé${NC}"
elif [[ "$BUILD" == true ]]; then
    echo -e "${YELLOW}🔨 Build de l'image...${NC}"
    if ! docker compose -f "$COMPOSE_FILE" build; then
        echo -e "${RED}❌ Erreur lors du build${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Build terminé${NC}"
fi

# Démarrer les conteneurs
echo -e "${GREEN}🚀 Démarrage des conteneurs...${NC}"
if ! docker compose -f "$COMPOSE_FILE" up -d; then
    echo -e "${RED}❌ Erreur lors du démarrage des conteneurs${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Conteneurs démarrés avec succès!${NC}"
echo ""

# Attendre que le serveur soit prêt
echo -e "${YELLOW}⏳ Vérification de l'état du serveur...${NC}"
sleep 3

MAX_ATTEMPTS=10
ATTEMPT=0
SERVER_READY=false

while [[ $ATTEMPT -lt $MAX_ATTEMPTS ]]; do
    if curl -f http://localhost:5000/health -s -o /dev/null 2>&1; then
        SERVER_READY=true
        break
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    echo -n "."
    sleep 2
done

echo ""

if [[ "$SERVER_READY" == true ]]; then
    echo -e "${GREEN}✅ Serveur opérationnel!${NC}"
else
    echo -e "${YELLOW}⚠️  Le serveur démarre... vérifiez les logs si nécessaire${NC}"
fi

echo ""
echo -e "${GREEN}🌟 Application disponible:${NC}"
echo -e "${CYAN}   • Interface web:     http://localhost:5000/${NC}"
echo -e "${CYAN}   • Documentation API: http://localhost:5000/api/docs${NC}"
echo -e "${CYAN}   • Health check:      http://localhost:5000/health${NC}"
echo -e "${CYAN}   • Statistiques:      http://localhost:5000/api/stats${NC}"
echo ""
echo -e "${YELLOW}📋 Commandes utiles:${NC}"
echo -e "${CYAN}   • Voir les logs:     ./docker-start.sh --logs${NC}"
echo -e "${CYAN}   • Statut:            ./docker-start.sh --status${NC}"
echo -e "${CYAN}   • Shell:             ./docker-start.sh --shell${NC}"
echo -e "${CYAN}   • Arrêter:           ./docker-start.sh --stop${NC}"
echo ""
