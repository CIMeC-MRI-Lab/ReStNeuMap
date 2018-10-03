%script that warps the network templates
%(https://findlab.stanford.edu/functional_ROIs.html) back to the subject
%space. Here you need to edit lines 33-35 inserting the path where you will have
%stored the network templates. For simplicity we suggest to save them in
%the same folder where SPM brain tissue template are saved.
function [] = batch_finproc(atlasdir)%-----------------------------------------------------------------------
% Job saved on 14-Dec-2017 16:39:36 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% if exist('ProcessDir','dir') ~= 0
% 
% cd ('ProcessDir')    
b.datadir=pwd;
matlabbatch = batch_jobreg(b,atlasdir); %Lisa's fix
try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
end

end

function [matlabbatch]=batch_jobreg(b,atlasdir)%
disp(b.datadir)
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.dir = {'../'};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.filter = 'iy';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{2}.spm.util.defs.comp{1}.def(1) = cfg_dep('File Selector (Batch Mode): Selected Files (iy)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.util.defs.out{1}.pull.fnames = {
                                                   [atlasdir, '/Language.nii']
                                                   [atlasdir, '/Sensorimotor.nii']
                                                   [atlasdir, '/prim_Visual.nii']
                                                   };
matlabbatch{2}.spm.util.defs.out{1}.pull.savedir.savepwd = 1;
matlabbatch{2}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch{2}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{2}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.write.ref = {'vmasksm4D_mask.nii,1'};
matlabbatch{3}.spm.spatial.coreg.write.source = {
                                                 'wLanguage.nii,1'
                                                 'wSensorimotor.nii,1'
                                                 'wprim_Visual.nii,1'
                                                 };
matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';
end