#!/bin/bash
# ==========================================================================
# DDSP Export Fixes
# ==========================================================================
# Apply all necessary patches to the DDSP library before running export.
# Run this ONCE before your first export. It is idempotent (safe to re-run).
#
# Fixes applied:
#   1. Add missing gin macros (frame_size, sample_rate, frame_rate) to
#      operative config — ddsp_export queries these but training doesn't
#      write them as macros.
#   2. Fix off-by-one array mismatch in postprocessing.py get_stats() —
#      power array and boolean mask can differ by 1 frame.
#   3. Fix input key mismatch (pw_scaled -> ld_scaled) in inference.py —
#      VST export passes 'pw_scaled' but decoder expects 'ld_scaled'.
#
# Usage:
#   chmod +x ddsp_fix.sh
#   ./ddsp_fix.sh
# ==========================================================================

set -e

# --- Configuration (edit these) -------------------------------------------
CONDA_ENV="ddsp_env"
MODEL_PATH="models/ddsp-solo-instrument"
OPERATIVE_CONFIG="${MODEL_PATH}/operative_config-0.gin"

# Derived from training config: n_samples / time_steps = 64000 / 1000
FRAME_SIZE=64
SAMPLE_RATE=16000
FRAME_RATE=250

# DDSP library location inside the conda env
DDSP_LIB="/usr/local/envs/${CONDA_ENV}/lib/python3.10/site-packages/ddsp/training"
# --------------------------------------------------------------------------

echo "=========================================="
echo "DDSP Export Fixes"
echo "=========================================="

# --- Fix 1: Add missing gin macros to operative config --------------------
echo "[1/3] Patching operative config with gin macros..."

if ! grep -q "^frame_size" "${OPERATIVE_CONFIG}"; then
    echo "" >> "${OPERATIVE_CONFIG}"
    echo "frame_size = ${FRAME_SIZE}" >> "${OPERATIVE_CONFIG}"
    echo "  Added: frame_size = ${FRAME_SIZE}"
else
    echo "  Already present: frame_size (skipping)"
fi

if ! grep -q "^sample_rate" "${OPERATIVE_CONFIG}"; then
    echo "sample_rate = ${SAMPLE_RATE}" >> "${OPERATIVE_CONFIG}"
    echo "  Added: sample_rate = ${SAMPLE_RATE}"
else
    echo "  Already present: sample_rate (skipping)"
fi

if ! grep -q "^frame_rate" "${OPERATIVE_CONFIG}"; then
    echo "frame_rate = ${FRAME_RATE}" >> "${OPERATIVE_CONFIG}"
    echo "  Added: frame_rate = ${FRAME_RATE}"
else
    echo "  Already present: frame_rate (skipping)"
fi

# --- Fix 2: Patch postprocessing.py (off-by-one in get_stats) -------------
echo "[2/3] Patching postprocessing.py (array dimension mismatch)..."
POSTPROC="${DDSP_LIB}/postprocessing.py"

if grep -q "min_len = min(len(x_i), len(m))" "${POSTPROC}"; then
    echo "  Already patched (skipping)"
else
    cp "${POSTPROC}" "${POSTPROC}.bak"

    python3 - "${POSTPROC}" << 'PYEOF'
import sys

filepath = sys.argv[1]
with open(filepath, 'r') as f:
    content = f.read()

# Fix boolean index mismatch in get_stats zip loops
old = "max_list.append(np.max(x_i[m]))"
new = "min_len = min(len(x_i), len(m)); max_list.append(np.max(x_i[:min_len][m[:min_len]]))"
content = content.replace(old, new)

old = "min_list.append(np.min(x_i[m]))"
new = "min_len = min(len(x_i), len(m)); min_list.append(np.min(x_i[:min_len][m[:min_len]]))"
content = content.replace(old, new)

old = "mean_list.append(np.mean(x_i[m]))"
new = "min_len = min(len(x_i), len(m)); mean_list.append(np.mean(x_i[:min_len][m[:min_len]]))"
content = content.replace(old, new)

# Fix x = x[note_mask] at end of else block
old = "      x = x[note_mask]"
new = "      min_len = min(x.shape[-1], note_mask.shape[-1])\n      x = x[:, :min_len][note_mask[:, :min_len]]"
content = content.replace(old, new)

with open(filepath, 'w') as f:
    f.write(content)

print("  Patched postprocessing.py successfully")
PYEOF
fi

# --- Fix 3: Patch inference.py (pw_scaled -> ld_scaled) -------------------
echo "[3/3] Patching inference.py (pw_scaled -> ld_scaled)..."
INFERENCE="${DDSP_LIB}/inference.py"

if grep -q "'pw_scaled'" "${INFERENCE}"; then
    cp "${INFERENCE}" "${INFERENCE}.bak"
    sed -i "s/'pw_scaled'/'ld_scaled'/g" "${INFERENCE}"
    echo "  Patched inference.py: pw_scaled -> ld_scaled"
else
    echo "  Already patched (skipping)"
fi

echo "=========================================="
echo "All fixes applied!"
echo "You can now run your export script."
echo "=========================================="
