#!/bin/bash

#fslvar=$(dirname $(dirname $(which fsl)))

FSLDIR=/usr/local/fsl # fsl needs to be installed in /usr/local/bin and not moved to other folders
#FSLDIR=$(dirname $(dirname $(which fsl)))
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh


echo "ReStNeuMap is now running melodic and saving outputs in:"
pwd

CUR_PATH=$(pwd)
melodic -i ../lowpassfilteredAROMA.nii --report

