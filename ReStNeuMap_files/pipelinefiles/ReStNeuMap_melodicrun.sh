#!/bin/bash

#fslvar=$(dirname $(dirname $(which fsl)))

FSLDIR=$(dirname $(dirname $(which fsl)))
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

echo "ReStNeuMap is now running melodic and saving outputs in:"
pwd

melodic -i vmasksm4D_mask.nii --report -d 10

melodic -i vmasksm4D_mask.nii --report -d 20

melodic -i vmasksm4D_mask.nii --report -d 30

melodic -i vmasksm4D_mask.nii --report

