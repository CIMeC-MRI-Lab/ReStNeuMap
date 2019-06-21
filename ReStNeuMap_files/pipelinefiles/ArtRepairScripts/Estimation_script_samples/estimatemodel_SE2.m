function estimatemodel_SE(SubjectDir, Images, Names, Results, Deweight)
%  TEST FOR SPM5  July 2008
% function estimatemodel(Study, Subject, Images, Names, Results, Deweight)
% v.2  For multiple sessions, assumes each session is repaired separately.
%  SHOULD WORK FOR SPM5
%
% Previously named art_batchestimation(Study, Subject, Images, Names, Results,Deweight)
%
%    Example of batch script that reads images and runs SPM estimation
% with an experiment design that is hard-coded in this program. If there
% is a text file named "art_deweighted.txt" in the Images folder for each session, then
% the image volumes named in that file will be apriori deweighted by 0.01
% in SPM estimation. A GUI asks for input arguments if none are supplied.
% For multiple sessions, art_deweighted.txt for each session is
% written by art_global into each session folder. (CHANGE FROM OLD VERSION)
%
% INPUT ARGUMENTS
%    Study   = main directory                 e.g.  'C:\GoNoGo';
%    Subject = folder of subject              e.g.  'ID7910';
%    Images  = images folder under subject    e.g.  'Session1'
%      For batch version with multiple sessions, input a character array
%      with each session name, where names are the same length.
%      e.g.  Images = [ 'sess1' ; 'sess2' ]; 
%    Names   = image names                    e.g.  'sr*img'
%    Results = results folder under Subject   e.g.  'SPMresults'
%    Deweight = 1 to apply deweighting,  = 0 to not apply deweighting
%
% DEWEIGHTING LOGIC
%    From the documentation for SPM2: If SPM.xX.W is not provided, 
% then SPM will default to starting the analysis with SPM.xX.W = I, 
% and will update it for whitening. However, if SPM.xX.W IS provided, 
% then this initial weighting is used in the analysis and SPM does not 
% do more whitening. 
%    When the ArtifactRepair program "repairs" the data, it writes the
% files art_deweighted.txt and art_repaired.txt to the Images folder.
% If the first file exists, the logic here initializes SPM.xX.W.
%
% Paul Mazaika - August 2006.
% v2.1  Update for multiple sessions and contrasts - Dec. 2006  pkm
%       Same code works for SPM5 and SPM2? 
%       changed initialization of SPM.xCon structure.
%       changed spm defaults call to set mode. Works for SPM2, also.

% Make sure defaults are present in workspace, and old data is not.

clear SPM scans;
%spm_defaults;  
% for SPM5 and SPM2
spm('defaults','fmri');
% Identify SPM version
[ dummy, spm_ver ] = fileparts(spm('Dir'));   

% Get image filenames from argument list or by GUI
if nargin > 0        % Argument input
    %study = Study;   
    %sub = Subject; 
    nsess = size(Images,1); 
    scans = [];       %%%%%%%%%%  NEED TO CONCATENATE SCANS OVER SESSIONS
    for i = 1:nsess
        if spm_ver == 'spm5'
            scansess = spm_select('FPList',[ SubjectDir Images(i,:) ], Names);
            scans = [ scans; scansess ];
        else   % spm2 version
            scans = [scans; spm_get('files',[ SubjectDir Images(i,:) ], Names)];
        end
    end
    imagedir = fileparts(scans(1,:));
    resdir=fullfile(SubjectDir, Results);
    %deweightlist = fullfile(study, sub, Images, 'art_deweighted.txt');


elseif nargin == 0   % GUI input
    nsess = spm_input('How many sessions?',1,'n',1,1);
    for i = 1:nsess
        if spm_ver == 'spm5'
            P{i} = spm_select(Inf,'image',['Select data images for session'  num2str(i) ':']);
        else   % spm2 version
            P{i} = spm_get(Inf,'v*.img',['Select data images for session'  num2str(i) ':']);
        end
    end
    scans = [];
    for i = 1:nsess
        scans = [ scans; P{i} ];
    end
    if spm_ver == 'spm5'
        resdir = spm_select(1,'dir','Select Results folder');
    else  % spm2 version
        resdir = spm_get(-1,'dummy','Select Results folder');
    end
    intfig = spm('CreateIntWin', 'on');
    Deweight = spm_input('Deweight scans?', 1, 'b', 'Yes | No', [1;0], 1);
    %resdir = Results;
    %imagedir = fileparts(scans(1,:));
    %deweightlist = fullfile(imagedir,'art_deweighted.txt');
end
disp('Loaded image names');
% scans array has all images for all sessions
nscans = size(scans,1)/nsess;   % number of images in a session



% Create and go to results directory
mkdir(resdir);
%unix(['mkdir -p ',resdir]);
cd(resdir);

