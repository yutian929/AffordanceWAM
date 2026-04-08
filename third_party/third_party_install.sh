# At the root directory of FastWAM
cd third_party/

# LIBERO Dependencies
git clone https://github.com/Lifelong-Robot-Learning/LIBERO.git
cd LIBERO/
pip install -r requirements.txt
pip install -e .
pip install mujoco==3.3.2
cd ..

# RoboTwin Dependencies
## Pytorch3d
pip install -U pip setuptools wheel
git clone https://github.com/facebookresearch/pytorch3d.git
cd pytorch3d/
git checkout stable
pip install --no-build-isolation -e .
cd ..
## Curobo
git clone https://github.com/NVlabs/curobo.git
cd curobo/
pip install -e . --no-build-isolation
cd ..
## Link the fastwam_policy
git clone https://github.com/RoboTwin-Platform/RoboTwin.git
cd RoboTwin
pip install open3d
bash script/_download_assets.sh
cd ../..
ln -sfn "$(pwd)/experiments/robotwin/fastwam_policy" "$(pwd)/third_party/RoboTwin/policy/fastwam_policy"

exit 0


# Set the model path
# ln -sfn /DATA/disk0/hs_25/AffordanceWAM/checkpoints checkpoints
# ls -ld checkpoints
# readlink -f checkpoints
# export MODELSCOPE_CACHE=/DATA/disk0/hs_25/AffordanceWAM/modelscope_cache

# export PYTHONPATH=/home/hs_25/WS/AffordanceWAM/third_party/LIBERO:$PYTHONPATH
# python experiments/libero/run_libero_manager.py \
#   task=libero_uncond_2cam224_1e-4 \
#   ckpt=/DATA/disk0/hs_25/AffordanceWAM/checkpoints/fastwam_release/libero_uncond_2cam224.pt \
#   EVALUATION.dataset_stats_path=/DATA/disk0/hs_25/AffordanceWAM/checkpoints/fastwam_release/libero_uncond_2cam224_dataset_stats.json \
#   MULTIRUN.num_gpus=4 \
#   MULTIRUN.max_tasks_per_gpu=1