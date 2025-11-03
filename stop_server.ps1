# Script PowerShell pour arrêter le serveur Flask SMA AI REST
# Usage: .\stop_server.ps1

param(
    [int]$Port = 5000,
    [switch]$All,
    [switch]$Help
)

# Fonction d'aide
function Show-Help {
    Write-Host "Script d'arrêt du serveur Flask SMA AI REST" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\stop_server.ps1 [OPTIONS]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Port <port>        Port du serveur à arrêter (défaut: 5000)" -ForegroundColor White
    Write-Host "  -All                Arrête tous les processus Python/Flask" -ForegroundColor White
    Write-Host "  -Help               Affiche cette aide" -ForegroundColor White
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Yellow
    Write-Host "  .\stop_server.ps1                     # Arrête le serveur sur le port 5000" -ForegroundColor Cyan
    Write-Host "  .\stop_server.ps1 -Port 8080          # Arrête le serveur sur le port 8080" -ForegroundColor Cyan
    Write-Host "  .\stop_server.ps1 -All                # Arrête tous les processus Python" -ForegroundColor Cyan
}

# Afficher l'aide si demandé
if ($Help) {
    Show-Help
    exit 0
}

Write-Host "🛑 Arrêt du serveur SMA AI REST..." -ForegroundColor Yellow

if ($All) {
    Write-Host "🔍 Recherche de tous les processus Python..." -ForegroundColor Cyan
    
    # Trouver tous les processus Python
    $pythonProcesses = Get-Process -Name "python*" -ErrorAction SilentlyContinue
    
    if ($pythonProcesses) {
        Write-Host "📋 Processus Python trouvés:" -ForegroundColor Yellow
        foreach ($process in $pythonProcesses) {
            Write-Host "   PID: $($process.Id) - $($process.ProcessName)" -ForegroundColor Gray
        }
        
        $confirm = Read-Host "Voulez-vous vraiment arrêter tous ces processus ? (y/N)"
        if ($confirm -eq "y" -or $confirm -eq "Y" -or $confirm -eq "yes" -or $confirm -eq "oui") {
            foreach ($process in $pythonProcesses) {
                try {
                    Stop-Process -Id $process.Id -Force
                    Write-Host "✅ Processus $($process.Id) arrêté" -ForegroundColor Green
                } catch {
                    Write-Host "❌ Impossible d'arrêter le processus $($process.Id): $_" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "🚫 Annulation de l'arrêt des processus" -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Host "ℹ️  Aucun processus Python trouvé" -ForegroundColor Blue
    }
} else {
    Write-Host "🔍 Recherche des processus utilisant le port $Port..." -ForegroundColor Cyan
    
    # Trouver les processus utilisant le port spécifié
    try {
        $netstatOutput = netstat -ano | Select-String ":$Port "
        
        if ($netstatOutput) {
            $pids = @()
            foreach ($line in $netstatOutput) {
                if ($line -match "\s+(\d+)$") {
                    $pid = $matches[1]
                    if ($pid -ne "0" -and $pids -notcontains $pid) {
                        $pids += $pid
                    }
                }
            }
            
            if ($pids.Count -gt 0) {
                Write-Host "📋 Processus utilisant le port $Port :" -ForegroundColor Yellow
                foreach ($pid in $pids) {
                    try {
                        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
                        if ($process) {
                            Write-Host "   PID: $pid - $($process.ProcessName)" -ForegroundColor Gray
                            
                            # Arrêter le processus
                            Stop-Process -Id $pid -Force
                            Write-Host "✅ Processus $pid arrêté" -ForegroundColor Green
                        }
                    } catch {
                        Write-Host "❌ Impossible d'arrêter le processus $pid : $_" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "ℹ️  Aucun processus trouvé utilisant le port $Port" -ForegroundColor Blue
            }
        } else {
            Write-Host "ℹ️  Aucun processus trouvé utilisant le port $Port" -ForegroundColor Blue
        }
    } catch {
        Write-Host "❌ Erreur lors de la recherche des processus: $_" -ForegroundColor Red
        
        # Méthode alternative : chercher les processus Python
        Write-Host "🔄 Tentative alternative..." -ForegroundColor Yellow
        $pythonProcesses = Get-Process -Name "python*" -ErrorAction SilentlyContinue
        
        if ($pythonProcesses) {
            Write-Host "📋 Processus Python trouvés (possiblement le serveur Flask):" -ForegroundColor Yellow
            foreach ($process in $pythonProcesses) {
                Write-Host "   PID: $($process.Id) - $($process.ProcessName)" -ForegroundColor Gray
            }
            
            $confirm = Read-Host "Voulez-vous arrêter ces processus Python ? (y/N)"
            if ($confirm -eq "y" -or $confirm -eq "Y" -or $confirm -eq "yes" -or $confirm -eq "oui") {
                foreach ($process in $pythonProcesses) {
                    try {
                        Stop-Process -Id $process.Id -Force
                        Write-Host "✅ Processus $($process.Id) arrêté" -ForegroundColor Green
                    } catch {
                        Write-Host "❌ Impossible d'arrêter le processus $($process.Id): $_" -ForegroundColor Red
                    }
                }
            }
        }
    }
}

Write-Host ""
Write-Host "🏁 Opération terminée" -ForegroundColor Green

# Vérifier si le port est maintenant libre
Start-Sleep -Seconds 2
Write-Host "🔍 Vérification du port $Port..." -ForegroundColor Cyan

try {
    $testConnection = Test-NetConnection -ComputerName "localhost" -Port $Port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if ($testConnection.TcpTestSucceeded) {
        Write-Host "⚠️  Le port $Port semble encore occupé" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Le port $Port est maintenant libre" -ForegroundColor Green
    }
} catch {
    Write-Host "✅ Le port $Port semble être libre" -ForegroundColor Green
}