%---------------------------------------------------
% User-defined parameters for this analysis (sample)
%---------------------------------------------------
%nscans             = 136;                   % OR, will find from input. 
%nsess              = 2;                     % OR, will find from input.
SPM.nscan          = nscans*ones(1, nsess); % number of scans for each of nsess sessions
SPM.xY.RT          = 2;                     % experiment TR in seconds

SPM.xGX.iGXcalc    = 'None';                % global normalization: OPTIONS:'Scaling'|'None'

SPM.xX.K.HParam    = 128;                   % high-pass filter cutoff (secs) [Inf = no filtering]

SPM.xVi.form       = 'none';                % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'

% basis functions and timing parameters (sample)
%--------------------------------------------------------------------------

SPM.xBF.name       = 'hrf';         % OPTIONS:'hrf'
                                    %         'hrf (with time derivative)'
                                    %         'hrf (with time and dispersion derivatives)'
                                    %         'Fourier set'
                                    %         'Fourier set (Hanning)'
                                    %         'Gamma functions'
                                    %         'Finite Impulse Response'
                                    % For TEST case, this is changed below.

  %  CHANGE dt TO GET AMPLITUDE?
SPM.xBF.T          = 30;            % number of time bins per scan
SPM.xBF.T0         = 15;            % reference time bin 
SPM.xBF.UNITS      = 'secs';       % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;             % OPTIONS: 1|2 = order of convolution; 1 = no Volterra


% Experiment Design  (conditions and user specified covariates)
%---------------------------------------------------------------------------

