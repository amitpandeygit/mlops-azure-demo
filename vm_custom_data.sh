#!/bin/bash
# Paste this into "Custom data" (Advanced tab) when you create the virtual machine.
# It installs MLflow and runs it on port 5000 as a service, so it also starts again after a reboot.
# Run records and model files are kept on the virtual machine's own disk.
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi
swapon /swapfile 2>/dev/null
apt-get update -y && apt-get install -y python3-venv
python3 -m venv /opt/mlenv
/opt/mlenv/bin/pip install mlflow==2.19.0 sqlalchemy==2.0.36
mkdir -p /opt/mlartifacts
cat > /etc/systemd/system/mlflow.service <<'UNIT'
[Unit]
Description=MLflow tracking server
After=network-online.target

[Service]
ExecStart=/opt/mlenv/bin/mlflow server --host 0.0.0.0 --port 5000 --backend-store-uri sqlite:////opt/mlflow.db --serve-artifacts --artifacts-destination /opt/mlartifacts
Restart=always

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now mlflow
