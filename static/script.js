// Configuration
const API_BASE_URL = '/api';

// Éléments DOM
const apiForm = document.getElementById('api-form');
const methodSelect = document.getElementById('method');
const urlInput = document.getElementById('url');
const headersInput = document.getElementById('headers');
const bodyInput = document.getElementById('body');
const proxyInput = document.getElementById('proxy');
const bodyGroup = document.getElementById('body-group');
const clearBtn = document.getElementById('clear-btn');
const responseSection = document.getElementById('response-section');
const statusBadge = document.getElementById('status-badge');
const responseTime = document.getElementById('response-time');
const responseBody = document.getElementById('response-body');
const responseHeaders = document.getElementById('response-headers');
const historyList = document.getElementById('history-list');
const refreshHistoryBtn = document.getElementById('refresh-history');
const exampleCards = document.querySelectorAll('.example-card');
const tabBtns = document.querySelectorAll('.tab-btn');

// Charger les statistiques du dashboard
async function loadDashboardStats() {
    try {
        const response = await fetch(`${API_BASE_URL}/stats`);
        const data = await response.json();
        
        if (data.success) {
            // Mettre à jour l'état du service
            const healthStatus = document.getElementById('health-status');
            if (data.health_status === 'healthy') {
                healthStatus.textContent = '✅ Opérationnel';
                healthStatus.style.color = 'var(--success-color)';
            } else {
                healthStatus.textContent = '⚠️ Dégradé';
                healthStatus.style.color = 'var(--danger-color)';
            }
            
            // Mettre à jour les statistiques
            document.getElementById('total-requests').textContent = data.total_requests;
            document.getElementById('recent-requests').textContent = data.recent_requests_24h;
            document.getElementById('avg-response-time').textContent = data.avg_response_time + 's';
            
            // Mettre à jour les statistiques par méthode
            Object.keys(data.methods).forEach(method => {
                const element = document.getElementById(`method-${method}`);
                if (element) {
                    element.textContent = data.methods[method];
                }
            });
        }
    } catch (error) {
        console.error('Erreur lors du chargement des statistiques:', error);
    }
}

// Gestion du body selon la méthode HTTP
methodSelect.addEventListener('change', () => {
    const method = methodSelect.value;
    if (method === 'GET' || method === 'DELETE') {
        bodyGroup.style.display = 'none';
        bodyInput.value = '';
    } else {
        bodyGroup.style.display = 'block';
    }
});

// Effacer le formulaire
clearBtn.addEventListener('click', () => {
    apiForm.reset();
    responseSection.style.display = 'none';
    bodyGroup.style.display = 'none';
    proxyInput.value = '';
});

