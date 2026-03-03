#!/bin/bash
set -e  # Exit on any error

ENV_NAME="ddsp_env"

echo "=========================================="
echo "DDSP Export Script"
echo "=========================================="

# Activate conda environment
echo "[1/2] Activating conda environment: $ENV_NAME..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Export configuration
MODEL_NAME="solo-instrument"
MODEL_PATH="models/ddsp-solo-instrument"
EXPORT_DIR="exports/ddsp-solo-instrument"

echo "[2/2] Exporting DDSP model..."
echo "  Model name: $MODEL_NAME"
echo "  Model path: $MODEL_PATH"
echo "  Export directory: $EXPORT_DIR"
echo "=========================================="

ddsp_export \
  --name="$MODEL_NAME" \
  --model_path="$MODEL_PATH" \
  --save_dir="$EXPORT_DIR" \
  --inference_model=vst_stateless_predict_controls \
  --tflite \
  --notfjs 
  #--gin_param="frame_size=64" \
 # --gin_param="sample_rate=16000"

echo "=========================================="
echo "Export complete!"
echo "Exported model saved to: $EXPORT_DIR"
echo "=========================================="
