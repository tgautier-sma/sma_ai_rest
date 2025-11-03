# Application de Requêtes API REST

Application web Python/Flask pour effectuer des appels API REST, afficher les résultats de manière structurée et sauvegarder l'historique des requêtes.

## Fonctionnalités

- 🌐 Interface web intuitive pour effectuer des appels API REST
- 📊 Affichage structuré et formaté des réponses JSON
- 💾 Sauvegarde automatique de toutes les requêtes dans une base de données
- 📜 Historique des requêtes avec possibilité de ré-exécution
- 🎨 Interface moderne et responsive

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

## Utilisation

1. Lancer l'application :
```bash
python app.py
```

2. Ouvrir votre navigateur à l'adresse : `http://localhost:5000`

3. Utiliser l'interface pour :
   - Entrer une URL d'API
   - Sélectionner la méthode HTTP (GET, POST, PUT, DELETE)
   - Ajouter des headers personnalisés (optionnel)
   - Ajouter un body JSON (pour POST/PUT)
   - Voir les résultats formatés
   - Consulter l'historique des requêtes

## Exemples d'API à tester

- **JSONPlaceholder** : https://jsonplaceholder.typicode.com/posts
- **Random User** : https://randomuser.me/api/
- **Dog API** : https://dog.ceo/api/breeds/image/random

## Structure du projet

```
demo_claude/
├── app.py              # Application Flask principale
├── models.py           # Modèles de base de données
├── requirements.txt    # Dépendances Python
├── templates/          # Templates HTML
│   └── index.html
└── static/            # Fichiers statiques (CSS, JS)
    ├── style.css
    └── script.js
```

## Technologies utilisées

- **Flask** : Framework web Python
- **SQLAlchemy** : ORM pour la base de données
- **Requests** : Bibliothèque HTTP
- **SQLite** : Base de données légère
