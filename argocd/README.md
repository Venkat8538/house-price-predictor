# ArgoCD Setup for MLOps Platform

## Install ArgoCD

```bash
# Create namespace and install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Deploy Application

```bash
# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Update repo URL in application.yaml with your GitHub repo
```

## Workflow

1. **Code Change** → Push to GitHub
2. **GitHub Actions** → Build images, push to ECR, update K8s manifests
3. **ArgoCD** → Detects manifest changes, deploys to EKS automatically

## Access

- ArgoCD UI: https://localhost:8080
- FastAPI: http://api.mlops.local
- Streamlit: http://app.mlops.local