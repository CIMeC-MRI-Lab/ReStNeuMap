function [] = reorient_reslice_ReStNeuMapnetworks(currdir)

cwd = pwd;

if cwd ~= currdir
   msgLenFslDir = 'ReStNeuMap is not working in the correct directory.';
   close all
   error(msgLenFslDir);
end

filesT1=dir('s*T1.nii');
d.files=filesT1.name;
T1img=spm_vol(d.files);

% insert here relevant networks in your current folder
allnetworks = {'lang.nii' 'lang_25.nii' 'lang_30.nii' 'lang_35.nii' 'vis.nii' 'vis_25.nii' 'vis_30.nii' 'vis_35.nii'...
    'motor.nii' 'motor_25.nii' 'motor_30.nii' 'motor_35.nii' };

for net=1:length(allnetworks) 
    currnetwork = allnetworks{net};
%d.filenetv=strcat(currnetwork);
    d.filenetv = cellstr(currnetwork);
    matlabbatch = batch_job4d_final(d);

    try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI'); 
        spm_jobman('serial', matlabbatch);
    catch
        disp ('missing files')
    end

end
end
    
function [matlabbatch]=batch_job4d_final(d)

matlabbatch{1}.spm.spatial.coreg.write.ref = cellstr(d.files);
%matlabbatch{1}.spm.spatial.coreg.write.source = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{1}.spm.spatial.coreg.write.source = cellstr(d.filenetv);
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = './2T1w/2T1w_';
end