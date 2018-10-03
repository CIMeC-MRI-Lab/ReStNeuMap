%-----------------------------------------------------------------------
% Job saved on 14-Dec-2017 16:46:49 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\4D.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {'\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_T1.nii,1'};
%%
matlabbatch{1}.spm.spatial.coreg.estimate.other = {
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Anomia_1.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Anomia_2.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Complex_Motor_Contraction_1.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Complex_Motor_Contraction_2.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Motor_1.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Motor_2.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Negative_Motor_1.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Semantic_1.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Semantic_2.nii,1'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_C_Speech_Arrest_1.nii,1'
                                                   };
%%
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.preproc.channel.vols = {'\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sanfilippo_Brigitte_T1.nii,1'};
matlabbatch{2}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{2}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{2}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(1).tpm = {'C:\Users\domenico.zaca\Documents\MATLAB\spm12\tpm\TPM.nii,1'};
matlabbatch{2}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{2}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(2).tpm = {'C:\Users\domenico.zaca\Documents\MATLAB\spm12\tpm\TPM.nii,2'};
matlabbatch{2}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{2}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(3).tpm = {'C:\Users\domenico.zaca\Documents\MATLAB\spm12\tpm\TPM.nii,3'};
matlabbatch{2}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{2}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(4).tpm = {'C:\Users\domenico.zaca\Documents\MATLAB\spm12\tpm\TPM.nii,4'};
matlabbatch{2}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{2}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(5).tpm = {'C:\Users\domenico.zaca\Documents\MATLAB\spm12\tpm\TPM.nii,5'};
matlabbatch{2}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{2}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(6).tpm = {'C:\Users\domenico.zaca\Documents\MATLAB\spm12\tpm\TPM.nii,6'};
matlabbatch{2}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{2}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{2}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{2}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{2}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{2}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{2}.spm.spatial.preproc.warp.write = [1 1];
matlabbatch{3}.spm.util.defs.comp{1}.def(1) = cfg_dep('Segment: Inverse Deformations', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','invdef', '()',{':'}));
matlabbatch{3}.spm.util.defs.out{1}.pull.fnames = {
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Language.nii'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\Sensorimotor.nii'
                                                   '\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\prim_Visual.nii'
                                                   };
matlabbatch{3}.spm.util.defs.out{1}.pull.savedir.savepwd = 1;
matlabbatch{3}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch{3}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{3}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{4}.spm.spatial.coreg.write.ref = {'\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\vmasksm4D_mask.nii,1'};
matlabbatch{4}.spm.spatial.coreg.write.source(1) = cfg_dep('Deformations: Warped Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','warped'));
matlabbatch{4}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{4}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{4}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{4}.spm.spatial.coreg.write.roptions.prefix = 'r';
