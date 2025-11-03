# Makefile pour SMA AI REST Server
# Simplifie les commandes Docker et de développement

.PHONY: help build run dev stop down logs shell clean test install

# Couleurs pour l'affichage
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Affiche cette aide
	@echo "$(GREEN)SMA AI REST Server - Commandes disponibles:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

# === Docker Production ===

build: ## Build l'image Docker (production)
	@echo "$(YELLOW)🔨 Build de l'image Docker...$(NC)"
	docker compose build

run: ## Lance l'application en production
	@echo "$(GREEN)🚀 Démarrage en mode production...$(NC)"
	docker compose up -d
	@echo "$(GREEN)✅ Application disponible sur http://localhost:5000$(NC)"

run-build: ## Build et lance en production
	@echo "$(YELLOW)🔨 Build et démarrage...$(NC)"
	docker compose up -d --build
	@echo "$(GREEN)✅ Application disponible sur http://localhost:5000$(NC)"

# === Docker Développement ===

dev: ## Lance l'application en mode développement (hot-reload)
	@echo "$(GREEN)🔧 Démarrage en mode développement...$(NC)"
	docker compose -f docker-compose.dev.yml up -d
	@echo "$(GREEN)✅ Application disponible sur http://localhost:5000$(NC)"

dev-build: ## Build et lance en développement
	@echo "$(YELLOW)🔨 Build et démarrage (dev)...$(NC)"
	docker compose -f docker-compose.dev.yml up -d --build
	@echo "$(GREEN)✅ Application disponible sur http://localhost:5000$(NC)"

# === Gestion des conteneurs ===

stop: ## Arrête les conteneurs
	@echo "$(YELLOW)🛑 Arrêt des conteneurs...$(NC)"
	docker compose stop
	docker compose -f docker-compose.dev.yml stop 2>/dev/null || true

restart: ## Redémarre les conteneurs
	@echo "$(YELLOW)🔄 Redémarrage...$(NC)"
	docker compose restart

down: ## Arrête et supprime les conteneurs
	@echo "$(YELLOW)🗑️  Suppression des conteneurs...$(NC)"
	docker compose down
	docker compose -f docker-compose.dev.yml down 2>/dev/null || true

clean: ## Nettoyage complet (conteneurs, images, volumes)
	@echo "$(YELLOW)⚠️  Nettoyage complet...$(NC)"
	docker compose down -v --rmi all 2>/dev/null || true
	docker compose -f docker-compose.dev.yml down -v --rmi all 2>/dev/null || true
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"

# === Logs et monitoring ===

logs: ## Affiche les logs en temps réel
	docker compose logs -f

logs-dev: ## Affiche les logs du mode dev
	docker compose -f docker-compose.dev.yml logs -f

status: ## Affiche le statut des conteneurs
	@echo "$(BLUE)📊 Statut des conteneurs:$(NC)"
	@docker compose ps
	@docker compose -f docker-compose.dev.yml ps 2>/dev/null || true

stats: ## Affiche les statistiques des conteneurs
	docker stats --no-stream $$(docker compose ps -q) 2>/dev/null || true

# === Shell et debug ===

shell: ## Ouvre un shell dans le conteneur
	@echo "$(BLUE)🐚 Ouverture d'un shell...$(NC)"
	docker compose exec sma-ai-rest bash || docker compose exec sma-ai-rest sh

shell-dev: ## Ouvre un shell dans le conteneur dev
	docker compose -f docker-compose.dev.yml exec sma-ai-rest-dev bash || \
	docker compose -f docker-compose.dev.yml exec sma-ai-rest-dev sh

# === Tests et qualité ===

test: ## Lance les tests (TODO: ajouter les tests)
	@echo "$(YELLOW)🧪 Lancement des tests...$(NC)"
	@echo "$(YELLOW)⚠️  Aucun test configuré pour le moment$(NC)"

health: ## Vérifie la santé de l'application
	@echo "$(BLUE)🏥 Vérification de la santé...$(NC)"
	@curl -s http://localhost:5000/health | python3 -m json.tool || \
	 curl -s http://localhost:5000/health

# === Développement local (sans Docker) ===

install: ## Installe les dépendances Python localement
	@echo "$(YELLOW)📦 Installation des dépendances...$(NC)"
	pip install -r requirements.txt
	@echo "$(GREEN)✅ Dépendances installées$(NC)"

venv: ## Crée un environnement virtuel Python
	@echo "$(YELLOW)🐍 Création de l'environnement virtuel...$(NC)"
	python3 -m venv venv
	@echo "$(GREEN)✅ Environnement créé. Activez-le avec:$(NC)"
	@echo "   source venv/bin/activate  (Linux/macOS)"
	@echo "   .\\venv\\Scripts\\Activate.ps1  (Windows PowerShell)"

local: ## Lance l'application localement (sans Docker)
	@echo "$(GREEN)🚀 Démarrage local...$(NC)"
	python3 app.py

# === Utilitaires ===

backup: ## Sauvegarde la base de données
	@echo "$(YELLOW)💾 Sauvegarde de la base de données...$(NC)"
	@mkdir -p backup
	@docker compose cp sma-ai-rest:/app/instance/api_requests.db backup/api_requests_$$(date +%Y%m%d_%H%M%S).db 2>/dev/null || \
	 cp instance/api_requests.db backup/api_requests_$$(date +%Y%m%d_%H%M%S).db 2>/dev/null || \
	 echo "$(YELLOW)⚠️  Aucune base de données à sauvegarder$(NC)"
	@echo "$(GREEN)✅ Sauvegarde terminée$(NC)"

prune: ## Nettoie Docker (images, conteneurs, volumes inutilisés)
	@echo "$(YELLOW)🧹 Nettoyage Docker...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"

rebuild: ## Rebuild complet sans cache
	@echo "$(YELLOW)🔨 Rebuild complet (no-cache)...$(NC)"
	docker compose build --no-cache
	docker compose up -d
	@echo "$(GREEN)✅ Rebuild terminé$(NC)"

# === Informations ===

info: ## Affiche les informations système
	@echo "$(BLUE)ℹ️  Informations système:$(NC)"
	@echo ""
	@echo "$(YELLOW)Docker:$(NC)"
	@docker --version
	@docker compose version
	@echo ""
	@echo "$(YELLOW)Images:$(NC)"
	@docker images | grep sma-ai-rest || echo "Aucune image"
	@echo ""
	@echo "$(YELLOW)Conteneurs:$(NC)"
	@docker ps -a | grep sma-ai-rest || echo "Aucun conteneur"
	@echo ""
	@echo "$(YELLOW)Volumes:$(NC)"
	@docker volume ls | grep sma || echo "Aucun volume"

urls: ## Affiche les URLs de l'application
	@echo "$(GREEN)🌐 URLs disponibles:$(NC)"
	@echo "  • Interface web:     $(BLUE)http://localhost:5000/$(NC)"
	@echo "  • Documentation API: $(BLUE)http://localhost:5000/api/docs$(NC)"
	@echo "  • Health check:      $(BLUE)http://localhost:5000/health$(NC)"
	@echo "  • Statistiques:      $(BLUE)http://localhost:5000/api/stats$(NC)"

.DEFAULT_GOAL := help
