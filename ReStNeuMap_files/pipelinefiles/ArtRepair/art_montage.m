function  [layout,locate] = art_montage(Y,plane,FS,CloseUp)
% FORMAT  [ layout, locate ] = art_montage(Y,plane,gap,FS,CloseUp)
%   Called by function art_movie.  V.2  allows hi-res images 128x128.
%
% FUNCTION:
%   Convert the 3D scan image Y into a 2D montage image of slices.
%   The 2D montage may contain all the slice (at one pixel per voxel),
%      or some of the slices (shown at 4 pixels per voxel).
%   Also returns vector "locate" to invert the process: from pixel -> voxel.
%
% INPUTS:  
%   Y is 3D matrix for a single image, comes in as type double.
%   plane is the plane to display
%   FS is the first slice to display in the CloseUp=1 mode
%   CloseUp = 0 gives all slices, with one pixel/voxel
%          = 1 gives ~20 consecutive slices, with four pixels/voxel.
% OUTPUTS: 
%  layout is a 2D image of all slices in designated plane, as type double.
%  locate is a length 6 vector used to locate the voxel from a pixel in layout.
%
% NOTE:  Large image arrays will be clipped to size (80,100,80),
%        unless they are hi-resolution with exact size 128x128 in-plane.
%
%See also:   display_slices, show_image, slice_overlay,  montage (in Matlab toolbox)
% Paul Mazaika, July 2004. V.2 upgrade for high-res August 2006.

%Note: There may be a faster way to do this using permute and reindexing.

% Maximum sizes allowed. Function will clip number and size of slices to fit.
[ A ] = size(Y);
NX = A(1);
NY = A(2);
NZ = A(3);
gap = 0;           %  No gaps allowed between slices.

% Is this a high-resolution 128x128 image?
size128 = find( A == 128 );
if (length(size128)==2)
   hires = 1;
else 
   hires = 0;
end

if hires == 0
   NX = min(NX,80);   % Slices are clipped for images larger than 80x100x80.
   NY = min(NY,100);  %   Bug: Would be nicer to clip in the middle.
   NZ = min(NZ,80);
end

%  Y(5,10,15) = 2000;   % Test Trace point for unmontage function.

% Layout an image array for regular volume
if hires == 0

    %{
    if CloseUp == 1  % For the 20-25 slice montage case
        % Three cases for slice sizes of the large image (79,95,69)
        %   Coronal   25 slices of size 79x70.  Montage is  5x5, size 790x700. 
        %   Sagittal  24 slices of size 95x70.  Montage is  4x6, size 760x840.
        %   Axial     20 slices of size 95x79.  Montage is  4x5, size 790x760
        if plane == 1  % axial/transverse    % was 4,5
            jlim = NX;  klim = NY;  NROWS = 5;  NCOLS = 4;  LastSlice = min(NZ,FS+19);
        elseif  plane == 2  %  sagittal
            jlim = NY;  klim = NZ;  NROWS = 4;  NCOLS = 6;  LastSlice = min(NX,FS+23);
        else   %  plane == 3  % coronal
            jlim = NX;  klim = NZ;  NROWS = 5;  NCOLS = 5;  LastSlice = min(NY,FS+24);
        end 
        layout = zeros(2*NROWS*jlim+6*gap,2*NCOLS*klim+6*gap);  % for the montage
        temp = zeros(jlim,klim);  % for a single slice
    else %  CloseUp = 0   %  For viewing all the slices
    %}
      
        % Steps:
        % Set up dynamic montage depending on number of slices.
        % Find NROWS number as square root of slice number and round the
        % number to highest integer.
        % Find NCOLS same as NROWS but round to lowest integer.
        % Add 1 if not enough NCOLS for all slices
        % IMPORTANT: NCOLS are really rows and NROWS are columns because
        % layout is transposed at the end.
        if plane == 1  % axial/transverse
            planeslices = NZ;
            NROWS = ceil(sqrt(planeslices));
            NCOLS = floor(sqrt(planeslices));
            if NROWS*NCOLS < planeslices NCOLS = NCOLS+1; end
            jlim = NX;  klim = NY; LastSlice = NZ;
        elseif  plane == 2  %  sagittal
            planeslices = NX;
            NROWS = ceil(sqrt(planeslices));
            NCOLS = floor(sqrt(planeslices));
            if NROWS*NCOLS < planeslices NCOLS = NCOLS+1; end
            jlim = NY; klim = NZ; LastSlice = NX;
        else   %  plane == 3  % coronal
            planeslices = NY;
            NROWS = ceil(sqrt(planeslices));
            NCOLS = floor(sqrt(planeslices));
            if NROWS*NCOLS < planeslices NCOLS = NCOLS+1; end
            jlim = NX;  klim = NZ;  LastSlice = NY;
        end
         
        %{
        % these lines not needed as we use dynamic montage above
        % Three cases for large image (79,95,69)
        %   Coronal   95(NY) slices of size 79x70.  Montage is 10x10, size 790x700. 
        %   Sagittal  79(NX) slices of size 95x70.  Montage is  8x10, size 760x700.
        %   Axial     69(NZ) slices of size 95x79.  Montage is  7x10, size 665x790
        %if plane == 1  % axial/transverse
        %    jlim = NX;  klim = NY;  NROWS = 6;  NCOLS = 5;  LastSlice = NZ;  % was 10,7
        %elseif  plane == 2  %  sagittal
        %    jlim = NY;  klim = NZ;  NROWS = 8;  NCOLS = 10;  LastSlice = NX;
        %else   %  plane == 3  % coronal
        %    jlim = NX;  klim = NZ;  NROWS = 10; NCOLS = 10;  LastSlice = NY;
        %end
        %}
        
        layout = zeros(NROWS*jlim,NCOLS*klim);  
        temp = zeros(jlim,klim);
        FS = 1;
    %{ end %}
