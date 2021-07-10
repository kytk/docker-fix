#!/bin/bash

# A script to run individual Melodic and FIX
# (ROBEX is used for skull-stripping)
# Please set the configuration below first

# Requirement
# This script assumes that the filenmae of 3D-T1 images starts with V_
# and the filename of rs-fMRI images starts with F_
#
# e.g. V_0001.nii.gz and F_0001.nii.gz 

# Usage
# copy this file to your working directory and run the script.
# You need to specify rs-fMRI files as arguments.
#
# e.g.
# $ cp /usr/local/bin/individual_fix.sh .
# $ ./individual_fix.sh F_*.nii.gz

# 10 Jul 2021 K.Nemoto

###Configuration#######################################

#Set FWHM
fwhm=5

#Set the number of volumes to be deleted (dummy volume)
delvol=4

#Slice timing correction
# 0 : None
# 1 : Regular up (0, 1, 2, 3, ...)
# 2 : Regular down
# 3 : Use slice order file
# 4 : Use slice timings file
# 5 : Interleaved (0, 2, 4 ... 1, 3, 5 ... )
st=1
######################################################

#Return error with no arguments
if [ $# -lt 1 ] ; then
        echo "Error! No file is specified!"
        echo "Usage: $0 F_ID.nii.gz"
fi


for f in "$@"
do

  #Check if the file name is correct
  if [ `echo $f | cut -c 1,2` != "F_" ] ; then
         echo "Error! File name is incorrect. Please specify fMRI files!"
         echo "Filename should begin with F_"
         echo "example: F_subj01.nii.gz"
         exit 1
  fi

  #Define variable func_orig and struct_orig
  func_orig=$(imglob $f)
  struct_orig=$(echo ${func_orig} | sed 's/F/V/')

  #Check if structural image exists
  if [ ! -e "${struct_orig}.nii.gz" ]; then
          echo "cannot identify structural image."
          echo "Structural image must be V_ID."
          exit 1
  fi

  #Set the orientation of structural image to axial
  fslreorient2std ${struct_orig} ${struct_orig}_std 
  struct=${struct_orig}_std
          
  #Skull stripping T1 image using ROBEX
  echo "Skull stripping ${struct} using ROBEX"
  /usr/local/ROBEX/runROBEX.sh $struct ${struct}_brain.nii.gz


  ##Image Parameters###################################
  #TR
  tr=$(fslval $f pixdim4)
  
  #Total volumes
  npts=$(fslval $f dim4)
  
  #Total voxles
  totalVoxels=$(fslstats $f -v | awk '{ print $1 }')
  
  #Feat files
  feat_files=$(imglob ${PWD}/$f)
  
  #Highres files
  highres_files=$(echo ${PWD}/${struct}_brain)
  #####################################################
  
  
cat << EOS > design_${func_orig}.fsf
set fmri(version) 3.15
set fmri(inmelodic) 1
set fmri(level) 1
set fmri(analysis) 7
set fmri(relative_yn) 0
set fmri(help_yn) 1
set fmri(featwatcher_yn) 1
set fmri(sscleanup_yn) 0
set fmri(outputdir) ""
# TR(s)
#set fmri(tr) 2.500000 
set fmri(tr) ${tr}
# Total volumes
#set fmri(npts) 244
set fmri(npts) ${npts}
# Delete volumes
#set fmri(ndelete) 4
set fmri(ndelete) ${delvol}
set fmri(tagfirst) 1
set fmri(multiple) 1
set fmri(inputtype) 2
set fmri(filtering_yn) 1
set fmri(brain_thresh) 10
set fmri(critical_z) 5.3
set fmri(noise) 0.66
set fmri(noisear) 0.34
set fmri(mc) 1
set fmri(sh_yn) 0
set fmri(regunwarp_yn) 0
set fmri(gdc) ""
set fmri(dwell) 0.0
set fmri(te) 0.0
set fmri(signallossthresh) 10
set fmri(unwarp_dir) y-
set fmri(st) ${st}
set fmri(st_file) ""
set fmri(bet_yn) 1
# Spatial smoothing FWHM (mm)
#set fmri(smooth) 5
set fmri(smooth) ${fwhm}
set fmri(norm_yn) 0
set fmri(perfsub_yn) 0
set fmri(temphp_yn) 1
set fmri(templp_yn) 0
set fmri(melodic_yn) 0
set fmri(stats_yn) 1
set fmri(prewhiten_yn) 1
set fmri(motionevs) 0
set fmri(motionevsbeta) ""
set fmri(scriptevsbeta) ""
set fmri(robust_yn) 0
set fmri(mixed_yn) 2
set fmri(randomisePermutations) 5000
set fmri(evs_orig) 1
set fmri(evs_real) 1
set fmri(evs_vox) 0
set fmri(ncon_orig) 1
set fmri(ncon_real) 1
set fmri(nftests_orig) 0
set fmri(nftests_real) 0
set fmri(constcol) 0
set fmri(poststats_yn) 1
set fmri(threshmask) ""
set fmri(thresh) 3
set fmri(prob_thresh) 0.05
set fmri(z_thresh) 3.1
set fmri(zdisplay) 0
set fmri(zmin) 2
set fmri(zmax) 8
set fmri(rendertype) 1
set fmri(bgimage) 1
set fmri(tsplot_yn) 1
set fmri(reginitial_highres_yn) 0
set fmri(reginitial_highres_search) 90
set fmri(reginitial_highres_dof) 3
set fmri(reghighres_yn) 1
set fmri(reghighres_search) 90
set fmri(reghighres_dof) BBR
set fmri(regstandard_yn) 1
set fmri(alternateReference_yn) 0
set fmri(regstandard) "/usr/local/fsl/data/standard/MNI152_T1_2mm_brain"
set fmri(regstandard_search) 90
set fmri(regstandard_dof) 12
set fmri(regstandard_nonlinear_yn) 0
set fmri(regstandard_nonlinear_warpres) 10
set fmri(paradigm_hp) 100
# Total voxels
set fmri(totalVoxels) 39976960
set fmri(ncopeinputs) 0
# 4D AVW data or FEAT directory (1)
set feat_files(1) "${feat_files}"
set fmri(confoundevs) 0
set highres_files(1) "${highres_files}"
set fmri(regstandard_res) 4
set fmri(varnorm) 1
set fmri(dim_yn) 1
set fmri(dim) 1
set fmri(icaopt) 1
set fmri(thresh_yn) 1
set fmri(mmthresh) 0.5
set fmri(ostats) 0
set fmri(ts_model_mat) ""
set fmri(ts_model_con) ""
set fmri(subject_model_mat) ""
set fmri(subject_model_con) ""
set fmri(alternative_mask) ""
set fmri(init_initial_highres) ""
set fmri(init_highres) ""
set fmri(init_standard) ""
set fmri(overwrite_yn) 0
EOS

  # Melodic preprocessing
  feat design_${func_orig}.fsf

  # FIX
  fix ${func_orig}.ica /usr/local/fix/training_files/Standard.RData 20 -m

done

exit