for j = 1:nsess
    
    % Sample onsets for three conditions, and two identical sessions.
    %  {[sess1,cond1],
    %   [sess1,cond2],
    %   [sess1,cond3]},
    %  {[sess2,cond1], etc.
    
% for standard experiment with 4nextras, use the following onsets
%onset = {{[15 16 22 30 32 34 51 54 61 72 77 91 95 103 109],...
%        [21 36	37 39 41 45 48 53 65 71 78 89 92 100 108],...
%	[19 27 52 57 66 75 79 80 85 90 94 96 99 107 112],...
%	[18 23 31 40 47	55 63 68 74 81 87 105 110 111 113]}}; 

% for experiment run with 2nextras use these onsets instead
%onset = {{[17 18 24 32 34 36 53 56 63 74 79 93 97 105 111],...
%       [23 38 39 41 43 47 50 55 67 73 80 91 94 102 110],...
%	[21 29 54 59 68 77 81 82 87 92 96 98 101 109 114],...
%	[20 25 33 42 49 57 65 70 76 83 89 107 112 113 115]}};

onset = {{[43 54 111 128 147 155 171 188 196 223 280 342 398 420 435 444 474 491],...
         [8 27 35 62 139 163 232 249 288 297 314 350 373 389 466 483 499 508],...
 	     [19 73 82 90 103 180 204 212 240 258 269 306 322 331 365 381 409 455]},... 
        {[43 54 111 128 147 155 171 188 196 223 280 342 398 420 435 444 474 491],...
         [8 27 35 62 139 163 232 249 288 297 314 350 373 389 466 483 499 508],...
         [19 73 82 90 103 180 204 212 240 258 269 306 322 331 365 381 409 455]}}; 
      
    SPM.Sess(j).U(1).name = {'trained'};                      % string in cell
    SPM.Sess(j).U(1).ons = onset{j}{1};      % onsets in scans or seconds - specified above
    SPM.Sess(j).U(1).dur = 0;                           % 0 for events, can be vector for epochs
    SPM.Sess(j).U(1).P.name = 'none';                   % 'none' | 'time' | 'other'    

    SPM.Sess(j).U(2).name = {'symmetry'};                      % string in cell
    SPM.Sess(j).U(2).ons = onset{j}{2};      % onsets in scans or seconds - specified above
    SPM.Sess(j).U(2).dur = 0;                           % 0 for events, can be vector for epochs
    SPM.Sess(j).U(2).P.name = 'none';                   % 'none' | 'time' | 'other'

    SPM.Sess(j).U(3).name = {'equivalence'};                      % string in cell
    SPM.Sess(j).U(3).ons = onset{j}{3};      % onsets in scans or seconds - specified above
    SPM.Sess(j).U(3).dur = 0;                           % 0 for events, can be vector for epochs
    SPM.Sess(j).U(3).P.name = 'none';                   % 'none' | 'time' | 'other'


%  IMPORTANT: Results are more accurate if you do NOT add regressor for rest periods..
%     SPM.Sess(j).U(3).name = {'rest'};                 % string in cell
%     SPM.Sess(j).U(3).ons = onset{j}{3};      % onsets in scans or seconds - specified above
%     SPM.Sess(j).U(3).dur = 15;                           % 0 for events, can be vector for epochs
%     SPM.Sess(j).U(3).P.name = 'none';                    % 'none' | 'time' | 'other'
        
    % sample for using no conditions
        %SPM.Sess(j).U = [];

    % sample for using parametric modulation
        %SPM.Sess(j).U(1).P.name = 'time';      % 'none' | 'time' | 'other'
        %SPM.Sess(j).U(1).P.h = 1;              % order of polynomial expansion
           %or
        %SPM.Sess(j).U(1).P.name = 'other';     % 'none' | 'time' | 'other'
        %SPM.Sess(j).U(1).P.P = param{j}{1}     % vector as long as current U's ons vector
        %SPM.Sess(j).U(1).P.h = 1;              % order of polynomial expansion
    
    % user-specified covariates
    % -------------------------
    SPM.Sess(j).C.C = [];
    SPM.Sess(j).C.name = {};
        
    % sample for using user-specified motion regressor
    % Here we assume name is rp_I_001.txt located in imagedir for each session 
    %   (Would be more robust to pass in the correct name in the arguments)
    % Don't forget to add 6 regressors to the contrast definitions.
    %     cd(imagedir)
    %     rf = load('rp_I_001.txt');
    %         SPM.Sess(j).C.C(:,1) = rf(:,1);          % [n x c double] covariates
    %         SPM.Sess(j).C.C(:,2) = rf(:,2);          % [n x c double] covariates
    %         SPM.Sess(j).C.C(:,3) = rf(:,3);          % [n x c double] covariates
    %         SPM.Sess(j).C.C(:,4) = rf(:,4);          % [n x c double] covariates
    %         SPM.Sess(j).C.C(:,5) = rf(:,5);          % [n x c double] covariates
    %         SPM.Sess(j).C.C(:,6) = rf(:,6);          % [n x c double] covariates
    %         SPM.Sess(j).C.name = {'x mvmt' 'y mvmt' 'z mvmt' ...
    %           'pitch' 'roll' 'yaw'};   % [1 x c cell]   names
    %    cd(resdir)


end     % end session loop
     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




    % specify data: matrix of filenames and TR
    %===========================================================================
    SPM.xY.P           = scans;

    % Configure design matrix
    %===========================================================================

    SPM = spm_fmri_spm_ui(SPM);
    
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    if nargin > 0
       fprintf(['Beginning estimation on subject ']);
    else
       fprintf(['Beginning estimation on subject \n']);
    end
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');


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
% a single session study, or to the folder of the first session
% in a multi-session study. If those files exist, the logic below
% initializes SPM.xX.W.
%
% Possible alternatives:
%  -To only deweight the repaired files, read art_repaired.txt instead.
%  -The omit scans logic in the 2005 version was here instead of deweight.

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
            outmsg = [num2str(length(outindex)) ' images will be deweighted in session ' isess];
            disp(outmsg)
        end
        %deweightlist = fullfile(study, sub, Images, 'art_deweighted.txt');
        %outindex = load(deweightlist);
        %Vom = ones(1,size(scans,1));
        %Vom(outindex) = 0.01;   % better than deweighting by 0.1
        SPM.xX.W = sparse(diag(Vom,0));
        disp('Applying Deweighting to GLM Estimatees')
    catch
        dummy = 1;  %  SPM.xX.W will follow SPM defaults.
        disp('WARNING: Could not locate a deweighting file for each session')
    end
end


%=======================================================================
% Estimate parameters
%===========================================================================

    SPM = spm_spm(SPM); 
    
% Add extra contrasts
%===========================================================================

% T-contrasts
%---------------------------------------------------------------------------
% 1st column go, 2nd column nogo, 3rd column rest, 
%    then repeated for the second session, then constants for each session.

con_vals{1}         = [ -1 1 0   -1 1 0   0 0];
con_name{1}         = 'symmetry-trained';

con_vals{2}         = [ -1 0 1   -1 0 1   0 0];
con_name{2}         = 'equivalence-trained';


  % Example contrasts for two session experiment
     % con_vals{1}         = [ 1 -1  0    1 -1  0    0 0];
     % con_vals{2}         = [ -1 1  0    -1 1  0    0 0];
     % con_vals{3}         = [ 1  1 -2    1  1 -2    0 0];
     
consize = length(SPM.xCon);
for j = 1:length(con_vals)
    % note: explicitly setting up the xCon structure for spm5
    spmtemp = spm_FcUtil('Set', con_name{j}, 'T', 'c', (con_vals{j})', SPM.xX.xKXs);
    if consize == 0 & j == 1
        SPM.xCon = spmtemp;     % Matlab initializes the structure
    else
        SPM.xCon(consize + j) = spmtemp;
    end
end

%  and evaluate
%-----------------------------------------------------------------
spm_contrasts(SPM);