end

% Layout an image array for high resolution case
if hires == 1
    %{
    if CloseUp == 1  % For the 20-25 slice montage case
        % Nominal high res volume is 128x128x25
        %  Get 3x3 images, or 3x15 at CloseUp view, 
        if plane == 1  % axial/transverse    % was 4,5
            if A(3) < 128 
               jlim = NX;  klim = NY;  NROWS = 3;  NCOLS = 3;  LastSlice = min(NZ,FS+8);
            else
                jlim = NX;  klim = NY;  NROWS = 3;  NCOLS = 15;  LastSlice = min(NZ,FS+44);
            end
        elseif  plane == 2  %  sagittal
            if A(1) < 128
               jlim = NY;  klim = NZ;  NROWS = 3;  NCOLS = 3;  LastSlice = min(NX,FS+8);
            else
               jlim = NY;  klim = NZ;  NROWS = 3;  NCOLS = 15;  LastSlice = min(NX,FS+44);
            end
        else   %  plane == 3  % coronal
            if A(2) < 128
               jlim = NX;  klim = NZ;  NROWS = 3;  NCOLS = 3;  LastSlice = min(NY,FS+8);
            else
               jlim = NX;  klim = NZ;  NROWS = 3;  NCOLS = 15;  LastSlice = min(NY,FS+44);
            end
        end 
        layout = zeros(2*NROWS*jlim+6*gap,2*NCOLS*klim+6*gap);  % for the montage
        temp = zeros(jlim,klim);  % for a single slice
    else %  CloseUp = 0   %  For viewing all the slices
    %}
    
        % Nominal high res volume is 128x128x25, not necessarily in that
        % order. Set up array either 6x6, or 6x25. 
        %     ( Note 6x25 includes all 128 slices)
        if plane == 1  % axial/transverse
            if A(3) < 128 % 6x6 view
                jlim = NX;  klim = NY;  NROWS = 6;  NCOLS = 6;  LastSlice = NZ;
            else   %  6x25 view
                jlim = NX;  klim = NY;  NROWS = 6;  NCOLS = 25;  LastSlice = NZ;
            end
        elseif  plane == 2  %  sagittal
            if A(1) < 128    % Is number of X planes small?
                jlim = NY;  klim = NZ;  NROWS = 6;  NCOLS = 6;  LastSlice = NX;
            else
                jlim = NY;  klim = NZ;  NROWS = 6;  NCOLS = 25;  LastSlice = NX;
            end
        else   %  plane == 3  % coronal
            if A(2) < 128 
                jlim = NX;  klim = NZ;  NROWS = 6; NCOLS = 6;  LastSlice = NY;
            else
                jlim = NX;  klim = NZ;  NROWS = 6; NCOLS = 25;  LastSlice = NY;
            end
        end
        layout = zeros(NROWS*jlim,NCOLS*klim);  
        temp = zeros(jlim,klim);
        FS = 1;
    %{ end %}
end

%killslice = 20; %dorian 


