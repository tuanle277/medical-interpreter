import os
import sys
import tempfile
import pytest
from unittest.mock import patch

# Add the backend directory to the sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.app.main import app  # Now this should work

@pytest.fixture
def client():
    db_fd, app.config['DATABASE'] = tempfile.mkstemp()
    app.config['TESTING'] = True

    with app.test_client() as client:
        with app.app_context():
            # Initialize any necessary components here
            pass
        yield client

    os.close(db_fd)
    os.unlink(app.config['DATABASE'])

@patch('backend.app.main.translate_text')
def test_interpret(mock_translate, client):
    mock_translate.return_value = 'Xin chào, bạn có khỏe không?'
    response = client.post('/interpret', json={'speech_text': 'Hello, how are you?'})
    assert response.status_code == 200
    data = response.get_json()
    assert 'translation' in data
    assert data['translation'] == 'Xin chào, bạn có khỏe không?'

@patch('backend.app.main.GeminiClient')
def test_analyze(mock_gemini, client):
    mock_gemini.return_value.get_understanding.return_value = 'neutral'
    with open('current_frame.jpg', 'rb') as img_file:  # Provide a path to a valid image for testing
        img_data = img_file.read()
    
    response = client.post('/analyze', data=img_data, content_type='application/octet-stream')
    assert response.status_code == 200
    data = response.get_json()
    assert 'understanding' in data
    assert data['understanding'] == 'neutral'
