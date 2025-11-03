# Script PowerShell pour lancer l'application Flask avec Docker
# Usage: .\docker-start.ps1 [OPTIONS]

param(
    [switch]$Dev,
    [switch]$Build,
    [switch]$Rebuild,
    [switch]$Logs,
    [switch]$Stop,
    [switch]$Down,
    [switch]$Clean,
    [switch]$Status,
    [switch]$Shell,
    [switch]$Help
)

# Fonction d'aide
function Show-Help {
    Write-Host "Script Docker pour SMA AI REST Server" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\docker-start.ps1 [OPTIONS]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Dev            Lance en mode développement avec hot-reload" -ForegroundColor White
    Write-Host "  -Build          Build l'image avant de lancer" -ForegroundColor White
    Write-Host "  -Rebuild        Rebuild complet (--no-cache)" -ForegroundColor White
    Write-Host "  -Logs           Affiche les logs en continu" -ForegroundColor White
    Write-Host "  -Stop           Arrête les conteneurs" -ForegroundColor White
    Write-Host "  -Down           Arrête et supprime les conteneurs" -ForegroundColor White
    Write-Host "  -Clean          Nettoyage complet (conteneurs, images, volumes)" -ForegroundColor White
    Write-Host "  -Status         Affiche le statut des conteneurs" -ForegroundColor White
    Write-Host "  -Shell          Ouvre un shell dans le conteneur" -ForegroundColor White
    Write-Host "  -Help           Affiche cette aide" -ForegroundColor White
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Yellow
    Write-Host "  .\docker-start.ps1                    # Lance en production" -ForegroundColor Cyan
    Write-Host "  .\docker-start.ps1 -Dev               # Lance en développement" -ForegroundColor Cyan
    Write-Host "  .\docker-start.ps1 -Build             # Build et lance" -ForegroundColor Cyan
    Write-Host "  .\docker-start.ps1 -Logs              # Affiche les logs" -ForegroundColor Cyan
    Write-Host "  .\docker-start.ps1 -Stop              # Arrête les conteneurs" -ForegroundColor Cyan
}

# Afficher l'aide
if ($Help) {
    Show-Help
    exit 0
}

# Vérifier que Docker est installé
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "🐳 Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas installé ou pas accessible" -ForegroundColor Red
    Write-Host "   Installez Docker Desktop depuis https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Vérifier que Docker Compose est disponible
try {
    $composeVersion = docker compose version 2>&1
    Write-Host "📦 Docker Compose: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose n'est pas disponible" -ForegroundColor Red
    exit 1
}

# Déterminer le fichier docker-compose à utiliser
if ($Dev) {
    $ComposeFile = "docker-compose.dev.yml"
    $Mode = "développement"
    $ServiceName = "sma-ai-rest-dev"
} else {
    $ComposeFile = "docker-compose.yml"
    $Mode = "production"
    $ServiceName = "sma-ai-rest"
}

# Vérifier que le fichier docker-compose existe
if (!(Test-Path $ComposeFile)) {
    Write-Host "❌ Fichier $ComposeFile introuvable" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🚀 SMA AI REST Server - Docker" -ForegroundColor Green
Write-Host "📁 Répertoire: $(Get-Location)" -ForegroundColor Cyan
Write-Host "🔧 Mode: $Mode" -ForegroundColor Cyan
Write-Host "📄 Configuration: $ComposeFile" -ForegroundColor Cyan
Write-Host ""

# Gestion des différentes actions
if ($Status) {
    Write-Host "📊 Statut des conteneurs:" -ForegroundColor Yellow
    docker compose -f $ComposeFile ps
    Write-Host ""
    Write-Host "📈 Statistiques:" -ForegroundColor Yellow
    docker stats --no-stream $(docker compose -f $ComposeFile ps -q) 2>$null
    exit 0
}

if ($Shell) {
    Write-Host "🐚 Ouverture d'un shell dans le conteneur..." -ForegroundColor Yellow
    docker compose -f $ComposeFile exec $ServiceName /bin/bash
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Bash non disponible, tentative avec sh..." -ForegroundColor Yellow
        docker compose -f $ComposeFile exec $ServiceName /bin/sh
    }
    exit 0
}

