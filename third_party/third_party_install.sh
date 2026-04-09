# At the root directory of FastWAM
cd third_party/

# LIBERO Dependencies
git clone https://github.com/Lifelong-Robot-Learning/LIBERO.git
cd LIBERO/
pip install -r requirements.txt
pip install -e .
pip install mujoco==3.3.2
## Compatibility patch for PyTorch>=2.6: LIBERO init-state files require torch.load(..., weights_only=False).
python - <<'PY'
from pathlib import Path

target = Path("libero/libero/benchmark/__init__.py")
src = target.read_text()
old = "init_states = torch.load(init_states_path)"
new = "init_states = torch.load(init_states_path, weights_only=False)"

if new in src:
    print("LIBERO torch.load patch already applied.")
elif old in src:
    target.write_text(src.replace(old, new, 1))
    print("Applied LIBERO torch.load compatibility patch.")
else:
    raise RuntimeError("Expected torch.load line not found in LIBERO benchmark init.")
PY
cd ..

# RoboTwin Dependencies
sudo apt install libvulkan1 mesa-vulkan-drivers vulkan-tools
## Pytorch3d
pip install -U pip setuptools wheel
git clone https://github.com/facebookresearch/pytorch3d.git
cd pytorch3d/
git checkout stable
pip install -e . --no-build-isolation -i https://pypi.tuna.tsinghua.edu.cn/simple
cd ..
## Curobo
git clone https://github.com/NVlabs/curobo.git
cd curobo/
pip install -e . --no-build-isolation -i https://pypi.tuna.tsinghua.edu.cn/simple
cd ..
## RoboTwin Requirements
git clone https://github.com/RoboTwin-Platform/RoboTwin.git
cd RoboTwin
bash script/_install.sh
# `sapien==3.0.0b1` imports `pkg_resources`, which is removed in newer setuptools.
# Keep setuptools in a compatible range for RoboTwin.
pip install "setuptools<81" -i https://pypi.tuna.tsinghua.edu.cn/simple
bash script/_download_assets.sh
## Code adjustment
echo "Adjusting code in sapien/wrapper/urdf_loader.py ..."
SAPIEN_LOCATION=$(pip show sapien | grep 'Location' | awk '{print $2}')/sapien
URDF_LOADER=$SAPIEN_LOCATION/wrapper/urdf_loader.py
sed -i -E 's/("r")(\))( as)/\1, encoding="utf-8") as/g' $URDF_LOADER
echo "Adjusting code in mplib/planner.py ..."
MPLIB_LOCATION=$(pip show mplib | grep 'Location' | awk '{print $2}')/mplib
PLANNER=$MPLIB_LOCATION/planner.py
sed -i -E 's/(if np.linalg.norm\(delta_twist\) < 1e-4 )(or collide )(or not within_joint_limit:)/\1\3/g' $PLANNER
## Link the fastwam_policy
cd ../..
ln -sfn "$(pwd)/experiments/robotwin/fastwam_policy" "$(pwd)/third_party/RoboTwin/policy/fastwam_policy"