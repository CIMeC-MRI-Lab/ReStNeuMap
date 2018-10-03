function art_spm_mean_ui(varargin)
% FORMAT art_spm_mean_ui(P)
% FORMAT art_spm_mean_ui
%_______________________________________________________________________
% Prompts for a series of images and averages them.
% art_spm_mean_ui simply averages a set of images to produce a mean image
% that is written as type int16 to "mean.img" (in the current directory).
%
% art_spm_mean_ui avoids halting the calculation for small orientation
% errors. NOTE: An approximate mean image will be produced as long as the
% images have the same dimensions. This assumes that any differences in 
% orientation and voxel size are small, which is good enough for outlier
% repair.
%
% The script can be given a string matrix of filenames as input, or
% if none is given the user will be queried to choose input.
%
% This is not a "softmean" - zero voxels are treated as zero.
%_______________________________________________________________________
% @(#)spm_mean_ui.m	2.4 John Ashburner, Andrew Holmes 98/10/21
% Input capabilities added by Jeff Cooper 02/11/11 to support art_global.
% Approximate mean allowed - Paul Mazaika, August 2004. [ no v.2 changes].
SCCSid = '2.4';


%-Say hello
%-----------------------------------------------------------------------
if nargin==0
    SPMid = spm('FnBanner',mfilename,SCCSid);
else
    fprintf('\nCalculating mean...\n');
end
% if I give it input, I want it quiet.


%-Select images & check dimensions, orientations and voxel sizes
%-----------------------------------------------------------------------
if nargin == 0
    fprintf('\t...select files')
    P = spm_get(Inf,'.img','Select images to be averaged');
else
    P = varargin{1};
end
fprintf(' ...mapping & checking files')
Vi = spm_vol(P);

n  = prod(size(Vi));
if n==0, fprintf('\t%s : no images selected\n\n',mfilename), return, end

if n>1 & any(any(diff(cat(1,Vi.dim),1,1),1)&[1,1,1,0])
	error('images don''t all have same dimensions'), end
if any(any(any(diff(cat(3,Vi.mat),1,3),3)))
	disp('WARNING: images don''t all have same orientation & voxel size')
    disp('Volume repair will be done with approximate mean image.')
end


%-Compute mean and write headers etc.
%-----------------------------------------------------------------------
fprintf(' ...computing')
Vo = struct(	'fname',	'mean.img',...
		'dim',		[Vi(1).dim(1:3),4],...
		'mat',		Vi(1).mat,...
		'pinfo',	[1.0,0,0]',...
		'descrip',	'spm2 - mean image');

%-Adjust scalefactors by 1/n to effect mean by summing
for i=1:prod(size(Vi))
	Vi(i).pinfo(1:2,:) = Vi(i).pinfo(1:2,:)/n; end;

%-Write basic header
Vo = spm_create_vol(Vo);  % was spm_create_image(Vo) for SPM99;

%-Use spm_add to do the donkey work. Adds images in place.
Vo.pinfo(1,1) = spm_add(Vi,Vo);
Vo            = spm_close_vol(Vo);
%-Write header  (complete with scaling information)
Vo            = spm_create_vol(Vo);   % was spm_create_image(Vo);
Vo            = spm_close_vol(Vo);
%-Write output image (uses spm_write_vol - which calls spm_write_plane)
%-----------------------------------------------------------------------
%Vo = spm_write_vol(Vo,Y);

%-End - report back
%-----------------------------------------------------------------------
fprintf(' ...done\n')
fprintf('\tMean image written to file ''%s'' in current directory\n\n',Vo.fname)
