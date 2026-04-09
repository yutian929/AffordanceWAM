``` bash
export PYTHONPATH=/data0/yutian/AffordanceWAM/third_party/LIBERO:$PYTHONPATH
export MUJOCO_GL=egl
export PYOPENGL_PLATFORM=egl
python experiments/libero/run_libero_manager.py \
  task=libero_uncond_2cam224_1e-4 \
  ckpt=./checkpoints/fastwam_release/libero_uncond_2cam224.pt \
  EVALUATION.dataset_stats_path=./checkpoints/fastwam_release/libero_uncond_2cam224_dataset_stats.json \
  MULTIRUN.num_gpus=2 \
  MULTIRUN.max_tasks_per_gpu=1
```
```bash
python experiments/robotwin/run_robotwin_manager.py \
  task=robotwin_uncond_3cam_384_1e-4 \
  ckpt=./checkpoints/fastwam_release/robotwin_uncond_3cam_384.pt \
  EVALUATION.dataset_stats_path=./checkpoints/fastwam_release/robotwin_uncond_3cam_384_dataset_stats.json \
  MULTIRUN.num_gpus=1 \
  MULTIRUN.max_tasks_per_gpu=1
```
