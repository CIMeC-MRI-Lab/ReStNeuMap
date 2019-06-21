function X = art_motionstats( SubjectDir , ImageDir, OutputDir )
% FUNCTION art_motionstats;   for GUI, or 
% FUNCTION X = art_motionstats( SubjectDir, OutputDir )    for batch.
%
%  Calculates statistics about the difficulty of the fMRI data set,
%  in terms of the total motion, scan-to-scan motion, jerkiness of the
%  motion. Assumes realignment rp*txt file
%  is available in the images folder for every session.
%. GUI mode with no input will do one subject; use the command arguments
%  for multiple subjects and sessions.
%
%  INPUT
%    RealignmentFile = Full path name of realignment file as char string
%       For multiple sessions, cell array with one name per session.
%    GUI will ask for it, if not provided.
%  OUTPUT
%    Six element vector, with 
%      - max translational motion from zero  (mm)
%      - maximum range of translational motions  (mm)
%      - avg RMS motion over the session, using model in Oates 2005.
%            where RMS is RMS of trans(mm) and rotation(deg) for each image
%            Note: For voxel 57 mm from origin, 1 deg rotation is 1 mm.
%      - avg scan-to-scan motion over the session  (mm)
%            where rotations assume voxels are 65 mm from origin.
%      - number of scans with translation head jerks > 0.2 mm,
%            using model in (Lemieux, 2007)
%      - number of scans with head jerks > 0.5 mm for combined translations
%            and rotations (ArtRepair default)
%    For GUI mode, makes a plot.
%  COMPATIBLE with SPM2,5,8, and 12.
%
%  Supports SPM12  Jan2015 pkm

%  paul July 2013, fixed printing bug.
%  paul  Nov 2010 for only motion, fixed bug rad->deg for rotation mvmt 
%  paul  nov 2007.  August 2008 for SPM5, SPM8

clear data1 xmin xmax ymin ymax zmin zmax

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin == 0   % Usual GUI from plotmove program
    if strcmp(spm_ver,'spm5')
        sub = spm_select(Inf,'^rp.*\.txt$','Select subject realignment file:');
        
    else   % spm2
        sub = spm_get(1,'rp*.txt',' Select Subject realignment file:'); 
    end
    load(sub);
    [fpath,fname,fext] = fileparts(sub);
    makeplot = 1;
    % irritatingly, we run into trouble now if our filename has a dot in it,
    % because MATLAB tries to interpret that as a structure field reference.
    dot = findstr(fname, '.');
    if ~(isempty(dot))
        fname = fname(1:(dot - 1));
    end
    data1 = eval(fname);
    %nscans = size(data1,1);
    num_sess = 1;
    numsubj = 1;
    OutputDir = fileparts(sub);
end
%keyboard;
if nargin > 0
    num_sess = size(ImageDir,1);
    %num_sess = 1;   % PATCH FOR GBB DATA
end
for ksession = 1:num_sess
    
if nargin > 0  % Do the whole subject loop for each image session  
    makeplot = 0;
    numsubj = length(SubjectDir);
    for i = 1:numsubj
        %sjDir = [ SubjectDir{i} ImageDir(ksession,:) ];
        sjDir = SubjectDir{i}; % ImageDir(ksession,:) ];  % PATCH FOR GBB
        if strcmp(spm_ver,'spm5')
             %realname = [ '^' prefix{6} '.*\.img$'  ];
            mvfile = spm_select('FPList', sjDir , '^rp.*\.txt');
            %mvfile = [sjDir  '^rp_.*\.' '_001.txt'];  % same prefix as realignment.];
            
        else   % spm2
            mvfile = spm_get('files', sjDir, 'rp*.txt');
            %mvfile = [sjDir  'rp*' '001.txt'];  % same prefix as realignment.];
            
        end
        if exist(mvfile) > 0
            R{i} = load(mvfile);
        else
            disp('Failure to find rp.txt file for this subject.')
            disp(sjDir)
        end
    end
end