% Map the images to the pixels
if CloseUp == 0    % All slices
	for icolumn = 1:NCOLS
        fsn = FS + NROWS*(icolumn-1);  % first slice to display
		for i = fsn:fsn + NROWS - 1
            if i <= LastSlice   % Montage is larger than number of slices
                if (plane == 2) temp(:,:) = Y(NX-i+1,1:jlim,1:klim); end
                if (plane == 3) temp(:,:) = Y(1:jlim,NY-i+1,1:klim); end
                if (plane == 1) temp(:,:) = Y(1:jlim,1:klim,NZ-i+1); end
%                if i == killslice temp(:,:) = 0; end    % temporary code to test slices dorian
                ix = gap + (i - fsn )*(jlim+gap);   % depend on (i-fsn)
                iy = gap + (icolumn -1)*(klim+gap);    % depend on icolumn
                for j = 1:jlim
                    for k = 1:klim   % for all slices,  use one pixel per voxel
                        layout(ix+j  ,iy+k)   = temp(j,k);
                    end
                end
            end
        end
    end
end

%{
if CloseUp == 1  %  CloseUp version
	for icolumn = 1:NCOLS
        fsn = FS + NROWS*(icolumn-1);  % first slice to display
		for i = fsn:fsn + NROWS - 1
            if i <= LastSlice   % Requested slices must be in the data set.
                if (plane == 2) temp(:,:) = Y(NX-i+1,1:jlim,1:klim); end
                if (plane == 3) temp(:,:) = Y(1:jlim,NY-i+1,1:klim); end
                if (plane == 1) temp(:,:) = Y(1:jlim,1:klim,NZ-i+1); end
                ix = gap + (i - fsn )*(2*jlim+gap);   % depend on (i-fsn)
                iy = gap + (icolumn -1)*(2*klim+gap);    % depend on icolumn
                for j = 1:jlim
                    for k = 1:klim   % for CloseUp, use four pixels per voxel
                        layout(ix+2*j  ,iy+2*k)   = temp(j,k);
                        layout(ix+2*j+1,iy+2*k)   = temp(j,k);
                        layout(ix+2*j  ,iy+2*k+1) = temp(j,k);
                        layout(ix+2*j+1,iy+2*k+1) = temp(j,k);
                    end
                end
            end
		end
    end
end
%}


% Arrange the image to get these orientations:
%    Axial - eyes up in a slice, slices with eyes in upper images
%    Sagittal - brain stem on right side
%    Coronal - slices with eyes in lower images.
% HiRes images probably will not helped by this logic.
layout = layout';  
layout = flipud(layout);
layout = fliplr(layout);

% We're done with the montage. A few more values are returned in case
% a user wants to identify a voxel from a pixel in the montage. 

%  Return values used to locate a voxel from a pixel.
locate(1) = plane;
locate(2) = NCOLS; %  nxrect, number slices in i-direction
locate(3) = NROWS; %  nyrect, number slices in j-direction
locate(4) = klim;  %  slice size in i-direction
locate(5) = jlim;  %  slice size in j-direction

%{
if (CloseUp == 1) locate(4) = 2*locate(4); end
locate(5) = jlim;  %  yrect, slice size in j-direction
if (CloseUp == 1 ) locate(5) = 2*locate(5); end
locate(6) = LastSlice;   %
%}

% NOTES: Procedure to return an (X,Y,Z) voxel from a pixel location.
% For the calculation in this function:
%   plane = 3 coronal, slice size is NZxNX, arrayrect(10,10)
%   plane = 2 sag., slice size is NZxNY, arrayrect(10,8)
%   plane = 1 axial, slice size is NYxNX, arrayrect(7,10)
%   If CloseUp = 1, need to double jlim and klim, and use LastSlice.
% To invert the process, need the following steps:
%   For the plane orientation, need to determine slice #, x and y values.
%   xrect, yrect is slice size in (i,j) direction.
%   nxrect, nyrect is number of slices in (i,j) direction
% For a pixel (I,J) is layout:
%   xc = floor(I/locate(4)) + 1;
%   yc = floor(j/locate(5)) + 1;
%   snum = xc*locate(3) - (locate(2) - yc)
%   if ( snum < 1 ) snum = 1; end
%   jc = J mod(locate(5));   %yrect
%   ic = I mod(locate(4)); % xrect
%   jca = yrect - jc;
%   ica = xrect - ic;
%   if plane = 3,  X = jca,  Z = ica, Y = slice
%   if plane = 2,  Y = jca,  Z = ica, X = slice
%   if plane = 1,  X = jca,  Y = ica, Z = slice

