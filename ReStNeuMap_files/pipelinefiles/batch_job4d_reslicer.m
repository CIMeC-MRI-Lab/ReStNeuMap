function [matlabbatch]=batch_job4d_reslicer(d)

matlabbatch{1}.spm.spatial.coreg.write.ref = {d.files};
matlabbatch{1}.spm.spatial.coreg.write.source = {d.filenetv};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = './T1w_res/T1w_';
end