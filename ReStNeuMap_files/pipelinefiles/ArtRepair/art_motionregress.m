function art_motionregress(ReslicedDir,ReslicedImages,RealignDir,RealignImages)
%  function art_motionregress
%  >> art_motionregress  for use by GUI
%   WARNING! This function will crash or run very slowly on normalized
%   images. Image volumes are much smaller before normalization.
%  See below for batch use.
%
% FUNCTIONS
%   Remove residual interpolation errors after the realign and reslice
%   operations (see Grootoonk 2000 for theory).
%   It is an alternative to adding motion regressors to the design matrix.
%   More fractional variation is removed on edge voxels with high variation,
%   while little variation is removed on non-edge voxels. The function
%   should be applied after realign and reslice, but before normalization.
%
% INPUT by GUI
%  Select realigned and resliced images, eg. 'rI*'.
%  Select realigned, unresliced images, e.g. 'I*img' where there
%     are associated .mat files. The .mat files describe the realignment
%     calculation, and give the x,y,z displacement of every voxel in
%     an image from realignment. 
% OUTPUT
%  Writes new image files with prefix 'm', that are the corrections of
%     the input images after motion adjustment.  
%  Writes maprior image, showing logarithm of regularization value.
%    Small values indicate more regression signal is removed, e.g.
%    most is removed when log = -5.2, none when log = 2.3.
%  Writes six mgamma images files containing motion regressors.
%  Writes file art_motion.txt listing files omitted during calculation
%    of regression parameters.
%
% BATCH FORM
%  art_motionregress( ReslicedDir, ReslicedImages, RealignDir, RealignImages)
%     ReslicedDir - folder with resliced images, e.g. '/net/fraX/subj1'
%     ReslicedImages - image names, e.g. 'rI*img' or 'sr*img'
%     RealignDir  - folder with realigned, but not resliced images.
%          The .mat files will be used from these images.
%     RealignImages  - image names, e.g. 'I*img'
%
%  This program keeps 63 images in memory, but runs well for fMRI images of 
%  size 64x64x18 on computers with 512MB of RAM. It may crash for lack of
%  memory on normalized images which are usually much larger.
%  
% Paul Mazaika,  May 2009
% Supports SPM12. Bug fix for .nii by M. Schmitgen. Dec2014.

