%%%%%% This script performs brain extraction via spm function
%processDir=what('ProcessDir');
%processDir=processDir.path;
c1Struct = dir(fullfile('c1*.nii'));
c1 = strcat(c1Struct.folder, filesep, c1Struct.name,',1');
c2Struct = dir(fullfile('c2*.nii'));
c2 = fullfile(c2Struct.folder, filesep, c2Struct.name);
T1dir = dir(fullfile(processDir, filesep, 's*T1.nii'));
T1 = fullfile(T1dir.folder, filesep, T1dir.name);

matlabbatch = jobpreprocskullstrip(c1,c2,T1);
try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
end

outputPath=what('skullstrippedT1.nii');
movefile('skullstrippedT1.nii', processDir);


function [matlabbatch] = jobpreprocskullstrip(c1,c2,T1)
tic
matlabbatch{1}.spm.util.imcalc.input = {c1
                                        c2
                                        T1
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'skullstrippedT1';
matlabbatch{1}.spm.util.imcalc.outdir = {pwd};
matlabbatch{1}.spm.util.imcalc.expression = '[i3.*(i1 +i2)]';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 0;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
end

