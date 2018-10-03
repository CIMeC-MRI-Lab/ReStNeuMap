function zout = art_despike(Images,FiltType,Despike)
% FUNCTION art_despike(Images,FiltType,Despike)
%  >> art_despike   to run by GUI
%
% Removes spikes and slow variations using clipping and a high pass filter.
% Generally, these functions remove large noise at the expense of slightly
% reducing the contrast between conditions. 
% WARNING! FOR UNNORMALIZED IMAGES ONLY. The large size of normalized
% images may cause this program to crash or go very slow.
%
% The user can choose a despike threshold and the type of filter.
% The DESPIKE function clips all values further than DESPIKE % from a
% rolling mean to exactly a DESPIKE % deviation. For example, if DESPIKE=4,
% a spike of size 6% will be reduced to size 4. Despiking is performed
% voxel-wise, since spikes may occur only on some voxels. Despike can be
% turned off by setting Despike=0.  
%  
% The high pass filter removes slow variations on each voxel with an AC-coupled
% filter, and adds the mean input image to write the output images. The
% GUI allows two high pass filter choices and a smoothing filter. The ends
% of the dataset are padded by reflection for the filter process. If both
% despike and filtering are chosen, images will be despiked before
% entering the high pass filter.
%
% INPUTS
%    Images is a list of images, in a single session.
%       Images must all have the same orientation and size.
%    FiltType has 4 options:
%       1. 17-tap filter, aggressive high pass filter.
%       2. 37-tap filter, long filter for block designs. SPM high pass 
%          filter may be better since it preserves gain.
%       3. No high pass filtering is done. Despiking is done based
%          on a 17-point moving average of unfiltered data.
%       4. Matched filter for single events using temporal smoothing.
%          Perhaps useful for movies of ER fMRI
%    Clip Threshold is used to despike the data, in units of percentage
%       signal change computed relative to the mean image.
%       If Despike = 0, no clipping is done. Despike=4 is the default.
% OUTPUTS
%    Images with a prefix "d" (for despike or detrend) in the same directory.
%       The filtered images have the same mean as the original series.
%    Mean input image, named meenINPUT.img, where INPUT is input image
%       name. Misspelling of mean is deliberately different from mean
%       image produced by spm realignment.
%    All input images are preserved.
%
% Clips and filters about 1 volume per second with default settings.
% SPM high-pass filtering is OK, but not required after this filter.
% Note these filters are applied to only the data, so there is a filter
% gain to try to preserve a quantitative amplitude information. This works
% OK for ER designs, but not as well for block designs. The SPM high pass
% filter applies to the data and design matrix, and is better for blocks. 
% Runs through all the images sequentially like a pipeline.
%
%  Compatible with SPM5, SPM8, SPM12 and SPM2.
%  Compatible with AnalyzeFormat and Nifti images.
%  v.1  July 2008  Paul Mazaika
%  v.2  May 2009 pkm  despike output works off centered mean.
%  v.3  supports SPM12. Bug fix for .nii by M. Schmitgen. Dec14

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin == 0
    CLIP = 1;   % 1 to despike,  0 to not despike which is a bit faster.
    % DE-SPIKE CLIP PERCENTAGE. Default is 4%.
    Despikedef = 4;
    Despike = spm_input('Enter clip threshold (pct sig chg)',1,'e',Despikedef);
    if Despike == 0; CLIP = 0; end
    FiltType = spm_input('Select high pass filter',...
		1,'m','17-tap, Robust filter for noisy images |37-tap, Better for block designs in clean images |No high pass filter.|Matched filter for isolated ER designs',[ 1 2 3 4], 1);
    if (Despike == 0 & FiltType == 3) disp('Error: Conflict in inputs.'); return; end;
    if strcmp(spm_ver,'spm5')
        Pimages = spm_select(Inf,'image','Select images to filter');
    else   % spm2
        Pimages  = spm_get(Inf,'.img','select images to filter');
    end
else
    Pimages = Images;
    %afilt = HPFilter;
    if Despike == 0 & FiltType ~= 3
        CLIP = 0
    elseif Despike > 0
        CLIP = 1;
    elseif Despike == 0 & FiltType == 3
        disp('Error: Conflict in art_despike inputs.');
        return;
    end
end

% Set up filter coefficients
%   HPFilter is a filter vector (1,N) where N must be ODD in length
%       and the sum of the coefficients is zero.
if FiltType == 1
    %  17-tap high pass filter with the coefficients sum of zero
    afilt = [ -1 -1 -1 -1 -1.5 -1.5 -2 -2 22 -2 -2 -1.5 -1.5 -1 -1 -1 -1];
    gain = 1.1/22;  % gain is set for small bias for HRF shape
