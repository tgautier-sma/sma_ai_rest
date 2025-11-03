# 🐳 Documentation Docker - SMA AI REST Server

Ce guide explique comment déployer et gérer l'application SMA AI REST Server avec Docker.

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Fichiers Docker](#fichiers-docker)
- [Démarrage rapide](#démarrage-rapide)
- [Modes de déploiement](#modes-de-déploiement)
- [Commandes utiles](#commandes-utiles)
- [Configuration](#configuration)
- [Volumes et persistance](#volumes-et-persistance)
- [Réseau](#réseau)
- [Troubleshooting](#troubleshooting)

## 🔧 Prérequis

- **Docker** 20.10+ installé ([Docker Desktop](https://www.docker.com/products/docker-desktop) recommandé)
- **Docker Compose** v2.0+ (inclus avec Docker Desktop)
- 2 GB de RAM minimum
- 1 GB d'espace disque

### Vérification de l'installation

```bash
docker --version
docker compose version
```

## 📁 Fichiers Docker

| Fichier | Description |
|---------|-------------|
| `Dockerfile` | Image de production avec Gunicorn |
| `Dockerfile.dev` | Image de développement avec hot-reload |
| `docker-compose.yml` | Configuration production |
| `docker-compose.dev.yml` | Configuration développement |
| `.dockerignore` | Fichiers exclus du build |
| `docker-start.ps1` | Script PowerShell pour Windows |
| `docker-start.sh` | Script Bash pour Linux/macOS |

## 🚀 Démarrage rapide

### Sur Windows (PowerShell)

```powershell
# Lancement en production
.\docker-start.ps1

# Lancement en développement
.\docker-start.ps1 -Dev

# Avec rebuild de l'image
.\docker-start.ps1 -Build
```

### Sur Linux/macOS (Bash)

```bash
# Rendre le script exécutable (première fois)
chmod +x docker-start.sh

# Lancement en production
./docker-start.sh

# Lancement en développement
./docker-start.sh --dev

# Avec rebuild de l'image
./docker-start.sh --build
```

### Avec Docker Compose directement

```bash
# Production
docker compose up -d

# Développement
docker compose -f docker-compose.dev.yml up -d

# Avec build
docker compose up -d --build
```

## 🏭 Modes de déploiement

### Mode Production

**Caractéristiques :**
- Serveur Gunicorn avec 4 workers
- Optimisations de performance
- Logs structurés
- Healthcheck automatique
- Utilisateur non-root pour la sécurité

**Démarrage :**
```bash
docker compose up -d
```

**Configuration Gunicorn :**
- Workers : 4
- Threads par worker : 2
- Timeout : 120s
- Keep-alive : 2s
- Max requests : 1000

### Mode Développement

**Caractéristiques :**
- Hot-reload automatique
- Mode debug activé
- Code source monté en volume
- Logs détaillés
- Serveur Flask intégré

**Démarrage :**
```bash
docker compose -f docker-compose.dev.yml up -d
```

**Modifications en temps réel :**
Les fichiers suivants sont montés et peuvent être modifiés sans redémarrage :
- `app.py`
- `models.py`
- `static/*`
- `templates/*`

## 📋 Commandes utiles

### Scripts PowerShell/Bash

| Commande | Description |
|----------|-------------|
| `docker-start.ps1` | Démarre en production |
| `docker-start.ps1 -Dev` | Démarre en développement |
| `docker-start.ps1 -Build` | Build et démarre |
| `docker-start.ps1 -Rebuild` | Rebuild complet (no-cache) |
| `docker-start.ps1 -Logs` | Affiche les logs |
| `docker-start.ps1 -Status` | Statut des conteneurs |
| `docker-start.ps1 -Shell` | Ouvre un shell dans le conteneur |
| `docker-start.ps1 -Stop` | Arrête les conteneurs |
| `docker-start.ps1 -Down` | Arrête et supprime les conteneurs |
| `docker-start.ps1 -Clean` | Nettoyage complet |

### Commandes Docker Compose

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose stop

# Arrêter et supprimer
docker compose down

# Voir les logs
docker compose logs -f

# Voir les logs d'un service spécifique
docker compose logs -f sma-ai-rest

# Redémarrer
docker compose restart

# Rebuild et redémarrer
docker compose up -d --build

# Statut
docker compose ps

# Statistiques
docker stats

# Shell dans le conteneur
docker compose exec sma-ai-rest bash
```

### Commandes Docker directes

```bash
# Lister les conteneurs
docker ps

# Logs d'un conteneur
docker logs -f sma-ai-rest-app

# Shell dans un conteneur
docker exec -it sma-ai-rest-app bash

# Inspecter un conteneur
docker inspect sma-ai-rest-app

# Statistiques en temps réel
docker stats sma-ai-rest-app

# Arrêter un conteneur
docker stop sma-ai-rest-app

# Supprimer un conteneur
docker rm sma-ai-rest-app

# Lister les images
docker images

# Supprimer une image
docker rmi sma-ai-rest:latest
```

## ⚙️ Configuration

### Variables d'environnement

Modifiez le fichier `docker-compose.yml` pour personnaliser :

```yaml
environment:
  - FLASK_APP=app.py
  - FLASK_ENV=production
  - FLASK_DEBUG=0
  # Ajoutez vos variables ici
```

### Ports

Par défaut, l'application est accessible sur le port 5000. Pour changer :

```yaml
ports:
  - "8080:5000"  # Expose sur le port 8080
```

### Ressources

Limiter les ressources utilisées :

```yaml
services:
  sma-ai-rest:
    # ... configuration existante ...
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

## 💾 Volumes et persistance

### Base de données SQLite

La base de données est persistée via un bind mount :

```yaml
volumes:
  - ./instance:/app/instance
```

**Emplacement :** `./instance/api_requests.db`

### Logs

Les logs peuvent être montés (optionnel) :

```yaml
volumes:
  - ./logs:/app/logs
```

### Backup de la base de données

```bash
# Copier depuis le conteneur
docker compose cp sma-ai-rest:/app/instance/api_requests.db ./backup/

# Restaurer dans le conteneur
docker compose cp ./backup/api_requests.db sma-ai-rest:/app/instance/
```

## 🌐 Réseau

### Réseau par défaut

Un réseau bridge `sma-ai-rest-network` est créé automatiquement.

### Communication inter-conteneurs

Si vous ajoutez d'autres services (Redis, PostgreSQL, etc.) :

```yaml
services:
  sma-ai-rest:
    # ...
    depends_on:
      - redis
  
  redis:
    image: redis:alpine
    networks:
      - sma-network
```

### Exposition externe

Pour exposer l'application avec Nginx :

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - sma-ai-rest
```

## 🔍 Healthcheck

Le conteneur inclut un healthcheck automatique :

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1
```

**Vérifier l'état de santé :**
```bash
docker inspect --format='{{.State.Health.Status}}' sma-ai-rest-app
```

## 🐛 Troubleshooting

### Le conteneur ne démarre pas

```bash
# Vérifier les logs
docker compose logs sma-ai-rest

# Vérifier les erreurs de build
docker compose build --no-cache
```

### Port déjà utilisé

```bash
# Trouver le processus utilisant le port 5000
# Windows
netstat -ano | findstr :5000

# Linux/macOS
lsof -i :5000

# Ou changer le port dans docker-compose.yml
ports:
  - "8080:5000"
```

### Problèmes de permissions

```bash
# Le conteneur utilise l'utilisateur 'flask' (UID 1000)
# Assurez-vous que les permissions sont correctes
chmod -R 777 instance/
```

### La base de données est corrompue

```bash
# Arrêter le conteneur
docker compose stop

# Supprimer la base de données
rm instance/api_requests.db

# Redémarrer (une nouvelle DB sera créée)
docker compose up -d
```

### Rebuild complet

```bash
# Arrêter et supprimer tout
docker compose down -v

# Supprimer l'image
docker rmi sma-ai-rest:latest

# Rebuild sans cache
docker compose build --no-cache

# Redémarrer
docker compose up -d
```

### Mémoire insuffisante

```bash
# Vérifier l'utilisation mémoire
docker stats

# Augmenter la mémoire de Docker Desktop
# Settings > Resources > Advanced > Memory
```

### Les logs ne s'affichent pas

```bash
# Vérifier que le conteneur tourne
docker compose ps

# Forcer l'affichage des logs
docker compose logs --tail=100 -f sma-ai-rest
```

## 🔒 Sécurité

### Bonnes pratiques implémentées

- ✅ Utilisateur non-root dans le conteneur
- ✅ Image de base officielle Python slim
- ✅ Dépendances système minimales
- ✅ Healthcheck configuré
- ✅ Variables d'environnement pour la configuration
- ✅ `.dockerignore` pour exclure les fichiers sensibles

### Recommandations supplémentaires

1. **Utiliser des secrets pour les données sensibles :**
   ```yaml
   secrets:
     db_password:
       file: ./secrets/db_password.txt
   ```

2. **Scanner l'image pour les vulnérabilités :**
   ```bash
   docker scout cves sma-ai-rest:latest
   ```

3. **Mettre à jour régulièrement :**
   ```bash
   docker compose pull
   docker compose up -d
   ```

## 📊 Monitoring

### Logs

```bash
# Logs en temps réel
docker compose logs -f

# Dernières 100 lignes
docker compose logs --tail=100

# Depuis une date spécifique
docker compose logs --since="2025-01-01T00:00:00"
```

### Métriques

```bash
# Statistiques en temps réel
docker stats

# Utilisation disque
docker system df

# Inspecter les ressources
docker inspect sma-ai-rest-app
```

## 🚀 Déploiement en production

### Sur un serveur distant

```bash
# 1. Cloner le projet
git clone <votre-repo>
cd sma_ai_rest

# 2. Créer les répertoires nécessaires
mkdir -p instance logs

# 3. Configurer les permissions
chmod -R 777 instance

# 4. Démarrer en production
docker compose up -d

# 5. Vérifier le déploiement
docker compose ps
curl http://localhost:5000/health
```

### Avec CI/CD

Exemple GitHub Actions :

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and deploy
        run: |
          docker compose build
          docker compose up -d
```

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Documentation Gunicorn](https://gunicorn.org/)
- [Best Practices Docker](https://docs.docker.com/develop/dev-best-practices/)

## 🆘 Support

Pour toute question ou problème :

1. Vérifiez les logs : `docker compose logs -f`
2. Vérifiez la santé : `docker compose ps`
3. Consultez cette documentation
4. Utilisez `docker-start.ps1 -Help` ou `./docker-start.sh --help`