# Scripts de Lancement - SMA AI REST Server

Ce répertoire contient des scripts pour faciliter le lancement et l'arrêt du serveur Flask SMA AI REST sur différents systèmes d'exploitation.

## 📁 Scripts Disponibles

### Windows (PowerShell)
- `start_server.ps1` - Démarre le serveur Flask
- `stop_server.ps1` - Arrête le serveur Flask

### Linux/macOS/Unix (Bash)
- `start_server.sh` - Démarre le serveur Flask
- `stop_server.sh` - Arrête le serveur Flask

## 🚀 Utilisation Rapide

### Windows
```powershell
# Démarrer le serveur (mode développement)
.\start_server.ps1

# Démarrer sur un port différent
.\start_server.ps1 -Port 8080

# Démarrer en mode production
.\start_server.ps1 -Production

# Arrêter le serveur
.\stop_server.ps1
```

### Linux/macOS/Unix
```bash
# Rendre le script exécutable (première fois seulement)
chmod +x start_server.sh stop_server.sh

# Démarrer le serveur (mode développement)
./start_server.sh

# Démarrer sur un port différent
./start_server.sh --port 8080

# Démarrer en mode production
./start_server.sh --production

# Arrêter le serveur
./stop_server.sh
```

## 📋 Options de Démarrage

### Script PowerShell (`start_server.ps1`)
- `-Port <port>` : Port d'écoute (défaut: 5000)
- `-Host <host>` : Adresse d'écoute (défaut: 0.0.0.0)
- `-Debug` : Active le mode debug
- `-Production` : Lance en mode production avec Waitress
- `-Help` : Affiche l'aide

### Script Bash (`start_server.sh`)
- `-p, --port <port>` : Port d'écoute (défaut: 5000)
- `-h, --host <host>` : Adresse d'écoute (défaut: 0.0.0.0)
- `-d, --debug` : Active le mode debug
- `-P, --production` : Lance en mode production avec Gunicorn
- `--help` : Affiche l'aide

## 📋 Options d'Arrêt

### Script PowerShell (`stop_server.ps1`)
- `-Port <port>` : Port du serveur à arrêter (défaut: 5000)
- `-All` : Arrête tous les processus Python/Flask
- `-Help` : Affiche l'aide

### Script Bash (`stop_server.sh`)
- `-p, --port <port>` : Port du serveur à arrêter (défaut: 5000)
- `-a, --all` : Arrête tous les processus Python/Flask
- `--help` : Affiche l'aide

## 🔧 Fonctionnalités Automatiques

Les scripts détectent et gèrent automatiquement :

### ✅ Environnement Python
- Détection de Python 3.x
- Activation automatique de l'environnement virtuel (`venv` ou `.venv`)
- Installation automatique des dépendances si nécessaire
- Vérification de la disponibilité de Flask

### ✅ Configuration du Serveur
- Configuration des variables d'environnement Flask
- Création du répertoire `instance` si nécessaire
- Choix automatique du serveur de production :
  - **Windows** : Waitress
  - **Linux/macOS** : Gunicorn

### ✅ Gestion des Erreurs
- Vérification de la présence d'`app.py`
- Gestion des erreurs de dépendances
- Messages d'erreur colorés et informatifs
- Nettoyage propre à l'arrêt (Ctrl+C)

## 🌐 Endpoints Disponibles

Une fois le serveur démarré, les endpoints suivants sont disponibles :

- **Interface web** : `http://localhost:5000/`
- **Documentation API** : `http://localhost:5000/api/docs`
- **Health check** : `http://localhost:5000/health`
- **Statistiques** : `http://localhost:5000/api/stats`

## 📦 Prérequis

### Obligatoires
- Python 3.7+ installé
- Fichier `requirements.txt` présent
- Fichier `app.py` dans le répertoire courant

### Recommandés
- Environnement virtuel Python (`venv` ou `.venv`)
- Pour la production :
  - Windows : Waitress (installé automatiquement)
  - Linux/macOS : Gunicorn (installé automatiquement)

## 🔄 Exemples d'Utilisation

### Développement Local
```bash
# Linux/macOS
./start_server.sh --debug

# Windows
.\start_server.ps1 -Debug
```

### Déploiement Production
```bash
# Linux/macOS
./start_server.sh --production --port 8080

# Windows
.\start_server.ps1 -Production -Port 8080
```

### Test Rapide
```bash
# Démarrer le serveur
./start_server.sh

# Dans un autre terminal, tester l'API
curl http://localhost:5000/health

# Arrêter le serveur
./stop_server.sh
```

## 🐛 Résolution de Problèmes

### Erreur "Python non trouvé"
```bash
# Vérifier l'installation de Python
python3 --version
# ou
python --version

# Ajouter Python au PATH si nécessaire
```

### Erreur "Port déjà utilisé"
```bash
# Arrêter tous les processus sur le port 5000
./stop_server.sh --port 5000

# Ou utiliser un autre port
./start_server.sh --port 8080
```

### Erreur "Dépendances manquantes"
```bash
# Activer l'environnement virtuel
source venv/bin/activate  # Linux/macOS
# ou
.\venv\Scripts\Activate.ps1  # Windows

# Installer les dépendances
pip install -r requirements.txt
```

### Script non exécutable (Linux/macOS)
```bash
chmod +x start_server.sh stop_server.sh
```

## 📝 Notes

- Les scripts créent automatiquement le répertoire `instance/` pour la base de données SQLite
- En mode développement, le rechargement automatique est activé
- En mode production, des optimisations de performance sont appliquées
- Les logs d'accès sont colorés pour une meilleure lisibilité
- L'arrêt propre du serveur est géré avec Ctrl+C

## 🆘 Support

Si vous rencontrez des problèmes :
1. Vérifiez que tous les prérequis sont installés
2. Consultez les messages d'erreur colorés des scripts
3. Utilisez l'option `--help` ou `-Help` pour plus d'informations
4. Vérifiez que le fichier `app.py` est présent dans le répertoire courant