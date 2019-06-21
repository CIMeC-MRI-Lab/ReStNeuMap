function alpha_motionJ(ReslicedDir,ReslicedImages,RealignDir,RealignImages)
%====================================================================================
%====================================================================================
%  TEST VERSION FOR SPM5. CALLS B5_MOTIONADJUST.
%  COMPATIBLE WITH SPM5 AND SPM2.
%
%  b_motionJ( ReslicedDir, ReslicedImages, RealignDir, RealignImages)
%     ReslicedDir - folder with resliced images, e.g. '/net/fraX/subj1'
%     ReslicedImages - image names, e.g. 'sr*img'
%     RealignDir  - folder with realigned, but not resliced images.
%          The mat files will be used from these images.
%     RealignImages  - image names, e.g. 'I*img'%  Function b_motionJ
%
%  FUNCTIONS
%   Performs 3-D rigid body motion adjustment to series of resliced images.
%   H version:  Ignores scans near large scan-to-scan motion. Aug 2007
%   J version:  Adds apriori matrix based on image curvatures.May 2008
%
%  INPUT by GUI
%  Read the names of the RESLICED images to be
%     adjusted for resampling error. Apply this correction BEFORE any
%     normalization, so that normalized images will not import the
%     resampling error. (Note this program stores 63 copies of the image,
%     and fMRI images are far smaller before normalization.)
%  Read the names of images before reslicing. Only the .mat files from
%     these images are used. The .mat files describe the realignment
%     calculation, and give the x,y,z displacement of every voxel in
%     an image from realignment.
%  OUTPUT
%  Writes new image files that are the corrections of the input images
%  after motion adjustment.The letter 'm' is prepended to the image names.
%  Writes six mgamma images files containing best motion regressors for each
%  voxel.Writes apriorarray giving motion weight per voxel.
%  Writes file art_motion.txt listing files it did not use to calculate
%  regress parameters.
%
%  ALGORITHM
%  Algorithm finds the x,y,z equivalent translational motion on each voxel,
%  assuming that small rotations are broken down into two translations.
%  The motion adjustment uses the regressors
%    [ sin x  1-cos x  sin y  1-cos y  sin z  1-cos z   1 ]
%  which are different for every voxel. The regressors 
%  are computed from the .mat data of unresliced images.
%  Regressors are applied more strongly near edges in the image ( brain
%  boundary and ventricles ) where interpolation effects are largest.
%  Strength of application is estimated by curvature in the image.
%  Algorithm proceeds in two passes. First pass estimates the six
%  regressors for every voxel, and writes these regressors as six images
%  named mgamma. Estimation is done b = inv(A'A)*A'y, where all values in the
%  A' and A'A matrices are accumulated by rolling through all the images.
%  Second pass uses the regressors to find the residuals after motion
%  correction. The residual images are written out with the prefix 'm'.
%  Calls the motionadjust function. This pass rolls through the
%  input images one more time to apply motion adjustment.
%
%  GOOD LUCK !!
%  This program requires lots of memory, but runs well for fMRI images of 
%  size 64x64x18 on computers with 512MB of RAM.It may not run on
%  normalized images which are usually much larger.
%  
%
% Paul Mazaika,  May 2007, J-version July 2008

% Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));
											

% DATA, REALIGNMENT, AND REPAIR LOCATIONS
if nargin == 0
%     if spm_ver == 'spm5'
        Pimages = spm_select(Inf,'image','Select resliced images to adjust');
        Rmats   = spm_select(Inf,'image','Select unresliced images (no r in name)');
%     else   % spm2
%         Pimages  = spm_get(Inf,'.img','Select resliced images to adjust');
%         Rmats  = spm_get(Inf,'.img','Select unresliced images (no r in name)');
%     end
elseif  nargin > 0  
%     if spm_ver == 'spm5'
         Pimages = spm_select('FPList',ReslicedDir, ReslicedImages);
         Rmats = spm_select('FPList',RealignDir, RealignImages);
%     else  %  spm2
%         Pimages = spm_get('files', ReslicedDir, ReslicedImages);  
%         Rmats   = spm_get('files', RealignDir, RealignImages);
%     end
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
meanY1 = 0.75*max(max(max(Y1)));  %  a guess!

