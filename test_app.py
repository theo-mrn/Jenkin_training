import pytest
from app import app

#ceci est mon ajout depuis feature
# nouvelle correction 
def test_hello():
    client = app.test_client()
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b"Hello Jenkins"
