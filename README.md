# MLOps Pipelines on Azure - demo repo

A small end-to-end ML pipeline on Microsoft Azure, built using only the browser.
The model is a logistic regression on 5 features of the breast cancer dataset.
Follow the step-by-step student guide (PDF) to run it.

| What | File | Where it runs |
|---|---|---|
| Data prep, plus a "next week" file with drift | src/prepare_data.py | GitHub Actions |
| Training, MLflow logging, quality gate (f1 >= 0.85) | src/train.py | GitHub Actions and the Docker build |
| Unit tests for the API | tests/test_api.py | GitHub Actions |
| Batch scoring | src/batch_predict.py | GitHub Actions |
| Drift check (KS test) | src/drift.py | GitHub Actions |
| Build image and push to Azure Container Registry | .github/workflows/deploy.yml | GitHub Actions |
| Real-time API (click Restart to load a new image) | src/app.py + Dockerfile | Azure Container Instances |
| MLflow server | vm_custom_data.sh | Azure virtual machine (B2ats v2) |
| Sample data | data/*.csv | upload to your storage account |

## Settings you must add in your fork

Open Settings, then Secrets and variables, then Actions.

- Secret MLFLOW_TRACKING_URI = http://YOUR_VM_PUBLIC_IP:5000
- Secrets ACR_USERNAME and ACR_PASSWORD = from your container registry, Access keys page
- Variable ACR_LOGIN_SERVER = your registry's login server, for example mlopsdemo123.azurecr.io

The lab account has the Contributor role, which cannot grant permissions, so GitHub signs in to the registry
with the registry's admin login. GitHub keeps secrets encrypted and never shows them in logs.

The lab also has no App Service quota, so the API runs on Azure Container Instances.
After the deploy workflow pushes a new image, open the container instance and click Restart:
the restart pulls the newest `latest` image.

## Run on your own computer (optional)

    pip install -r requirements-dev.txt
    python -m src.prepare_data
    python -m src.train
    pytest -q
    python -m src.batch_predict
    python -m src.drift
