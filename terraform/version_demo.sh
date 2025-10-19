#!/bin/bash
# Demo script to show Git + Semantic Versioning in Terraform

echo "🏷️  Model Versioning Demo"
echo "========================"

# Get current Git commit
GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null | cut -c1-8 || echo "local")
VERSION="v1.0.0-$GIT_COMMIT"

echo "📝 Git Commit: $GIT_COMMIT"
echo "🏷️  Model Version: $VERSION"
echo "📦 S3 Model Path: s3://YOUR-BUCKET/models/house-price-model/$VERSION/"
echo "🔗 Latest Symlink: s3://YOUR-BUCKET/models/house-price-model/latest/"

echo ""
echo "🚀 To deploy with versioning:"
echo "   terraform apply"
echo "   # This will create versioned model paths automatically"

echo ""
echo "📋 Model Registry Structure:"
echo "   s3://bucket/models/house-price-model/"
echo "   ├── v1.0.0-a1b2c3d4/"
echo "   │   ├── model.tar.gz"
echo "   │   └── metadata.json"
echo "   ├── v1.0.1-e5f6g7h8/"
echo "   │   ├── model.tar.gz"
echo "   │   └── metadata.json"
echo "   └── latest/ → points to current version"