%  ALGORITHM
%  Algorithm finds the x,y,z equivalent translational motion on each voxel,
%  assuming that small rotations are broken down into two translations.
%  The motion adjustment uses the regressors
%    [ sin x  1-cos x  sin y  1-cos y  sin z  1-cos z   1 ]
%  which are different for every voxel. The regressors 
%  are computed from the .mat data of unresliced images. Images with fast
%  variation are omitted from this calculation, although all images will
%  be corrected by it.
%  Regressors are applied more strongly near edges in the image ( brain
%  boundary and ventricles ) where interpolation effects are largest.
%  Strength of application is determined using a regularization R that
%  depends on an heuristic function of the RMS variation on a voxel.
%  Algorithm proceeds in two passes. First pass estimates the six
%  regressors for every voxel, and writes these regressors as six images
%  named mgamma. Estimation is done b = inv(R+A'A)*A'y, where all values in the
%  A' and A'A matrices are accumulated by rolling through all the images.
%  Second pass uses the regressors to find the residuals after motion
%  correction. The residual images are written out with the prefix 'm'.
%  Calls the art_motionadjust function. This pass rolls through the
%  input images one more time to apply motion adjustment.
%  This program accumulates all cross-products for the matrix inversion,
%  storing the equivalent of 63 3D-images. This works only for
%  the smaller fMRI images before normalization.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


% DATA, REALIGNMENT, AND REPAIR LOCATIONS
if nargin == 0
    if strcmp(spm_ver,'spm5')
        Pimages = spm_select(Inf,'image','Select resliced images to adjust');
        Rmats   = spm_select(Inf,'image','Select unresliced images (no r in name)');
    else   % spm2
        Pimages  = spm_get(Inf,'.img','Select resliced images to adjust');
        Rmats  = spm_get(Inf,'.img','Select unresliced images (no r in name)');
    end
elseif  nargin > 0  
    if strcmp(spm_ver,'spm5')
         Pimages = spm_select('FPList',ReslicedDir, ReslicedImages);
         Rmats = spm_select('FPList',RealignDir, RealignImages);
    else  %  spm2
        Pimages = spm_get('files', ReslicedDir, ReslicedImages);  
        Rmats   = spm_get('files', RealignDir, RealignImages);
    end
end
P = spm_vol(Pimages);
R = spm_vol(Rmats);
[imagedir,  imagename ] = fileparts(P(1).fname);
motiondir = imagedir;
resdir = imagedir;    

% Get image size and voxel size. Flip x-voxel size to positive.
% Imagesize are the images to be motion adjusted.
% Voxelsize is the voxel size of image that was scanned.
nscan = size(P,1);
imagesize = P(1).dim;
dx = imagesize(1); dy = imagesize(2); dz = imagesize(3);
imagedim = [ dx dy dz ];
voxelsize = R(1).mat;
vx = abs(voxelsize(1,1)); vy = voxelsize(2,2); vz = voxelsize(3,3);
Y1 = spm_read_vols(P(1));
%meanY1 = 0.75*max(max(max(Y1)));  %  a guess!

disp('Generated mask image is written to file ArtifactMask.img.')
%Pnames = P{1};
Automask = art_automask(P(1,:),-1,1);
maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
voxelcount = prod(size(Automask));    %  Number of voxels in 3D volume.
Y1 = Y1.*Automask;
meanY1 = mean(mean(mean(Y1)))*voxelcount/maskcount;

% ------------------------
% Use art_global to find time points with rapid scan-to-scan movement
% Scans with these indices should be removed from motion regression
% calculation because the realignment parameters may have errors.
% One could try to fix these realignment values here, but instead we will
% use art_repair later to smooth the intensities on the same images.
% ------------------------ 
mv_thresh = 0.5;    % perhaps 0.3 for good subjects

 disp('Detect scans to remove from motion calculation using art_global');
 nsess = 1;
 %realname = [ '^' prefix{6} '.*\.img$'  ];
 mvname    = [ '^rp_' '.*\.txt$'];  % same prefix as realignment.];
 for i = 1:nsess
    mvfile = spm_select('FPList',[ imagedir ], mvname);
    % Make list of bad scans
    %c5_art_global(Pimages, mvfile, 4,0); % fixed, no clipmvmt
    art_global(Pimages, mvfile, 4,0); % fixed, no clipmvmt
    %b5_art_global(imgFile, mvfile, 4,2);
    outnames    = textread([ imagedir '/art_suspects.txt']); 
    mvout_idx = outnames;
 end
 numberout = length(mvout_idx);
 numberst = ['Excluding ' num2str(numberout) ' volumes from motion adjustment estimation.'];
 disp(numberst)
delta(1:nscan,1) = 0;
delta(mvout_idx) = 1;

% Save list of scans excluded from estimation of motion
temppwd = pwd;
cd(fileparts(P(1).fname));
save art_motion.txt mvout_idx -ascii
cd(temppwd);
    
    

% Initialize accumulation arrays and first image
% This repetitive code uses 3D arrays because 
%    4D arrays can be slow depending on subscript order.
disp('Reading image files to solve regression on all voxels.');

mbeta01 = zeros(dx,dy,dz); mbeta02 = zeros(dx,dy,dz); mbeta03 = zeros(dx,dy,dz);
mbeta04 = zeros(dx,dy,dz); mbeta05 = zeros(dx,dy,dz); mbeta06 = zeros(dx,dy,dz);
mbeta07 = zeros(dx,dy,dz); mbeta08 = zeros(dx,dy,dz); mbeta09 = zeros(dx,dy,dz);
mbeta10 = zeros(dx,dy,dz); mbeta11 = zeros(dx,dy,dz); mbeta12 = zeros(dx,dy,dz);