if makeplot == 1
    page = figure('NumberTitle', 'off', 'PaperOrientation', 'landscape', 'PaperPosition', [0 0 11 8.5], 'Units', 'inches', 'Position', [0 0 11 8.5]);
    h1 = subplot(2,1,1), plot(data1(:,1:3));
    h2 = subplot(2,1,2), plot(data1(:,4:6));

    %plotline(14,'k:');
    %plotline(320,'k:');
    subplot(h1), ylabel('movement in mm');
    xlabel('scans');
    y_lim = get(gca, 'YLim');
    legend('x mvmt', 'y mvmt', 'z mvmt',0);

    subplot(h2);
    ylabel('movement in rad');
    xlabel('scans');
    y_lim = get(gca, 'YLim');
    %legend('pitch', 'roll', 'yaw',0);
    legend('pitch', 'roll', 'yaw', ['max:' num2str(y_lim(2))], ['min:' num2str(y_lim(1))],0);

    set(h1,'Ygrid','on');
    set(h2,'Ygrid','on');
end


% Let's make MOTION SUMMARIES of maximum, total, and rapid motions.

for isubj = 1:numsubj
 if nargin > 0
     clear data1;
     data1 = R{isubj};  % realignment data
 end
 nscans = size(data1,1);
% Max and min motion in each translational direction
xmin = min(data1(:,1));  ymin = min(data1(:,2)); zmin = min(data1(:,3));
xmax = max(data1(:,1));  ymax = max(data1(:,2)); zmax = max(data1(:,3));
% Maximum motion from zero
maxmot = max([ abs(xmin) abs(xmax) abs(ymin) abs(ymax) abs(zmin) abs(zmax)]);
% Maximum translational range
maxrange = max( [(xmax-xmin) (ymax-ymin) (zmax-zmin) ]);

% Max and min rotation in each angular direction
pmin = min(data1(:,4));  qmin = min(data1(:,5)); yawmin = min(data1(:,6));
pmax = max(data1(:,4));  qmax = max(data1(:,5)); yawmax = max(data1(:,6));
% Maximum motion from zero
maxrotmot = max([ abs(pmin) abs(pmax) abs(qmin) abs(qmax) abs(yawmin) abs(yawmax)]);
% Maximum rotational range
maxrotrange = max( [(pmax-pmin) (qmax-qmin) (yawmax-yawmin) ]);

% RMS motion  (from Oates,Comparison paper, NeuroImage 2005)
% take RMS with rotation expressed in degrees
%    deg = 180/pi*rad
    r2d2 = (180/pi)^2;
    for i = 1:nscans
          rss(i) = data1(i,1)'^2 + data1(i,2)^2 + data1(i,3)^2 + ...
               (data1(i,4)^2 + data1(i,5)^2 + data1(i,6)^2 )*r2d2;
    end
    rms = sqrt(rss);
    % Average RMS motion over scan session
    meanrms = mean(rms);
    
% Head jerk counts according to Lemieux 2007.
% Find translational displacement, d. reference image not stated.
% FSL McFLIRT appears to be the same, uses reference as middle image.
% Count delta-d in mm/scan > 0.2 mm, and mean size of these head jerks.
% Also Find max delta-d, avg delta-d over data set.
% FSL also measures relative scan-to-scan motion


