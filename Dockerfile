# Dockerfile pour SMA AI REST API
# Image de base Python optimisée
FROM python:3.11-slim

# Métadonnées de l'image
LABEL maintainer="SMA AI REST Team"
LABEL description="API REST Client avec Flask et SQLite"
LABEL version="1.0.0"

# Variables d'environnement Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Répertoire de travail
WORKDIR /app

# Installer les dépendances système nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copier les fichiers de dépendances
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

# Copier le code de l'application
COPY app.py .
COPY models.py .
COPY static/ static/
COPY templates/ templates/

# Créer le répertoire pour la base de données
RUN mkdir -p /app/instance && \
    chmod 777 /app/instance

# Exposer le port de l'application
EXPOSE 5000

# Variables d'environnement par défaut
ENV FLASK_APP=app.py \
    FLASK_ENV=production \
    FLASK_DEBUG=0

# Healthcheck pour vérifier l'état du conteneur
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Créer un utilisateur non-root pour la sécurité
RUN useradd -m -u 1000 flask && \
    chown -R flask:flask /app

# Basculer vers l'utilisateur non-root
USER flask

# Commande par défaut - serveur Gunicorn pour la production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--threads", "2", "--timeout", "120", "--keep-alive", "2", "--max-requests", "1000", "--max-requests-jitter", "100", "--access-logfile", "-", "--error-logfile", "-", "--log-level", "info", "app:app"]
