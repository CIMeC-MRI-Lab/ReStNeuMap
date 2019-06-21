function  Y = art_automask(Image,Threshold,WriteVol);
% Y = art_automask( Image, Threshold, WriteVol )      (v2.3)
% art_automask;                                 
%
%    Calculates a pretty good mask image from an input full-head Image
% in order to detect artifacts in the data. The threshold
% is higher than usual for SPM because the spiral scan generates more
% noise outside the head. When called with one 
% or no arguments, the mask is adapted for the input image, and the mask is
% written to "ArtifactMask.img" for later user review. The adaptation
% sets a threshold level, removes speckle, and removes corner artifacts.
% The adaptive mask is usually a bit larger than the head.
%    The GUI version allows a user to select a threshold,e.g. by looking at
% an SPM display of the image to estimate a value. The program will fill
% in small holes in the mask, so you can pick slightly high values to 
% suppress noise and still obtain a mask without gaps.
% 
% GUI INPUT
%  Image  - select the image to use
%  Threshold  - Select a threshold to use.
%  UserMask  - Select a name for the derived mask file.
% BATCH INPUT:
%  Image  - full path name of an image file, e.g. 'C:\test\V002.img' 
%  Threshold- measured as a FRACTION of the range of Image
%      If > 0, applies that threshold. Values from 0.10 to 0.30 are typical.
%         e.g. if the Image range is [0,2000] and Threshold = 0.15,  
%         then a fixed threshold of 300 is applied.
%      If not supplied, threshold is set adaptively to a value that is
%         0.2 to 0.4 of the max range of the smoothed image.       
%  WriteVol = 0 does not write a mask file.
%      If not supplied, mask file is written.
%OUTPUT:
%  Y  3D mask array, with 1's and 0's.
%  ArtifactMask.img, written to the image directory, if WriteVol = 1.
%  UserMaskname.img, written to the image directory in GUI maode.
%
% Paul Mazaika  April 2004.
% V.2  adapts to different mean image levels.  Paul Mazaika Aug. 2006.
% V2.1 write maskvalue=1. get/write changes for SPM5. (2/07) 
% v2.3 support SPM12 (12/14)


% Adaptive Threshold Logic depends on estimated error rate outside the head.
% Fraction of points outside the head that pass the threshold must be small.
% For each slice, set the slice to zero if the fraction of mask points on
% the slice is smaller than parameter FMR.
FMR = 0.015;   % False Mask Percentage. 

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin == 0
    if strcmp(spm_ver,'spm5')
        Image = spm_select(1,'image','Select image as source for automask.');
    else  % spm2 version
        Image = spm_get(1,'.img','Select image as source for automask.');
    end
    %Image = spm_select(1,'image','Select image as source for automask.');
    %Threshold = -1;  %  Adaptive mask by default
    Threshold = spm_input('Select threshold value' ,1,'r');   
    MaskName = spm_input('Select name for calculated mask file' ,1,'s','UserMask');
    WriteVol = 1;    %  Writes the mask out for inspection.
elseif nargin == 1
    Threshold = -1;  %  Adaptive mask by default.
    WriteVol = 1;    %  Writes the mask out for inspection.
end

% Get the image data.
    V = spm_vol(Image(:,:));  % Input could be a matrix; only need one image.
    n  = prod(size(V));
    Y = spm_read_vols(V);
% Fill in the small holes and reduce the noise spikes.    
    Y = smooth3(Y);  % default 3x3x3 box smoothing.
    Yr = max(max(max(Y))) - min(min(min(Y)));  % previously used range.
    
% User defined mask threshold
if Threshold > 0  % Make the mask directly
    % Array temp is logical array with 1's and 0's
    temp(:,:,:) = (Y(:,:,:)>Threshold);
end

% Adaptive Mask Threshold
if ( Threshold == -1 )   % Find a threshold that discards three outer faces.
    % Use gray matter density as lower limit- count is 400.
    Tlow = fix(0.2*Yr);  Thigh = fix(0.4*Yr); Tskip = max(fix(Tlow/20),1); % upper thresh 0.5 was 0.4 before
    for Tbar = Tlow:Tskip:Thigh   % 400:20:800
        temp(:,:,:) = (Y(:,:,:) > Tbar);
	% Count the number of mask points in the far faces of the volume
         xdim = size(Y);
         count1 = sum(sum(temp(:,:,1)));
         count2 = sum(sum(temp(:,:,xdim(3))));
         count3 = sum(sum(temp(:,1,:)));
         count4 = sum(sum(temp(:,xdim(2),:)));
         count5 = sum(sum(temp(1,:,:)));
         count6 = sum(sum(temp(xdim(1),:,:)));
     % Always have one face with large counts, sometimes have 2 such faces.
         countA = count1+count2+count3+count4+count5+count6;
         Xbar = [ count1 count2 count3 count4 count5 count6 ];
         Ybar = sort(Xbar);
         countC = Ybar(1) + Ybar(2);  % the two smallest face counts
         countB = Ybar(1) + Ybar(2) + Ybar(3);  % three smallest face counts
         % Number of voxels on 3 faces is approximately:
         nvox = xdim(1)*xdim(2) + xdim(2)*xdim(3) + xdim(1)*xdim(3);
         if ( countC < FMR*nvox )  
             break;   % Exit the For loop, current Tbar is good enough.
         end