elseif FiltType == 2
    %  37-tap high pass filter, Takes about 2 sec per image.
    afilt = [ -ones(1,18)  36  -ones(1,18) ];
    gain = 1/36;  % gain is set for small avg. bias to block length 11.
elseif FiltType == 3
    % Skip filtering step. nfilt =17 for clipping baseline.
    afilt = [ -ones(1,7) 0 14 0  -ones(1,7)  ];  % dummy values used only to set nfilt.
    gain = 1/14;
elseif FiltType == 4
    % Movie filter, to possibly see single HRFs in art_movie
    % Filter is matched to HRF shape, assuming TR=2 sec.
    afilt = [ -1 -1 -1.2 -1.2 -1.2 -1.2 -1 -1 2.5 6.3 6.3 2.5 0 -1 -1 -1.2 -1.2 -1.2 -1.2 -1 -1];
    gain = 1/14;
end

% Filter characterization
nfilt = length(afilt); 
if mod(nfilt,2) == 0   % check that filter length is odd.
    disp('Warning from art_despike: Filter length must be odd')
    return
end
if abs(mean(afilt)) > 0.000001
    disp('Warning from art_despike: Filter coefficients must sum to zero.')
    return
end
lag = (nfilt-1)/2;  % filtered value at 9 corresponds to a peak at 5.
% Convert despike threshold in percent to fractional mulitplier limits
spikeup = 1 + 0.01*Despike;
spikedn = 1 - 0.01*Despike;

fprintf('\n NEW IMAGE FILES WILL BE CREATED');
fprintf('\n The filtered scan data will be saved in the same directory');
fprintf('\n with "d" (for despike or detrend) pre-pended to their filenames.\n');
prechar = 'd';
if CLIP == 1
    disp('Spikes are clipped before high pass filtering')
    disp('Spikes beyond this percentage value are clipped.')
    disp(Despike)
else
    disp('No despiking will be done.');
end
if FiltType ~= 3
    disp('The high pass filter is:');
    disp(afilt);
    wordsgain = [ 'With gain =' num2str(gain) ];
    disp(wordsgain);
else
    disp('No filtering will be done.');
end



% FILTER AND DESPIKE IMAGES
% Process all the scans sequentially
% Start and End are padded by reflection, e.g. sets data(-1) = data(3).
% Initialize lagged values for filtering with reflected values
% Near the end, create forward values for filtering with reflected values.

% Find mean image
    P = spm_vol(Pimages);
    startdir = pwd;
    cd(fileparts(Pimages(1,:)));
    [ xaa, xab, xac ] = fileparts(Pimages(1,:));
    xaab = strtok(xab,'_');   % trim off the volume number
    %meanimagename = [ 'mean' xaab xac ];
    meanimagename = [ 'meen' xaab '.img' ];
    local_mean_ui(P,meanimagename);
    Pmean = spm_vol(meanimagename);
    Vmean = spm_read_vols(Pmean);
    nscans = size(Pimages,1);

% Initialize arrays with reflected values.
Y4 = zeros(nfilt,size(Vmean,1),size(Vmean,2),size(Vmean,3));
Y4s = zeros(1,size(Vmean,1),size(Vmean,2),size(Vmean,3));
disp('Initializing filter inputs for starting data')
for i = 1:(nfilt+1)/2
    i2 = i + (nfilt-1)/2;
    Y4(i2,:,:,:) = spm_read_vols(P(i));
    i3 = (nfilt+1) -  i2;
    if i > 1   % i=1 then i3 = i2.
        Y4(i3,:,:,:) = Y4(i2,:,:,:);
    end
end
%  Start up clipping is done here
if CLIP ==1 
   movmean = squeeze(mean(Y4,1));
   for i = 1:nfilt
       Y4s = squeeze(Y4(i,:,:,:));
       Y4s = min(Y4s,spikeup*movmean);
       Y4s = max(Y4s,spikedn*movmean);
       Y4(i,:,:,:) = Y4s;
   end
end

