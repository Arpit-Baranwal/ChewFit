#!/bin/bash
#SBATCH --job-name=matlab_job
#SBATCH --partition=single
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=output.log

# Load the MATLAB module
module load  math/matlab/R2023a

# Run the MATLAB script
matlab -nodisplay -nosplash -r "run('dataset_generator.m'); exit;"

