function art_redo
% FUNCTION art_redo   v3.2
%    
% Applies repairs and deweighting to an existing SPM design. This program
% asks to replace the images in each session with repaired images, and
% applies deweighting in estimation according to the art_deweighted.txt file.
% It assumes user has repaired images with art_global to create repaired
% images (with prefix v). Each session should be repaired separately.
%
% Deweighting is applied as a fixed value of 0.01 on all repaired images,
% essentially knocking them out of the estimate, but maintaining the size
% of the design matrix. Deweighted scans show up as dark bars on the
% SPM design matrix display. User can compare before and after results
% with Global Quality program.
%
% INPUT by GUI
%    Specify the SPM.mat file.
%    Specify a new folder for repaired Results.
%    Specify the replacement images for each session
% OUTPUT 
%    Writes a new SPM.mat in the designated new Results folder,
%       with deweight factors and the replacement images.
%    Runs SPM estimation and contrasts for this repaired design,
%       and writes beta, con, etc. images in new Results folder.
%
% All original SPM.mat and results files are preserved.
% BUGS: Hardly affects the estimates since repairs to do most of work.
%       Prevents the whitening process in SPM estimation.
% 
% v3.1  May09 pkm
% v3.2 supports SPM12 Dec2014 pkm


% v2.2  changed SPM.xVi.form from 'i.i.d' to 'none'.   Jul 2007
%       scales to % using peak of regressor and contrast sum.
% v3.   Removed functionality to repair and run global quality.
%       assumes each file realigned and repaired separately. Mar09 pkm
% v3.1  fixed bugs (RMitchell): Deweight=1, spm_ver 
% Paul Mazaika, Jan 2007
% Bug fix for output. A. Gonzalo

clear SPM scans;
% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


% Get the existing SPM file
if strcmp(spm_ver,'spm5')
    origSPM   = spm_select(1,'mat','Select SPM design to re-estimate');
    RepairResults = spm_select(1,'dir','Select folder for Repaired Results');
else
    origSPM = spm_get(1, 'SPM.mat', 'Select SPM design to re-estimate');
    RepairResults = spm_get(-1,'*','Select folder for Repaired Results');
end
dirSPM = fileparts(origSPM);
cd(dirSPM);
load SPM;
num_sess = size(SPM.Sess,2);  % size(SPM.nscan,2)
% images for all sessions are in  SPM.xY.P, size of session is SPM.nscan(i)
session_size = SPM.nscan(1);   % assumed all sessions are the same length.

% SELECT A NEW FOLDER FOR REPAIRED RESULTS
SPM.swd = RepairResults;

  
% Get the repaired data
AutoRepair = 0;
%spm_input('!DeleteInputObj');
if AutoRepair == 0
    % (Preferable if program automatically checked for necessary v-files.)
    % Update each session with existing v file data.
    % nwd=cd(fileparts(SPM.xY.P(1,:))); fails if upper paths changed.
    for j=1:num_sess
        askstring = ['Select repaired images for session ' num2str(j) ];
        if strcmp(spm_ver,'spm5')
            Pnew{j}   = spm_select(Inf,'image', askstring,[],dirSPM,'^v.*' );
        else
            Pnew{j}   = spm_get(Inf,'v*img', askstring, nwd );  % for SPM2
        end
    end
    scans = [];
    for i = 1:num_sess
        scans = [ scans; Pnew{i} ];
    end
    if ~(size(SPM.xY.P,1) == size(scans,1))
        disp('ERROR: Must enter same number of new data points.')
        return;
    else     % Assign the repaired data to the design matrix.
        SPM.xY.P           = scans;
    end
end


% Configure the design matrix with the new scans  (v2.2)
 if (strcmp(SPM.xVi.form, 'i.i.d'))  % changed name is used in spm_fmri_spm_ui.
       SPM.xVi.form = 'none';
 end
SPM = spm_fmri_spm_ui(SPM); 
    
%=====================================================================
%  LOGIC FOR DEWEIGHTING SCANS
%-------------------------------------------------------------------------
%    If SPM.xX.W is not provided, then SPM will default to starting
% the analysis with SPM.xX.W = Identity Matrix, and will update it
% for whitening. There is only one SPM.xX.W input that covers all
% the sessions for a multi-session study.
%    When SPM.xX.W is provided as input, then SPM uses the initial 
% weighting in the analysis and SPM does not do more whitening. 
%    When the ArtifactRepair program "repairs" the data, it writes the
% files art_deweighted.txt and art_repaired.txt to the Images folder in
% a single session study. For multiple sessions, we assume each session
% is repaired separately. If those files exist, the logic below
% initializes SPM.xX.W.
%
% Possible alternatives:
%  -To only deweight the repaired files, read art_repaired.txt instead.
%  -The omit scans logic in the 2005 version was here instead of deweight.

Deweight = 1;
nsess = num_sess;
nscans = session_size;
if Deweight == 1
    % For multiple sessions, deweightlist is in EACH session folder.
    Vom = ones(1,size(scans,1));
    try
        for isess = 1:nsess
            index = (isess-1)*nscans + 1;  % first image of session isess.
            imagedir = fileparts(scans(index,:));
            deweightlist = fullfile(imagedir,'art_deweighted.txt');
            outindex = load(deweightlist);
            Vom(outindex + index -1) = 0.01;
            outmsg = [num2str(length(outindex)) ' images will be deweighted in session ' num2str(isess)];
            disp(outmsg)
        end
        SPM.xX.W = sparse(diag(Vom,0));
        disp('Applying Deweighting to GLM Estimatees')
    catch
        dummy = 1;  %  SPM.xX.W will follow SPM defaults.
        disp('WARNING: Could not locate a deweighting file for each session')
    end
end

% %================================
% %  OLD LOGIC LOGIC FOR DEWEIGHTING SCANS
% %--------------------------------
% % This version assumed all sessions were realigned together.
% deweightdir = fileparts(SPM.xY.P(1,:));
% deweightlist = fullfile(deweightdir,'art_deweighted.txt');
% 
% Deweight = 1; 
% if Deweight == 1
%     try
%         outindex = load(deweightlist);
%         Vom = ones(1,size(SPM.xY.P,1));
%         Vom(outindex) = 0.01;   % better than deweighting by 0.1
%         SPM.xX.W = sparse(diag(Vom,0));
%         disp('Applying Deweighting Factors to Images')
%         outmsg = [num2str(length(outindex)) ' images will be deweighted'];
%         disp(outmsg)
%     catch
%         dummy = 1;  %  SPM.xX.W will follow SPM defaults.
%         disp('WARNING: Could not locate a deweighting file')
%     end
% end

%-------------------------------------------------------------
% Write the amended SPM.mat file with deweighting and new data included.
disp('The SPM.mat file has been modified and saved to disk.');
cd(SPM.swd);
save SPM SPM;


% Estimate parameters and contrasts

% Save contrast definitions, before deletion by spm_spm.
temp = SPM.xCon;
consize = length(SPM.xCon);
SPM = spm_spm(SPM); 

% Recover the contrasts and run them
SPM.xCon = temp;  % explicitly sets up structure for SPM5, but fills in too much.
for j = 1:consize
    spmtemp = spm_FcUtil('Set', temp(j).name, temp(j).STAT, 'c', temp(j).c, SPM.xX.xKXs);
    SPM.xCon(j) = spmtemp;
end
if consize > 0
    spm_contrasts(SPM);
end

disp('Done. New estimates have been created.');
disp('Compare new and old estimates with Global Quality metric.');


