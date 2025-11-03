# 📝 Aide-Mémoire des Commandes - SMA AI REST Server

Guide de référence rapide pour toutes les commandes disponibles.

---

## 🐳 DOCKER - Commandes de base

### Démarrage
```bash
docker compose up -d                              # Production
docker compose -f docker-compose.dev.yml up -d    # Développement
docker compose up -d --build                      # Avec rebuild
```

### Arrêt
```bash
docker compose stop                               # Arrête les conteneurs
docker compose down                               # Arrête et supprime
docker compose down -v                            # Arrête et supprime + volumes
docker compose down -v --rmi all                  # Nettoyage complet
```

### Logs et monitoring
```bash
docker compose logs -f                            # Logs en temps réel
docker compose logs -f --tail=100                 # 100 dernières lignes
docker compose ps                                 # Statut des conteneurs
docker stats                                      # Statistiques CPU/RAM
```

### Build
```bash
docker compose build                              # Build
docker compose build --no-cache                   # Build sans cache
docker compose pull                               # Télécharge les images
```

### Shell et debug
```bash
docker compose exec sma-ai-rest bash              # Shell dans le conteneur
docker compose exec sma-ai-rest sh                # Si bash indisponible
docker compose exec sma-ai-rest python            # Console Python
```

---

## 📜 SCRIPTS POWERSHELL (Windows)

### docker-start.ps1
```powershell
.\docker-start.ps1                                # Production
.\docker-start.ps1 -Dev                           # Développement
.\docker-start.ps1 -Build                         # Avec build
.\docker-start.ps1 -Rebuild                       # Rebuild complet
.\docker-start.ps1 -Logs                          # Affiche les logs
.\docker-start.ps1 -Status                        # Statut
.\docker-start.ps1 -Shell                         # Ouvre un shell
.\docker-start.ps1 -Stop                          # Arrête
.\docker-start.ps1 -Down                          # Arrête et supprime
.\docker-start.ps1 -Clean                         # Nettoyage total
.\docker-start.ps1 -Help                          # Aide
```

### start_server.ps1 (sans Docker)
```powershell
.\start_server.ps1                                # Développement
.\start_server.ps1 -Port 8080                     # Port personnalisé
.\start_server.ps1 -Production                    # Mode production
.\start_server.ps1 -Debug                         # Mode debug
.\start_server.ps1 -Help                          # Aide
```

### stop_server.ps1 (sans Docker)
```powershell
.\stop_server.ps1                                 # Arrête port 5000
.\stop_server.ps1 -Port 8080                      # Arrête port 8080
.\stop_server.ps1 -All                            # Arrête tous les processus Python
```

---

## 🐧 SCRIPTS BASH (Linux/macOS)

### docker-start.sh
```bash
./docker-start.sh                                 # Production
./docker-start.sh --dev                           # Développement
./docker-start.sh --build                         # Avec build
./docker-start.sh --rebuild                       # Rebuild complet
./docker-start.sh --logs                          # Affiche les logs
./docker-start.sh --status                        # Statut
./docker-start.sh --shell                         # Ouvre un shell
./docker-start.sh --stop                          # Arrête
./docker-start.sh --down                          # Arrête et supprime
./docker-start.sh --clean                         # Nettoyage total
./docker-start.sh --help                          # Aide
```

### start_server.sh (sans Docker)
```bash
./start_server.sh                                 # Développement
./start_server.sh --port 8080                     # Port personnalisé
./start_server.sh --production                    # Mode production
./start_server.sh --debug                         # Mode debug
./start_server.sh --help                          # Aide
```

### stop_server.sh (sans Docker)
```bash
./stop_server.sh                                  # Arrête port 5000
./stop_server.sh --port 8080                      # Arrête port 8080
./stop_server.sh --all                            # Arrête tous les processus Python
```

---

## 🔨 MAKEFILE (Linux/macOS/WSL)

### Commandes principales
```bash
make help                                         # Affiche l'aide
make run                                          # Production
make dev                                          # Développement
make build                                        # Build l'image
make run-build                                    # Build + run
make dev-build                                    # Build + dev
```

### Gestion
```bash
make stop                                         # Arrête
make restart                                      # Redémarre
make down                                         # Supprime
make clean                                        # Nettoyage complet
make rebuild                                      # Rebuild sans cache
```

### Monitoring
```bash
make logs                                         # Logs production
make logs-dev                                     # Logs développement
make status                                       # Statut des conteneurs
make stats                                        # Statistiques CPU/RAM
make health                                       # Healthcheck
```

### Debug
```bash
make shell                                        # Shell production
make shell-dev                                    # Shell développement
make test                                         # Lance les tests
```

### Utilitaires
```bash
make install                                      # Installe dépendances localement
make venv                                         # Crée environnement virtuel
make local                                        # Lance localement (sans Docker)
make backup                                       # Sauvegarde la DB
make prune                                        # Nettoie Docker
make info                                         # Informations système
make urls                                         # Affiche les URLs
```

---

## 🐍 PYTHON (sans Docker)

### Environnement virtuel
```bash
# Créer
python -m venv venv                               # ou python3

# Activer
venv\Scripts\activate                             # Windows
source venv/bin/activate                          # Linux/macOS

# Désactiver
deactivate                                        # Tous OS
```

### Dépendances
```bash
pip install -r requirements.txt                   # Installer
pip freeze > requirements.txt                     # Exporter
pip list                                          # Lister
pip install --upgrade -r requirements.txt         # Mettre à jour
```

### Lancement
```bash
python app.py                                     # Développement
flask run                                         # Alternative Flask
gunicorn app:app                                  # Production (Linux/macOS)
waitress-serve --host=0.0.0.0 --port=5000 app:app # Production (Windows)
```

---

