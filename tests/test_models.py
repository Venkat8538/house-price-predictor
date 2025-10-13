import pytest
import os
import joblib

def test_model_files_exist():
    """Test that required model files exist"""
    model_path = "models/trained/house_price_model.pkl"
    preprocessor_path = "models/trained/preprocessor.pkl"
    
    assert os.path.exists(model_path), "Model file not found"
    assert os.path.exists(preprocessor_path), "Preprocessor file not found"

def test_model_loading():
    """Test that models can be loaded without errors"""
    model_path = "models/trained/house_price_model.pkl"
    preprocessor_path = "models/trained/preprocessor.pkl"
    
    if os.path.exists(model_path):
        model = joblib.load(model_path)
        assert model is not None, "Model failed to load"
        
    if os.path.exists(preprocessor_path):
        preprocessor = joblib.load(preprocessor_path)
        assert preprocessor is not None, "Preprocessor failed to load"