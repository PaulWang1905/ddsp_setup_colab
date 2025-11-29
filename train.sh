#!/bin/bash
set -e  # Exit on any error

ENV_NAME="ddsp_env"

echo "=========================================="
echo "DDSP Training Script"
echo "=========================================="

# Activate conda environment
echo "[1/2] Activating conda environment: $ENV_NAME..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Training configuration
SAVE_DIR="models/ddsp-solo-instrument"
TRAIN_TFRECORD_FILEPATTERN="data/train.tfrecord*"

echo "[2/2] Starting DDSP training..."
echo "  Save directory: $SAVE_DIR"
echo "  Data pattern: $TRAIN_TFRECORD_FILEPATTERN"
echo "=========================================="

ddsp_run \
  --mode=train \
  --alsologtostderr \
  --save_dir="$SAVE_DIR" \
  --gin_file=models/solo_instrument.gin \
  --gin_file=datasets/tfrecord.gin \
  --gin_param="TFRecordProvider.file_pattern='$TRAIN_TFRECORD_FILEPATTERN'" \
  --gin_param="batch_size=16" \
  --gin_param="train_util.train.num_steps=30000" \
  --gin_param="train_util.train.steps_per_save=300" \
  --gin_param="trainers.Trainer.checkpoints_to_keep=10"

echo "=========================================="
echo "Training complete!"
echo "=========================================="