mbetaab = zeros(dx,dy,dz); mbetaac = zeros(dx,dy,dz); mbetaap = zeros(dx,dy,dz);
mbetaaq = zeros(dx,dy,dz); mbetaar = zeros(dx,dy,dz); mbetabc = zeros(dx,dy,dz);
mbetabp = zeros(dx,dy,dz); mbetabq = zeros(dx,dy,dz); mbetabr = zeros(dx,dy,dz);
mbetacp = zeros(dx,dy,dz); mbetacq = zeros(dx,dy,dz); mbetacr = zeros(dx,dy,dz);
mbetapq = zeros(dx,dy,dz); mbetapr = zeros(dx,dy,dz); mbetaqr = zeros(dx,dy,dz);
mbeta00 = zeros(dx,dy,dz);   % difference of first from the mean.
mbetac1 = zeros(dx,dy,dz); mbetac2 = zeros(dx,dy,dz); mbetac3 = zeros(dx,dy,dz);
mbetac4 = zeros(dx,dy,dz); mbetac5 = zeros(dx,dy,dz); mbetac6 = zeros(dx,dy,dz);
msumsq = zeros(dx,dy,dz);
% 
% Accumulate the correlations
% ------------------------------------------------------------
for i = 1:nscan
    if (delta(i) == 1) continue; end
    Y = spm_read_vols(P(i));
    [ Xp, Yp, Zp ] = rmove(R(i).mat, imagedim, R(1).mat);
    Y = Y - Y1;   %difference from the baseline.
    mbeta00 = Y + mbeta00;
    msumsq = Y.*Y + msumsq;
    ax = sin(Xp*2*pi/vx);  % ax should be a matrix
    mbeta01 = Y.*ax  + mbeta01;
    mbeta07 = ax.*ax + mbeta07;
    mbetac1 = ax + mbetac1;
    bx = (1-cos(Xp*2*pi/vx));
    mbeta02 = Y.*bx  + mbeta02;
    mbeta08 = bx.*bx + mbeta08;
    mbetac2 = bx + mbetac2;
    cx = sin(Yp*2*pi/vy); 
    mbeta03 = Y.*cx  + mbeta03;
    mbeta09 = cx.*cx + mbeta09;
    mbetac3 = cx + mbetac3;
    px = (1-cos(Yp*2*pi/vy));
    mbeta04 = Y.*px  + mbeta04;
    mbeta10 = px.*px + mbeta10;
    mbetac4 = px + mbetac4;
    qx = sin(Zp*2*pi/vz); 
    mbeta05 = Y.*qx  + mbeta05;
    mbeta11 = qx.*qx + mbeta11;
    mbetac5 = qx + mbetac5;
    rx = (1-cos(Zp*2*pi/vz));
    mbeta06 = Y.*rx  + mbeta06;
    mbeta12 = rx.*rx + mbeta12;
    mbetac6 = rx + mbetac6;
    
    mbetaab = ax.*bx + mbetaab;
    mbetaac = ax.*cx + mbetaac;
    mbetaap = ax.*px + mbetaap;
    mbetaaq = ax.*qx + mbetaaq;
    mbetaar = ax.*rx + mbetaar;
    mbetabc = bx.*cx + mbetabc;
    mbetabp = bx.*px + mbetabp;
    mbetabq = bx.*qx + mbetabq;
    mbetabr = bx.*rx + mbetabr;
    mbetacp = cx.*px + mbetacp;
    mbetacq = cx.*qx + mbetacq;
    mbetacr = cx.*rx + mbetacr;
    mbetapq = px.*qx + mbetapq;
    mbetapr = px.*rx + mbetapr;
    mbetaqr = qx.*rx + mbetaqr;
