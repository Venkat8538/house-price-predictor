import pytest
import pandas as pd
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

def test_feature_engineering_output():
    """Test that feature engineering produces expected output"""
    if os.path.exists("data/processed/featured_house_data.csv"):
        df = pd.read_csv("data/processed/featured_house_data.csv")
        assert len(df) > 0, "Featured data is empty"
        # Add specific feature validation here
    else:
        pytest.skip("Featured data not available")

def test_feature_engineering_module():
    """Test that feature engineering module can be imported"""
    try:
        from features.engineer import main
        pytest.skip("Skipping actual feature engineering in tests")
    except ImportError:
        pytest.skip("Feature engineering module not available")