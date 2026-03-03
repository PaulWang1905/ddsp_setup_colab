#!/bin/bash
set -e  # Exit on any error

ENV_NAME="ddsp_env"

echo "=========================================="
echo "Setting up DDSP Environment: $ENV_NAME"
echo "=========================================="

# Step 1: Create conda environment with Python 3.10 and CUDA
echo "[1/4] Creating conda environment..."
conda create -n $ENV_NAME python=3.10 cudatoolkit=11.2 cudnn=8.1 -c conda-forge -y

# Step 2: Activate the environment
echo "[2/4] Activating environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Step 3: Set up LD_LIBRARY_PATH
echo "[3/4] Setting up LD_LIBRARY_PATH..."
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Make LD_LIBRARY_PATH persistent for this environment
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
mkdir -p $CONDA_PREFIX/etc/conda/deactivate.d

cat > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh << 'EOF'
#!/bin/bash
export OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
EOF

cat > $CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh << 'EOF'
#!/bin/bash
export LD_LIBRARY_PATH=$OLD_LD_LIBRARY_PATH
unset OLD_LD_LIBRARY_PATH
EOF

# Step 4: Install packages with pinned versions
echo "[4/4] Installing packages with pinned versions..."

# Core dependencies first (order matters for compatibility)
pip install --upgrade pip

# Install numpy first (many packages depend on it)
# pip install "numpy<1.24"

# Install protobuf early (fixes proto dependency bugs)
# pip install "protobuf<=3.20"

# Install TensorFlow and related packages
#pip install "tensorflow-probability<=0.19"
#pip install "tensorflow-datasets<=4.9"
#pip install "tensorflowjs<3.19"
#pip install "tflite_support<=0.1"

# Install audio/ML dependencies
#pip install "librosa<=0.10"
#pip install "scipy<=1.10.1"
#pip install "crepe<=0.0.12"
#pip install "mir_eval<=0.7"
#pip install "note_seq<0.0.4"
#pip install "hmmlearn<=0.2.7"
#pip install "pydub<=0.25.1"

# Install utility packages
#pip install "absl-py"
#pip install "apache-beam"
#pip install "cloudml-hypertune<=0.1.0.dev6"
#pip install "dill<=0.3.4"
#pip install "future"
#pip install "gin-config>=0.3.0"
#pip install "google-cloud-storage"
#pip install "six"
pip install crepe==0.0.12 --no-build-isolation --break-system-packages
# Install DDSP
pip install "tensorflow<=2.11"
pip install ddsp
pip install tensorflow-probability==0.19.0
pip install apache_beam==2.46.0 --break-system-packages
pip install protobuf==3.20.*  --break-system-packages

echo "=========================================="
echo "Setup complete!"
echo ""
echo "To activate this environment, run:"
echo "source \"$(conda info --base)/etc/profile.d/conda.sh\""
echo "    conda activate $ENV_NAME"
echo ""
echo "LD_LIBRARY_PATH will be set automatically on activation."
echo "=========================================="