end
% Divide by nscan and save these intermediate results.
disp('Storing variances and cross-correlations')
tempnscan = nscan;
nscan = nscan - numberout;
mbeta01 = mbeta01/nscan; mbeta02 = mbeta02/nscan; mbeta03 = mbeta03/nscan;
mbeta04 = mbeta04/nscan; mbeta05 = mbeta05/nscan; mbeta06 = mbeta06/nscan;
mbeta07 = mbeta07/nscan; mbeta08 = mbeta08/nscan; mbeta09 = mbeta09/nscan;
mbeta10 = mbeta10/nscan; mbeta11 = mbeta11/nscan; mbeta12 = mbeta12/nscan;
mbetaab = mbetaab/nscan;
mbetaac = mbetaac/nscan;
mbetaap = mbetaap/nscan;
mbetaaq = mbetaaq/nscan;
mbetaar = mbetaar/nscan;
mbetabc = mbetabc/nscan;
mbetabp = mbetabp/nscan;
mbetabq = mbetabq/nscan;
mbetabr = mbetabr/nscan;
mbetacp = mbetacp/nscan;
mbetacq = mbetacq/nscan;
mbetacr = mbetacr/nscan;
mbetapq = mbetapq/nscan;
mbetapr = mbetapr/nscan;
mbetaqr = mbetaqr/nscan;
mbeta00 = mbeta00/nscan;
mbetac1 = mbetac1/nscan; mbetac2 = mbetac2/nscan; mbetac3 = mbetac3/nscan;
mbetac4 = mbetac4/nscan; mbetac5 = mbetac5/nscan; mbetac6 = mbetac6/nscan;
nscan = tempnscan;  % undo the hack
clear Xp Yp Zp Y Y1 ax bx cx px qx rx;

% % REGULARIZATION FOR MATRIX INVERSION
% % Vary limit on each voxel depending on RMS variation to remove more
% when variation is larger.
% % Find RMS variation on voxel
scansused = nscan-numberout;
msumsq = msumsq/scansused;
msumsq = msumsq - mbeta00.*mbeta00;  % estimates variance
msumsq = sqrt(msumsq)/meanY1;   % fractional variation on the voxel
msumsq(1,:,:) =1; msumsq(64,:,:) = 1; msumsq(:,1,:)=1; msumsq(:,64,:)=1;
% NOW ASSUME SOME HEURISTIC VALUES FOR INVERSION...
% Best performance used 0.005 and 0.0025 for edges in the Phantom Data
% %    Pretty good values for phantom were 0.01 and 0.001
% Smooth this msumsq array?  Not in this version.
% SECOND GUESS 
% Fractional variation > 0.05, set to less than 0.0037 
% Fractional variation < 0.01, set to more than 5  ( a guess)
apriorarray =  50*exp(-200*msumsq); 

% NEXT SET MINIMUM LIMIT ON REGULARIZATION TO MAINTAIN STABILITY
% Matlab gives no inversion warnings, even for 0.0001, or 0.001 fixed everywhere.
% Regressors are clipped in a few ventral posterior edge at 0.005 fixed, while
% %        clipping also occurs in ventral anterior, and top at 0.0001.
apriorlimit = 0.0025;
apriorhigh  = 6;
apriorarray = max(apriorarray, apriorlimit);
apriorarray = min(apriorarray, apriorhigh);  % prevents Matlab warning 

