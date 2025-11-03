# 🚀 SMA AI REST - Application de Requêtes API REST

Application web Python/Flask pour effectuer des appels API REST, afficher les résultats de manière structurée et sauvegarder l'historique des requêtes.

## ✨ Fonctionnalités

- 🌐 Interface web intuitive pour effectuer des appels API REST
- 📊 Affichage structuré et formaté des réponses JSON
- 💾 Sauvegarde automatique de toutes les requêtes dans une base de données
- 📜 Historique des requêtes avec possibilité de ré-exécution
- 🎨 Interface moderne et responsive
- 🔍 Support de proxy pour les requêtes
- 📈 Statistiques et métriques d'utilisation
- 🏥 Endpoint de health check
- 📚 Documentation API Swagger intégrée
- 🐳 Support Docker complet (production et développement)

## 🚀 Démarrage rapide

### 🐳 Avec Docker (Recommandé)

La méthode la plus simple pour démarrer l'application :

```bash
# Windows
.\docker-start.ps1

# Linux/macOS
./docker-start.sh
```

L'application sera accessible sur **http://localhost:5000**

👉 [Voir la documentation Docker complète](DOCKER.md)

### 🖥️ Sans Docker

## Installation

1. Créer un environnement virtuel :
```bash
python -m venv venv
```

2. Activer l'environnement virtuel :
```bash
# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

3. Installer les dépendances :
```bash
pip install -r requirements.txt
```

## 📋 Utilisation

### 🐳 Avec Docker

```bash
# Démarrer en production
docker compose up -d

# Démarrer en développement (avec hot-reload)
docker compose -f docker-compose.dev.yml up -d

# Voir les logs
docker compose logs -f

# Arrêter
docker compose stop
```

**Ou utilisez les scripts simplifiés :**

```bash
# Windows PowerShell
.\docker-start.ps1           # Démarre en production
.\docker-start.ps1 -Dev      # Démarre en développement
.\docker-start.ps1 -Logs     # Affiche les logs
.\docker-start.ps1 -Stop     # Arrête les conteneurs

# Linux/macOS
./docker-start.sh            # Démarre en production
./docker-start.sh --dev      # Démarre en développement
./docker-start.sh --logs     # Affiche les logs
./docker-start.sh --stop     # Arrête les conteneurs
```

**Ou avec Make (Linux/macOS/WSL) :**

```bash
make help       # Affiche toutes les commandes
make run        # Démarre en production
make dev        # Démarre en développement
make logs       # Affiche les logs
make stop       # Arrête les conteneurs
```

### 🖥️ Sans Docker (méthode manuelle)

1. Lancer l'application :
```bash
# Avec les scripts simplifiés (recommandé)
# Windows
.\start_server.ps1

# Linux/macOS
./start_server.sh

# Ou manuellement
python app.py
```

2. Ouvrir votre navigateur à l'adresse : `http://localhost:5000`

### 🌐 Endpoints disponibles

- **Interface web** : http://localhost:5000/
- **Documentation API (Swagger)** : http://localhost:5000/api/docs
- **Health check** : http://localhost:5000/health
- **Statistiques** : http://localhost:5000/api/stats

### 💡 Utiliser l'interface

1. **Effectuer un appel API** :
   - Entrer une URL d'API
   - Sélectionner la méthode HTTP (GET, POST, PUT, DELETE, PATCH)
   - Ajouter des headers personnalisés (optionnel)
   - Ajouter un body JSON (pour POST/PUT/PATCH)
   - Configurer un proxy (optionnel)
   - Voir les résultats formatés

2. **Consulter l'historique** :
   - Voir toutes les requêtes précédentes
   - Ré-exécuter une requête
   - Supprimer des entrées de l'historique

## 🧪 Exemples d'API à tester

Voici quelques APIs publiques pour tester l'application :

| API | URL | Méthode | Description |
|-----|-----|---------|-------------|
| JSONPlaceholder | `https://jsonplaceholder.typicode.com/posts` | GET | Posts de blog fictifs |
| JSONPlaceholder | `https://jsonplaceholder.typicode.com/posts` | POST | Créer un post |
| Random User | `https://randomuser.me/api/` | GET | Données utilisateur aléatoires |
| Dog API | `https://dog.ceo/api/breeds/image/random` | GET | Images de chiens aléatoires |
| Cat Facts | `https://catfact.ninja/fact` | GET | Faits aléatoires sur les chats |
| IP Info | `https://ipapi.co/json/` | GET | Informations géolocalisation IP |
| REST Countries | `https://restcountries.com/v3.1/all` | GET | Données sur tous les pays |