% RMS scan-to-scan motion. Logic from art_global.
%  and count the head jerks
% Rotation measure assumes voxel is 65 mm from origin of rotation.
mv_data = data1;
mv_data(:,4:6) = mv_data(:,4:6)*180/pi;
        delta = zeros(nscans,1);  % Mean square displacement in two scans
        for i = 2:nscans
            delta(i,1) = (mv_data(i-1,1) - mv_data(i,1))^2 +...
                    (mv_data(i-1,2) - mv_data(i,2))^2 +...
                    (mv_data(i-1,3) - mv_data(i,3))^2 +...
                    1.28*(mv_data(i-1,4) - mv_data(i,4))^2 +...
                    1.28*(mv_data(i-1,5) - mv_data(i,5))^2 +...
                    1.28*(mv_data(i-1,6) - mv_data(i,6))^2;
            delta(i,1) = sqrt(delta(i,1));
        end
        % FSL and Lemieux use only translations
        delta2 = zeros(nscans,1);  % Mean square displacement in two scans
        for i = 2:nscans
            delta2(i,1) = (mv_data(i-1,1) - mv_data(i,1))^2 +...
                    (mv_data(i-1,2) - mv_data(i,2))^2 +...
                    (mv_data(i-1,3) - mv_data(i,3))^2; 
            delta2(i,1) = sqrt(delta2(i,1));
        end
 % Average scan-to-scan motion over scan session
 meandelta = mean(delta(:,1));
 meandeltafsl = mean(delta2(:,1));
 % Count the head jerks larger than 0.2 mm, and 0.5 mm.
 jerks2 = find(delta(:,1) > 0.2);
 numjerks02 = length(jerks2);
 jerks = find(delta(:,1) > 0.5);
 numjerks05 = length(jerks);
 % Head jerks by method in Lemieux 2007
 jerksLem = find(delta2(:,1) > 0.2);
 numjerksLem = length(jerksLem);
 
 
 
 
 if nargin == 0 | ( nargin > 0 & isubj == 1 )
     disp(' ')
     disp('SIX motion metrics are computed.')
     disp('Max translational motion from reference scan.')
     disp('Max range of translational motion.')
     disp('Average RMS motion from reference scan. Includes rotation in degrees. (Oates 2005)')
     disp('Average scan-to-scan motion over session.')
     disp('Number of head jerks with translational scan-to-scan > 0.2 mm  (Lemieux)')
     disp('Number of head jerks with trans+rotational scan-to-scan > 0.5 mm  (ArtRepair)')
     %disp('Number of image volumes repaired')
     %disp('Number of image volumes flagged to deweight')
     disp(' ')
 end
 %keyboard;
 X = [ maxmot  maxrange  meanrms   meandelta  numjerksLem  numjerks05  ];
 Xall(isubj,1:6) = X(1:6);
 
 if nargin > 0 & isubj == 1
     disp('Writing results file to Quality Check directory')
     % Total number of scans in a session
     words = ['Number of scans in a session = ' num2str(nscans) ];
     disp(words)
     disp('First motion result is shown here.')
     disp(SubjectDir{isubj});    
     disp(X);  
 end
 if nargin == 0
     disp('Subject')
     disp(fpath) 
     % Total number of scans in a session
     words = ['Number of scans in a session = ' num2str(nscans) ];
     disp(words)
     disp(X);  
 end
 
% PRINT OUT A TABLE OF RESULTS TO SPECIFIED FOLDER
% Each session gets a separate table, in a separate file.
if nargin > 0
  if isubj == 1    % header information and list of subjects
    
    tstamp = clock;
    filen = ['MotionChars',date,'Time',num2str(tstamp(4)),...
        num2str(tstamp(5)),num2str(tstamp(6)),'.txt'];
    logname = fullfile(OutputDir,filen);
    logID = fopen(logname,'wt');
    fprintf(logID,'Motion and Rapid Motion Statistics from art_motionstats program:  \n  %s\n');

    % Print a LIST of subjects rp files used for this analysis
    fprintf(logID,'\nLIST OF INPUT FOLDERS containing rp.txt realignment files');   
    for i = 1:numsubj  %size(Rimages,1)
        fprintf(logID,'\n%3d  %s',i, SubjectDir{i}); 
    end
    
    fprintf(logID,'\n\n Results for Session %d', ksession);
    fprintf(logID,'\n   %d  scans in each session',nscans);
    fprintf(logID,'\n\n SIX motion metrics are computed for each subject.');
    fprintf(logID,'\nFirst column is the subject index number.');
    fprintf(logID,'\n\nMax translational motion from reference scan (mm).');
    fprintf(logID,'\nMax range of translational motion (mm).');
    fprintf(logID,'\nAverage RMS motion from reference volume. Includes rotation in degrees. (Oates,2005)');
    fprintf(logID,'\nMean over session of scan-to-scan relative motion with translation and rotation (mm).');
    fprintf(logID,'\nNumber of head jerks with relative translational motion > 0.2 mm. (Lemieux, 2007)');
    fprintf(logID,'\nNumber of head jerks with relative overall motion > 0.5 mm.  (ArtRepair)');
    %fprintf(logID,'\nNumber of image volumes repaired.');
    %fprintf(logID,'\nNumber of image volumes flagged to deweight.  \n');
  end

% For each subject, print out subject ID and X array
  fprintf(logID,'\n%4d %8.4f   %8.4f   %8.4f   %8.4f  %6d.0  %6d.0', isubj, X);
  ComTransRot(isubj,1:4) = [ maxmot  maxrange  57.3*maxrotmot  57.3*maxrotrange ];
    
  if isubj == numsubj;  fclose(logID); end
end  % end print to file for batch mode

end

end % THIS IS THE KSESSION OUTER LOOP

if nargin >0; disp(ComTransRot); end
dummy = 1;


%save Xall Xall;