mbetaones = ones(dx,dy,dz);
%  FULL MATRIX INVERSE ON EVERY VOXEL
for in = 1:dx
    for jn = 1:dy
        for kn = 1:dz
            M = [ mbeta07(in,jn,kn) mbetaab(in,jn,kn) mbetaac(in,jn,kn) mbetaap(in,jn,kn) mbetaaq(in,jn,kn) mbetaar(in,jn,kn) mbetac1(in,jn,kn); ...
                  mbetaab(in,jn,kn) mbeta08(in,jn,kn) mbetabc(in,jn,kn) mbetabp(in,jn,kn) mbetabq(in,jn,kn) mbetabr(in,jn,kn) mbetac2(in,jn,kn); ...
                  mbetaac(in,jn,kn) mbetabc(in,jn,kn) mbeta09(in,jn,kn) mbetacp(in,jn,kn) mbetacq(in,jn,kn) mbetacr(in,jn,kn) mbetac3(in,jn,kn); ...
                  mbetaap(in,jn,kn) mbetabp(in,jn,kn) mbetacp(in,jn,kn) mbeta10(in,jn,kn) mbetapq(in,jn,kn) mbetapr(in,jn,kn) mbetac4(in,jn,kn); ...
                  mbetaaq(in,jn,kn) mbetabq(in,jn,kn) mbetacq(in,jn,kn) mbetapq(in,jn,kn) mbeta11(in,jn,kn) mbetaqr(in,jn,kn) mbetac5(in,jn,kn); ...
                  mbetaar(in,jn,kn) mbetabr(in,jn,kn) mbetacr(in,jn,kn) mbetapr(in,jn,kn) mbetaqr(in,jn,kn) mbeta12(in,jn,kn) mbetac6(in,jn,kn); ...
                  mbetac1(in,jn,kn) mbetac2(in,jn,kn) mbetac3(in,jn,kn) mbetac4(in,jn,kn) mbetac5(in,jn,kn) mbetac6(in,jn,kn) mbetaones(in,jn,kn) ];
            %  aacond(in,jn,kn) = cond(M);
            %  maximum condition number is 9000000 in phantom data!
            % M = M + aprior(in,jn,kn)*eye(7) regularizes everything.
            % Only regularize singular locations
            aprior = max(apriorlimit,apriorarray(in,jn,kn));
            for nn = 1:6
                M(nn,nn) = max(M(nn,nn), aprior);
            end
            %  apcond(in,jn,kn) = cond(M);
            %  With regularization, condition number has range 100000 in
            %  phantom data. Could use pinv(M) here, but not needed.
            MM =  inv(M);
            bvec = [ mbeta01(in,jn,kn) mbeta02(in,jn,kn) mbeta03(in,jn,kn) mbeta04(in,jn,kn) mbeta05(in,jn,kn) mbeta06(in,jn,kn) mbeta00(in,jn,kn) ]';

            mgamma01(in,jn,kn) = MM(1,1:7)*bvec;
            mgamma02(in,jn,kn) = MM(2,1:7)*bvec;
            mgamma03(in,jn,kn) = MM(3,1:7)*bvec;
            mgamma04(in,jn,kn) = MM(4,1:7)*bvec;
            mgamma05(in,jn,kn) = MM(5,1:7)*bvec;
            mgamma06(in,jn,kn) = MM(6,1:7)*bvec;
            % Better to also estimate and write out mgamma00, the difference between mean and baseline value.
        end
    end
end

% %  TEST CODE for ONLY Z COMPONENT MATRIX INVERSE ON EVERY VOXEL
% for in = 1:dx
%     for jn = 1:dy
%         for kn = 1:dz
%             M = [ mbeta11(in,jn,kn) mbetaqr(in,jn,kn) mbetac5(in,jn,kn); ...
%                   mbetaqr(in,jn,kn) mbeta12(in,jn,kn) mbetac6(in,jn,kn);...
%                   mbetac5(in,jn,kn) mbetac6(in,jn,kn)  1              ];
%             aacond(in,jn,kn) = cond(M);
%             %  condition numbers are from 2.4 - 3.5 for 1D phantom data!
%             %M = M + aprior(in,jn,kn)*eye(2);
%             M = M + [ 0.05  0  0;  0  0.05  0;  0  0  0 ]; % *eye(3);
%             %apcond(in,jn,kn) = cond(M);
%             %  No regularization needed in 1D algorithm for phantom.
%             %  phantom data
%             MM = inv(M);
%             bvec = [  mbeta05(in,jn,kn) mbeta06(in,jn,kn) mbeta00(in,jn,kn) ]';
%             mgamma01(in,jn,kn) = 0;
%             mgamma02(in,jn,kn) = 0;
%             mgamma03(in,jn,kn) = 0;
%             mgamma04(in,jn,kn) = 0;
%             mgamma05(in,jn,kn) = MM(1,1:3)*bvec;
%             mgamma06(in,jn,kn) = MM(2,1:3)*bvec;
%         end
%     end
% end


