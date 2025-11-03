#!/bin/bash

# Script Bash pour lancer le serveur Flask SMA AI REST
# Usage: ./start_server.sh [OPTIONS]
# Options:
#   -p, --port <port>           Port d'écoute (défaut: 5000)
#   -h, --host <host>           Adresse d'écoute (défaut: 0.0.0.0)
#   -d, --debug                 Active le mode debug
#   -P, --production            Lance en mode production avec Gunicorn
#   --help                      Affiche cette aide

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Variables par défaut
PORT=5000
HOST="0.0.0.0"
DEBUG=false
PRODUCTION=false

# Fonction d'aide
show_help() {
    echo -e "${GREEN}Script de lancement du serveur Flask SMA AI REST${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./start_server.sh [OPTIONS]${NC}"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}-p, --port <port>           ${NC}Port d'écoute (défaut: 5000)"
    echo -e "  ${CYAN}-h, --host <host>           ${NC}Adresse d'écoute (défaut: 0.0.0.0)"
    echo -e "  ${CYAN}-d, --debug                 ${NC}Active le mode debug (défaut en développement)"
    echo -e "  ${CYAN}-P, --production            ${NC}Lance en mode production avec Gunicorn"
    echo -e "  ${CYAN}--help                      ${NC}Affiche cette aide"
    echo ""
    echo -e "${YELLOW}Exemples:${NC}"
    echo -e "  ${CYAN}./start_server.sh                     ${NC}# Lance en mode développement"
    echo -e "  ${CYAN}./start_server.sh -p 8080             ${NC}# Lance sur le port 8080"
    echo -e "  ${CYAN}./start_server.sh --production        ${NC}# Lance en mode production"
    echo -e "  ${CYAN}./start_server.sh --debug             ${NC}# Lance avec debug activé"
}

# Fonction pour nettoyer à la sortie
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt du serveur...${NC}"
    echo -e "${GREEN}👋 Au revoir !${NC}"
    exit 0
}

# Configurer le nettoyage à la sortie
trap cleanup SIGINT SIGTERM

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--host)
            HOST="$2"
            shift 2
            ;;
        -d|--debug)
            DEBUG=true
            shift
            ;;
        -P|--production)
            PRODUCTION=true
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

# Vérifier que nous sommes dans le bon répertoire
if [[ ! -f "app.py" ]]; then
    echo -e "${RED}❌ Erreur: Le fichier app.py n'a pas été trouvé dans le répertoire courant.${NC}"
    echo -e "${YELLOW}   Assurez-vous d'être dans le répertoire racine du projet SMA AI REST.${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Démarrage du serveur SMA AI REST...${NC}"
echo -e "${CYAN}📁 Répertoire: $(pwd)${NC}"
echo -e "${CYAN}🌐 Adresse: http://${HOST}:${PORT}${NC}"

# Vérifier si Python est installé
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}❌ Erreur: Python n'est pas installé ou pas dans le PATH.${NC}"
    echo -e "${YELLOW}   Installez Python depuis https://python.org${NC}"
    exit 1
fi

# Déterminer la commande Python
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PIP_CMD="pip3"
else
    PYTHON_CMD="python"
    PIP_CMD="pip"
fi

# Afficher la version de Python
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
echo -e "${GREEN}🐍 Version Python: ${PYTHON_VERSION}${NC}"

# Vérifier si l'environnement virtuel existe et l'activer
if [[ -f "venv/bin/activate" ]]; then
    echo -e "${YELLOW}🔧 Activation de l'environnement virtuel...${NC}"
    source venv/bin/activate
    echo -e "${GREEN}✅ Environnement virtuel activé${NC}"
    PYTHON_CMD="python"
    PIP_CMD="pip"
elif [[ -f ".venv/bin/activate" ]]; then
    echo -e "${YELLOW}🔧 Activation de l'environnement virtuel (.venv)...${NC}"
    source .venv/bin/activate
    echo -e "${GREEN}✅ Environnement virtuel activé${NC}"
    PYTHON_CMD="python"
    PIP_CMD="pip"
else
    echo -e "${YELLOW}⚠️  Aucun environnement virtuel détecté${NC}"
    echo -e "${CYAN}   Pour créer un environnement virtuel:${NC}"
    echo -e "${CYAN}   python3 -m venv venv${NC}"
    echo -e "${CYAN}   source venv/bin/activate${NC}"
    echo -e "${CYAN}   pip install -r requirements.txt${NC}"
fi

# Vérifier les dépendances
if [[ -f "requirements.txt" ]]; then
    echo -e "${YELLOW}📦 Vérification des dépendances...${NC}"
    
    # Vérifier si Flask est installé
    if $PYTHON_CMD -c "import flask; print(f'Flask {flask.__version__} installé')" 2>/dev/null; then
        echo -e "${GREEN}✅ Les dépendances principales sont installées${NC}"
    else
        echo -e "${YELLOW}⚠️  Les dépendances ne semblent pas être installées${NC}"
        echo -e "${CYAN}   Installation des dépendances...${NC}"
        $PIP_CMD install -r requirements.txt
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}❌ Erreur lors de l'installation des dépendances${NC}"
            exit 1
        fi
    fi
fi

# Configurer les variables d'environnement
export FLASK_APP="app.py"

if [[ "$PRODUCTION" == true ]]; then
    export FLASK_ENV="production"
    echo -e "${MAGENTA}🏭 Mode: Production${NC}"
else
    export FLASK_ENV="development"
    echo -e "${YELLOW}🔧 Mode: Développement${NC}"
fi

if [[ "$DEBUG" == true ]] || [[ "$PRODUCTION" == false ]]; then
    export FLASK_DEBUG="1"
    echo -e "${YELLOW}🐛 Debug: Activé${NC}"
fi

# Créer le répertoire instance s'il n'existe pas
if [[ ! -d "instance" ]]; then
    mkdir -p instance
    echo -e "${GREEN}📁 Répertoire instance créé${NC}"
fi

echo ""
echo -e "${GREEN}🌟 Endpoints disponibles:${NC}"
echo -e "${CYAN}   • Interface web:     http://${HOST}:${PORT}/${NC}"
echo -e "${CYAN}   • Documentation API: http://${HOST}:${PORT}/api/docs${NC}"
echo -e "${CYAN}   • Health check:      http://${HOST}:${PORT}/health${NC}"
echo -e "${CYAN}   • Statistiques:      http://${HOST}:${PORT}/api/stats${NC}"
echo ""

# Démarrer le serveur
if [[ "$PRODUCTION" == true ]]; then
    # Vérifier si Gunicorn est installé
    if ! $PYTHON_CMD -c "import gunicorn" 2>/dev/null; then
        echo -e "${YELLOW}📦 Installation de Gunicorn pour le mode production...${NC}"
        $PIP_CMD install gunicorn
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}❌ Erreur lors de l'installation de Gunicorn${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}🚀 Démarrage du serveur en mode production avec Gunicorn...${NC}"
    exec gunicorn --bind ${HOST}:${PORT} --workers 4 --timeout 120 --keep-alive 2 --max-requests 1000 --max-requests-jitter 100 app:app
else
    echo -e "${GREEN}🚀 Démarrage du serveur en mode développement...${NC}"
    echo -e "${GRAY}   Utilisez Ctrl+C pour arrêter le serveur${NC}"
    exec $PYTHON_CMD -c "
from app import app
import os
app.run(
    debug=os.environ.get('FLASK_DEBUG', '0') == '1',
    host='${HOST}',
    port=${PORT},
    use_reloader=True,
    threaded=True
)
"
fi