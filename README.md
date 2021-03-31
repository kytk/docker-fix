# docker-fix

- A container for FSL-FIX


## How to use this container

- cd to the working directory in which you have fMRI and T1 data

- Pull the image and mount working directory as /home/brain in the container

```
docker run -it --rm -u brain -v $PWD:/home/brain docker-fix:latest
```

- Run the "individual-fix.sh" script

    - This script assumes that the filename of fMRI data starts with F_, and T1 data starts with V_ and shares the same ID. e.g. F_subj1.nii.gz and V_subj1.nii.gz

```
cd # cd to /home/brain
individual-fix.sh F_*.nii.gz
```

- Then the scripts run MELODIC for fMRI data and FIX after that with default parameter (Stardard.R 20 -m).
   - The result data would be "filtered_func_data_clean.nii.gz" under *.ica


