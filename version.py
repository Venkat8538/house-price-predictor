"""
Model Versioning System - Git + Semantic Versioning
Used by Netflix, Uber, Airbnb for production ML models
"""
import os
import subprocess
import datetime
from typing import Optional

class ModelVersioning:
    def __init__(self, major: int = 1, minor: int = 0, patch: int = 0):
        self.major = major
        self.minor = minor  
        self.patch = patch
        
    def get_git_commit(self) -> str:
        """Get current git commit hash"""
        try:
            # Try GitHub Actions first
            github_sha = os.getenv("GITHUB_SHA")
            if github_sha:
                return github_sha[:8]
            
            # Try local git
            result = subprocess.run(
                ["git", "rev-parse", "HEAD"], 
                capture_output=True, text=True, check=True
            )
            return result.stdout.strip()[:8]
        except:
            return "local"
    
    def get_version(self) -> str:
        """Generate version string: v1.0.0-a3b4c5d6"""
        git_hash = self.get_git_commit()
        return f"v{self.major}.{self.minor}.{self.patch}-{git_hash}"
    
    def get_model_path(self, bucket: str, model_name: str = "house-price-model") -> str:
        """Generate S3 path with version"""
        version = self.get_version()
        return f"s3://{bucket}/models/{model_name}/{version}/"
    
    def get_timestamp(self) -> str:
        """Get timestamp for backup versioning"""
        return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

# Default version instance
versioning = ModelVersioning(major=1, minor=0, patch=0)