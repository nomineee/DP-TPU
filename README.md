# DP-TPU
This is the code for Digital-Twin-Driven Unambiguous Structured Light 3D Imaging with Physics-Aware Learning.

## Blender environment

This code was tested in Blender 4.0.
Since we used the function "Scriping" in Blender, a Python environment is needed.
Run the following command to create the conda environment.
```
comda create -- name DP-TPU python=3.10 -y
conda activate DP-TPU
pip install numpy
conda env create -f environment.yml
```
After that, you need to link this environment to Blender. You can refer to [How to install Python packages for Blender (Pandas)](https://www.youtube.com/watch?v=gyRoY9QUNg0) for a detailed opration.

