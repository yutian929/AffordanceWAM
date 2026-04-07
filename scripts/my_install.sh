# FastWAM Dependencies
pip install omegaconf
pip install ninja -i https://pypi.org/simple/
pip install sapien
pip install mplib
pip install hydra-core


# LIBERO Dependencies
cd third_party/
git clone https://github.com/Lifelong-Robot-Learning/LIBERO.git
cd LIBERO/
pip install -r requirements.txt
pip install -e .
pip install mujoco==3.3.2
cd ../..


# RoboTwin Dependencies
## 1.Pytorch3d
cd third_party/
pip install -U pip setuptools wheel
git clone https://github.com/facebookresearch/pytorch3d.git
cd pytorch3d/
git checkout stable
pip install --no-build-isolation -e .
## 1.* code adjustment
echo "Adjusting code in sapien/wrapper/urdf_loader.py ..."
SAPIEN_LOCATION=$(pip show sapien | grep 'Location' | awk '{print $2}')/sapien
URDF_LOADER=$SAPIEN_LOCATION/wrapper/urdf_loader.py
sed -i -E 's/("r")(\))( as)/\1, encoding="utf-8") as/g' $URDF_LOADER
echo "Adjusting code in mplib/planner.py ..."
MPLIB_LOCATION=$(pip show mplib | grep 'Location' | awk '{print $2}')/mplib
PLANNER=$MPLIB_LOCATION/planner.py
sed -i -E 's/(if np.linalg.norm\(delta_twist\) < 1e-4 )(or collide )(or not within_joint_limit:)/\1\3/g' $PLANNER
## 2.Curobo
cd ../
git clone https://github.com/NVlabs/curobo.git
cd curobo/
pip install -e . --no-build-isolation
## 3.Link the fastwam_policy
ln -sfn "$(pwd)/experiments/robotwin/fastwam_policy" "$(pwd)/third_party/RoboTwin/policy/fastwam_policy"

exit 0


# Set the model path
ln -sfn /DATA/disk0/hs_25/AffordanceWAM/checkpoints checkpoints
ls -ld checkpoints
readlink -f checkpoints
export MODELSCOPE_CACHE=/DATA/disk0/hs_25/AffordanceWAM/modelscope_cache

export PYTHONPATH=/home/hs_25/WS/AffordanceWAM/third_party/LIBERO:$PYTHONPATH
python experiments/libero/run_libero_manager.py \
  task=libero_uncond_2cam224_1e-4 \
  ckpt=/DATA/disk0/hs_25/AffordanceWAM/checkpoints/fastwam_release/libero_uncond_2cam224.pt \
  EVALUATION.dataset_stats_path=/DATA/disk0/hs_25/AffordanceWAM/checkpoints/fastwam_release/libero_uncond_2cam224_dataset_stats.json \
  MULTIRUN.num_gpus=4 \
  MULTIRUN.max_tasks_per_gpu=1