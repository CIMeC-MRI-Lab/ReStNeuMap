function batchmotionstats
% Batch routine to get motion statistics for multiple subjects
%
% Enter subjects that have been realigned and artrepaired as a
% list, and statistics will be computed using art_motionstats. 
%
% INPUTS to be coded inside this program
%   - Subject directory for each subject
%   - Image folder for each session (must be same name for all subjects)
%   - Folder with the scripts batchmotionstats and art_motionstats
%   - A Quality Check folder where the results are written as a text file.
% Assumes subjects have been realigned and artrepaired already.
%--------------------------------------------------------------
%  Derived from estiscript.
%  P. Mazaika - Jan. 2007
%  Supports SPM12 Jan2015  pkm


clear all;
% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


%-----------------------%
%-- SET SUBJECTS HERE --%
%-----------------------%
% Sample datasets from ReadingBrain study
% Use a slash at the beginning and end of these names
sjDir={...
%'/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/5004/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/5006/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/5007/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/5016/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/5020/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/6011/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/6015/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/6024/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/6025/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/6028/',...
% '/fs/Projects/softwareDevelopment/PaulsSW/from_spnlbnrc/MotionExperiment/6031/'...
'/Volumes/Projects/Dyslexia/ReadingBrain/5013_20080809_891_BD/fMRI_old/Phono1/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5016_20081005_1123_SG/fMRI_old/Phono1/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6019_20081026_1265_IP/fMRI_old/Phono1/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5106_20091018_2822_KS/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5112_20090822_2488_AB/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5119_20090912_2563_HM/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6105_20090814_2450_TEH/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6115_20091018_2818_JE/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6117_20090913_2564_CE/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6118_20091001_2705_KB/fMRI_old/Phono1_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5013_20080809_891_BD/fMRI_old/Phono2/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5016_20081005_1123_SG/fMRI_old/Phono2/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6019_20081026_1265_IP/fMRI_old/Phono2/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5106_20091018_2822_KS/fMRI_old/Phono2_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5112_20090822_2488_AB/fMRI_old/Phono2_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/5119_20090912_2563_HM/fMRI_old/Phono2_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6105_20090814_2450_TEH/fMRI_old/Phono2_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6115_20091018_2818_JE/fMRI_old/Phono2_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6117_20090913_2564_CE/fMRI_old/Phono2_paul/',...
'/Volumes/Projects/Dyslexia/ReadingBrain/6118_20091001_2705_KB/fMRI_old/Phono2_paul/'...

};

%-----------------------%
%-- SET IMAGE FOLDERS --%
%-----------------------%
% Use the same length names, if possible, for multiple sessions
%  Images = [ 'sess1/' ; 'sess2/' ];
% Use a slash at the end of each name, but not the beginning.
Images = [ 'processed/' ];

%----------------------------%
%-- PATHS, SCRIPT LOCATION --%
%----------------------------%
scriptDir = '/Users/paulmazaika/MatlabTools/artMotionStats/';
addpath(scriptDir);
%put directory name where your scripts are.

% What folder to store the Quality Check outputs?
% Use slash at beginning, not at the end.
QCDir= '/Users/paulmazaika/MatlabTools/artMotionStats/QCDir';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- NO MORE USER CHANGES, THE CODE BELOW IS AUTOMATIC  -----%
%------------------------------------------------------------%
processesE =[ 0 0 1]; prefixE={...
'dummy',...
'dummy'}; ResultsFolder  = '/dummy';
% No need to change the code below! *************************
%  Specify where to write the logfile and artrepair file.
[dummy, dum ] = mkdir(scriptDir,'LogDir');
LogDirfull = [ scriptDir 'LogDir' ];
MaskPath = ResultsFolder;  % vestigial code, passed but not used.

% Set up Log File
disp('Writing BatchMultiSubject Log file to specified Log directory')
tstamp = clock;
filen = ['LogBatchMotionStats',date,'Time',num2str(tstamp(4)),num2str(tstamp(5)),'.txt'];
logname = fullfile(LogDirfull,filen);
logMegE = fopen(logname,'wt');
fprintf(logMegE,filen);
fprintf(logMegE,'\nCONFIGURATION');
fprintf(logMegE,'\n Subjects');
for i = 1:size(sjDir,2)
    fprintf(logMegE,'\n  %s', sjDir{i});
end

fprintf(logMegE,'\n \nPROGRESS');
fclose(logMegE);
%ConfigE = { processesE; prefixE; ResultsFolder; ResultsFolder; ...
%    ConImage; ConImage; MaskPath; MaskPath; Images };


%-- Run motion characterization on all subjects
%process=processesE(3);
process = 1; 
if process==1
    [dum1, dum2 ] = fileparts(QCDir);
    [dummy, dum ] = mkdir(dum1,dum2);
    art_motionstats( sjDir, Images, QCDir );
end

cd(scriptDir); 
disp('batch motionstats run complete!')







 





