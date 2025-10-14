# GitHub Actions Setup

## Required Secrets

Add these secrets in your GitHub repository settings:

1. **AIRFLOW_URL**: Your Airflow server URL (e.g., `http://your-server:8080`)
2. **AIRFLOW_AUTH**: Base64 encoded `username:password` (e.g., `YWRtaW46YWRtaW4=` for admin:admin)

## How to set secrets:

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add:
   - Name: `AIRFLOW_URL`
   - Value: `http://your-airflow-server:8080`
   - Name: `AIRFLOW_AUTH` 
   - Value: `YWRtaW46YWRtaW4=` (base64 of admin:admin)

## Generate base64 auth:
```bash
echo -n "admin:admin" | base64
```

## Workflow Triggers:

- **Push to main**: Triggers full pipeline with Airflow
- **Pull Request**: Runs tests only
- **Path filters**: Only triggers on ML-related file changes

## Pipeline Flow:

1. Code changes in `src/models/`, `src/features/`, etc.
2. GitHub Actions runs tests
3. Builds Docker images
4. Triggers Airflow ML pipeline
5. Airflow retrains and deploys model