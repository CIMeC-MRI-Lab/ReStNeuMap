function art_slice(Pimages, OUTSLICE, repair_flag, mask_flag)
% FORMAT art_slice  (v3.1)
% 
% SUMMARY
%   Reads a set of images and writes a new set of images 
%   after filtering the data for noise.  User is asked to choose the
%   repair method or methods. This program is best applied
%   to the raw images, so the cleaned output images can be fed into
%   slicetiming or realignment algorithms. 
%
%   V.2 uses the scale factor of input images for the output images
%   to improve compatibility when output is used by external programs
%   (SPM and FSL use different default scaling.)
%
%   To automatically screen an image data set for bad slices, use the
%   Detect and Repair Bad Slices option which writes a BadSliceLog
%   of all the bad slices detected and repaired.
%
%   No original data is removed- the old images are all preserved.
%
% User is asked via GUI to supply:
%   - Set of images
%   - A repair method
%   - If repairing bad slices, user can choose a threshold.
% POSSIBLE REPAIRS
% 1. Filter all the images with a 3-point median filter in time. An 
%     excellent filter for block designs with TR=2 or less. If TR > 2 sec.,
%     or for Rapid Event 
%     experiments where events are separated by 2 TR's or less, this filter
%     may reduce sensitivity and clobber activations.
%     Adds a prefix "f" to the cleaned output images.
% 2. Detect and repair bad slices. Derives new values for the bad slice
%     using linear interpolation of the before and after volumes.
%     If the same slice is bad in multiple volumes, uses spatial
%     interpolation with neighboring slices instead of pure temporal
%     interpolation (added logic for v3).
%     Bad slices are detected when the amount of data scattered outside
%     the head is at least T above the usual amount for the slice. (The usual
%     amount is determined as the average of the best two of the first three 
%     volumes. It differs for each slice.) The default
%     value of T is 5, which the user can adjust. A preview estimate
%     of the amount of repaired data at T=5 is shown in the Matlab window.
%     This filter removes outliers, but may reduce activations, so it's 
%     safest when fewer than 5% of the slices are cleaned up. 
%     Adds a prefix "g" to the cleaned output images.
%     Writes a text file BadSliceLog of all bad slices detected.
% 3. Eliminate data outside the head. Generates a head mask automatically,
%     and writes it as ArtifactMask.img. Sets voxels outside the head 
%     to zero. This process may help realignment to be more accurate when
%     there is large clutter in the field of view, e.g. prenatal imaging.
%     Adds a prefix "h" to the cleaned output images.
% 4. Combinations of methods 1 and 3, or 2 and 3.
%
% NOTES
%  1. Use art_movie to compare the input and repaired images.
%  2. First and last volumes will not be filtered.
% Paul Mazaika - December 2004.  V.2  August 2006, 
% v2.2  allows user to specify a head mask instead of automatic. July 2007
% v2.3  compatible with multiple spm versions.  Mar09
% v3.0  added code for cases when slice used for interpolation is
%       artifactual. Dorian Pustina, Oct 2012
% v3.1  supports SPM12 Dec2014 pkm.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


% PARAMETERS
OUTSLICEdef =  18;  %  Threshold above sample means to filter slices
   %  15 is very visible on contrast image. 8 is slightly visible.
   
% THREEE CONTROL OPTIONS
%   Mask the images    - Set amask = 1.
%   Median filter all the images  - Set allfilt = 1.
%   Detect and repair bad slices  - Set slicefilt = 1.
if strcmp(spm_ver,'spm5')
    %mask = spm_select(1, 'image', 'Select mask image in functional space'); 
    if exist('Pimages','var') == 0, Pimages  = spm_select(Inf,'image','select images'); end
 else  % spm2 version
    %mask = spm_get(1, '.img', 'Select mask image in functional space');
    if exist('Pimages','var') == 0, Pimages  = spm_get(Inf,'image','select images'); end;
 end

P = spm_vol(Pimages);

if exist('repair_flag','var') == 0
    repair_flag = spm_input('Which repair methods to use?', 1, 'm', ...
    ' Repair Bad Slices and Write BadSliceLog ( repairs only the bad slices ) | Median Filter All Data  ( aggressive filter for very noisy data ) | Eliminate data outside head | Repair Bad Slices and Eliminate data outside head | Median Filter All Data and Eliminate data outside head',...
              [1 2 3 4 5], 1);
end

