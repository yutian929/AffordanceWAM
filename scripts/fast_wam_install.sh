# At the root directory of FastWAM

# FastWAM Dependencies
pip install torch==2.7.1+cu128 torchvision==0.22.1+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install omegaconf
pip install ninja -i https://pypi.org/simple/
pip install sapien
pip install mplib
pip install hydra-core
pip install -U huggingface_hub
export HF_ENDPOINT=https://hf-mirror.com
pip install httpx[socks]
pip install -e .

# Code adjustment
echo "Adjusting code in sapien/wrapper/urdf_loader.py ..."
SAPIEN_LOCATION=$(pip show sapien | grep 'Location' | awk '{print $2}')/sapien
URDF_LOADER=$SAPIEN_LOCATION/wrapper/urdf_loader.py
sed -i -E 's/("r")(\))( as)/\1, encoding="utf-8") as/g' $URDF_LOADER
echo "Adjusting code in mplib/planner.py ..."
MPLIB_LOCATION=$(pip show mplib | grep 'Location' | awk '{print $2}')/mplib
PLANNER=$MPLIB_LOCATION/planner.py
sed -i -E 's/(if np.linalg.norm\(delta_twist\) < 1e-4 )(or collide )(or not within_joint_limit:)/\1\3/g' $PLANNER

# Model Preparation
hf auth login
hf auth whoami
## Wan-AI & DiffSynth-Studio
mkdir -p checkpoints
export DIFFSYNTH_MODEL_BASE_PATH="$(pwd)/checkpoints"
python scripts/preprocess_action_dit_backbone.py \
  --model-config configs/model/fastwam.yaml \
  --output checkpoints/ActionDiT_linear_interp_Wan22_alphascale_1024hdim.pt \
  --device cuda \
  --dtype bfloat16
## libero & robotwin uncond fastwam-release
hf download yuanty/fastwam \
  libero_uncond_2cam224.pt \
  libero_uncond_2cam224_dataset_stats.json \
  robotwin_uncond_3cam_384.pt \
  robotwin_uncond_3cam_384_dataset_stats.json \
  --local-dir ./checkpoints/fastwam_release

# Data Preparation
## libero
mkdir -p data/libero_mujoco3.3.2
hf download yuanty/LIBERO-fastwam --include "*.tar.gz" --repo-type dataset --local-dir data/libero_mujoco3.3.2
cd data/libero_mujoco3.3.2
for f in *.tar.gz; do
  tar -xzf "$f"
done  
cd ../..
## robotwin
mkdir -p data/robotwin2.0
hf download yuanty/robotwin2.0-fastwam --repo-type dataset --local-dir data/robotwin2.0
cd data/robotwin2.0
cat robotwin2.0.tar.gz.part-* | tar -xzf -
cd ../..
exit 0