## 🔍 DOCKER - Commandes avancées

### Inspection
```bash
docker inspect <container_id>                     # Détails d'un conteneur
docker inspect <image_id>                         # Détails d'une image
docker logs <container_id>                        # Logs d'un conteneur
docker exec -it <container_id> bash               # Shell dans conteneur
```

### Images
```bash
docker images                                     # Lister les images
docker rmi <image_id>                            # Supprimer une image
docker image prune                                # Nettoyer images inutilisées
docker build -t sma-ai-rest:latest .             # Build manuel
```

### Conteneurs
```bash
docker ps                                         # Conteneurs actifs
docker ps -a                                      # Tous les conteneurs
docker stop <container_id>                        # Arrêter
docker start <container_id>                       # Démarrer
docker restart <container_id>                     # Redémarrer
docker rm <container_id>                          # Supprimer
```

### Volumes
```bash
docker volume ls                                  # Lister les volumes
docker volume inspect <volume_name>               # Détails d'un volume
docker volume rm <volume_name>                    # Supprimer un volume
docker volume prune                               # Nettoyer volumes inutilisés
```

### Réseau
```bash
docker network ls                                 # Lister les réseaux
docker network inspect <network_name>             # Détails d'un réseau
docker network create <network_name>              # Créer un réseau
docker network rm <network_name>                  # Supprimer un réseau
```

### Système
```bash
docker system df                                  # Utilisation disque
docker system prune                               # Nettoyer (prudence!)
docker system prune -a --volumes                  # Nettoyage complet
docker version                                    # Version Docker
docker info                                       # Informations système
```

---

## 🌐 CURL - Test des endpoints

### Health check
```bash
curl http://localhost:5000/health
curl -s http://localhost:5000/health | jq        # Avec jq (formatage JSON)
```

### Statistiques
```bash
curl http://localhost:5000/api/stats
curl -s http://localhost:5000/api/stats | jq
```

### Appel API GET
```bash
curl -X GET http://localhost:5000/api/call \
  -H "Content-Type: application/json" \
  -d '{"url": "https://jsonplaceholder.typicode.com/posts/1", "method": "GET"}'
```

### Appel API POST
```bash
curl -X POST http://localhost:5000/api/call \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://jsonplaceholder.typicode.com/posts",
    "method": "POST",
    "headers": {"Content-Type": "application/json"},
    "body": {"title": "Test", "body": "Test body", "userId": 1}
  }'
```

### Historique
```bash
curl http://localhost:5000/api/history
curl http://localhost:5000/api/history?limit=10
curl http://localhost:5000/api/history/1
```

---

## 🛠️ GIT

### Commandes de base
```bash
git status                                        # Statut
git add .                                         # Ajouter tout
git add <file>                                    # Ajouter un fichier
git commit -m "message"                           # Commit
git push                                          # Envoyer
git pull                                          # Récupérer
```

### Branches
```bash
git branch                                        # Lister branches
git branch <name>                                 # Créer branche
git checkout <name>                               # Changer de branche
git checkout -b <name>                            # Créer et changer
git merge <name>                                  # Fusionner
```

### Historique
```bash
git log                                           # Historique
git log --oneline                                 # Historique condensé
git diff                                          # Différences
git show <commit>                                 # Détails d'un commit
```

---

## 💾 BACKUP & RESTORE

### Backup base de données
```bash
# Depuis le conteneur
docker compose cp sma-ai-rest:/app/instance/api_requests.db ./backup/

# Localement
cp instance/api_requests.db backup/api_requests_$(date +%Y%m%d).db

# Avec Make
make backup
```

### Restore base de données
```bash
# Vers le conteneur
docker compose cp ./backup/api_requests.db sma-ai-rest:/app/instance/

# Localement
cp backup/api_requests.db instance/
```

---

## 🔑 VARIABLES D'ENVIRONNEMENT

### Créer le fichier .env
```bash
cp .env.example .env                              # Copier le template
nano .env                                         # Éditer (Linux/macOS)
notepad .env                                      # Éditer (Windows)
```

### Variables importantes
```bash
FLASK_ENV=production                              # Environment
FLASK_DEBUG=0                                     # Debug off
GUNICORN_WORKERS=4                                # Workers Gunicorn
```

---

## 📊 MONITORING

### Logs en temps réel
```bash
# Docker
docker compose logs -f
docker compose logs -f sma-ai-rest

# Fichiers logs (si configuré)
tail -f logs/app.log
Get-Content logs/app.log -Wait                    # PowerShell
```

### Healthcheck
```bash
# Vérifier l'état
docker inspect --format='{{.State.Health.Status}}' sma-ai-rest-app

# Tester manuellement
curl http://localhost:5000/health
```

### Métriques système
```bash
docker stats                                      # Temps réel
docker stats --no-stream                          # Snapshot
htop                                              # Linux (si installé)
```

---

## 🚨 TROUBLESHOOTING

### Port déjà utilisé
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <pid> /F

# Linux/macOS
lsof -i :5000
kill -9 <pid>
```

### Rebuild complet
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### Nettoyer Docker
```bash
docker system prune -a --volumes                  # ATTENTION: Supprime tout!
```

### Vérifier les logs
```bash
docker compose logs --tail=100                    # 100 dernières lignes
docker compose logs --since="2h"                  # Dernières 2 heures
```

---

## 📞 AIDE

```bash
# Scripts
.\docker-start.ps1 -Help                          # Windows
./docker-start.sh --help                          # Linux/macOS
make help                                         # Make

# Docker
docker --help
docker compose --help
docker run --help

# Documentation
cat README.md
cat DOCKER.md
cat QUICKSTART.md
```

---

**💡 Astuce** : Ajoutez cette page à vos favoris pour une référence rapide !
