#! /bin/sh

#fslvar=$(dirname $(dirname $(which fsl)))

#FSLDIR=$(dirname $(dirname $(which fsl)))
#PATH=${FSLDIR}/bin:${PATH}
#export FSLDIR PATH
#. ${FSLDIR}/etc/fslconf/fsl.sh

########### This script overlays network templates relevant slices to the T1 image, as well as the top 3 IC from CC values ###########

echo "ReStNeuMap is now overlaying network templates and saving outputs in:"
pwd

for IC in $(pwd); do

    # PRIM VISUAL
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Prim_Visual_2_T1.nii 0.1 1 Prim_Visual1.nii 0.1 10 top1Prim_Visual.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Prim_Visual_2_T1.nii 0.1 1 Prim_Visual2.nii 0.1 10 top2Prim_Visual.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Prim_Visual_2_T1.nii 0.1 1 Prim_Visual3.nii 0.1 10 top3Prim_Visual.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Prim_Visual_2_T1.nii 0.1 1 Prim_Visual_template.nii
    # MOTOR
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Sensorimotor_2_T1.nii 0.1 1 Sensorimotor1.nii 0.1 10 top1Sensorimotor.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Sensorimotor_2_T1.nii 0.1 1 Sensorimotor2.nii 0.1 10 top2Sensorimotor.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Sensorimotor_2_T1.nii 0.1 1 Sensorimotor3.nii 0.1 10 top3Sensorimotor.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Sensorimotor_2_T1.nii 0.1 1 Sensorimotor_template.nii
    # Language
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Language_2_T1.nii 0.1 1 Language1.nii 0.1 10 top1Language.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Language_2_T1.nii 0.1 1 Language2.nii 0.1 10 top2Language.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Language_2_T1.nii 0.1 1 Language3.nii 0.1 10 top3Language.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Language_2_T1.nii 0.1 1 Language_template.nii
    # Speech_Arrest
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Speech_Arrest_2_T1.nii 0.1 1 Speech_Arrest1.nii 0.1 10 top1Speech_Arrest.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Speech_Arrest_2_T1.nii 0.1 1 Speech_Arrest2.nii 0.1 10 top2Speech_Arrest.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Speech_Arrest_2_T1.nii 0.1 1 Speech_Arrest3.nii 0.1 10 top3Speech_Arrest.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Speech_Arrest_2_T1.nii 0.1 1 Speech_Arrest_template.nii
    # FPN
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a FPN_2_T1.nii 0.1 1 FPN1.nii 0.1 10 top1FPN.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a FPN_2_T1.nii 0.1 1 FPN2.nii 0.1 10 top2FPN.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a FPN_2_T1.nii 0.1 1 FPN3.nii 0.1 10 top3FPN.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a FPN_2_T1.nii 0.1 1 FPN_template.nii
    # DMN
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a DMN_2_T1.nii 0.1 1 DMN1.nii 0.1 10 top1DMN.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a DMN_2_T1.nii 0.1 1 DMN2.nii 0.1 10 top2DMN.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a DMN_2_T1.nii 0.1 1 DMN3.nii 0.1 10 top3DMN.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a DMN_2_T1.nii 0.1 1 DMN_template.nii
    # VSN
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Visuospatial_2_T1.nii 0.1 1 Visuospatial1.nii 0.1 10 top1Visuospatial.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Visuospatial_2_T1.nii 0.1 1 Visuospatial2.nii 0.1 10 top2Visuospatial.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Visuospatial_2_T1.nii 0.1 1 Visuospatial3.nii 0.1 10 top3Visuospatial.nii
    $FSLDIR/bin/overlay 1 0 skullstrippedT1.nii -a Visuospatial_2_T1.nii 0.1 1 Visuospatial_template.nii


    # visual
    $FSLDIR/bin/slicer top1Prim_Visual.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1Prim_Visual.png
    $FSLDIR/bin/slicer top2Prim_Visual.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2Prim_Visual.png
    $FSLDIR/bin/slicer top3Prim_Visual.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3Prim_Visual.png
    $FSLDIR/bin/slicer Prim_Visual_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 Prim_Visual_template.png
    # motor
    $FSLDIR/bin/slicer top1Sensorimotor.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1Sensorimotor.png
    $FSLDIR/bin/slicer top2Sensorimotor.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2Sensorimotor.png
    $FSLDIR/bin/slicer top3Sensorimotor.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3Sensorimotor.png
    $FSLDIR/bin/slicer Sensorimotor_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 Sensorimotor_template.png
    # language
    $FSLDIR/bin/slicer top1Language.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1Language.png
    $FSLDIR/bin/slicer top2Language.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2Language.png
    $FSLDIR/bin/slicer top3Language.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3Language.png
    $FSLDIR/bin/slicer Language_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 Language_template.png
    # Speech_Arrest
    $FSLDIR/bin/slicer top1Speech_Arrest.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1Speech_Arrest.png
    $FSLDIR/bin/slicer top2Speech_Arrest.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2Speech_Arrest.png
    $FSLDIR/bin/slicer top3Speech_Arrest.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3Speech_Arrest.png
    $FSLDIR/bin/slicer Speech_Arrest_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 Speech_Arrest_template.png
    # leftfpn
    $FSLDIR/bin/slicer top1FPN.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1FPN.png
    $FSLDIR/bin/slicer top2FPN.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2FPN.png
    $FSLDIR/bin/slicer top3FPN.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3FPN.png
    $FSLDIR/bin/slicer FPN_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 FPN_template.png
    # DMN
    $FSLDIR/bin/slicer top1DMN.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1DMN.png
    $FSLDIR/bin/slicer top2DMN.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2DMN.png
    $FSLDIR/bin/slicer top3DMN.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3DMN.png
    $FSLDIR/bin/slicer DMN_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 DMN_template.png
    # VSN
    $FSLDIR/bin/slicer top1Visuospatial.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top1Visuospatial.png
    $FSLDIR/bin/slicer top2Visuospatial.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top2Visuospatial.png
    $FSLDIR/bin/slicer top3Visuospatial.nii.gz -t -n -u -l ./gt_rc_DG.lut -S 4 6000 top3Visuospatial.png
    $FSLDIR/bin/slicer Visuospatial_template.nii.gz -t -n -L -l ./gt_rc_DG_template.lut -S 4 6000 Visuospatial_template.png
done