if ( repair_flag == 3 ) amask = 1; allfilt = 0; slicefilt = 0; end
if ( repair_flag == 1 ) amask = 0; allfilt = 0; slicefilt = 1; end
if ( repair_flag == 2 ) amask = 0; allfilt = 1; slicefilt = 0; end
if ( repair_flag == 4 ) amask = 1; allfilt = 0; slicefilt = 1; end
if ( repair_flag == 5 ) amask = 1; allfilt = 1; slicefilt = 0; end

%  Set the prefix correctly on the written files
if  ( amask ==1 & allfilt == 0 & slicefilt == 0 ) prechar = 'h'; end
if  ( amask ==1 & allfilt == 1 & slicefilt == 0 ) prechar = 'fh'; end
if  ( amask ==1 & allfilt == 0 & slicefilt == 1 ) prechar = 'gh'; end
if  ( amask ==0 & allfilt == 1 & slicefilt == 0 ) prechar = 'f'; end
if  ( amask ==0 & allfilt == 0 & slicefilt == 1 ) prechar = 'g'; end

fprintf('\n NEW IMAGE FILES WILL BE CREATED');
fprintf('\n The filtered scan data will be saved in the same directory');
fprintf('\n with %s pre-pended to their filenames.\n',prechar);

if amask == 1 | slicefilt == 1 %  Automask options
    if exist('mask_flag','var') == 0
        mask_flag = spm_input('Which mask image to use?', 1, 'm', ...
    'Automatic ( will generate ArtifactMask image ) | User specified mask ',...
              [1 2], 1);
    end
        if mask_flag == 2
         if strcmp(spm_ver,'spm5')
             maskimg = spm_select(1, 'image', 'Select mask image in functional space');
         else  % spm2 version
             maskimg = spm_get(1, '.img', 'Select mask image in functional space');
         end
         Automask = spm_read_vols(spm_vol(maskimg));
         maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
         voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
    else  %  mask_flag == 1
        fprintf('\n Generated mask image is written to file ArtifactMask.img.\n');
        fprintf('\n');
        Pnames = P(1).fname;
        Automask = art_automask(Pnames(1,:),-1,1);
        maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
        voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
    end
end

if amask == 1
    fprintf('\n ELIMINATE DATA OUTSIDE HEAD');
    fprintf('\n All scans will have voxels outside the head set to zero.\n');
end

if slicefilt == 1  % Prepare some thresholds for slice testing.
    fprintf('\n INTERPOLATE THROUGH BAD SLICES\n');
    % Find the slice orientation used to collect the data
    [ vx, vy, vz ] = size(Automask);
    orient = 0;
    if ( vx < vy & vx < vz ) orient = 1; disp(' Remove bad Sagittal slices'); end
    if ( vy < vx & vy < vz ) orient = 2; disp(' Remove bad Coronal slices'); end
    if ( vz < vx & vz < vy ) orient = 3; disp(' Remove bad Axial slices'); end
    nslice = min([vx vy vz]);
    if ( orient == 0 ) 
        disp('Cannot determine slice orientation for bad slice filtering.')
        return; 
    end
    % Find 3 samples of slice baseline activity outside the head.
    p = zeros(3,nslice);
    for i = 1:3
        Y1 = spm_read_vols(P(i));
        Y1 = ( 1 - Automask ).*Y1;
        % Get the plane sums perpendicular to orient direction
        if ( orient == 1 ) p(i,:) = mean(mean(Y1,3),2); end 
        if ( orient == 2 ) p(i,:) = mean(mean(Y1,1),3); end 
        if ( orient == 3 ) p(i,:) = mean(mean(Y1,1),2); end 
    end
    % Select a low value for each plane, and set threshold a bit above it.
    pq = 0.5*( min(p) + median(p,1));
    % Preview estimate of bad slice fraction...
       prebad = length(find(p(1,:) > pq + OUTSLICEdef));
       prebad = length(find(p(2,:) > pq + OUTSLICEdef)) + prebad;
       prebad = length(find(p(3,:) > pq + OUTSLICEdef)) + prebad;
       percentbad = round(prebad*100/(3*nslice));
       disp('Estimated percent bad slices at default threshold')
       disp(percentbad)
    % User Input Threshold, and default suggestion.
    if exist('OUTSLICE','var') == 0
        OUTSLICE = spm_input(['Select threshold (default is shown)' ],1,'n',OUTSLICEdef); 
    end
    pq = pq + OUTSLICE;  % pq array is the threshold test for bad slices.
    fprintf('\n Interpolating new values for bad slices when ');
    fprintf('\n average value outside head is %3d counts over baseline.\n',OUTSLICE);
    fprintf('\n Bad slice log will be written.');
    fprintf('\n');
    %  DETECT, COUNT, AND LOG THE ARTIFACTS
    disp('Writing Artifact Log to location of image set')
    [ dirname, sname ] = fileparts(P(1).fname);   %  XXXXXX
    tstamp = clock;
    filen = ['BadSliceLog',date,'Time',num2str(tstamp(4)),num2str(tstamp(5)),'.txt'];
    logname = fullfile(dirname,filen);
    logID = fopen(logname,'wt');
    fprintf(logID,'Bad Slice Log, Image Set first file is:  \n  %s\n', sname);
    fprintf(logID,'Test Criteria for Artifacts');  
    fprintf(logID,'\n  Outslice (counts) = %4.1f' , OUTSLICE);
    fprintf(logID,'\n Slice Artifact List (Vol 1 = First File)\n');
	BadError = 0;     % Counts bad slices
