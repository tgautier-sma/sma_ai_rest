from flask import Flask, render_template, request, jsonify
from flask_swagger_ui import get_swaggerui_blueprint
import requests
import json
import time
from models import db, APIRequest
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///api_requests.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialiser la base de données
db.init_app(app)

# Créer les tables
with app.app_context():
    db.create_all()

# Configuration Swagger UI
SWAGGER_URL = '/api/docs'  # URL pour accéder à la documentation Swagger
API_URL = '/static/swagger.yaml'  # Chemin vers le fichier de spécification

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={
        'app_name': "API REST Client",
        'docExpansion': 'list',
        'defaultModelsExpandDepth': 3,
        'displayRequestDuration': True
    }
)

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint pour vérifier l'état de l'application"""
    try:
        # Vérifier la connexion à la base de données
        db.session.execute(db.text('SELECT 1'))
        db_status = 'healthy'
    except Exception as e:
        db_status = f'unhealthy: {str(e)}'
    
    health_status = {
        'status': 'healthy' if db_status == 'healthy' else 'degraded',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0',
        'services': {
            'database': db_status,
            'api': 'healthy'
        }
    }
    
    status_code = 200 if health_status['status'] == 'healthy' else 503
    return jsonify(health_status), status_code

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Récupérer les statistiques de l'application"""
    try:
        # Nombre total de requêtes
        total_requests = APIRequest.query.count()
        
        # Requêtes par méthode HTTP
        methods_stats = {}
        for method in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
            count = APIRequest.query.filter_by(method=method).count()
            methods_stats[method] = count
        
        # Requêtes des dernières 24h
        from datetime import timedelta
        yesterday = datetime.utcnow() - timedelta(days=1)
        recent_requests = APIRequest.query.filter(APIRequest.timestamp >= yesterday).count()
        
        # Temps de réponse moyen
        avg_response_time = db.session.query(
            db.func.avg(APIRequest.response_time)
        ).filter(APIRequest.response_time.isnot(None)).scalar()
        
        # Statut de santé
        try:
            db.session.execute(db.text('SELECT 1'))
            health_status = 'healthy'
        except:
            health_status = 'unhealthy'
        
        stats = {
            'success': True,
            'total_requests': total_requests,
            'recent_requests_24h': recent_requests,
            'methods': methods_stats,
            'avg_response_time': round(avg_response_time, 3) if avg_response_time else 0,
            'health_status': health_status,
            'version': '1.0.0',
            'timestamp': datetime.utcnow().isoformat()
        }
        
        return jsonify(stats)
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/')
def index():
    """Page d'accueil"""
    return render_template('index.html')

@app.route('/api/call', methods=['POST'])
def call_api():
    """Effectuer un appel API et sauvegarder la requête"""
    try:
        data = request.get_json()
        
        url = data.get('url')
        method = data.get('method', 'GET').upper()
        headers = data.get('headers', {})
        body = data.get('body')
        proxy_url = data.get('proxy', '').strip()
        
        # Valider l'URL
        if not url:
            return jsonify({'error': 'URL manquante'}), 400
        
        # Configurer le proxy
        proxies = None
        if proxy_url:
            try:
                # Valider le format du proxy
                if not (proxy_url.startswith('http://') or proxy_url.startswith('https://') or proxy_url.startswith('socks5://')):
                    return jsonify({'error': 'Le proxy doit commencer par http://, https:// ou socks5://'}), 400
                
                proxies = {
                    'http': proxy_url,
                    'https': proxy_url
                }
            except Exception as e:
                return jsonify({'error': f'Configuration proxy invalide: {str(e)}'}), 400
        
        # Préparer les headers
        if isinstance(headers, str):
            try:
                headers = json.loads(headers)
            except:
                headers = {}
        
        # Préparer le body
        request_body = None
        if body and method in ['POST', 'PUT', 'PATCH']:
            if isinstance(body, str):
                try:
                    request_body = json.loads(body)
                except:
                    request_body = body
            else:
                request_body = body
        
        # Effectuer l'appel API
        start_time = time.time()
        
        try:
            if method == 'GET':
                response = requests.get(url, headers=headers, proxies=proxies, timeout=30)
            elif method == 'POST':
                response = requests.post(url, headers=headers, json=request_body, proxies=proxies, timeout=30)
            elif method == 'PUT':
                response = requests.put(url, headers=headers, json=request_body, proxies=proxies, timeout=30)
            elif method == 'DELETE':
                response = requests.delete(url, headers=headers, proxies=proxies, timeout=30)
            elif method == 'PATCH':
                response = requests.patch(url, headers=headers, json=request_body, proxies=proxies, timeout=30)
            else:
                return jsonify({'error': f'Méthode {method} non supportée'}), 400
            
            response_time = time.time() - start_time
            
            # Essayer de parser la réponse en JSON
            try:
                response_data = response.json()
            except:
                response_data = response.text
            
            # Sauvegarder dans la base de données
            api_request = APIRequest(
                url=url,
                method=method,
                headers=json.dumps(headers) if headers else None,
                body=json.dumps(request_body) if request_body else None,
                proxy=proxy_url if proxy_url else None,
                response_status=response.status_code,
                response_data=json.dumps(response_data) if isinstance(response_data, (dict, list)) else response_data,
                response_time=response_time
            )
            
            db.session.add(api_request)
            db.session.commit()
            
            # Retourner la réponse
            return jsonify({
                'success': True,
                'status_code': response.status_code,
                'response_data': response_data,
                'response_time': round(response_time, 3),
                'headers': dict(response.headers),
                'request_id': api_request.id
            })
            
        except requests.exceptions.Timeout:
            return jsonify({'error': 'Timeout - La requête a pris trop de temps'}), 408
        except requests.exceptions.ConnectionError:
            return jsonify({'error': 'Erreur de connexion - Impossible de joindre le serveur'}), 503
        except requests.exceptions.RequestException as e:
            return jsonify({'error': f'Erreur de requête: {str(e)}'}), 500
            
    except Exception as e:
        return jsonify({'error': f'Erreur serveur: {str(e)}'}), 500

@app.route('/api/history', methods=['GET'])
def get_history():
    """Récupérer l'historique des requêtes"""
    try:
        limit = request.args.get('limit', 50, type=int)
        requests_list = APIRequest.query.order_by(APIRequest.timestamp.desc()).limit(limit).all()
        
        return jsonify({
            'success': True,
            'requests': [req.to_dict() for req in requests_list]
        })
    except Exception as e:
        return jsonify({'error': f'Erreur: {str(e)}'}), 500

@app.route('/api/history/<int:request_id>', methods=['GET'])
def get_request_detail(request_id):
    """Récupérer les détails d'une requête spécifique"""
    try:
        api_request = APIRequest.query.get(request_id)
        if not api_request:
            return jsonify({'error': 'Requête non trouvée'}), 404
        
        return jsonify({
            'success': True,
            'request': api_request.to_dict()
        })
    except Exception as e:
        return jsonify({'error': f'Erreur: {str(e)}'}), 500

@app.route('/api/history/<int:request_id>', methods=['DELETE'])
def delete_request(request_id):
    """Supprimer une requête de l'historique"""
    try:
        api_request = APIRequest.query.get(request_id)
        if not api_request:
            return jsonify({'error': 'Requête non trouvée'}), 404
        
        db.session.delete(api_request)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Requête supprimée'
        })
    except Exception as e:
        return jsonify({'error': f'Erreur: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