% ------------------------
% Find time points with rapid scan-to-scan movement
% Scans with these indices should be removed from motion regression
% calculation because the realignment parameters may have errors.
% One could try to fix these realignment values here, but instead we will
% use art_repair later to smooth the intensities on the same images.
% ------------------------ 
    mv_thresh = 0.5;    % perhaps 0.3 for good subjects
    
    disp('Check for large scan-to-scan movements')
% Motion measure assumes voxels are 65 mm from origin of rotation.
% Find six voxels that are 65 mm away from origin.
    uu = 65;
    %uu = 25;  % prenatal imaging
    ts(1,1) = min(dx,round(dx/2 + uu/vx)); ts(1,2) = round(dy/2); ts(1,3) = round(dz/2);
    ts(2,1) = max(1,round(dx/2 - uu/vx)); ts(2,2) = round(dy/2); ts(2,3) = round(dz/2);
    ts(3,1) = round(dx/2); ts(3,2) = min(dy,round(dy/2 + uu/vy)); ts(3,3) = round(dz/2);
    ts(4,1) = round(dx/2); ts(4,2) = max(1,round(dy/2 - uu/vy)); ts(4,3) = round(dz/2);
    ts(5,1) = round(dx/2); ts(5,2) = round(dy/2); ts(5,3) = min(dz,round(dz/2 + uu/vz));
    ts(6,1) = round(dx/2); ts(6,2) = round(dy/2); ts(6,3) = max(1,round(dz/2 - uu/vz));
 % Find scan-to-scan motion for every voxel, then sample six voxels at 65mm
 %     Very inefficient!.   
    delta = zeros(nscan,1);  % Mean square displacement in two scans
    deltaw = zeros(nscan,1);

	spm_progress_bar('Init',nscan,'Checking for large scan-to-scan movements','scans completed');											
    for i = 2:nscan
        [ Xp, Yp, Zp ] = rmove(R(i).mat, imagedim, R(i-1).mat);
        dist = 0;
        for ii = 1:6
            dist = Xp(ts(ii,1),ts(ii,2),ts(ii,3))^2 + ...
                 Yp(ts(ii,1),ts(ii,2),ts(ii,3))^2 + ...
                 Zp(ts(ii,1),ts(ii,2),ts(ii,3))^2  + dist; 
        end
        delta(i) = sqrt(dist/6);  % RMS displacement avg over 6 sample points
		spm_progress_bar('Set',i)
    end
	spm_progress_bar('Clear')
  % Also name the scans before the big motions
    for i = 1:nscan-1
        deltaw(i) = max(delta(i), delta(i+1));
    end
    deltaw(nscan) = delta(nscan);
    % Adapt the threshold  (v2.3 fix)
    %if RepairType == 2
        delsort = sort(deltaw);
        if delsort(round(0.7*nscan)) > mv_thresh
            mv_thresh = min(1.0,delsort(round(0.75*nscan)));
            words = ['MotionAdjust changed movement threshold to ' num2str(mv_thresh)];
            disp(words)
        end
    %end
    mvout_idx = find(deltaw > mv_thresh)';
    numberout = length(mvout_idx);
    numberst = ['Excluding ' num2str(numberout) ' volumes from motion adjustment estimation.'];
        disp(numberst)
    delta(:,1) = 0;
    delta(mvout_idx) = 1;

    % Save list of scans excluded from estimation of motion
    temppwd = pwd;
    cd(fileparts(P(1).fname));
    save art_motion.txt mvout_idx -ascii
    cd(temppwd);
    
 % Find total motion for every voxel, then sample six voxels at 65mm
 %     Staggeringly Very inefficient!. to get a max motion value  
    deltad = zeros(nscan,1);  % Mean displacement of scan for scan 1.
    %deltaw = zeros(nscan,1);
											
	spm_progress_bar('Init',nscan,'Finding total motion','scans completed');											
    for i = 2:nscan
        [ Xp, Yp, Zp ] = rmove(R(i).mat, imagedim, R(1).mat);
        dist = 0;
        for ii = 1:6
            dist = Xp(ts(ii,1),ts(ii,2),ts(ii,3))^2 + ...
                 Yp(ts(ii,1),ts(ii,2),ts(ii,3))^2 + ...
                 Zp(ts(ii,1),ts(ii,2),ts(ii,3))^2  + dist; 
        end
        deltad(i) = sqrt(dist/6);  % RMS displacement avg over 6 sample points
		spm_progress_bar('Set',i)											
    end
	spm_progress_bar('Clear')											
    deltamax = max(deltad);
 
    
