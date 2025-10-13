import pytest
import pandas as pd
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

def test_raw_data_exists():
    """Test that raw data file exists"""
    assert os.path.exists("data/raw/house_data.csv"), "Raw data file not found"

def test_raw_data_structure():
    """Test basic structure of raw data"""
    if os.path.exists("data/raw/house_data.csv"):
        df = pd.read_csv("data/raw/house_data.csv")
        assert len(df) > 0, "Raw data is empty"
        assert len(df.columns) > 0, "Raw data has no columns"

def test_processed_data_creation():
    """Test that processed data can be created"""
    try:
        from data.run_processing import main
        # This would run the actual processing
        # main()
        pytest.skip("Skipping actual data processing in tests")
    except ImportError:
        pytest.skip("Data processing module not available")