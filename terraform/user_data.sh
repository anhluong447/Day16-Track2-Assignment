#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user_data setup for ML Inference Endpoint (CPU)"

# 1. System updates and Python installation
dnf update -y
dnf install -y python3 python3-pip

# 2. Install ML and API libraries
pip3 install --upgrade pip
pip3 install lightgbm scikit-learn pandas numpy fastapi uvicorn pydantic

# 3. Setup directory
mkdir -p /opt/ml
cd /opt/ml

# 4. Create training script
cat << 'EOF' > train.py
import lightgbm as lgb
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

print("Generating synthetic dataset...")
X, y = make_classification(n_samples=10000, n_features=20, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

train_data = lgb.Dataset(X_train, label=y_train)
test_data = lgb.Dataset(X_test, label=y_test, reference=train_data)

params = {
    'objective': 'binary',
    'metric': 'binary_logloss',
    'boosting_type': 'gbdt',
    'num_leaves': 31,
    'learning_rate': 0.05,
    'feature_fraction': 0.9,
    'verbose': -1
}

print("Training LightGBM model...")
model = lgb.train(
    params,
    train_data,
    num_boost_round=100,
    valid_sets=[test_data],
    callbacks=[lgb.early_stopping(stopping_rounds=10)]
)

model.save_model('model.txt')
print("Model saved to model.txt")
EOF

# 5. Create FastAPI server script
cat << 'EOF' > main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import lightgbm as lgb
import numpy as np

app = FastAPI(title="LightGBM ML API")

# Load model globally
model = lgb.Booster(model_file='model.txt')

class PredictionRequest(BaseModel):
    features: list[float]

@app.post("/predict")
def predict(request: PredictionRequest):
    if len(request.features) != 20:
        raise HTTPException(status_code=400, detail="Expected 20 features")
    
    # Reshape for LightGBM
    data = np.array([request.features])
    prob = model.predict(data)[0]
    prediction = int(prob > 0.5)
    
    return {
        "probability": float(prob),
        "prediction": prediction
    }

@app.get("/health")
def health():
    return {"status": "healthy"}
EOF

# 6. Train the model
python3 train.py

# 7. Create systemd service for FastAPI
cat << 'EOF' > /etc/systemd/system/ml-api.service
[Unit]
Description=ML API Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/ml
ExecStart=/usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the service
systemctl daemon-reload
systemctl enable ml-api
systemctl start ml-api

echo "ML setup complete and API is running on port 8000"