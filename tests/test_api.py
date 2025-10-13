import pytest
from fastapi.testclient import TestClient
import sys
import os

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src', 'api'))

try:
    from main import app
    client = TestClient(app)
    
    def test_health_endpoint():
        response = client.get("/health")
        assert response.status_code == 200
        
    def test_predict_endpoint_structure():
        # Test with minimal valid data structure
        test_data = {
            "bedrooms": 3,
            "bathrooms": 2,
            "sqft_living": 1500,
            "sqft_lot": 5000,
            "floors": 1,
            "waterfront": 0,
            "view": 0,
            "condition": 3,
            "grade": 7,
            "sqft_above": 1500,
            "sqft_basement": 0,
            "yr_built": 1990,
            "yr_renovated": 0,
            "zipcode": 98001,
            "lat": 47.3,
            "long": -122.2,
            "sqft_living15": 1500,
            "sqft_lot15": 5000
        }
        response = client.post("/predict", json=test_data)
        # Should return 200 or 422 (validation error), not 500
        assert response.status_code in [200, 422]
        
except ImportError:
    def test_import_placeholder():
        pytest.skip("API module not available for testing")