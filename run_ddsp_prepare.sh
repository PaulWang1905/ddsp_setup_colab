#!/bin/bash
set -e  # Exit on any error

ENV_NAME="ddsp_env"

echo "=========================================="
echo "Running DDSP Data Preparation"
echo "=========================================="

# Activate conda environment
echo "[1/3] Activating conda environment: $ENV_NAME..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Download the prepare_ddsp_data.py script
echo "[2/3] Downloading prepare_ddsp_data.py..."
wget -q --show-progress https://raw.githubusercontent.com/PaulWang1905/ddsp_setup_colab/refs/heads/main/prepare_ddsp_data.py -O prepare_ddsp_data.py

# Run the script
echo "[3/3] Running prepare_ddsp_data.py..."
python prepare_ddsp_data.py

echo "=========================================="
echo "Data preparation complete!"
echo "=========================================="
