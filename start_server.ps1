# Script PowerShell pour lancer le serveur Flask SMA AI REST
# Usage: .\start_server.ps1 [OPTIONS]
# Options:
#   -Port <port>        Port d'écoute (défaut: 5000)
#   -Host <host>        Adresse d'écoute (défaut: 0.0.0.0)
#   -Debug              Active le mode debug
#   -Production         Lance en mode production avec Waitress
#   -Help               Affiche cette aide

param(
    [int]$Port = 5000,
    [string]$Host = "0.0.0.0",
    [switch]$Debug,
    [switch]$Production,
    [switch]$Help
)

# Fonction d'aide
function Show-Help {
    Write-Host "Script de lancement du serveur Flask SMA AI REST" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\start_server.ps1 [OPTIONS]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Port <port>        Port d'écoute (défaut: 5000)" -ForegroundColor White
    Write-Host "  -Host <host>        Adresse d'écoute (défaut: 0.0.0.0)" -ForegroundColor White
    Write-Host "  -Debug              Active le mode debug (défaut en développement)" -ForegroundColor White
    Write-Host "  -Production         Lance en mode production avec Waitress" -ForegroundColor White
    Write-Host "  -Help               Affiche cette aide" -ForegroundColor White
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Yellow
    Write-Host "  .\start_server.ps1                    # Lance en mode développement" -ForegroundColor Cyan
    Write-Host "  .\start_server.ps1 -Port 8080         # Lance sur le port 8080" -ForegroundColor Cyan
    Write-Host "  .\start_server.ps1 -Production        # Lance en mode production" -ForegroundColor Cyan
    Write-Host "  .\start_server.ps1 -Debug             # Lance avec debug activé" -ForegroundColor Cyan
}

# Afficher l'aide si demandé
if ($Help) {
    Show-Help
    exit 0
}

# Vérifier que nous sommes dans le bon répertoire
if (!(Test-Path "app.py")) {
    Write-Host "❌ Erreur: Le fichier app.py n'a pas été trouvé dans le répertoire courant." -ForegroundColor Red
    Write-Host "   Assurez-vous d'être dans le répertoire racine du projet SMA AI REST." -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 Démarrage du serveur SMA AI REST..." -ForegroundColor Green
Write-Host "📁 Répertoire: $(Get-Location)" -ForegroundColor Cyan
Write-Host "🌐 Adresse: http://${Host}:${Port}" -ForegroundColor Cyan

# Vérifier si Python est installé
try {
    $pythonVersion = python --version 2>&1
    Write-Host "🐍 Version Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur: Python n'est pas installé ou pas dans le PATH." -ForegroundColor Red
    Write-Host "   Installez Python depuis https://python.org" -ForegroundColor Yellow
    exit 1
}

# Vérifier si l'environnement virtuel existe
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "🔧 Activation de l'environnement virtuel..." -ForegroundColor Yellow
    try {
        & "venv\Scripts\Activate.ps1"
        Write-Host "✅ Environnement virtuel activé" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Impossible d'activer l'environnement virtuel, utilisation de Python système" -ForegroundColor Yellow
    }
} elseif (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Host "🔧 Activation de l'environnement virtuel (.venv)..." -ForegroundColor Yellow
    try {
        & ".venv\Scripts\Activate.ps1"
        Write-Host "✅ Environnement virtuel activé" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Impossible d'activer l'environnement virtuel, utilisation de Python système" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Aucun environnement virtuel détecté" -ForegroundColor Yellow
    Write-Host "   Pour créer un environnement virtuel:" -ForegroundColor Cyan
    Write-Host "   python -m venv venv" -ForegroundColor Cyan
    Write-Host "   .\venv\Scripts\Activate.ps1" -ForegroundColor Cyan
    Write-Host "   pip install -r requirements.txt" -ForegroundColor Cyan
}

# Vérifier les dépendances
if (Test-Path "requirements.txt") {
    Write-Host "📦 Vérification des dépendances..." -ForegroundColor Yellow
    
    # Vérifier si Flask est installé
    try {
        python -c "import flask; print(f'Flask {flask.__version__} installé')" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Les dépendances principales sont installées" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Les dépendances ne semblent pas être installées" -ForegroundColor Yellow
        Write-Host "   Installation des dépendances..." -ForegroundColor Cyan
        pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
            exit 1
        }
    }
}

# Configurer les variables d'environnement
$env:FLASK_APP = "app.py"
if ($Production) {
    $env:FLASK_ENV = "production"
    Write-Host "🏭 Mode: Production" -ForegroundColor Magenta
} else {
    $env:FLASK_ENV = "development"
    Write-Host "🔧 Mode: Développement" -ForegroundColor Yellow
}

if ($Debug -or (!$Production)) {
    $env:FLASK_DEBUG = "1"
    Write-Host "🐛 Debug: Activé" -ForegroundColor Yellow
}

# Créer le répertoire instance s'il n'existe pas
if (!(Test-Path "instance")) {
    New-Item -ItemType Directory -Name "instance" | Out-Null
    Write-Host "📁 Répertoire instance créé" -ForegroundColor Green
}

Write-Host ""
Write-Host "🌟 Endpoints disponibles:" -ForegroundColor Green
Write-Host "   • Interface web:     http://${Host}:${Port}/" -ForegroundColor Cyan
Write-Host "   • Documentation API: http://${Host}:${Port}/api/docs" -ForegroundColor Cyan
Write-Host "   • Health check:      http://${Host}:${Port}/health" -ForegroundColor Cyan
Write-Host "   • Statistiques:      http://${Host}:${Port}/api/stats" -ForegroundColor Cyan
Write-Host ""

# Fonction pour nettoyer à la sortie
function Cleanup {
    Write-Host ""
    Write-Host "🛑 Arrêt du serveur..." -ForegroundColor Yellow
    Write-Host "👋 Au revoir !" -ForegroundColor Green
}

# Configurer le nettoyage à la sortie
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { Cleanup }

try {
    if ($Production) {
        # Vérifier si Waitress est installé
        try {
            python -c "import waitress" 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "📦 Installation de Waitress pour le mode production..." -ForegroundColor Yellow
                pip install waitress
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "❌ Erreur lors de l'installation de Waitress" -ForegroundColor Red
                    exit 1
                }
            }
        } catch {
            Write-Host "📦 Installation de Waitress..." -ForegroundColor Yellow
            pip install waitress
        }
        
        Write-Host "🚀 Démarrage du serveur en mode production avec Waitress..." -ForegroundColor Green
        waitress-serve --host=$Host --port=$Port --call app:app
    } else {
        Write-Host "🚀 Démarrage du serveur en mode développement..." -ForegroundColor Green
        Write-Host "   Utilisez Ctrl+C pour arrêter le serveur" -ForegroundColor Gray
        python -c "
from app import app
import os
app.run(
    debug=os.environ.get('FLASK_DEBUG', '0') == '1',
    host='$Host',
    port=$Port,
    use_reloader=True
)
"
    }
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur: $_" -ForegroundColor Red
    exit 1
} finally {
    Cleanup
}