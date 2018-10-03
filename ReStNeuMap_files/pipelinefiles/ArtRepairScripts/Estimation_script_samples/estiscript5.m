function estiscript5
% Estimation script for SPM5
%   1. Copy this function to your script directory, and rename it.
%   2. Copy estimationmodel.m to your script directory, and rename it.
%   3. Modify these two programs as needed.
%
%   FOR SPM5 Paul  July 2008
%   Estimation of a model, with or without repairs.
%
% Top Level SCRIPT to estimate single subject results,and 
% calculate and compare global quality results for multiple subjects.
% This function calls the custom program "estimatemodelMine.m" ,
% where the user will need to get into
% the Matlab code to define the experiment design and contrasts.
%
% ASSUMPTIONS
%   - Multiple sessions were realigned and artifact repaired separately,
%     so that deweighting file from art_global is in the the images folder
%     for each session.
%   - ResultsFolder for SPM estimation will be written into the 
%     folder that contains folder for images.
%   - User specifies a Quality Check folder.
%--------------------------------------------------------------
%  V2. 
%  Updates by Jenny Drexler to get to multiple sessions 08/07
%  P. Mazaika - Jan. 2007
%  This code is styled after megascript.m by Fumiko Hoeft.


clear all;
% Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));

%-----------------------%
%-- SET SUBJECTS HERE --%
%-----------------------%
% Use a slash at the beginning and end of these names
sjDir={...
'/fs/spnlbnrc/mazaika_paul/bipolar5/control_subs/001/',…
'/fs/spnlbnrc/mazaika_paul/bipolar5/control_subs/005/',…
% '/fs/s4_spnl/mazaika_paul/bipolar/control_subs/003/',…
% '/fs/s4_spnl/mazaika_paul/bipolar/control_subs/008/',…
};

%-----------------------%
%-- SET IMAGE FOLDERS --%
%-----------------------%
% Use the same length names, if possible, for multiple sessions
%  Images = [ 'sess1/' ; 'sess2/' ];
% Use a slash at the end of each name, but not the beginning.
Images = [ 'images5/' ];

%-----------------------------------% 
%-- SET PROCESSING METHODS HERE --%
%-----------------------------------%  
%  Set the two run processes as desired.
processesE =[ 0 1 ];
% 1. Esitmation and Deweighting choice
%     1 = Estimation without deweighting, 
%     2 = Estimation with deweighting  (recommended for bigascript)
%     0 = no estimation done
% 2. Compare Global Quality scores of subjects
%     1 = Yep.
%     0 = Nope.

%---------------------%
%-- SET PREFIX HERE --%
%---------------------% 
prefixE={...
'sw',...
'con'    % this one is not used
};
% Prefix 1 names the images used for processing step 1.
% e.g sw are the smoothed normalized images. 

%-----------------------------------%
%-- SET RESULTS FOLDER NAME HERE --%
%-----------------------------------%
ResultsFolder  = '/ResultsSPM5';
% The Estimation step will put SPM results in sjDir with this folder name,
%   one ResultsFolder written for each subject (and scan date).

%----------------------------%
%-- PATHS, SCRIPT LOCATION --%
%----------------------------%
scriptDir = '/fs/spnlbnrc/mazaika_paul/bipolar5/';
addpath(scriptDir);
%put directory name where your scripts are.

%----------------------------------%
%-- SET THE ESTIMATION MODEL HERE --%
%----------------------------------%
% The name of your model, in your SCRIPT LOCATION
%   goes somewhere around line 270. See code below.



%-----------------------------------%
%-- FOR THE GROUP QUALITY CHECK   --%
%-----------------------------------%
% Which contrast image to analyze?: SPM5 puts an extra zero in name.
if strcmp(spm_ver,'spm5')
    ConImage = 'con_0002.img';
else  % spm2
    ConImage = 'con_002.img';
end
% What scaling to use for percent signal change?.
% Enter the peak value divided by the contrast sum.
% Run the art_summary program on a single subject to get these values.
pctscale = 1.13;

% What folder to store the Quality Check outputs?
% Use slash at beginning, not at the end.
QCDir= '/fs/spnlbnrc/mazaika_paul/bipolar5/control_subs/QualityCheckDir';





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- NO MORE USER CHANGES, THE CODE BELOW IS AUTOMATIC  -----%
%------------------------------------------------------------%

% No need to change the code below! *************************
%  Specify where to write the logfile and artrepair file.
[dummy, dum ] = mkdir(scriptDir,'LogDir');
LogDirfull = [ scriptDir 'LogDir' ];
MaskPath = ResultsFolder;  % vestigial code, passed but not used.

