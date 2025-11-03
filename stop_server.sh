#!/bin/bash

# Script Bash pour arrêter le serveur Flask SMA AI REST
# Usage: ./stop_server.sh [OPTIONS]

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Variables par défaut
PORT=5000
ALL=false

# Fonction d'aide
show_help() {
    echo -e "${GREEN}Script d'arrêt du serveur Flask SMA AI REST${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./stop_server.sh [OPTIONS]${NC}"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}-p, --port <port>           ${NC}Port du serveur à arrêter (défaut: 5000)"
    echo -e "  ${CYAN}-a, --all                   ${NC}Arrête tous les processus Python/Flask"
    echo -e "  ${CYAN}--help                      ${NC}Affiche cette aide"
    echo ""
    echo -e "${YELLOW}Exemples:${NC}"
    echo -e "  ${CYAN}./stop_server.sh                      ${NC}# Arrête le serveur sur le port 5000"
    echo -e "  ${CYAN}./stop_server.sh -p 8080              ${NC}# Arrête le serveur sur le port 8080"
    echo -e "  ${CYAN}./stop_server.sh --all                ${NC}# Arrête tous les processus Python"
}

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -a|--all)
            ALL=true
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

echo -e "${YELLOW}🛑 Arrêt du serveur SMA AI REST...${NC}"

if [[ "$ALL" == true ]]; then
    echo -e "${CYAN}🔍 Recherche de tous les processus Python...${NC}"
    
    # Trouver tous les processus Python
    PYTHON_PIDS=$(pgrep -f "python.*app\.py\|python.*flask\|gunicorn.*app\|waitress.*app" 2>/dev/null)
    
    if [[ -n "$PYTHON_PIDS" ]]; then
        echo -e "${YELLOW}📋 Processus Python/Flask trouvés:${NC}"
        for pid in $PYTHON_PIDS; do
            if ps -p $pid > /dev/null 2>&1; then
                PROCESS_INFO=$(ps -p $pid -o pid,comm,args --no-headers 2>/dev/null)
                echo -e "${GRAY}   $PROCESS_INFO${NC}"
            fi
        done
        
        echo -n "Voulez-vous vraiment arrêter tous ces processus ? (y/N): "
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]([Ee][Ss])?$|^[Oo][Uu][Ii]$ ]]; then
            for pid in $PYTHON_PIDS; do
                if ps -p $pid > /dev/null 2>&1; then
                    if kill -TERM $pid 2>/dev/null; then
                        echo -e "${GREEN}✅ Signal d'arrêt envoyé au processus $pid${NC}"
                        sleep 2
                        # Vérifier si le processus est encore actif
                        if ps -p $pid > /dev/null 2>&1; then
                            echo -e "${YELLOW}⚠️  Arrêt forcé du processus $pid${NC}"
                            kill -KILL $pid 2>/dev/null
                        fi
                        echo -e "${GREEN}✅ Processus $pid arrêté${NC}"
                    else
                        echo -e "${RED}❌ Impossible d'arrêter le processus $pid${NC}"
                    fi
                fi
            done
        else
            echo -e "${YELLOW}🚫 Annulation de l'arrêt des processus${NC}"
            exit 0
        fi
    else
        echo -e "${BLUE}ℹ️  Aucun processus Python/Flask trouvé${NC}"
    fi
