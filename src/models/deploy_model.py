"""
Model Deployment with Versioning
Handles S3 upload with proper version management
"""
import boto3
import os
import sys
import logging
from pathlib import Path

# Add parent directory to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))
from version import versioning

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ModelDeployer:
    def __init__(self, bucket_name: str):
        self.bucket_name = bucket_name
        self.s3_client = boto3.client('s3')
        
    def upload_versioned_model(self, local_model_path: str, model_name: str = "house-price-model"):
        """Upload model with version to S3"""
        version = versioning.get_version()
        
        # Create versioned S3 path
        s3_key = f"models/{model_name}/{version}/model.tar.gz"
        
        try:
            # Upload model
            self.s3_client.upload_file(local_model_path, self.bucket_name, s3_key)
            logger.info(f"Model uploaded: s3://{self.bucket_name}/{s3_key}")
            
            # Update latest symlink
            self._update_latest_version(model_name, version)
            
            return f"s3://{self.bucket_name}/{s3_key}"
            
        except Exception as e:
            logger.error(f"Upload failed: {e}")
            raise
    
    def _update_latest_version(self, model_name: str, version: str):
        """Update latest version pointer"""
        latest_key = f"models/{model_name}/latest/version.txt"
        
        try:
            # Upload version info to latest
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=latest_key,
                Body=version.encode('utf-8')
            )
            logger.info(f"Latest version updated to: {version}")
        except Exception as e:
            logger.warning(f"Failed to update latest version: {e}")
    
    def list_model_versions(self, model_name: str = "house-price-model"):
        """List all model versions"""
        prefix = f"models/{model_name}/"
        
        try:
            response = self.s3_client.list_objects_v2(
                Bucket=self.bucket_name,
                Prefix=prefix,
                Delimiter='/'
            )
            
            versions = []
            for obj in response.get('CommonPrefixes', []):
                version = obj['Prefix'].split('/')[-2]
                if version != 'latest':
                    versions.append(version)
            
            return sorted(versions, reverse=True)
            
        except Exception as e:
            logger.error(f"Failed to list versions: {e}")
            return []

if __name__ == "__main__":
    # Example usage
    bucket_name = "your-mlops-bucket"  # Replace with your bucket
    model_path = "/opt/ml/processing/output/model.tar.gz"
    
    deployer = ModelDeployer(bucket_name)
    
    if os.path.exists(model_path):
        s3_path = deployer.upload_versioned_model(model_path)
        print(f"Model deployed to: {s3_path}")
        
        # List all versions
        versions = deployer.list_model_versions()
        print(f"Available versions: {versions}")
    else:
        print(f"Model file not found: {model_path}")