% Set up Log File
disp('Writing BatchMultiSubject Log file to specified Log directory')
tstamp = clock;
filen = ['LogBatchGQ',date,'Time',num2str(tstamp(4)),num2str(tstamp(5)),'.txt'];
logname = fullfile(LogDirfull,filen);
logMegE = fopen(logname,'wt');
fprintf(logMegE,filen);
fprintf(logMegE,'\nCONFIGURATION');
fprintf(logMegE,'\n Subjects');
for i = 1:size(sjDir,2)
    fprintf(logMegE,'\n  %s', sjDir{i});
end
fprintf(logMegE,'\n processesE %3i \n');
fprintf(logMegE,'%4i', processesE); 
for i = 1:size(prefixE,2)
    fprintf(logMegE,'\n Prefix %2i  %s ',  i, prefixE{i});
end
fprintf(logMegE,'\n ResultsFolder2 = %s ', ResultsFolder);
%fprintf(logMegE,'\n ResultsFolder3 = %s ', ResultsFolder3);
fprintf(logMegE,'\n ConImage4      = %s ', ConImage);
%fprintf(logMegE,'\n ConImage5      = %s ', ConImage5);
fprintf(logMegE,'\n MaskPath4      = %s ', MaskPath);
%fprintf(logMegE,'\n MaskPath5      = %s ', MaskPath5);
fprintf(logMegE,'\n \nPROGRESS');
fclose(logMegE);
ConfigE = { processesE; prefixE; ResultsFolder; ResultsFolder; ...
    ConImage; ConImage; MaskPath; MaskPath; Images };

%-- Start Processing and Estimation for each subject--%
for i=1:length(sjDir)
    logMegE = fopen(logname,'a');
	sj = [sjDir{i}];
    fprintf(logMegE,'\n Starting subject \n  %s', sj);
	runestiscript_here(sj, ConfigE);
    fprintf(logMegE,'\n Finished subject ');
    fclose(logMegE);
end

%-- Run groupoutlier program on all subjects
process=processesE(2);
if process==1
    [dum1, dum2 ] = fileparts(QCDir);
    [dummy, dum ] = mkdir(dum1,dum2);
    groupoutlier5( sjDir, ResultsFolder, ConImage, pctscale, QCDir );
%  Future updated programs.
%     % Assemble full con image names
%     for i = 1:length(sjDir)
%         FullConName{i}=(fullfile(char(sjDir{i}),ResultsFolder,ConImage));
%     end
%     % Second argument 0 means each contrast uses its own mask.
%     art_groupoutlier(FullConName, 0, pctscale, QCDir);
end

cd(scriptDir); 

%%-----------------------------------------------------------------------
function runestiscript_here(SubjectDir, ConfigE)
% FUNCTION runestiscript(SubjectDir, ConfigE).  version 3
%      Image folders are defined separately from
%      subject folder to handle multiple sessions.
%
% Example function to repair data for a single subject, MULTIPLE session
% experiment, run estimations, and run global quality on results.
% Results are written to a file called GlobalQuality.txt in the 
% Subject folder. Comparing the GQ before and after repairs lets a user
% validate the effectiveness of the repair method.
%------------------------------------------------
% V3   Embedded into estiscript.
% V2.  Handles multiple sessions via Images array. 09/07
% Paul Mazaika, January 2007.

% Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));

%STEP 0: Unravel the function arguments
% First the image paths
   % [ Uppath, xImages ] = fileparts(SubjectDir);
    [ StudyA, dummy ] = fileparts(SubjectDir);
    [ Study, Subject ] = fileparts(StudyA);
% Next the cell argument into variable names
% ConfigE = { processesE; prefixE; ResultsFolder; ResultsFolder; ...
%    ConImage; ConImage; MaskPath; MaskPath; Images };
    processesE                  = ConfigE{1};
    prefixE                     = ConfigE{2};
    ResultsFolder              = ConfigE{3};
    ResultsFolder              = ConfigE{4};
    ConImage                   = ConfigE{5};
    ConImage                   = ConfigE{6};
    MaskPath                   = ConfigE{7};
    MaskPath                   = ConfigE{8};
    Images                      = ConfigE{9};

% STEP 1:  SPM Estimation, with or without Deweighting
process=processesE(1);
if process == 1 | process == 2
    Results = ResultsFolder;
    if process == 1;  Deweight = 0; end
    if process == 2;  Deweight = 1; end
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	SubjectDir
	fprintf('%-4s:\n','Starting SPM Estimation...');                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    if strcmp(spm_ver,'spm5')
        Names = ['^' prefixE{1}  '.*\.img$'  ];
    else  % spm2
	    Names = [prefixE{1} '*.img'];
    end
    
    %%%%%%%% YOUR MODEL NAME GOES BELOW HERE %%%%%%%%%%%%%%%%%%%
    
    estimatemodelMine(SubjectDir, Images, Names, Results, Deweight);
    
    %%%%%%%% YOUR MODEL NAME GOES ABOVE HERE %%%%%%%%%%%%%%%%%%%
    
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	SubjectDir
	fprintf('%3s\n','... SPM Estimation Done');                                          
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
end









 