% Prevent runaway large values
clear mbeta*
disp('Clipping regressors that are too large')
acap = 0.21;    % correction from any one term < 5% of mean image
               % phantom data had max of 21%. 
maxgamma = acap*meanY1;
mingamma = - maxgamma;
mgamma01 = min(mgamma01,maxgamma);
mgamma02 = min(mgamma02,maxgamma);
mgamma03 = min(mgamma03,maxgamma);
mgamma04 = min(mgamma04,maxgamma);
mgamma05 = min(mgamma05,maxgamma);
mgamma06 = min(mgamma06,maxgamma);
mgamma01 = max(mgamma01,mingamma);
mgamma02 = max(mgamma02,mingamma);
mgamma03 = max(mgamma03,mingamma);
mgamma04 = max(mgamma04,mingamma);
mgamma05 = max(mgamma05,mingamma);
mgamma06 = max(mgamma06,mingamma);


 disp('Writing mgamma images with motion regressors for each voxel.')
 %V = spm_vol(P(1).fname);
 v = P(1);  % was V;
 [dirname, sname, sext ] = fileparts(P(1).fname);
 v = rmfield(v,'pinfo');  % Allows SPM5 to scale images.
 
 sfname = 'mgamma01';
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,mgamma01);  
 sfname = 'mgamma02';
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,mgamma02);
 sfname = 'mgamma03';
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,mgamma03); 
 sfname = 'mgamma04';
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,mgamma04);
 sfname = 'mgamma05';
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,mgamma05); 
 sfname = 'mgamma06';
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,mgamma06); 
 sfname = 'maprior';
 logaprior = log(apriorarray);  % natural log
 %  To read the apriorarray later...
 %  Note log .005 is -5.2, and log 10 is 2.3.
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,logaprior); 
 clear mgamma*;
 
% Estimate motion adjusted images
disp('Write images after motion adjustment');
if strcmp(spm_ver,'spm5')
    % file extension may be img or nii, this logic should do both.
    realname = '^mgamma.*\.(img$|nii$)';
    mgams = spm_select('FPList',imagedir, realname);
    %mgams = spm_select('FPList',imagedir, '^mgamma.*\.img$'); 
    %mgams = spm_select('FPList',imagedir, '^mgamma.*\.nii$');
else  %  spm2
    mgams = spm_get('files',imagedir, 'mgamma*img');
end
%cd(motiondir)
art_motionadjust(P, mgams, R);
%b_motionadjust(P, mgams, R);


%--------------------------------------------------------------
function [ Xp, Yp, Zp ] = rmove(New,imagedim,Baseline);
%  P.mat transforms voxel coordinates to x,y,z position in mm.
%  New is P.mat for image, Baseline is P(1).mat for baseline image
%  dim is 3D vector of image size.
%  Output is change in (x,y,z) position for every voxel on this image.
Mf = New - Baseline;
for i = 1:imagedim(1)
    for j = 1:imagedim(2)
        for k = 1:imagedim(3)
            Xp(i,j,k) = Mf(1,1)*i+Mf(1,2)*j+Mf(1,3)*k+Mf(1,4);
            Yp(i,j,k) = Mf(2,1)*i+Mf(2,2)*j+Mf(2,3)*k+Mf(2,4);
            Zp(i,j,k) = Mf(3,1)*i+Mf(3,2)*j+Mf(3,3)*k+Mf(3,4);
        end
    end
end