if ($Stop) {
    Write-Host "🛑 Arrêt des conteneurs..." -ForegroundColor Yellow
    docker compose -f $ComposeFile stop
    Write-Host "✅ Conteneurs arrêtés" -ForegroundColor Green
    exit 0
}

if ($Down) {
    Write-Host "🗑️  Arrêt et suppression des conteneurs..." -ForegroundColor Yellow
    docker compose -f $ComposeFile down
    Write-Host "✅ Conteneurs supprimés" -ForegroundColor Green
    exit 0
}

if ($Clean) {
    Write-Host "⚠️  ATTENTION: Nettoyage complet!" -ForegroundColor Red
    Write-Host "   Cela supprimera:" -ForegroundColor Yellow
    Write-Host "   - Les conteneurs" -ForegroundColor Yellow
    Write-Host "   - Les images" -ForegroundColor Yellow
    Write-Host "   - Les volumes (base de données)" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Êtes-vous sûr ? (yes pour confirmer)"
    
    if ($confirm -eq "yes") {
        Write-Host "🗑️  Nettoyage en cours..." -ForegroundColor Yellow
        docker compose -f docker-compose.yml down -v --rmi all 2>$null
        docker compose -f docker-compose.dev.yml down -v --rmi all 2>$null
        Write-Host "✅ Nettoyage terminé" -ForegroundColor Green
    } else {
        Write-Host "🚫 Nettoyage annulé" -ForegroundColor Yellow
    }
    exit 0
}

if ($Logs) {
    Write-Host "📋 Affichage des logs (Ctrl+C pour quitter)..." -ForegroundColor Yellow
    docker compose -f $ComposeFile logs -f
    exit 0
}

# Créer le répertoire instance et logs s'ils n'existent pas
if (!(Test-Path "instance")) {
    New-Item -ItemType Directory -Name "instance" | Out-Null
    Write-Host "📁 Répertoire instance créé" -ForegroundColor Green
}

if (!(Test-Path "logs")) {
    New-Item -ItemType Directory -Name "logs" | Out-Null
    Write-Host "📁 Répertoire logs créé" -ForegroundColor Green
}

# Build de l'image si nécessaire
if ($Rebuild) {
    Write-Host "🔨 Rebuild complet de l'image (sans cache)..." -ForegroundColor Yellow
    docker compose -f $ComposeFile build --no-cache
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors du build" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Build terminé" -ForegroundColor Green
} elseif ($Build) {
    Write-Host "🔨 Build de l'image..." -ForegroundColor Yellow
    docker compose -f $ComposeFile build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors du build" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Build terminé" -ForegroundColor Green
}

# Démarrer les conteneurs
Write-Host "🚀 Démarrage des conteneurs..." -ForegroundColor Green
docker compose -f $ComposeFile up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du démarrage des conteneurs" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Conteneurs démarrés avec succès!" -ForegroundColor Green
Write-Host ""

# Attendre que le serveur soit prêt
Write-Host "⏳ Vérification de l'état du serveur..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$maxAttempts = 10
$attempt = 0
$serverReady = $false

while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $serverReady = $true
            break
        }
    } catch {
        # Serveur pas encore prêt
    }
    
    $attempt++
    Start-Sleep -Seconds 2
    Write-Host "." -NoNewline -ForegroundColor Gray
}

Write-Host ""

if ($serverReady) {
    Write-Host "✅ Serveur opérationnel!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Le serveur démarre... vérifiez les logs si nécessaire" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌟 Application disponible:" -ForegroundColor Green
Write-Host "   • Interface web:     http://localhost:5000/" -ForegroundColor Cyan
Write-Host "   • Documentation API: http://localhost:5000/api/docs" -ForegroundColor Cyan
Write-Host "   • Health check:      http://localhost:5000/health" -ForegroundColor Cyan
Write-Host "   • Statistiques:      http://localhost:5000/api/stats" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Commandes utiles:" -ForegroundColor Yellow
Write-Host "   • Voir les logs:     .\docker-start.ps1 -Logs" -ForegroundColor Cyan
Write-Host "   • Statut:            .\docker-start.ps1 -Status" -ForegroundColor Cyan
Write-Host "   • Shell:             .\docker-start.ps1 -Shell" -ForegroundColor Cyan
Write-Host "   • Arrêter:           .\docker-start.ps1 -Stop" -ForegroundColor Cyan
Write-Host ""