### 📝 Exemple de requête POST

**URL** : `https://jsonplaceholder.typicode.com/posts`  
**Méthode** : POST  
**Headers** :
```json
{
  "Content-Type": "application/json"
}
```
**Body** :
```json
{
  "title": "Mon test",
  "body": "Ceci est un test de l'API",
  "userId": 1
}
```

## 📚 Documentation

- **[DOCKER.md](DOCKER.md)** - Documentation complète sur l'utilisation de Docker
- **[SCRIPTS_README.md](SCRIPTS_README.md)** - Documentation des scripts de lancement
- **Swagger UI** - http://localhost:5000/api/docs (documentation API interactive)

## 🔒 Sécurité

### En production, pensez à :

- ✅ Utiliser HTTPS avec des certificats SSL
- ✅ Configurer un reverse proxy (Nginx)
- ✅ Limiter les origines CORS
- ✅ Mettre en place un rate limiting
- ✅ Utiliser des variables d'environnement pour les secrets
- ✅ Activer les logs de sécurité
- ✅ Mettre à jour régulièrement les dépendances

## 🐛 Troubleshooting

### Le serveur ne démarre pas

```bash
# Vérifier si le port 5000 est libre
# Windows
netstat -ano | findstr :5000

# Linux/macOS
lsof -i :5000

# Utiliser un autre port
python app.py  # Modifier le port dans app.py
# ou
.\start_server.ps1 -Port 8080
```

### Erreur de dépendances

```bash
# Réinstaller les dépendances
pip install --upgrade -r requirements.txt
```

### Problème avec Docker

```bash
# Rebuild complet
docker compose down -v
docker compose build --no-cache
docker compose up -d

# Voir les logs
docker compose logs -f
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Auteurs

- **SMA AI REST Team**

## 🙏 Remerciements

- Flask et sa communauté
- Toutes les APIs publiques utilisées pour les tests
- Les contributeurs open-source

## 📁 Structure du projet

```
sma_ai_rest/
├── app.py                      # Application Flask principale
├── models.py                   # Modèles de base de données SQLAlchemy
├── requirements.txt            # Dépendances Python
├── README.md                   # Ce fichier
├── DOCKER.md                   # Documentation Docker complète
├── SCRIPTS_README.md           # Documentation des scripts
│
├── templates/                  # Templates HTML Jinja2
│   └── index.html             # Interface web principale
│
├── static/                     # Fichiers statiques
│   ├── style.css              # Styles CSS
│   ├── script.js              # JavaScript frontend
│   └── swagger.yaml           # Spécification OpenAPI/Swagger
│
├── instance/                   # Base de données SQLite (créé au runtime)
│   └── api_requests.db
│
├── logs/                       # Logs de l'application (optionnel)
│
├── Dockerfile                  # Image Docker production
├── Dockerfile.dev             # Image Docker développement
├── docker-compose.yml         # Configuration Docker Compose production
├── docker-compose.dev.yml     # Configuration Docker Compose développement
├── .dockerignore              # Fichiers exclus du build Docker
├── nginx.conf.example         # Configuration Nginx (optionnel)
│
├── start_server.ps1           # Script PowerShell de lancement
├── start_server.sh            # Script Bash de lancement
├── stop_server.ps1            # Script PowerShell d'arrêt
├── stop_server.sh             # Script Bash d'arrêt
├── docker-start.ps1           # Script Docker PowerShell
├── docker-start.sh            # Script Docker Bash
└── Makefile                   # Commandes Make simplifiées
```

## 🛠️ Technologies utilisées

- **Flask 3.0** : Framework web Python moderne
- **SQLAlchemy 3.1** : ORM pour la base de données
- **Requests 2.31** : Bibliothèque HTTP
- **SQLite** : Base de données légère
- **Flask-Swagger-UI** : Documentation API interactive
- **Gunicorn** : Serveur WSGI pour la production
- **Docker** : Conteneurisation
- **Nginx** : Reverse proxy (optionnel)
