from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import json

db = SQLAlchemy()

class APIRequest(db.Model):
    """Modèle pour sauvegarder les requêtes API"""
    id = db.Column(db.Integer, primary_key=True)
    url = db.Column(db.String(500), nullable=False)
    method = db.Column(db.String(10), nullable=False)
    headers = db.Column(db.Text, nullable=True)
    body = db.Column(db.Text, nullable=True)
    proxy = db.Column(db.String(500), nullable=True)
    response_status = db.Column(db.Integer, nullable=True)
    response_data = db.Column(db.Text, nullable=True)
    response_time = db.Column(db.Float, nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<APIRequest {self.method} {self.url}>'
    
    def to_dict(self):
        """Convertir l'objet en dictionnaire"""
        return {
            'id': self.id,
            'url': self.url,
            'method': self.method,
            'headers': json.loads(self.headers) if self.headers else {},
            'body': self.body,
            'proxy': self.proxy,
            'response_status': self.response_status,
            'response_data': json.loads(self.response_data) if self.response_data else None,
            'response_time': self.response_time,
            'timestamp': self.timestamp.strftime('%Y-%m-%d %H:%M:%S')
        }
