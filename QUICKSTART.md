# 🚀 Guide de Démarrage Rapide - SMA AI REST

Ce guide vous permet de démarrer l'application en quelques minutes.

## ⚡ Démarrage ultra-rapide (Docker)

**Prérequis** : Docker installé

```bash
# 1. Cloner ou accéder au projet
cd sma_ai_rest

# 2. Démarrer l'application
# Windows
.\docker-start.ps1

# Linux/macOS
./docker-start.sh
```

**C'est tout !** 🎉

L'application est maintenant accessible sur **http://localhost:5000**

## 🐳 Commandes Docker essentielles

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose stop

# Voir les logs
docker compose logs -f

# Redémarrer
docker compose restart

# Nettoyer
docker compose down
```

## 💻 Démarrage sans Docker

**Prérequis** : Python 3.7+

```bash
# 1. Créer un environnement virtuel
python -m venv venv

# 2. Activer l'environnement
# Windows
venv\Scripts\activate
# Linux/macOS
source venv/bin/activate

# 3. Installer les dépendances
pip install -r requirements.txt

# 4. Démarrer l'application
# Avec script (recommandé)
# Windows
.\start_server.ps1
# Linux/macOS
./start_server.sh

# Ou manuellement
python app.py
```

## 🌐 Accès à l'application

Une fois démarré, accédez à :

| Service | URL |
|---------|-----|
| **Interface Web** | http://localhost:5000 |
| **API Docs (Swagger)** | http://localhost:5000/api/docs |
| **Health Check** | http://localhost:5000/health |
| **Statistiques** | http://localhost:5000/api/stats |

## 🧪 Premier test

1. Ouvrez http://localhost:5000 dans votre navigateur
2. Dans le champ URL, entrez : `https://jsonplaceholder.typicode.com/posts/1`
3. Sélectionnez la méthode `GET`
4. Cliquez sur "Envoyer la requête"
5. Observez la réponse JSON formatée !

## 🛠️ Commandes utiles

### Avec Make (Linux/macOS/WSL)

```bash
make run      # Démarrer en production
make dev      # Démarrer en développement
make logs     # Voir les logs
make stop     # Arrêter
make help     # Voir toutes les commandes
```

### Avec scripts PowerShell (Windows)

```powershell
.\docker-start.ps1              # Démarrer
.\docker-start.ps1 -Dev         # Mode développement
.\docker-start.ps1 -Logs        # Voir les logs
.\docker-start.ps1 -Stop        # Arrêter
.\docker-start.ps1 -Help        # Aide
```

### Avec scripts Bash (Linux/macOS)

```bash
./docker-start.sh              # Démarrer
./docker-start.sh --dev        # Mode développement
./docker-start.sh --logs       # Voir les logs
./docker-start.sh --stop       # Arrêter
./docker-start.sh --help       # Aide
```

## 📚 Documentation complète

- **[README.md](README.md)** - Documentation générale
- **[DOCKER.md](DOCKER.md)** - Guide Docker complet
- **[SCRIPTS_README.md](SCRIPTS_README.md)** - Documentation des scripts

## ❓ Problèmes courants

### Port 5000 déjà utilisé

```bash
# Utiliser un autre port
# Modifier dans docker-compose.yml :
ports:
  - "8080:5000"  # Utilise le port 8080
```

### Docker ne démarre pas

```bash
# Vérifier que Docker est en cours d'exécution
docker --version

# Rebuild complet
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Erreurs Python

```bash
# Réinstaller les dépendances
pip install --upgrade -r requirements.txt
```

## 🎯 Prochaines étapes

1. ✅ Testez l'interface web
2. ✅ Consultez la documentation API Swagger
3. ✅ Explorez l'historique des requêtes
4. ✅ Testez différentes APIs publiques
5. ✅ Lisez la documentation complète

## 🆘 Besoin d'aide ?

- Consultez les logs : `docker compose logs -f`
- Vérifiez la santé : `http://localhost:5000/health`
- Lisez la documentation : [README.md](README.md)

---

**Bon développement ! 🚀**
