feat ICAsetting.fsf
feat ICAsetting10.fsf
feat ICAsetting20.fsf
feat ICAsetting30.fsf


flirt -in sm4D_mask.ica/filtered_func_data.ica/melodic_IC -applyxfm -init boldtoMNI.mat -out melodic_IC_MNIfree.nii -paddingsize 0.0 -interp trilinear -ref /mnt/storage/tier2/MUMI/Domenico_Zaca/clinicalRSdata/september15analysis_scripts/DataperAbstracrt/MNI152_T1_2mm.nii.gz

flirt -in sm4D_mask+.ica/filtered_func_data.ica/melodic_IC -applyxfm -init boldtoMNI.mat -out melodic_IC_MNI10.nii -paddingsize 0.0 -interp trilinear -ref /mnt/storage/tier2/MUMI/Domenico_Zaca/clinicalRSdata/september15analysis_scripts/DataperAbstracrt/MNI152_T1_2mm.nii.gz

flirt -in sm4D_mask++.ica/filtered_func_data.ica/melodic_IC -applyxfm -init boldtoMNI.mat -out melodic_IC_MNI20.nii -paddingsize 0.0 -interp trilinear -ref /mnt/storage/tier2/MUMI/Domenico_Zaca/clinicalRSdata/september15analysis_scripts/DataperAbstracrt/MNI152_T1_2mm.nii.gz


flirt -in sm4D_mask+++.ica/filtered_func_data.ica/melodic_IC -applyxfm -init boldtoMNI.mat -out melodic_IC_MNI30.nii -paddingsize 0.0 -interp trilinear -ref /mnt/storage/tier2/MUMI/Domenico_Zaca/clinicalRSdata/september15analysis_scripts/DataperAbstracrt/MNI152_T1_2mm.nii.gz