%          iter = iter + 1;
%          ygraph(1,iter) = countA;
%          ygraph(2,iter) = countB;
%          ygraph(3,iter) = countC;
     end
     disp('Adaptive Mask Threshold')
     disp(Tbar)
     %disp(countC)
     %disp(ygraph')
end
if Threshold == -1
    if Tbar >= Thigh-Tskip
        disp('Automask program failed.   Try choosing a mean image,')
        disp(' or manually set a threshold. Type help art_automask.')
        return
    end
end
 

 % Clean up the corner alias artifact sometimes evident in the spiral data.
 % If the edge of a plane has much more data than the center, delete the
 % edge. Then if any plane has too few data points (meaning close to noise level)
 % then set the entire plane in the mask image to zero. Note for spiral scans
 % a better idea might be to determine the orientation of the spiral, and just 
 % remove the potential alias effects at those four edges corners.
        xdim = size(Y);
        iedge = floor(max(5,0.2*xdim(1)));
        jedge = floor(max(5,0.2*xdim(2)));
        kedge = floor(max(5,0.2*xdim(3)));
 % Clear out the edges, and then check the planes.
    for i = 1:xdim(1)
        % If edges are bigger than center, then delete edges.
        fmaski = sum(sum(temp(i,jedge:xdim(2)-jedge,kedge:xdim(3)-kedge))); 
        mo1 = sum(sum(temp(i,1:jedge,:)));
        if ( mo1 > 2*fmaski ) temp(i,1:5,:) = 0; end
        mo2 = sum(sum(temp(i,xdim(2)-jedge:xdim(2),:)));
        if (mo2 > 2*fmaski) temp(i,xdim(2)-4:xdim(2),:) = 0; end
        mo3 = sum(sum(temp(i,:,1:kedge)));
        if (mo3 > 2*fmaski)  temp(i,:,1:5) = 0; end
        mo4 = sum(sum(temp(i,:,xdim(3)-kedge:xdim(3))));
        if (mo4 > 2*fmaski) temp(i,:,xdim(3)-4:xdim(3)) = 0; end
        % If face is about the noise level, then delete the face.
        fmaski = sum(sum(temp(i,:,:))); 
        if fmaski < 2*FMR*xdim(2)*xdim(3)
            temp(i,:,:) = 0;
        end
	end
	for j = 1:xdim(2)
        fmaskj = sum(sum(temp(iedge:xdim(1)-iedge,j,kedge:xdim(3)-kedge))); 
        mo1 = sum(sum(temp(1:iedge,j,:)));
        if ( mo1 > 2*fmaskj ) temp(1:5,j,:) = 0; end
        mo2 = sum(sum(temp(xdim(1)-iedge:xdim(1),j,:)));
        if (mo2 > 2*fmaskj) temp(xdim(1)-4:xdim(1),j,:) = 0; end
        mo3 = sum(sum(temp(:,j,1:kedge)));
        if (mo3> 2*fmaskj)  temp(:,j,1:5) = 0; end
        mo4 = sum(sum(temp(:,j,xdim(3)-kedge:xdim(3))));
        if (mo4 > 2*fmaskj) temp(:,j,xdim(3)-4:xdim(3)) = 0; end
        fmaskj = sum(sum(temp(:,j,:)));
        if fmaskj < 2*FMR*xdim(1)*xdim(3)
            temp(i,:,:) = 0;
        end
	end
	for k = 1:xdim(3)
        fmaskk = sum(sum(temp(:,:,k)));
        if fmaskk < 2*FMR*xdim(2)*xdim(1)
            temp(i,:,:) = 0;
        end
	end

% Outputs
Y = temp;
    
if ( WriteVol == 1 )     
    v = V;  % preserves the header structure
    [dirname, xname, xext ] = fileparts(V.fname);
    artifname = ['ArtifactMask'  xext];
    if nargin == 0
        artifname = [MaskName xext];
    end
    artifpath = fullfile(dirname,artifname);
    v.fname = artifpath;
    noscale_write_vol(v,Y);  
end

%---------------------------------------------------------------
% Create and write image without the scale and offset steps  
% This function is spm_write_vol without error checking and scaling.
function noscale_write_vol(V,Y);
V = spm_create_vol(V);
for p=1:V.dim(3),
    V = spm_write_plane(V,Y(:,:,p),p);
end;
%V = spm_close_vol(V);  % not for SPM5   