% Main Loop
% Speed Note: Use Y4(1,:,:,:) = spm_read_vols(P(1));  % rows vary fastest
disp('Starting Main Loop')
for i = (nfilt+1)/2:nscans+(nfilt-1)/2
    if i <= nscans
        Y4(nfilt,:,:,:) = spm_read_vols(P(i));
    else   % Must pad the end data with reflected values.
        i2 = i - nscans;  
        Y4(nfilt,:,:,:) = spm_read_vols(P(nscans-i2)); % Y4(i2,:,:,:);
    end
    %  Incremental clipping is done here
    if CLIP == 1 & FiltType == 3   % only despiking
        movmean2 = mean(Y4,1);
        movmean = squeeze(movmean2);  % just a speed thing.
        % This lag is from FiltType = 3
        Y4s = squeeze(Y4(nfilt-lag,:,:,:));  % centered for despike only
        Y4s = min(Y4s,spikeup*movmean);
        Y4s = max(Y4s,spikedn*movmean);
        Yn2 = squeeze(Y4s);
    elseif CLIP == 1 & FiltType ~= 3   % combined despike and filter
        movmean2 = mean(Y4,1);
        movmean = squeeze(movmean2);  % just a speed thing.
        Y4s = squeeze(Y4(nfilt,:,:,:));  % predictive despike to use in filter
        Y4s = min(Y4s,spikeup*movmean);
        Y4s = max(Y4s,spikedn*movmean);
        Y4(nfilt,:,:,:) = Y4s;
    end
    if FiltType ~= 3     % apply filter to original or despiked data
        Yn = filter(afilt,1,Y4,[],1);
        Yn2 = squeeze(Yn(nfilt,:,:,:));
        Yn2 = gain*Yn2 + Vmean;
    end

    % Prepare the header for the filtered volume, with lag removed.
    V = spm_vol(P(i-lag).fname);
    v = V;
    [dirname, sname, sext ] = fileparts(V.fname);
    sfname = [ prechar, sname ];
    filtname = fullfile(dirname,[sfname sext]);
    v.fname = filtname;
    spm_write_vol(v,Yn2); 
    % Slide the read volumes window up.
    showprog = [' Filtered volume   ', sname, sext ];
    disp(showprog); 
    for js = 1:nfilt-1
        Y4(js,:,:,:) = Y4(js+1,:,:,:);
    end 
end

zout = 1;
fprintf('\nDone with despike and high pass filter!\n');
cd(startdir)

% Plot a sample voxel
demovoxel = round( size(Vmean)/3 );
xin = art_plottimeseries(Pimages  ,demovoxel);
SubjectDir = fileparts(Pimages(1,:));   
if strcmp(spm_ver,'spm5') 
    realname = [ '^d' '.*\.(img$|nii$)'  ];
	Qimages = spm_select('FPList',[SubjectDir ], realname);
else   % spm2
    realname = ['d' '*.img'];
	Qimages = spm_get('files',[SubjectDir ], realname);
end
xhi = art_plottimeseries( Qimages  ,demovoxel);
xscanin = [ 1:nscans];
xscanout = [ 1:size(Qimages,1) ];
figure(99)
plot(xscanin,xin,'r',xscanout,xhi,'b');
titlewords = ['Timeseries before (red) and after (blue) for Voxel '  num2str(demovoxel)];
title(titlewords)

%------------------------------------------------
function local_mean_ui(P,meanimagename)
% Batch adaptation of spm_mean_ui, with image name added.
% meanimagename is a character string, e.g. 'meansr.img'
% FORMAT spm_mean_ui
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience
% John Ashburner, Andrew Holmes
% $Id: spm_mean_ui.m 1096 2008-01-16 12:12:57Z john $
Vi = spm_vol(P);
n  = prod(size(Vi));
spm_check_orientations(Vi);

%-Compute mean and write headers etc.
%-----------------------------------------------------------------------
fprintf(' ...computing')
Vo = struct(	'fname',	meanimagename,...
		'dim',		Vi(1).dim(1:3),...
		'dt',           [4, spm_platform('bigend')],...
		'mat',		Vi(1).mat,...
		'pinfo',	[1.0,0,0]',...
		'descrip',	'spm - mean image');

%-Adjust scalefactors by 1/n to effect mean by summing
for i=1:prod(size(Vi))
	Vi(i).pinfo(1:2,:) = Vi(i).pinfo(1:2,:)/n; end;

Vo            = spm_create_vol(Vo);
Vo.pinfo(1,1) = spm_add(Vi,Vo);
Vo            = spm_create_vol(Vo);


%-End - report back
%-----------------------------------------------------------------------
fprintf(' ...done\n')
fprintf('\tMean image written to file ''%s'' in current directory\n\n',Vo.fname)

