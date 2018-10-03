%====================================================================================
%								ALPHASCRIPT for SPM
%====================================================================================
%
%-- Version 1.0 August 2009 (Matthew Marzelli)
%		*** SPM5 compatible only ***
%		*** Single sessions only ***
%		This script builds off of bigascript by Paul Mazaika and
%		megascript by Fumiko Hoeft
%		Additions:
%			- Art Despike to remove low frequency drift in mean global signal
%			- Coregistration using high-res T1 anatomicals
%				- Bias Correction
%				- Gray matter segmentation
%				- Coregistration via gray matter segmentation
%			- Normalization using custom T1 anatomical or gray matter templates
%			- Purge unnecessary intermediate files
%			- Stores commonly referenced results files in a new directoy: preproc_data
%               *** Changed default slice repair to bad slice, instead of median.  - pkm 2015
%
%
% -- Version 3  July 2008 (bigascript5 - Paul Mazaika)
%		- Compatible with SPM5 and SPM2
%		- MotionJ, gives better activations
%
%
% -- Version 2  September 2007 (bigascript - Paul Mazaika)
%		- Multiple sessions are allowed
%		- Allows smoothing after normalization for group studies
%
%
% -- Version 1  January 2007 (megascript - Fumiko Hoeft)
%		Fumiko's megascript runs all preprocessing steps in batch mode
%		Starts from matlab
%		Adds a logfile of configuration and progress
%		Calls the artrepair code after smoothing
%		Replacement from old to new art repair program by Paul
%		Fixes images after smoothing 
%         (but you can choose to ignore the repaired
%          images and do your own or chose the smoothed
%         (pre-fixed) images for stats
%		Option to choose which image to realign your data
%		Saves artrepair image in jpeg rather than bmp
%         (compatible with new matlab and is smaller file-size)
%
%====================================================================================
%====================================================================================


clear all;
spm_defaults;
% Identify spm version.
[ dummy, spm_ver ] = fileparts(spm('Dir'));


%====================================================================================
%			PATH TO SCRIPT DIRECTORY 
%====================================================================================

%--scriptDir is the path to the directory containing alphascript.m

scriptDir = 'C:\Users\domenico.zaca\Documents\Grant\FondazioneCaritro2015\Activity\DataAnalysis\Scripts\ArtRepairScripts\alphascript\';

addpath(scriptDir);
cd(scriptDir);


%====================================================================================
%			SET SUBJECTS
%====================================================================================

%--sjDir is an array in which each elemtent is the path to a new subject.

sjDir = {...
%'/fs/sandhill/SMRIUsers/marzelli_matthew/testbiga/subjects/11/',...
'C:\Users\domenico.zaca\Documents\Grant\FondazioneCaritro2015\Activity\DataAnalysis\Scripts\ArtRepairScripts\Subtest2\',...
%'/fs/sandhill/SMRIUsers/marzelli_matthew/testbiga/subjects/23/',...
%'/fs/sandhill/SMRIUsers/marzelli_matthew/testbiga/subjects/24/',...
%'/fs/sandhill/SMRIUsers/marzelli_matthew/testbiga/subjects/25/',...
};


%====================================================================================
%			SET IMAGE FOLDERS
%====================================================================================

%--images is the standard directory that contains a subject's functional files

images = [ 'Data\' ];


%====================================================================================
%			SET PROCESSING METHODS
%====================================================================================

%--process is an 11 element array in which each element corresponds to a unique
%  option that will either be ignored or performed.
% 0 = Ignore process
% 1 = Perform process

process = [ 1 1 1 1 1 1 1 0 0  0 0 ];

% List of available processes in the order they appear in the 'processes' array
% 1. bad slice filter - repairs noisy slices
% 2. slice time correction
% 3. realignment (reslice performed)
% 4. artifact despiking
% 5. spatial smoothing (individual)
% 6. motion correction
% 7  artifact detection and repair
% 8. coregistration
% 9. normalization (reslice performed)
% 10. spatial smoothing (group)    (NOT RECOMMENDED, images are smooth enough already)
% 11. purge intermediate files


%====================================================================================
%			SET PREFIXES
%====================================================================================

%--prefix is a 10 element array in which each element corresponds to the prefix of the
%  functional files that will be operated on during each of the 10 preprocessing steps.
%  Processes that are set to be ignored still require a corresponding dummy prefix as a 
%  placeholder. Note that option 11 does not require a prefix or a placeholder.

prefix = {...
'4D',...
'f4D',...
'af4D',...
'raf4D',...
'draf4D',...
'sdraf4D',...
'msdraf4D',...
% 'vmsdragI',...
% 'vmsdragI',...
% 'wvmsdragI',...
};

% I: raw image prefix
% g: bad slice filtered image prefix
% a: slice time corrected image prefix 
% r: realigned image prefix
% d: artifact despiked image prefix
% s: smoothed image prefix
% m: motion corrected image prefix
% v: artifact detected and repaired image prefix
%  : coregistered images do not generate new files with a unique prefex
% w: normalized image prefix
% s: group smoothed image prefix  (NOT RECOMMENDED, images are smooth enough already)


% These are the default prefixes you want to use if you are doing all 10 steps. 
% If you skip a process, the corresponding lettered prefix should be removed from
% each individual prefix string.

% prefix = {...
% 'I',...
% 'gI',...
% 'agI',...
% 'ragI',...
% 'dragI',...
% 'sdragI',...
% 'msdragI',...
% 'vmsdragI',...
% 'vmsdragI',...
% 'wvmsdragI',...
% };


%====================================================================================
%			1. BAD SLICE FILTER PARAMETERS 
%====================================================================================

% CIBSR users do not need to define any parameters for bad slice filter.


%====================================================================================
%			2. SLICE TIME CORRECTION PARAMETERS
%====================================================================================

%--sliceTime.order is the order in which slices were acquired within each functional
%  volume (1-ascending; 2-descending; 3-interleaved)
%--sliceTime.interval is the time interval over which each functional volume was
%  acquired (i.e. seconds/TR)

sliceTime.order = 3;
sliceTime.interval = 2.6;


%====================================================================================
%			3. REALIGNMENT PARAMETERS
%====================================================================================

%--realign.source is the number of the n-frame to which all other functional files
%  will be realigned.

realign.source = '00004';


%====================================================================================
%			4. ARTIFACT DESPIKE PARAMETERS
%====================================================================================

% CIBSR users do not need to define any parameters for artifact despike.


%====================================================================================
%			5. SMOOTHING PARAMETERS
%====================================================================================

%--smooth.individualFWHM is the size of the Gaussian smoothing kernel (mm) that will
%  be applied to help better estimate motion for each subject during motion correction.

smooth.individualFWHM = 8;


%====================================================================================
%			6. MOTION CORRECTION PARAMETERS
%====================================================================================

% CIBSR users do not need to define any parameters for motion correction.


%====================================================================================
%			7. ARTIFACT DETECTION AND REPAIR PARAMETERS
%====================================================================================

% CIBSR users do not need to define any parameters for artifact detection & repair.


%====================================================================================
%			8 & 9. COREGISTRATION & NORMALIZATION PARAMETERS
%====================================================================================

% The appropriate coregistration method is based on your selected normalization method
% and will automatically be implemented. There are 2 normalization methods. Only the
% variables for the selected method will be called when the script is run.

% Note that coregistration is performed on the anatomical image and no new files are
% generated.

		% -------------- Description of Parameters -------------- %

%--anatDir is the standard directory name within each subject folder that contains a
%	high-res T1 anatomical image. ***DO NOT store any other files in this directory as
%	they will be deleted at the end of this step.
%--anatPrefix is a prefix that is common to all of your anatomical images. This will
%   most likely need to be manually added to all filenames.
%   (e.g. 'abc' for abc_subj#1_rawdata.img and abc_subj#2_rawdata.img)
%--method is the normalization method you wish to run (1 or 2)
%--templateDir is the directory that contains your template image(s).
%--templateFile is the name of your template file(s) (EPI/gray/white/csf).

		% -------------- Begin Parameter Selection -------------- %

norm.method = 1;

				% -------------- Method # 1 -------------- %

%-- Normalization method # 1 registers and normalizes your functional images to a
%   standard EPI template via the mean functional image. Coregistration is skipped.

norm.method1.templateDir = '/fs/fmrihome/fMRItools/matlab/spm5/templates/';
norm.method1.templateFile = 'EPI.nii';

				% -------------- Method # 2 -------------- %

%-- Normalization method # 2 uses coregistration to register your functional images to
%   a custom T1 gray matter template via each subjects own T1 anatomical image.
%   Anatomical images are first bias corrected and then a gray matter segmentation is
%   performed. (RECOMMENDED)

norm.method2.anatDir = 'anatomical/';
norm.method2.anatPrefix = 'rotate';
norm.method2.templateDir = '/fs/fmrihome/fMRItools/matlab/spm2/vanilla/pediatricCCHMC/CCHMC2_girls_5-18/';
norm.method2.templateFile.gray = 'gray.img';
norm.method2.templateFile.white = 'white.img';
norm.method2.templateFile.csf = 'csf.img';


%====================================================================================
%			10. GROUP SMOOTHING PARAMETERS
%====================================================================================

%--smooth.groupFWHM is the size of the Gaussian smoothing kernel (mm) that will be
%  applied to help cluster activation regions across subjects in a group analysis.

smooth.groupFWHM = 7;


%====================================================================================
%			11. PURGE INTERMEDIATE FILES
%====================================================================================

%****** PLEASE BE CAREFUL WHEN USING THIS OPTION ******

%--'purge.images' will delete files from each subject's images directory. This process
%   can free up ~300MB-1GB of space per scan!
%	0: Nothing will be deleted
%	1: 'I' files, art_repaired files**, and group smoothed files will be SPARED.
%	2: ONLY 'I' files will be spared.
%	**If your preprocessing pipeline included art_despike instead of art_repair, this
%	option will alternatively spare your motion corrected files.

purge.images = 0;

%--'purge.preproc_data' will delete the preproc_data directory generated by alphascript.
%	0: preproc_data will not be touched
%	1: preproc_data and all of its contents will be deleted

purge.preproc_data = 0;



%***********************************************************************************
%*************************** NO NEED TO CHANGE THIS CODE! **************************
%***********************************************************************************

flags.images		= images;
flags.process		= process;
flags.prefix		= prefix;
flags.sliceTime		= sliceTime;
flags.realign		= realign;
flags.smooth		= smooth;
flags.norm			= norm;
flags.purge			= purge;

%***********************************************************************************
%			CREATE A LOG FILE OF CONFIGURATION & PARAMETERS
%***********************************************************************************

%  Specify where to write the logfile and artrepair file.
[dumb1,dumb2]=mkdir(scriptDir,'LogDir');
LogDirfull = [ scriptDir 'LogDir' ];

disp('Writing Bigascript Log file to specified Log directory')
tstamp = clock;
filen = ['LogBiga',date,'Time',num2str(tstamp(4)),num2str(tstamp(5)),'.txt'];
logname = fullfile(LogDirfull,filen);
logMeg = fopen(logname,'wt');
fprintf(logMeg,filen);
fprintf(logMeg,'\nCONFIGURATION');
fprintf(logMeg,'\n Subjects');
for i = 1:size(sjDir,2)
	fprintf(logMeg,'\n  %s', sjDir{i});
end
fprintf(logMeg,'\n Processes %3i \n');
fprintf(logMeg,'%4i', process); 
for i = 1:size(prefix,2)
	fprintf(logMeg,'\n Prefix %2i  %s ',  i, prefix{i});
end
if process(2) == 1
	fprintf(logMeg,'\n sliceTime.order = %3i', sliceTime.order);
	fprintf(logMeg,'\n sliceTime.interval = %5.3f',sliceTime.interval);
end
if process(3) == 1
	fprintf(logMeg,'\n realign.source = %s', realign.source);
end
if process(5) == 1
	fprintf(logMeg,'\n smooth,individualFWHM = %5.2f', smooth.individualFWHM);
end
if process(8) == 1 | process(9) == 1
	fprintf(logMeg,'\n norm.method = %3i', norm.method);
	if norm.method == 1
		fprintf(logMeg,'\n template = %s', [norm.method1.templateDir norm.method1.templateFile]);
	end
	if norm.method == 2
		fprintf(logMeg,'\n graytemplate = %s', [norm.method2.templateDir norm.method2.templateFile.gray]);
		fprintf(logMeg,'\n whitetemplate = %s', [norm.method2.templateDir norm.method2.templateFile.white]);
		fprintf(logMeg,'\n csftemplate = %s', [norm.method2.templateDir norm.method2.templateFile.csf]);
	end
end
if process(10) == 1
	fprintf(logMeg,'\n smooth.groupFWHM = %5.2f', smooth.groupFWHM);
end
fprintf(logMeg,'\n \nPROGRESS');
fclose(logMeg);


%***********************************************************************************
%								START PREPROCESSING
%***********************************************************************************

alpha_splash();

for i=1:length(sjDir)
	cd(scriptDir);

	logMeg = fopen(logname,'a');

sj = [sjDir{i}];
	fprintf(logMeg,'\n Starting subject \n  %s', sj);
	runalphascript(sj, flags);
	fprintf(logMeg,'\n Finished subject ');
	fclose(logMeg);

end

cd(scriptDir);

%***********************************************************************************
%***********************************************************************************
%***********************************************************************************

