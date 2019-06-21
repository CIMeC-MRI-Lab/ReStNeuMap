    function [exitstatus] = ReStNeuMap_PreProc_main(input1, input2)
clearvars -except input1 input2
%clear all;
nullmessage = '(no folder selected)';


[statusHome, pathHome] = system('echo $HOME');
pathHome = strrep(pathHome, sprintf('\n'),'');
if ismac()
    if exist([pathHome,'/.bash_profile']) == 2
        [code, outFslDir] = system('cat $HOME/.bash_profile | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    elseif exist([pathHome,'/.profile']) == 2
        [code, outFslDir] = system('cat $HOME/.profile | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    elseif exist([pathHome,'/.bashrc']) == 2
        [code, outFslDir] = system('cat $HOME/.bashrc | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    else
        msgOutFslDir = 'ReStNeuMap can''t find your bash profile.';
        close all
        error(msgOutFslDir)
    end
    if length(outFslDir) == 0 && exist([pathHome,'/.bashrc']) == 2 && exist([pathHome,'/.profile']) == 2
        [code, outFslDir] = system('cat $HOME/.bashrc | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    end
    if length(outFslDir) == 0 && exist([pathHome,'/.bashrc']) == 2 && exist([pathHome,'/.bash_profile']) == 2
        [code, outFslDir] = system('cat $HOME/.bashrc | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    end
    
end
if ~ismac()
    if exist([pathHome,'/.bashrc']) == 2
        [code, outFslDir] = system('cat $HOME/.bashrc | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    elseif exist([pathHome,'/.bash_profile']) == 2
        [code, outFslDir] = system('cat $HOME/.bash_profile | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    elseif exist([pathHome,'/.profile']) == 2
        [code, outFslDir] = system('cat $HOME/.profile | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    else
        msgOutFslDir = 'ReStNeuMap can''t find your bash profile.';
        close all
        error(msgOutFslDir)
    end
    if length(outFslDir) == 0 && exist([pathHome,'/.bashrc']) == 2 && exist([pathHome,'/.profile']) == 2
        [code, outFslDir] = system('cat $HOME/.profile | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    end
    if length(outFslDir) == 0 && exist([pathHome,'/.bashrc']) == 2 && exist([pathHome,'/.bash_profile']) == 2
        [code, outFslDir] = system('cat $HOME/.bash_profile | grep FSLDIR | grep -v export | grep -v PATH | grep -v etc | tail -1');
        outFslDir = strrep(outFslDir, sprintf('\n'),'');
    end
    
end

if length(outFslDir) == 0
   msgLenFslDir = 'ReStNeuMap can''t find FSLDIR in your bash profile file. Please check your FSL installation.';
   close all
   error(msgLenFslDir);
end
if outFslDir(end) == '/'
     outFslDir = outFslDir(1:end-1);
end
[outFslDirPath folderName] = fileparts(outFslDir);
outFslDir = strtok(outFslDir,'FSLDIR=');
if folderName == 'FSL'
    outFslDir = [outFslDir folderName];
end
setenv( 'FSLDIR', outFslDir);
fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;

current_path = getenv('PATH');
new_path = [current_path,pathsep,outFslDir,'/bin'];
setenv('PATH',new_path)

spmWhPath = what('spm12');
spmdir = spmWhPath.path;
NetworkTemplatesWhPath = what('ReStNeuMapNetworkTemplates');
atldir = NetworkTemplatesWhPath.path;
%%%%%%%%%%%%%%%%%%%


%throw error if there is a missing folder
if isequal(input1,nullmessage) || isequal(input2,nullmessage)
    msgfoldersel = 'not all folders selected!';
    error(msgfoldersel)
    close all
end

fwaitb = waitbar(0,'ReStNeuMap is processing your data. Please wait...');
null_ai = 'no anatomical images folder selected!';
null_rs = 'no resting-state images folder selected!';
c.anatdatadir = input1
c.datadir = input2
%spmdir = input3
%atldir = input4
%clear input3

if isequal(c.anatdatadir,nullmessage) | isequal(c.datadir,nullmessage) | isequal(c.anatdatadir,null_ai) | isequal(c.datadir,null_rs)
    close all
    error('not all folders selected')
end

if isequal(c.anatdatadir,0) | isequal(c.datadir,0)
    close all
    error('not all folders selected')
end


clear null_message
clear null_ai
clear null_rs

pause(10)


cd (c.anatdatadir)

%dcm to nii conversion anatomical images
matlabbatch = batch_joban(c);
try
    spm_jobman('initcfg')
    spm('defaults', 'FMRI');
    spm_jobman('serial', matlabbatch);
end

waitbar(0.1,fwaitb);
b.datadir=c.datadir;
cd (b.datadir)

%dcm to nii conversion functional images
matlabbatch = batch_job(b);

try
    spm_jobman('initcfg')
    spm('defaults', 'FMRI');
    spm_jobman('serial', matlabbatch);
end

waitbar(0.15,fwaitb);

%step to separate the raw DICOM data from all the preprocessed generated
%files moving them in a subfolder
dirlist=dir;
dirlist(1:2)=[];
dirFlags = ~[dirlist.isdir];
files=dirlist(dirFlags);
    
if exist('rawdata','dir') == 0
    mkdir 'rawdata'
end

for i=1:size(files,1)
    if isempty(strfind(files(i,1).name,'.nii'))==1 && isempty(strfind(files(i,1).name,'.mat'))==1
        movefile(files(i,1).name,'rawdata');
    end
end

%Affine T1 coregistration with EPI first volume. Brain tissue segmentation and
%resampling of brain tissue maps to functional images voxel size
%filesT1=dir('*t1mprage*');
filesT1=dir('s*T1.nii');
d.files=filesT1.name;
%files_epi=dir('*lnifepi*');
files_epi=dir('4D.nii');
d.files1=files_epi.name;
matlabbatch = batch_job4d(d,spmdir); %Lisa's fix
try
    spm_jobman('initcfg')
    spm('defaults', 'FMRI'); 
    spm_jobman('serial', matlabbatch);
end

waitbar(0.2,fwaitb);
if exist('ProcessDir','dir') == 0
    mkdir 'ProcessDir'
elseif exist('ProcessDir','dir') == 7
    msgProcessDirCreat = ['A duplicate instance of the ProcessDir folder has', ...
    ' been detected. \n A possible reason for this is that ReStNeuMap''s ' ...
    'Sample_output folder \n is in your matlab path (e.g. instead of adding ' ...
    'to path the ReStNeuMap_files folder, \n you added to path with subfolders the '...
    'ReStNeuMap_v0.1.1 folder: \n by doing so you included the ProcessDir folder '...
    'within the Sample_output one). \n \n Please remove from path other instances of '...
    'ProcessDir and \n remove all files generated so far by ReStNeuMap. \n '...
    'In other words, please return to the initial file structure \n before '...
    'relaunching ReStNeuMap. \n'];
    fprintf(msgProcessDirCreat)
    %throw error without calling error() function: 
    %call not existent variable
    varErr = notExistentVar;
end


% start slice timing and motion correction
files4D=dir('4D.nii');
e.files=files4D.name;

matlabbatch = batch_jobpreproc(e);
try
    spm_jobman('initcfg')
    spm('defaults', 'FMRI');
    spm_jobman('serial', matlabbatch);
end

% end slice timing and motion correction
waitbar(0.35,fwaitb);
%delete first 4 volumes
nii_cropVolumes('raOutBrick.nii',4,inf);

%detrending,filtering and smoothing
filtering_sept;

%create brain mask using the T1 segmentation results
segmfile=dir('rc*.nii');
frame=spm_vol(segmfile(1,1).name);
gm=spm_read_vols(spm_vol(segmfile(1,1).name));
wm=spm_read_vols(spm_vol(segmfile(2,1).name));
csf=spm_read_vols(spm_vol(segmfile(3,1).name));
brainmask=+(or(or(gm,wm),csf));

%mask smoothed functional imaging data
numberofvol=dir('smIn*.nii');
for k=1:size(numberofvol,1)
    formatfile = 'smInputDetFiltReg_00%d.nii';
    str = sprintf(formatfile,k);
    funcvolout=spm_vol(str);
    funcvol_dat=spm_read_vols(funcvolout).*brainmask;
    funcvolout.fname=strcat('mask',str);
    spm_write_vol(funcvolout,funcvol_dat);
end

%imagefiltmask_ls=ls('masksmInputDetFiltReg_00*');
%spm_file_merge(imagefiltmask_ls,'sm4D_mask.nii');
list_dir = dir('masksmInputDetFiltReg_00*');
list_files = '';

%convert 3D to 4D preprocessed smoothed files
for i = 1:length(list_dir)
    cur_files = dir([list_dir(i).name]);
    list_files = [list_files,{cur_files.name}];
end

list_files_tran=transpose(list_files);
spm_file_merge(list_files_tran,'sm4D_mask.nii');

!cp sm4D_mask.nii ./ProcessDir/sm4D_mask.nii

%motionplot;

%copyfile('*t1mprage*','ProcessDir');

!T1=s*T1*.nii
!cp s*T1*.nii ./ProcessDir/$T1


%detects volume outliers volume (after motion correction) and repairs them
%after the last preprocessing step based on ArtRepair (http://cibsr.stanford.edu/tools/human-brain-project/artrepair-software.html)
% FORMAT art_global(Images, RealignmentFile, HeadMaskType, RepairType)
%    Images  = Full path name of images to be repaired.
%       For multiple sessions, all Images are in one array, e.g.SPM.xY.P
%    RealignmentFile = Full path name of realignment file
%       For multiple sessions, cell array with one name per session.
%    HeadMaskType  = 1 for SPM mask, = 4 for Automask
%    RepairType = 1 for ArtifactRepair alone (0.5 movment and add margin).
%               = 2 for Movement Adjusted images  (0.5 movement, no margin)
realname = [ '^ua.*_00.*\.nii$'  ];
imgFile = spm_select('FPList',pwd, realname);
motname = [ '^rp.*\.txt$'  ];
mvfile = spm_select('FPList',pwd, motname);
waitbar(0.4,fwaitb);
alpha_art_global_dz_v3(imgFile, mvfile, 4,2);%

close all
fwaitb = waitbar(0.4,'ReStNeuMap is processing your data. Please wait...');
%coregistration to MNI space applying the deformation field results from
%segmentation
% g.string='MNI norm';
% matlabbatch = batch_jobmni(g);
% trymain_LNgood_melodic(handles.text6.String, handles.text12.String)
%         spm_jobman('initcfg')
%         spm('defaults', 'FMRI');
%         spm_jobman('serial', matlabbatch);
% end

spm_check_registration(strcat(filesT1.name,',1'),'4D_00001.nii,1');
saveas(gcf,'checkreg_output.png')

cd ProcessDir 

%set-up environment variables for running melodic and fslstats (fslstats is
%run later, in GUI_LN.m)
fid = fopen('path.txt','wt');
fprintf(fid,[fileparts(atldir),'/pipelinefiles/ReStNeuMap_melodicrun.sh']);
fclose(fid);
fid_fslstats = fopen('path2fslstats.txt','wt');
fprintf(fid_fslstats,[fileparts(atldir),'/pipelinefiles/ReStNeuMap_fslstatsrun.sh']);
fclose(fid_fslstats);
melodicstatus = system('pathvar=$(cat path.txt); cp $pathvar .; bash ReStNeuMap_melodicrun.sh');
    
% check that melodic has converged
comp10 = false;
comp20 = false;
comp30 = false;
compinf = false;

if melodicstatus ~=0
    
    if ~exist('vmasksm4D_mask.ica', 'dir') && ...
        ~exist('vmasksm4D_mask.ica+', 'dir') && ...
        ~exist('vmasksm4D_mask.ica++', 'dir') && ...
        ~exist('vmasksm4D_mask.ica+++', 'dir') && ...
            close all    
            msgmelodic = 'An error occurred running melodic.';
            error(msgmelodic)
            
    end
    
end
    
if exist('./vmasksm4D_mask.ica/melodic_IC.nii.gz','file') > 0  
    comp10 = true;
else
    warning('Melodic run for 10 components did not converge!')
end

if exist('./vmasksm4D_mask.ica+/melodic_IC.nii.gz','file') > 0  
    comp20 = true;
else
    warning('Melodic run for 20 components did not converge!')
end

if exist('./vmasksm4D_mask.ica++/melodic_IC.nii.gz','file') > 0  
    comp30 = true;
else
    warning('Melodic run for 30 components did not converge!')
end

if exist('./vmasksm4D_mask.ica+++/melodic_IC.nii.gz','file') > 0  
    compinf = true;
else
    warning('Melodic run in free modality did not converge!')
end

if ~any([comp10, comp20, comp30, compinf])
    close all    
    error('melodic has run, but it did not converge for any component set.')
end    
    


exitstatus.comp10 = comp10;
exitstatus.comp20 = comp20;
exitstatus.comp30 = comp30;
exitstatus.compinf = compinf;

close(fwaitb)
end

 function [matlabbatch]=batch_joban(c)%-----------------------------------------------------------------------
% % % % Job saved on 02-Jul-2015 16:50:43 by cfg_util (rev $Rev: 6134 $)
% % % % spm SPM - SPM12 (6225)
% % % % cfg_basicio BasicIO - Unknown
% % % %-----------------------------------------------------------------------
% % % %%
rawfiles=dir;
rawfiles=rawfiles(~ismember({rawfiles.name},{'.','..'}));
anatfiles=strcat(rawfiles(1,1).name(1:2),'*');
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.dir = {c.anatdatadir};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.filter = anatfiles;%'IM*';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{2}.spm.util.import.dicom.data(1) = cfg_dep('File Selector (Batch Mode): Selected Files (IM*)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.util.import.dicom.root = 'flat';
matlabbatch{2}.spm.util.import.dicom.outdir = {c.anatdatadir};
matlabbatch{2}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{2}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{2}.spm.util.import.dicom.convopts.icedims = 0;
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('DICOM Import: Converted Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.copyren.copyto = {c.datadir};
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.copyren.patrep.pattern = '01';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.copyren.patrep.repl = 'T1';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.copyren.unique = false;


end

 function [matlabbatch]=batch_job(b)
rawfiles=dir;
rawfiles=rawfiles(~ismember({rawfiles.name},{'.','..'}));
funcfiles=strcat(rawfiles(1,1).name(1:2),'*');
 disp(b.datadir);
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.dir = {b.datadir};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.filter = funcfiles;%'IM*';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{2}.spm.util.import.dicom.data(1) = cfg_dep('File Selector (Batch Mode): Selected Files (IM*)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.util.import.dicom.root = 'flat';
matlabbatch{2}.spm.util.import.dicom.outdir = {b.datadir};
matlabbatch{2}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{2}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{2}.spm.util.import.dicom.convopts.icedims = 0;
matlabbatch{3}.spm.util.cat.vols(1) = cfg_dep('DICOM Import: Converted Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{3}.spm.util.cat.name = '4D.nii';
matlabbatch{3}.spm.util.cat.dtype = 0;
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('DICOM Import: Converted Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;
matlabbatch{5}.spm.util.split.vol(1) = cfg_dep('3D to 4D File Conversion: Concatenated 4D Volume', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','mergedfile'));
matlabbatch{5}.spm.util.split.outdir = {b.datadir};
  end

function [matlabbatch]=batch_job4d(d, spmdir)
matlabbatch{1}.spm.util.exp_frames.files = {d.files1};
matlabbatch{1}.spm.util.exp_frames.frames = 1;
matlabbatch{2}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.spatial.coreg.estimate.source = {d.files};
matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {[spmdir, '/tpm/TPM.nii,1']};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {[spmdir, '/tpm/TPM.nii,2']};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {[spmdir, '/tpm/TPM.nii,3']};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {[spmdir, '/tpm/TPM.nii,4']};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {[spmdir, '/tpm/TPM.nii,5']};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {[spmdir, '/tpm/TPM.nii,6']};
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [1 1];  % segmentation saving both forward and inverse MNI transformation
matlabbatch{4}.spm.spatial.coreg.write.ref(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{4}.spm.spatial.coreg.write.source(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{4}.spm.spatial.coreg.write.source(2) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
matlabbatch{4}.spm.spatial.coreg.write.source(3) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
matlabbatch{4}.spm.spatial.coreg.write.roptions.interp = 4;%trilinear interpolation
matlabbatch{4}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{4}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{4}.spm.spatial.coreg.write.roptions.prefix = 'r';
end
% % 
 function [matlabbatch]=batch_jobpreproc(e) %slice timing and motion correction
% 
%imag=dicominfo('IM0');
rawfiles=dir('rawdata');
rawfiles=rawfiles(~ismember({rawfiles.name},{'.','..'}));
imag=dicominfo(strcat('rawdata/',rawfiles(1,1).name));
if isequal(imag.Manufacturer,'SIEMENS')
    %Siminfo=SiemensInfo(imag);
    nslices=size(imag.Private_0019_1029,1);
    [B,I]=sort(imag.Private_0019_1029);
    acqorder=transpose(I);
elseif isequal(imag.Manufacturer,'GE MEDICAL SYSTEMS')
    nslices=imag.ImagesInAcquisition;
    evensl=2:2:nslices;
    oddsl=1:2:nslices;
    acqorder=horzcat(oddsl,evensl);
else
    nslices=imag.Private_2001_1018;
    evensl=2:2:nslices;
    oddsl=1:2:nslices;
    acqorder=horzcat(oddsl,evensl);
end;
acqtime=(imag.RepetitionTime/1000)-((imag.RepetitionTime/1000)/nslices);
matlabbatch{1}.spm.util.exp_frames.files ={e.files};
matlabbatch{1}.spm.util.exp_frames.frames = [1:1:size(rawfiles,1)];%[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275];
matlabbatch{2}.spm.temporal.st.scans{1}(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.temporal.st.nslices=nslices;
matlabbatch{2}.spm.temporal.st.tr = imag.RepetitionTime;
matlabbatch{2}.spm.temporal.st.ta = acqtime;
matlabbatch{2}.spm.temporal.st.so = acqorder;%[48 46 44 42 40 38 36 34 32 30 28 26 24 22 20 18 16 14 12 10 8 6 4 2 47 45 43 41 39 37 35 33 31 29 27 25 23 21 19 17 15 13 11 9 7 5 3 1];
matlabbatch{2}.spm.temporal.st.refslice = acqorder(1,round(size(acqorder,2)/2)+1);%acqtime;
matlabbatch{2}.spm.temporal.st.prefix = 'a';
%unwarping instead of only realigning
matlabbatch{3}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{3}.spm.spatial.realignunwarp.data.pmscan = '';
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.rtm = 0;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.einterp = 2;
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
matlabbatch{3}.spm.spatial.realignunwarp.eoptions.weight = '';
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{3}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{3}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
matlabbatch{4}.spm.util.cat.vols(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
matlabbatch{4}.spm.util.cat.name = 'raOutBrick.nii';
matlabbatch{4}.spm.util.cat.dtype = 0;
matlabbatch{5}.spm.util.split.vol(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
matlabbatch{5}.spm.util.split.outdir = {''};
% 

 end