// Soumettre le formulaire
apiForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const btnText = document.querySelector('.btn-text');
    const btnLoading = document.querySelector('.btn-loading');
    
    // Afficher le loader
    btnText.style.display = 'none';
    btnLoading.style.display = 'inline';
    
    const url = urlInput.value.trim();
    const method = methodSelect.value;
    const proxy = proxyInput.value.trim();
    let headers = {};
    let body = null;
    
    // Parser les headers
    if (headersInput.value.trim()) {
        try {
            headers = JSON.parse(headersInput.value);
        } catch (error) {
            alert('Format JSON invalide pour les headers');
            btnText.style.display = 'inline';
            btnLoading.style.display = 'none';
            return;
        }
    }
    
    // Parser le body
    if (bodyInput.value.trim() && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
        try {
            body = JSON.parse(bodyInput.value);
        } catch (error) {
            alert('Format JSON invalide pour le body');
            btnText.style.display = 'inline';
            btnLoading.style.display = 'none';
            return;
        }
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/call`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                url,
                method,
                headers,
                body,
                proxy
            })
        });
        
        const data = await response.json();
        
        if (data.error) {
            alert(`Erreur: ${data.error}`);
        } else {
            displayResponse(data);
            loadHistory(); // Recharger l'historique
            loadDashboardStats(); // Mettre à jour les statistiques
        }
    } catch (error) {
        alert(`Erreur de communication avec le serveur: ${error.message}`);
    } finally {
        btnText.style.display = 'inline';
        btnLoading.style.display = 'none';
    }
});

// Afficher la réponse
function displayResponse(data) {
    responseSection.style.display = 'block';
    
    // Status
    const statusCode = data.status_code;
    const statusClass = `status-${Math.floor(statusCode / 100)}xx`;
    statusBadge.className = `status-badge ${statusClass}`;
    statusBadge.textContent = `Status: ${statusCode}`;
    
    // Temps de réponse
    responseTime.textContent = `⏱️ ${data.response_time}s`;
    
    // Body
    responseBody.textContent = JSON.stringify(data.response_data, null, 2);
    
    // Headers
    responseHeaders.textContent = JSON.stringify(data.headers, null, 2);
    
    // Scroll vers les résultats
    responseSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Charger l'historique
async function loadHistory() {
    historyList.innerHTML = '<div class="loading">Chargement...</div>';
    
    try {
        const response = await fetch(`${API_BASE_URL}/history?limit=50`);
        const data = await response.json();
        
        if (data.success && data.requests.length > 0) {
            historyList.innerHTML = '';
            data.requests.forEach(req => {
                const item = createHistoryItem(req);
                historyList.appendChild(item);
            });
        } else {
            historyList.innerHTML = '<div class="loading">Aucune requête dans l\'historique</div>';
        }
    } catch (error) {
        historyList.innerHTML = '<div class="loading">Erreur de chargement</div>';
    }
}

// Créer un élément d'historique
function createHistoryItem(req) {
    const div = document.createElement('div');
    div.className = 'history-item';
    div.dataset.requestId = req.id;
    
    const statusClass = req.response_status ? `status-${Math.floor(req.response_status / 100)}xx` : '';
    
    div.innerHTML = `
        <button class="delete-btn" title="Supprimer cette requête" aria-label="Supprimer">✕</button>
        <div class="history-item-header">
            <span class="method-badge method-${req.method}">${req.method}</span>
            <span class="status-badge ${statusClass}" style="font-size: 0.8rem; padding: 4px 8px;">
                ${req.response_status || 'N/A'}
            </span>
        </div>
        <div class="history-url">${req.url}</div>
        <div class="history-meta">
            <span>📅 ${req.timestamp}</span>
            <span>⏱️ ${req.response_time ? req.response_time + 's' : 'N/A'}</span>
        </div>
    `;
    
    // Bouton de suppression
    const deleteBtn = div.querySelector('.delete-btn');
    deleteBtn.addEventListener('click', async (e) => {
        e.stopPropagation(); // Empêcher le clic sur l'item
        
        if (confirm('Voulez-vous vraiment supprimer cette requête de l\'historique ?')) {
            try {
                const response = await fetch(`${API_BASE_URL}/history/${req.id}`, {
                    method: 'DELETE'
                });
                
                const data = await response.json();
                
                if (data.success) {
                    // Animation de suppression
                    div.style.opacity = '0';
                    div.style.transform = 'translateX(-20px)';
                    setTimeout(() => {
                        div.remove();
                        
                        // Vérifier s'il reste des éléments
                        if (historyList.children.length === 0) {
                            historyList.innerHTML = '<div class="loading">Aucune requête dans l\'historique</div>';
                        }
                        
                        // Mettre à jour les statistiques
                        loadDashboardStats();
                    }, 300);
                } else {
                    alert('Erreur lors de la suppression: ' + (data.error || 'Erreur inconnue'));
                }
            } catch (error) {
                alert('Erreur de communication avec le serveur: ' + error.message);
            }
        }
    });
    
    // Clic pour réutiliser la requête
    div.addEventListener('click', () => {
        urlInput.value = req.url;
        methodSelect.value = req.method;
        
        if (req.headers && Object.keys(req.headers).length > 0) {
            headersInput.value = JSON.stringify(req.headers, null, 2);
        } else {
            headersInput.value = '';
        }
        
        if (req.proxy) {
            proxyInput.value = req.proxy;
        } else {
            proxyInput.value = '';
        }
        
        if (req.body) {
            bodyInput.value = req.body;
            bodyGroup.style.display = 'block';
        } else {
            bodyInput.value = '';
            if (req.method === 'GET' || req.method === 'DELETE') {
                bodyGroup.style.display = 'none';
            }
        }
        
        // Afficher la réponse si disponible
        if (req.response_data) {
            displayResponse({
                status_code: req.response_status,
                response_time: req.response_time,
                response_data: req.response_data,
                headers: {}
            });
        }
        
        // Scroll vers le formulaire
        apiForm.scrollIntoView({ behavior: 'smooth' });
    });
    
    return div;
}

// Actualiser l'historique
refreshHistoryBtn.addEventListener('click', loadHistory);

// Gestion des onglets de réponse
tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        const tabName = btn.dataset.tab;
        
        // Retirer la classe active de tous les boutons et contenus
        tabBtns.forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        
        // Ajouter la classe active
        btn.classList.add('active');
        document.getElementById(`${tabName}-tab`).classList.add('active');
    });
});

// Exemples d'API
exampleCards.forEach(card => {
    card.addEventListener('click', () => {
        const url = card.dataset.url;
        const method = card.dataset.method;
        
        urlInput.value = url;
        methodSelect.value = method;
        headersInput.value = '';
        bodyInput.value = '';
        proxyInput.value = '';
        
        if (method === 'GET' || method === 'DELETE') {
            bodyGroup.style.display = 'none';
        }
        
        // Scroll vers le formulaire
        apiForm.scrollIntoView({ behavior: 'smooth' });
    });
});

// Charger l'historique et les statistiques au démarrage
window.addEventListener('DOMContentLoaded', () => {
    loadHistory();
    loadDashboardStats();
    
    // Actualiser les statistiques toutes les 30 secondes
    setInterval(loadDashboardStats, 30000);
});
