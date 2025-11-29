#!/bin/bash

# DDSP Training Script

SAVE_DIR="models/ddsp-solo-instrument"
TRAIN_TFRECORD_FILEPATTERN="data/train.tfrecord*"

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