% REGULARIZATION FOR MATRIX INVERSION
% DIFFERENT FOR EVERY VOXEL, DEPENDING ON LOCAL GRADIENTS AND CURVATURE
% INCLUDE A LOWER LIMIT.
disp('Estimating spatial gradient image for voxelwise regularization.')
% Need aprior factor for cases when there is no motion in a direction.
% Only use the factor when diagonal element is small.
% Since mbetas were scaled by nscan, aprior does not depend on nscan.
% BEST Values for Phantom Data are 0.005, and 0.0025.
%    Pretty good values for phantom are 0.01 and 0.001
% Matlab does fine inverting the matrix for condition number 180,000! 
apriorlimit = 0.005;
% One factor is gradient x realignment error.
% One factor is curvature x total motion
% If no curvature or motion -> no motion correction.
% OR, if these are small relative to other contributions on the voxel,
%   cognitive signal and thermal noise, should suppress them.
% These values were found earlier.
% Set up gradient and curvature array
% Gradient correction and curvature correction
% Interpolation error is larger when curvature is larger.
% Residual realignment error is larger when gradient is larger.
 [fx, fy, fz ] = gradient(Y1,vx,vy,vz);
 fw = sqrt(fx.*fx + fy.*fy + fz.*fz);
 [fx, fy, fz ] = gradient(fw,vx,vy,vz);
 gw = sqrt(fx.*fx + fy.*fy + fz.*fz);
 clear fx fy fz;
 xmax = deltamax;  % largest motion
 gw = 100*gw/meanY1;   % percent signal change
 gw = gw*xmax;     % largest pct error due to curvature 
 fw = 100*fw*0.1/meanY1;  % largest pct error due to realignment error
 jw = 1*(fw+gw);   % smoothed images underestimate short scale variation
      %  want brain edges to have jw = 5. 1 is better than 3.
 hw = max(0.025,(jw).*(jw));
 apriorarray = 0.25./hw;  % scales so that (gw+fw) = 0.2 -> 6.25
                             % (gw+fw) = 5 -> 0.01.
 %apriorarray = min(10,apriorarray);
 apriorarray = max(apriorarray,apriorlimit);
 clear gw fw hw jw;
 

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
% 
% Accumulate the correlations
% ------------------------------------------------------------
											
spm_progress_bar('Init',nscan,'Solving regression on all voxels','scans completed');											
for i = 1:nscan
    if (delta(i) == 1) continue; end
    Y = spm_read_vols(P(i));
    [ Xp, Yp, Zp ] = rmove(R(i).mat, imagedim, R(1).mat);
    Y = Y - Y1;   %difference from the baseline.
    mbeta00 = Y + mbeta00;
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
spm_progress_bar('Set',i);											
end
spm_progress_bar('Clear')
											
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
 filtname = fullfile(dirname,[sfname sext]);
 v.fname = filtname;
 spm_write_vol(v,apriorarray); 
 
%  %TEST CODE for scaling
% sfname = 'mgamma01TEST';
%  filtname = fullfile(dirname,[sfname sext]);
%  v.fname = filtname; 
%  v = rmfield(v,'pinfo');
%  spm_write_vol(v,mgamma01); 
%  sfname = 'mapriorTEST';
%  filtname = fullfile(dirname,[sfname sext]);
%  v.fname = filtname; 
%  %v = rmfield(v,'pinfo');
%  spm_write_vol(v,apriorarray); 
 
% % Estimate parameters

clear mgamma*;
disp('Write images after motion adjustment');
%if spm_ver == 'spm5'
    % file extension may be img or nii, this logic should do both
    realname = '^mgamma.*\.(img$|nii$)';
    mgams = spm_select('FPList',imagedir, realname);
    %mgams = spm_select('FPList',imagedir, '^mgamma.*\.img$'); 
    %mgams = spm_select('FPList',imagedir, '^mgamma.*\.nii$');  
%else  %  spm2
%    mgams = spm_get('files',imagedir, 'mgamma*img');
%end
%cd(motiondir)
alpha_motionadjust(P, mgams, R);


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




