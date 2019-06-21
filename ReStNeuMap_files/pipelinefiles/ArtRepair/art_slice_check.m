function [slices orient] = art_slice_check(Pimages)
% This is a reduced version of art_slice used used to calculate bad slices for display
% purposes. This function is called by art_movie.
% Any changes made to this file WILL NOT reflect the actual bad
% slice repair performed by art_slice.m
% Viceversa, any change to art_slice WILL NOT reflect the correct
% display of bad slices by art_movie.
% Dorian Pustina, October 2012, v. 1
% supports SPM12, Dec2014 pkm.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


% PARAMETERS
OUTSLICEdef =  10;  %  Threshold above sample means to filter slices
   %  15 is very visible on contrast image. 8 is slightly visible.

P = spm_vol(Pimages);

amask = 0; allfilt = 0; slicefilt = 1;


if amask == 1 | slicefilt == 1 %  Automask options
    mask_flag = 1

    fprintf('\n Generated mask image is written to file ArtifactMask.img.\n');
    fprintf('\n');
    Pnames = P(1).fname;
    Automask = art_automask(Pnames(1,:),-1,1);
    maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
    voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
end


if slicefilt == 1  % Prepare some thresholds for slice testing.
    % Find the slice orientation used to collect the data
    [ vx, vy, vz ] = size(Automask);
    orient = 0;
    if ( vx < vy & vx < vz ) orient = 1; disp(' Orientation: Sagittal'); end
    if ( vy < vx & vy < vz ) orient = 2; disp(' Orientation: Coronal'); end
    if ( vz < vx & vz < vy ) orient = 3; disp(' Orientation Axial'); end
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
       disp(['Estimated percent bad slices at default threshold (' num2str(OUTSLICEdef) '):'])
       disp(percentbad)
    % User Input Threshold, and default suggestion.
    OUTSLICE = spm_input(['Bad slice threshold' ],1,'n',OUTSLICEdef);
    disp('User threshold:');
    disp(OUTSLICE)
    pq = pq + OUTSLICE;  % pq array is the threshold test for bad slices.
    %  DETECT, COUNT, AND LOG THE ARTIFACTS
    BadError = 0;     % Counts bad slices
end
     

spm_input('!DeleteInputObj');


% Main Loop - Filter everything but the first and last volumes.
nscans = size(P,1);
Y4(1,:,:,:) = spm_read_vols(P(1));  % rows vary fastest
Y4(2,:,:,:) = spm_read_vols(P(2));
slice_check{length(Pimages)} = []; % initialize main variable at number of images
h = waitbar(0,['Calculating bad slices'], 'Name','Please wait'); BadError = 0;
for i = 3:nscans

        waitbar(i/nscans,h,['Bad slices found: ' num2str(BadError)]);
    
        Y4(3,:,:,:) = spm_read_vols(P(i));
        if allfilt == 1  % Filter all data by median.
            Yn = median(Y4,1);
            Yn2 = squeeze(Yn);
        end
        if slicefilt == 1  % Repair bad slices by linear interpolation.
            % Check if outside head value is over pq. If so, filter.
            Yn2 = squeeze(Y4(2,:,:,:));
            Y = ( 1 - Automask).*Yn2;
            if ( orient == 1 ) 
                py = mean(mean(Y,3),2); 
                for j = 1:vx
                    if py(j) > pq(j)  % slice needs to be filtered.
                        slice_check{i-1} = [slice_check{i-1} j];      % register the slice and volume number
                        BadError = BadError + 1;
                    end  
                end 
            end
            if ( orient == 2 )
                py = mean(mean(Y,1),3); 
                for j = 1:vy
                    if py(j) > pq(j)  % slice needs to be filtered.
                        slice_check{i-1} = [slice_check{i-1} j];      % register the slice and volume number
                        BadError = BadError + 1;
                    end  
                end 
            end 
            if ( orient == 3 )
                py = mean(mean(Y,1),2);
                for j = 1:vz
                    if py(j) > pq(j)  % slice needs to be filtered.
                        slice_check{i-1} = [slice_check{i-1} j];      % register the slice and volume number
                        BadError = BadError + 1;
                    end  
                end 
            end
        end

        % Slide the read volumes window up.
        Y4(1,:,:,:) = Y4(2,:,:,:);
        Y4(2,:,:,:) = Y4(3,:,:,:); 
end
delete(h)
disp(['Total number of bad slices found:']);
disp(BadError);
slices = slice_check;