else
    echo -e "${CYAN}🔍 Recherche des processus utilisant le port $PORT...${NC}"
    
    # Trouver les processus utilisant le port spécifié
    if command -v lsof &> /dev/null; then
        # Utiliser lsof si disponible
        PIDS=$(lsof -ti:$PORT 2>/dev/null)
    elif command -v ss &> /dev/null; then
        # Utiliser ss comme alternative
        PIDS=$(ss -tulpn | grep ":$PORT " | grep -oP 'pid=\K\d+' 2>/dev/null)
    elif command -v netstat &> /dev/null; then
        # Utiliser netstat en dernier recours
        PIDS=$(netstat -tulpn 2>/dev/null | grep ":$PORT " | awk '{print $7}' | cut -d'/' -f1 | grep -E '^[0-9]+$')
    else
        echo -e "${RED}❌ Aucun outil disponible pour vérifier les ports (lsof, ss, netstat)${NC}"
        echo -e "${YELLOW}🔄 Tentative de recherche des processus Python...${NC}"
        PIDS=$(pgrep -f "python.*app\.py\|python.*flask\|gunicorn.*app" 2>/dev/null)
    fi
    
    if [[ -n "$PIDS" ]]; then
        echo -e "${YELLOW}📋 Processus utilisant le port $PORT ou processus Flask trouvés:${NC}"
        for pid in $PIDS; do
            if ps -p $pid > /dev/null 2>&1; then
                PROCESS_INFO=$(ps -p $pid -o pid,comm,args --no-headers 2>/dev/null)
                echo -e "${GRAY}   $PROCESS_INFO${NC}"
            fi
        done
        
        for pid in $PIDS; do
            if ps -p $pid > /dev/null 2>&1; then
                echo -e "${YELLOW}🛑 Arrêt du processus $pid...${NC}"
                if kill -TERM $pid 2>/dev/null; then
                    echo -e "${GREEN}✅ Signal d'arrêt envoyé au processus $pid${NC}"
                    sleep 3
                    # Vérifier si le processus est encore actif
                    if ps -p $pid > /dev/null 2>&1; then
                        echo -e "${YELLOW}⚠️  Arrêt forcé du processus $pid${NC}"
                        kill -KILL $pid 2>/dev/null
                    fi
                    echo -e "${GREEN}✅ Processus $pid arrêté${NC}"
                else
                    echo -e "${RED}❌ Impossible d'arrêter le processus $pid${NC}"
                fi
            fi
        done
    else
        echo -e "${BLUE}ℹ️  Aucun processus trouvé utilisant le port $PORT${NC}"
        
        # Recherche alternative des processus Python
        echo -e "${CYAN}🔍 Recherche alternative des processus Flask...${NC}"
        ALT_PIDS=$(pgrep -f "python.*app\.py\|python.*flask" 2>/dev/null)
        
        if [[ -n "$ALT_PIDS" ]]; then
            echo -e "${YELLOW}📋 Processus Flask potentiels trouvés:${NC}"
            for pid in $ALT_PIDS; do
                if ps -p $pid > /dev/null 2>&1; then
                    PROCESS_INFO=$(ps -p $pid -o pid,comm,args --no-headers 2>/dev/null)
                    echo -e "${GRAY}   $PROCESS_INFO${NC}"
                fi
            done
            
            echo -n "Voulez-vous arrêter ces processus ? (y/N): "
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]([Ee][Ss])?$|^[Oo][Uu][Ii]$ ]]; then
                for pid in $ALT_PIDS; do
                    if ps -p $pid > /dev/null 2>&1; then
                        kill -TERM $pid 2>/dev/null && echo -e "${GREEN}✅ Processus $pid arrêté${NC}"
                    fi
                done
            fi
        fi
    fi
fi

echo ""
echo -e "${GREEN}🏁 Opération terminée${NC}"

# Vérifier si le port est maintenant libre
sleep 2
echo -e "${CYAN}🔍 Vérification du port $PORT...${NC}"

if command -v nc &> /dev/null; then
    if nc -z localhost $PORT 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Le port $PORT semble encore occupé${NC}"
    else
        echo -e "${GREEN}✅ Le port $PORT est maintenant libre${NC}"
    fi
elif command -v telnet &> /dev/null; then
    if timeout 1 telnet localhost $PORT 2>/dev/null | grep -q "Connected"; then
        echo -e "${YELLOW}⚠️  Le port $PORT semble encore occupé${NC}"
    else
        echo -e "${GREEN}✅ Le port $PORT est maintenant libre${NC}"
    fi
else
    echo -e "${BLUE}ℹ️  Impossible de vérifier l'état du port (nc ou telnet non disponible)${NC}"
fi