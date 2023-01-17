# Environment setup:

⦁	Create the conda environment quot_env, and install quot following the instructions here: https://github.com/alecheckert/quot

⦁	Create a second conda environment called stardist_env, and install StarDist, saspt, and jupyter-lab:

`conda create -n stardist_env`

`pip install stardist`

`pip install saspt`

`conda install jupyterlab`

# Running the analysis:

Copy and scripts and set parameters:

⦁	Copy runTrackingAll.py and settings.toml to the folder containing your SMT data.  Adjust the settings in settings.toml as desired. Setting basefnames =  [""] in runTrackingAll.py will process all files in that directory.

⦁	Copy segment_all.py to the folder containing your snapshots. Setting basefnames =  [""] in the script will process all files in that directory.

⦁	Copy cellpicker.m, callCellPicker.m, placeholder.png, sort_and_saspt.ipynb, and traj_sorting.py to your experiment folder

At the command line:

⦁	Navigate to SMT folder and run tracking on SMT movies:

`conda activate quot_env`

`python runTrackingAll.py` (this requires file settings.toml)

⦁	Navigate to snapshots folder, and run StarDist segmentation on snapshot images to give nuclear masks:

`conda activate stardist_env`

`python segment_all.py`

In MATLAB: 

Navigate to experiment folder. Set basefname and range in script callCellPicker.m, and run the script to select good cells using the cellpicker function.

At the command line:

`conda activate stardist_env`

`jupyter-lab`

⦁	Copy and paste the link provided into a browser to run JupyterLab

⦁	In the Jupyter Lab browser window, open sort_and_saspt.ipynb.

⦁	Set maskmat to the name of the mat file exported by MATLAB in the previous step

⦁	Set csvfolder to the name of your SMT data folder containing tracked CSV files

⦁	Run the first two cells to classify and write out CSVs for all selected cells.

⦁	Run the 3rd and 4th cells to do SASPT analysis of all trajectories from selected cells. You can change the sample_size variable if desired to increase the maximum number of trajectories analyzed.


