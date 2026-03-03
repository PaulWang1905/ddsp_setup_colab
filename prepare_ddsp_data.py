"""
DDSP Data Preparation Script
Converts audio files to TFRecord format for DDSP training.
"""

import glob
import os
import subprocess
import argparse


# ============== Configuration ==============
AUDIO_DIR = 'data/audio'
SAVE_DIR = 'models/ddsp-solo-instrument'
TRAIN_TFRECORD = 'data/train.tfrecord'
NUM_SHARDS = 10


def setup_directories(audio_dir: str, save_dir: str):
    """Create necessary directories if they don't exist."""
    os.makedirs(audio_dir, exist_ok=True)
    os.makedirs(save_dir, exist_ok=True)
    print(f"Created directories:\n  Audio: {audio_dir}\n  Save: {save_dir}")


def prepare_tfrecord(audio_dir: str, output_tfrecord: str, num_shards: int = 10):
    """
    Prepare TFRecord files from audio files using ddsp_prepare_tfrecord.
    
    Args:
        audio_dir: Directory containing audio files
        output_tfrecord: Output path for TFRecord files
        num_shards: Number of shards for the TFRecord
    """
    audio_filepattern = os.path.join(audio_dir, '*')
    
    # Check if audio files exist
    audio_files = glob.glob(audio_filepattern)
    if not audio_files:
        raise ValueError(f'No audio files found in {audio_dir}. '
                        'Please add audio files to the directory.')
    
    print(f"Found {len(audio_files)} audio file(s):")
    for f in audio_files:
        print(f"  - {f}")
    
    # Prepare TFRecord
    cmd = [
    'ddsp_prepare_tfrecord',
    f'--input_audio_filepatterns={audio_filepattern}',
    f'--output_tfrecord_path={output_tfrecord}',
    f'--num_shards={num_shards}',
    '--sample_rate=16000',
    '--frame_rate=50',
    '--example_secs=4.0',
    '--hop_secs=1.0',
    '--viterbi=True',
    '--center=True',
    '--alsologtostderr'
]
    
    print(f"\nRunning: {' '.join(cmd)}\n")
    subprocess.run(cmd, check=True)
    
    # Verify output
    tfrecord_files = glob.glob(output_tfrecord + '*')
    print(f"\nCreated {len(tfrecord_files)} TFRecord file(s):")
    for f in tfrecord_files:
        print(f"  - {f}")


def main():
    parser = argparse.ArgumentParser(
        description='Prepare audio data for DDSP training'
    )
    parser.add_argument(
        '--audio_dir',
        type=str,
        default=AUDIO_DIR,
        help=f'Directory containing audio files (default: {AUDIO_DIR})'
    )
    parser.add_argument(
        '--save_dir',
        type=str,
        default=SAVE_DIR,
        help=f'Directory to save models (default: {SAVE_DIR})'
    )
    parser.add_argument(
        '--output_tfrecord',
        type=str,
        default=TRAIN_TFRECORD,
        help=f'Output TFRecord path (default: {TRAIN_TFRECORD})'
    )
    parser.add_argument(
        '--num_shards',
        type=int,
        default=NUM_SHARDS,
        help=f'Number of TFRecord shards (default: {NUM_SHARDS})'
    )
    
    args = parser.parse_args()
    
    # Setup directories
    setup_directories(args.audio_dir, args.save_dir)
    
    # Prepare TFRecord
    prepare_tfrecord(
        audio_dir=args.audio_dir,
        output_tfrecord=args.output_tfrecord,
        num_shards=args.num_shards
    )
    
    print("\nData preparation complete!")


if __name__ == '__main__':
    main()
