# Stage 1: prepare data and train the model during the build.
# If the quality gate in train.py fails, the build fails and nothing is deployed.
FROM python:3.11-slim AS trainer
WORKDIR /app
COPY requirements-dev.txt requirements.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt
COPY src/ src/
RUN python -m src.prepare_data && python -m src.train

# Stage 2: small image that only serves the trained model.
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ src/
COPY --from=trainer /app/model/ model/
# The API listens on port 8080. Open port 8080 when you create the container instance.
CMD exec uvicorn src.app:app --host 0.0.0.0 --port ${PORT:-8080}
