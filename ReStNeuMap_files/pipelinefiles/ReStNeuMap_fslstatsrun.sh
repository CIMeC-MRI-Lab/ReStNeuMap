#!/bin/bash

FSLDIR=$(dirname $(dirname $(which fsl)))
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

echo "ReStNeuMap is now extracting mean connectivity values (z-scores)"

fslstats lang_25.nii -M >> lang_mean_zscores.txt

fslstats lang_30.nii -M >> lang_mean_zscores.txt

fslstats lang_35.nii -M >> lang_mean_zscores.txt

fslstats motor_25.nii -M >> motor_mean_zscores.txt

fslstats motor_30.nii -M >> motor_mean_zscores.txt

fslstats motor_35.nii -M >> motor_mean_zscores.txt

fslstats vis_25.nii -M >> visual_mean_zscores.txt

fslstats vis_30.nii -M >> visual_mean_zscores.txt

fslstats vis_35.nii -M >> visual_mean_zscores.txt