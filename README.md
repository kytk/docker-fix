# docker-fix

- A container for FSL-FIX


## How to use this container

- cd to the working directory in which you have fMRI and T1 data

- Pull the image and mount working directory as /home/brain in the container

```
docker run -it --rm -v $PWD:/home/brain kytk/docker-fix:latest
```

- Option 1: Run the "individual-fix_func_t1w.sh"

    - You specify functional and sturctural images individually.

```
cd # cd to /home/brain
cp /usr/local/bin/individual-fix_func_t1w.sh .
(edit the script)
./individual-fix_func_t1w.sh <func.nii.gz> <struct.nii.gz>
```

- Option 2: Run the "individual-fix.sh" script

    - This script assumes that the filename of fMRI data starts with F_, and T1 data starts with V_ and shares the same ID. e.g. F_subj1.nii.gz and V_subj1.nii.gz

```
cd # cd to /home/brain
individual-fix.sh F_*.nii.gz
```

- Then the script runs MELODIC for fMRI data and FIX after that with default parameter (Stardard.R 20 -m).
   - The result data would be "filtered_func_data_clean.nii.gz" under *.ica