end
     
if allfilt == 1
    fprintf('\n MEDIAN FILTER ALL THE DATA');
	fprintf('\n All scans are being filtered by median 3-point time filter.');
	fprintf('\n This is safe to do when TR = 2. Otherwise, use the');
	fprintf('\n    Remove Bad Slices option instead.\n');
    fprintf('\n');
end
spm_input('!DeleteInputObj');


%% Main Loop - Filter everything but the first and last volumes.
% Procedure:
% first two volumes in Y4(1) and Y4(2)
% start 'for loop' from third volume and put it in Y4(3)
% mask Y4(2) with automask and put in Y
% find mean(Y) and compare with threshold for specific slice pq(j)
% if higher than threshold interpolate slice as mean from adjacent Y4(1) and Y4(3)
% shift Y4(1<-2<-3) and check next Y4(3)


nscans = size(P,1);
STDvol = art_slice_STD(P, orient, nscans, pq, Automask, vx, vy, vz);
Y4(1,:,:,:) = spm_read_vols(P(1));  % rows vary fastest
Y4(2,:,:,:) = spm_read_vols(P(2));
for i = 3:nscans
        Y4(3,:,:,:) = spm_read_vols(P(i));  % this is the post volume
        if allfilt == 1  % Filter all data by median.
            Yn = median(Y4,1);
            Yn2 = squeeze(Yn);
        end
        if slicefilt == 1  % Repair bad slices by linear interpolation.
            % Check if outside head value is over pq. If so, filter.
            
            Yn1 = squeeze(Y4(1,:,:,:)); % pre-post volumes
            Yn3 = squeeze(Y4(3,:,:,:));
            Ypre = ( 1 - Automask).*Yn1;
            Ypost = ( 1 - Automask).*Yn3;
            
            Yn2 = squeeze(Y4(2,:,:,:)); % actual volume
            Y = ( 1 - Automask).*Yn2;
            if ( orient == 1 ) 
                pypre = mean(mean(Ypre,3),2);
                pypost = mean(mean(Ypost,3),2);
                py = mean(mean(Y,3),2);
                for j = 1:vx
                    if py(j) > pq(j)  % slice needs to be filtered.
                        % new code, check pre post slices are not over threshold
                        if pypost(j) > pq(j) && pypre(j) < pq(j)      % POST BAD, PRE OK
                            
                            % calculate amount of change this slice would
                            % have changed according to the change of the
                            % adjacent slice
                            addvalue = 0;
                            if j > 1                                                    % if slice not first
                                change = LastGoodVol(j-1,:,:) - Yn2(j-1,:,:);           % how much the adjacent slice changed between last volume and this volume
                                sliceSTD = STDvol(j-1,:,:);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(j,:,:).*STDchange;                    % apply the same ratio to calculate current slice change
                            end                               
                            
                            % if slice is first, addvalue =0  and
                            % slice would be equal to pre in time                            
                            Yn2(j,:,:) = squeeze(Y4(1,j,:,:))+addvalue;       % set to pre + calculated change from adjacent slice
                            fprintf('   Interpolated sagittal with pre. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated sagittal with pre. Vol %d, Slice %d.\n',i-1,j);
                            
                        elseif pypost(j) < pq(j) && pypre(j) > pq(j)   % POST OK, PRE BAD
                            
                            % calculate amount of change this slice would
                            % have changed according to the adjacent slice
                            addvalue = 0;
                            if j > 1 && pypost(j-1) < pq(j-1)                           % if slice not first and adjacent of next volume not bad
                                change = squeeze(Y4(3,j-1,:,:)) - Yn2(j-1,:,:);         % how much the adjacent slice will change to next volume
                                sliceSTD = STDvol(j-1,:,:);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(j,:,:).*STDchange;                    % apply the same ratio to calculate current slice change
                            end                            

                            % if slice is first or adjacent of next volume is bad
                            % addvalue=0 and slice will be equal to post in time
                            Yn2(j,:,:) = squeeze(Y4(3,j,:,:)) + addvalue;        % set to post + calculated change from adjacent slice
                            fprintf('   Interpolated sagittal with post. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated sagittal with post. Vol %d, Slice %d.\n',i-1,j);
                            
                        elseif pypost(j) > pq(j) && pypre(j) > pq(j)   % PRE BAD, POST BAD
                            
                            % calculate amount of change this slice would
                            % have changed according to the change of the
                            % adjacent slice
                            addvalue = 0;
                            if j > 1                                                    % if slice not first
                                change = LastGoodVol(j-1,:,:) - Yn2(j-1,:,:);           % how much the adjacent slice changed between last volume and this volume
                                sliceSTD = STDvol(j-1,:,:);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(j-1,:,:).*STDchange;                    % apply the same ratio to calculate current slice change
                            end                              
                            
                            Yn2(j,:,:) = LastGoodVol(j,:,:) + addvalue;          % set to last good known slice + value of change
                            fprintf('   Interpolated sagittal with latest good one. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated sagittal with latest good one. Vol %d, Slice %d.\n',i-1,j);
                            
                        else                                                        % PRE GOOD, POST GOOD (original pre-post inrepolation)
                            
                            Yn2(j,:,:) = squeeze((Y4(1,j,:,:) + Y4(3,j,:,:))/2.0);  % interpolate pre and post
                            fprintf('   Interpolated sagittal. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated sagittal. Vol %d, Slice %d.\n',i-1,j);
                            
                        end
                        
                        LastGoodVol = Yn2(j,:,:);
                        BadError = BadError + 1;   
                    end
                    LastGoodVol = Yn2;
                end 
            end
            if ( orient == 2 )
                pypre = mean(mean(Ypre,1),3);
                pypost = mean(mean(Ypost,1),3);
                py = mean(mean(Y,1),3); 
                for j = 1:vy
                    if py(j) > pq(j)  % slice needs to be filtered.
                        % new code, check pre post slices are not over threshold
                        if pypost(j) > pq(j) && pypre(j) < pq(j)      % post bad, pre ok
                            
                            % calculate amount of change this slice would
                            % have changed according to the change of the
                            % adjacent slice
                            addvalue = 0;
                            if j > 1                                                    % if slice not first
                                change = LastGoodVol(:,j-1,:) - Yn2(:,j-1,:);           % how much the adjacent slice changed between last volume and this volume
                                sliceSTD = STDvol(:,j-1,:);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(:,j,:).*STDchange;                    % apply the same ratio to calculate current slice change
                            end                            
 
                            % if slice is first, addvalue =0  and
                            % slice would be equal to pre in time
                            Yn2(:,j,:) = squeeze(Y4(1,:,j,:))+addvalue;       % set to pre + calculated change from adjacent slice
                            fprintf('   Interpolated coronal with pre. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated coronal with pre. Vol %d, Slice %d.\n',i-1,j);
                        elseif pypost(j) < pq(j) && pypre(j) > pq(j)   % post ok, pre bad
                            
                            % calculate amount of change this slice would
                            % have changed according to the adjacent slice
                            addvalue = 0;
                            if j > 1 && pypost(j-1) < pq(j-1)                           % if slice not first and adjacent of next volume not bad
                                change = squeeze(Y4(3,:,j-1,:)) - Yn2(:,j-1,:);         % how much the adjacent slice will change to next volume
                                sliceSTD = STDvol(:,j-1,:);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(:,j,:).*STDchange;                    % apply the same ratio to calculate current slice change
                            end                            

                            % if slice is first or adjacent of next volume is bad
                            % addvalue=0 and slice will be equal to post in time
                            Yn2(:,j,:) = squeeze(Y4(3,:,j,:)) + addvalue;        % set to post + calculated change from adjacent slice
                            fprintf('   Interpolated coronal with post. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated coronal with post. Vol %d, Slice %d.\n',i-1,j);
                        elseif pypost(j) > pq(j) && pypre(j) > pq(j)   % pre bad, post bad
                            
                            % calculate amount of change this slice would
                            % have changed according to the change of the
                            % adjacent slice
                            addvalue = 0;
                            if j > 1                                                    % if slice not first
                                change = LastGoodVol(:,j-1,:) - Yn2(:,j-1,:);           % how much the adjacent slice changed between last volume and this volume
                                sliceSTD = STDvol(:,j-1,:);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(:,j-1,:).*STDchange;                    % apply the same ratio to calculate current slice change
                            end                            
                            
                            Yn2(:,j,:) = LastGoodVol(:,j,:) + addvalue;          % set to last good known slice + value of change
                            fprintf('   Interpolated coronal with latest good one. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated coronal with latest good one. Vol %d, Slice %d.\n',i-1,j);
                        else                                                        % pre good, post good
                            Yn2(:,j,:) = squeeze((Y4(1,:,j,:) + Y4(3,:,j,:))/2.0);  % interpolate pre and post
                            fprintf('   Interpolated coronal. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated coronal. Vol %d, Slice %d.\n',i-1,j);
                        end
                            
                        LastGoodVol = Yn2(:,j,:);
                        BadError = BadError + 1; 
                    end
                end 
            end 
            if ( orient == 3 )
                pypre = mean(mean(Ypre,1),2);
                pypost = mean(mean(Ypost,1),2);
                py = mean(mean(Y,1),2);
                for j = 1:vz
                    if py(j) > pq(j)  % slice needs to be filtered.
                        % new code, check pre post slices are not over
                        % threshold and interpolates intelligently
                         
                        if pypost(j) > pq(j) && pypre(j) < pq(j)                         % post bad, pre ok
 
                            % calculate amount of change this slice would
                            % have changed according to the change of the
                            % adjacent slice
                            addvalue = 0;
                            if j > 1                                                    % if slice not first
                                change = LastGoodVol(:,:,j-1) - Yn2(:,:,j-1);           % how much the adjacent slice changed between last volume and this volume
                                sliceSTD = STDvol(:,:,j-1);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(:,:,j).*STDchange;                    % apply the same ratio to calculate current slice change
                            end
                            
                            % if slice is first, addvalue =0  and
                            % slice would be equal to pre in time
                            Yn2(:,:,j) = squeeze(Y4(1,:,:,j)) + addvalue;                 % set to pre + calculated change from adjacent slice
                            fprintf('   Interpolated axial with pre. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated axial with pre. Vol %d, Slice %d.\n',i-1,j);      
                            
                            
                        elseif pypost(j) < pq(j) && pypre(j) > pq(j)   % post ok, pre bad
                            
                            % calculate amount of change this slice would
                            % have changed according to the adjacent slice
                            addvalue = 0;
                            if j > 1 && pypost(j-1) < pq(j-1)                           % if slice not first and adjacent of next volume not bad
                                change = squeeze(Y4(3,:,:,j-1)) - Yn2(:,:,j-1);         % how much the adjacent slice will change to next volume
                                sliceSTD = STDvol(:,:,j-1);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(:,:,j).*STDchange;                    % apply the same ratio to calculate current slice change
                            end

                            % if slice is first or adjacent of next volume is bad
                            % addvalue=0 and slice will be equal to post in time
                            Yn2(:,:,j) = squeeze(Y4(3,:,:,j)) + addvalue;        % set to post + calculated change from adjacent slice
                            fprintf('   Interpolated axial with post. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated axial with post. Vol %d, Slice %d.\n',i-1,j);
                            
                        
                         elseif pypost(j) > pq(j) && pypre(j) > pq(j)   % pre bad, post bad

                            % calculate amount of change this slice would
                            % have changed according to the change of the
                            % adjacent slice
                            addvalue = 0;
                            if j > 1                                                    % if slice not first
                                change = LastGoodVol(:,:,j-1) - Yn2(:,:,j-1);           % how much the adjacent slice changed between last volume and this volume
                                sliceSTD = STDvol(:,:,j-1);                             % what is the STD for the adjacent slice
                                STDchange = change./sliceSTD;                           % ratio of change of adjacent slice compared to its STD
                                addvalue = STDvol(:,:,j).*STDchange;                    % apply the same ratio to calculate current slice change
                            end
                            
                            Yn2(:,:,j) = LastGoodVol(:,:,j) + addvalue;          % set to last good known slice + value of change
                            fprintf('   Interpolated axial with latest good one. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Replaced axial with latest good one. Vol %d, Slice %d.\n',i-1,j);
  
                        else                                                        % pre good, post good
                            Yn2(:,:,j) = squeeze((Y4(1,:,:,j) + Y4(3,:,:,j))/2.0);  % interpolate pre and post
                            fprintf('   Interpolated axial. Vol %d, Slice %d.\n',i-1,j);
                            fprintf(logID,'   Interpolated axial. Vol %d, Slice %d.\n',i-1,j);
  
                        end
                        BadError = BadError + 1; 
                    end
                end 
            end    
        end
        
        LastGoodVol = Yn2;
        
        if  ( allfilt == 0 & slicefilt == 0 )  % Head mask only.
            Yn2 = squeeze(Y4(2,:,:,:));
        end
        % Yn is a 4D file including the smoothed Y2 now.
        if ( amask ) Yn2 = Yn2.*Automask; end
        % Prepare the header for the filtered volume.
           V = spm_vol(P(i-1).fname);
           v = V;
           [dirname, sname, sext ] = fileparts(V.fname);
           sfname = [ prechar, sname ];
           filtname = fullfile(dirname,[sfname sext]);
           v.fname = filtname;
        %spm_write_vol(v,Yn2);  
        noscale_write_vol(v,Yn2);
        showprog = [' Writing volume   ', prechar, sname, sext ];
        disp(showprog); 
        if i == 3   % Write unfiltered first scan
            Yn1 = squeeze(Y4(1,:,:,:)); 
            if ( amask ) Yn1 = Yn1.*Automask; end
            [dirname, sname, sext ] = fileparts(P(1).fname);
            sfname = [ prechar, sname ];
            filtname = fullfile(dirname,[sfname sext]);
            v.fname = filtname;
            %spm_write_vol(v,Yn1); 
            noscale_write_vol(v,Yn1);
            showprog = [' Writing volume   ', prechar, sname, sext ];
            disp(showprog); 
        end
        if i == nscans  % Write unfiltered last scan.
            Yn1 = squeeze(Y4(3,:,:,:));
            if ( amask ) Yn1 = Yn1.*Automask; end
            Vlast = spm_vol(P(nscans).fname);
            [dirname, sname, sext ] = fileparts(P(nscans).fname);
            sfname = [ prechar, sname ];
            filtname = fullfile(dirname,[sfname sext]);
            v.fname = filtname;
            %spm_write_vol(v,Yn1); 
            noscale_write_vol(v,Yn1);
            showprog = [' Writing volume   ', prechar, sname, sext ];
            disp(showprog); 
        end
        
        % Slide the read volumes window up.
        Y4(1,:,:,:) = Y4(2,:,:,:);
        Y4(2,:,:,:) = Y4(3,:,:,:); 
end

%  Summarize the slice errors, in the bad slice case.
if slicefilt == 1
    totalslices = nscans*nslice;
    ArtifactCount = BadError;  %  Number of unique bad slices with artifacts
    badpercent = BadError*100.0/totalslices;
    if ( ArtifactCount == 0 )
        disp(' CLEAN DATA! No bad slices detected'); 
        fprintf(logID, '\n\nCLEAN DATA. No bad slices detected.');
    end
    if  ArtifactCount > 0
        fprintf(logID,'\n\n Number of slices repaired = %4.0d',ArtifactCount);
        fprintf(logID,'\n\n Percentage of slices repaired = %5.1f',badpercent);
    end
    fclose(logID); 
end
    
disp(['Done! ' num2str(BadError) ' slices fixed (' num2str(round(badpercent)) '%)' ]);

%---------------------------------------------------------------
% Create and write image without the scale and offset steps  
% This function is spm_write_vol without error checking and scaling.
function noscale_write_vol(V,Y);
V = spm_create_vol(V);
for p=1:V.dim(3),
    V = spm_write_plane(V,Y(:,:,p),p);
end;
%V = spm_close_vol(V);  % not for SPM5


