function art_movie(Action)
% FORMAT art_movie    (v. 4.2)
%   
% FUNCTIONS:  Displays bulk data for quick visual review by a user. Typical
%   time to process and display all the data in 100 scans of size (64,64,30)
%   is a minute or two. Every voxel of scan data can be seen.
%       The contrast view and high contrast view roughly show 16% and
%   4% variations from a reference image. This automatic scaling first
%   adjusts input images so that the mean over the brain is 1000. 
%   The contrast movie range of -160 to +160 corresponds to a -16% to +16%
%   variation on those voxels. The high contrast limits of 40 are 4%.
%       Each scan is made into a montage of slices with orientation
%   chosen by input. The montage may be all slices or about 25 consecutive
%   slices. The slice displays may either be raw image data, contrast
%   mode or high contrast mode. The contrast modes show the difference between
%   each image and a reference image, amplified so that small data variations
%   are more visible. The reference image is selected by the user, or will
%   default to the second image in the range.
%       In slider mode, every scan montage is available by selecting the 
%   slider position. The display is a default Matlab window where the zoom
%   button can be used to examine individual pixels. In movie mode, every scan
%   montage is shown, followed by a time history of mean intensity of each scan.
%       An Export option allows the contrast images will be written in
%   AnalyzeFormat. All contrasts are made positive by adding 512 to the
%   difference. This mode is for data interchange with other programs.
%      
% INPUTS
%   Choose Orientation:  Axial, Sagittal, or Coronal.
%       For raw images, a * marks the orientation of slice collection.
%   Choose a Set of Images (in .img format) to review.
%   Choose a Range of images to process. 
%       Hundreds of images can be chosen, but the program will run slower.
%   Select All slices, or 25 close-up slices.
%       In close-up mode, about 20-25 consecutive slices are shown in a
%       montage at twice the image size per slice. Select the desired 
%       center slice of the montage.
%   Select Raw or Contrast or High Contrast display. 
%       Raw shows the image data in the set of scans. 
%       Contrast shows the difference of the image from a reference scan.
%          The display shows yellow as higher, and blue as lower from the 
%          reference. Values are amplified to be 6x more sensitive for viewing.
%          Contrast mode helps to see artifacts in raw images.
%       High Contrast is the same as Contrast, but amplified 25x more
%          sensitive than raw for a close look at voxel noise.
%   Select Reference image. User may choose any image, or the mean images, 
%       or the second image in the range. The dynamic image option compares
%       every image to the immediately preceding image.
%       Typical user choice might be a mean image or a rest state.
%   Select Movie & Time History,  or interactive Slider.
%       If a movie, select a movie frame rate. Three loops are played.
%          2 or 4 fps is slow enough to visually spot artifacts.
%          At the end of the movie, a time history of the average intensity 
%          and position of each scan is displayed.
%       The slider shows individual frames and allows user to zoom in and out.
%   Select Export option, if desired, for Analyze image output. 
%           
% OUTPUTS
%   The reference image in raw image format.
%   A movie of a montage of slices, for all the scans of data, 
%          followed by a time history plot, OR
%   An interactive slider display with all frames of the montage movie.
%       Slices outlined in red mean unusual noise was detected on the
%       slice.
%   If Export is selected, contrast images will be written in AnalyzeFormat
%       with the letter "c" prepended to the filename.
%
% BUGS
%    Left-Right is not well-defined on the output images.
%    Out of Memory error message may occur for large numbers of scans.
%        Reduce the number of scans, or close other running programs.
%    The reference scan will show as solid black in contrast viewing.
%
% See also:  spm_movie,  AnalyzeMovie

% Paul Mazaika  Feb 2005,. v2.2 minor tweaks, July 2007
% v2.3  fix to image drawing by Volkmar Glauche, June 2008
% v3    scale mean image to 1000 (instead of using peak voxel) Mar 2009 pkm
%       multiple SPM versions
% v4.1  changes by Dorian Pustina, October 2012
%       Increased memory limit to half of SPM memory limit
%       Added option to select mean image, or dynamic image, as reference.
%       Scales display to fill window using all slices. Removed the CloseUp option.
%       Detects and displays slices with unusual noise.
% v4.2  supports SPM12, Dec2014 pkm.  Parse slice default changed to No.


% SIZE LIMIT - This parameter can be adjusted for a particular computer.
%   Matlab data is read as type double, then compressed to 8 bits.
%   400 volumes of (64x64x30) is 50 MB stored as type uint8.
%   An experiment session may contain 300-600 volumes.
%   The number of volumes affects the loading speed.
%   Set maximum memory usage as half of what SPM can use

% if strcmp(spm('Ver'),'SPM8') == 1
%     spm('Defaults', 'fmri');
%     MAXSIZE = spm_get_defaults('stats.maxmem')/2;
% else
%     spm_defaults;
%     global defaults;
%     MAXSIZE = defaults.stats.maxmem/2;
% end

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5'))
    spm_defaults;
    global defaults;
    MAXSIZE = defaults.stats.maxmem/2;
else
    spm('Defaults','fmri'); 
    MAXSIZE = spm_get_defaults('stats.maxmem')/2;
end



% GET THE USER'S INPUTS
if (nargin==0)  % For calling in line with arguments
    if strcmp(spm_ver,'spm5')
         F = spm_select(Inf,'image','select images');
    else  % spm2 version
         F = spm_get(Inf, '.img', 'Select images');
    end
    %F      = spm_select(Inf,'image','select images');
    nFsize = size(F,1);
    % Get the image dimensions. Set bounds on the number of scans allowed.
    f = deblank(F(1,:));    % take the first filename
    V = spm_vol(f);         % get first image header
    Y = spm_read_vols(V);   % read first image data
    sdims = size(Y);        % count first image dimensions (also in the header)
    [ sy, si ] = sort(sdims);  % si(1) is the minimum dimension
    sor = 1;   % default preference for axial.
    if ( sy(2)==sy(3) & (sy(2) == 64 | sy(2) == 128 ))
        disp('Image dimensions look like a raw image!')
        if ( si(1) == 1 ) disp('  Sagittal slices'); sor = 2; end
        if ( si(1) == 2 ) disp('  Coronal slices');  sor = 3; end
        if ( si(1) == 3 ) disp('  Axial slices');    sor = 1; end
    end
    Orient= spm_input('Select slice orientation',...
		1,'m','axial|sagittal|coronal',[ 1 2 3], sor);  % Orient=1 for transverse, etc.
    slnum = 50;   %  a default number of slices. Shouldn't need this.
    if ( Orient == 1 ) slnum = sdims(3); end
    if ( Orient == 2 ) slnum = sdims(1); end
    if ( Orient == 3 ) slnum = sdims(2); end
    
	mdims = prod(sdims);                    % calculate memory need for an image
    mxscans = round(MAXSIZE/mdims);         % removed '* 100' because MEMSIZE is now the exact number of bytes;   
    MAXSCAN = mxscans;

    % Get the images and define the viewing montage.
    defaultscansel = ['1:' num2str(nFsize)];
    scansel = spm_input([num2str(nFsize) ' vols. Select range, e.g. 10:99'],1,'e',defaultscansel,NaN);  %array of integers
    
    
    % variables outdated but still needed for other functions
    CloseUp = 0;    % option CloseUp = 1 removed
    slicesel = 1;   % variable used for CloseUp = 1, but still required

    
    
    typesel = spm_input('Select Data Magnification',1,'m', ...
        ' Raw Image Data | Contrast (best for finding artifacts in raw images} | High contrast (for viewing preprocessed images)',...
        [ 1 2 3 ], 2);
    refsel = 1;  % For non-contrast image, reference choice doesn't matter.
    if typesel > 1   % For contrast modes, ask for a reference image
        refsel = spm_input('Choose a Reference Image',1,'m', ...
            'Mean Image (calculate mean and use as reference) | Dynamic (last volume becomes reference for next) | Static-default (from the middle of the list) | Static-manual (user-specified)', [4 3 1 2], 1);
        if refsel == 2
             if strcmp(spm_ver,'spm5')  
                 Frefer      = spm_select(1,'image','select one reference image');
             else  % spm2 version
                 Frefer      = spm_get(Inf,'.img','select one reference image');
             end
            %Frefer      = spm_select(Inf,'image','select one reference image');
            fref = deblank(Frefer);
        end
    end
    
    
    smode=spm_input('Select viewing mode',1,'m', ...
        ' Slider | Movie (montage movie in Matlab) | Export (writes AnalyzeFormat images of contrasts ) | Slider and Export', [ 1 0 2 3] );
    if ( smode == 1 | smode == 3 )  % slider
        nloops = 1;
        mode = 1;
        export = 0;
    end
    if  smode == 0   %  smode == 0, movie
        frate = spm_input('Frames/second ? (e.g. 4)',1);
        nloops = spm_input('Number of movie loops',1);
        mode = 0;
        export = 0;
    end
    if  ( smode == 2 | smode == 3 )  % export in writevols
        export = 1;
        mode = 1;
    end
    %  Advanced Options - not implemented
    %   DeepView - matched filter, rest offset, variance beta.
        %    TR value   - affects the averaging for activation preview
        %    offset value  - estimated rest state deviation from reference,  or automatic
    %  Preliminary sizing
     f = deblank(F(1,:));
     V = spm_vol(f);
     nFsize = size(F,1);
     Action = 'Load'; nnnn = 6;
end

spm_input('!DeleteInputObj');

switch lower(Action), case('load')

    
% INITIALIZE ARRAYS, REFERENCE IMAGE, AND COLORMAP
% Adjust for number of scans and size limit
% Last scan is minimum of user selection, size limited, or end of group.
% Note Scan 1 is first scan in group; its name is usually not image_001. !!!
firstscan = scansel(1);   
lastscanU = firstscan + length(scansel) - 1;  % User choice for last scan
lastscanM = firstscan + MAXSCAN - 1;  % Size limit for memory and program speed
lastscanF = nFsize;       % Size limit by end of available files.
lastscan = min( [ lastscanU lastscanM lastscanF ] );
Slimit = lastscan - firstscan + 1;   % Number of scans that will be processed.

%% warn the user if not all selected images are displayed
if Slimit < numel(scansel)
   h =warndlg(sprintf(['Impossible to display all selected images.\nNot enough memory or missing files in drive.'...
       '\n\nSelection:    ' num2str(numel(scansel)) ' images'...
       '\nLimited to first:    ' num2str(Slimit) ' images']), 'Internal limit reached.');
   waitfor(h);  % don't proceed until the user clicks OK, otherwise the warning will be covered with other windows
end

%% Determine name of reference image
% If user selected the reference image, then fref is known and refsel=2.
% If user selected dynamic reference (refsel=1), then fref is the image in
% the middle of the list.
if refsel == 1
    nbase = ceil(Slimit/2);                                                                                 % reference scan from the middle of timeseries
    fref = deblank(F(nbase,:));
    [refdir refname refext] = fileparts(fref);
    disp(['Reference image: ''' refname '.img'' (middle of ' num2str(Slimit) ' images in the list)']);      % display the selected reference in Matlab prompt
    clear refdir refname refext;
elseif refsel == 3              % dynamic reference case
                                % temporary load first image as reference
                                % to start art_montage layout
    nbase = 1;
    fref = deblank(F(nbase,:));
elseif refsel == 4                     % mean image calculation
    h = waitbar(0,['Calculating Mean Volume'], 'Name','Please wait...');
    for iscan = firstscan:lastscan
        total = (lastscan-firstscan+1); position = (iscan - firstscan + 1);
        proportion = position/total;
        waitbar(proportion,h);

        nscan = iscan - firstscan + 1;
        f =deblank(F(iscan,:));
        V = spm_vol(f);
        Y = spm_read_vols(V);
        if exist('Ymean') ~= 1  Ymean = zeros(V.dim); end
        Ymean = Ymean+Y;
    end
    delete(h);
    Ymean = Ymean/(lastscan-firstscan+1);   % divite YMean to get the mean
    [dirname, xname, xext ] = fileparts(V.fname);
    fref = fullfile(dirname,['temporary_mean' xext]);
    V.fname = fref;
    spm_write_vol(V,Ymean);
    clear thisimg nscan f V Y Ymean dirname xname xext;
end


%% load  reference image previously define
% will be middle for static default or
% will be mean image for mean calculated choice or
% will be user selected filename or
% will be first image for dynamic reference just to setup layout
V = spm_vol(fref);
gap = 0;   %  No space allowed between image slices in the montage.
% Read and draw the preview image.
Yref = spm_read_vols(V);   % Y is type double, size 4MB for (79,95,68); 
% Y is a 4D representation of images, 4th dimension is the scan number.
[layout,nil] = art_montage(Yref,Orient,slicesel,CloseUp);    % Currently double
figure(4);   % Standard Matlab window has zoom enlargement, etc.
Yrmax = max(max(max(Yref)));
Yrmin = min(min(min(Yref)));

% SCALE IMAGE so that image mean is 1000. Report scale factors
Automask = art_automask(V.fname,-1,1);
maskcount = sum(sum(sum(Automask)));  %  Number of voxels in mask.
sumref = sum(sum(sum(Automask.*Yref)));
meanimage = sumref/maskcount;
words = [' Mean of actual image over head mask = ',num2str(meanimage)];
%  Scale all image data by Y =Y*1000/meanimage
disp(words)
words = [' Scaling mean of image to 1000 for contrast displays.'];
disp(words)
words = [' Colorbar value of 160 will be 16% of mean. Colorbar value of 40 is 4%.'];
disp(words)
disp(' ')

imagesc(layout,[ Yrmin Yrmax ]); colormap(gray)   % puts one image up to start.
drawnow;
disp('Reference image has been read and displayed.')





%% Set up the arrays. Size of the image was determined in function art_montage.
[ xs, ys ] = size(layout);
    % In movie mode, data is stored in movie frames, not in the imageblock array.
        if (mode == 0)  Slimit = 1; end
    % Dimension imageblock on the fly, else "zeros" command makes type double.
    % imageblock = uint8(zeros(xs,ys,Slimit));  % Size is 50MB for 100 scans of uint8 data.
    temp = uint16(zeros(xs,ys));
    temp1 = zeros(xs,ys);
    layout8 = uint8(zeros(xs,ys)); 
    history = zeros(lastscan,4);  %  Track some global properties 
    
    
%% Set the colormap 
% For a raw image, Range 0-2040 is mapped to range of 64.
% For contrast image, amplitude scale will be 5x larger. -160,+160 -> 0,64.   
cmap = colormap(gray);   % Size cmap is 64, so must map imageblock values to 0-63.
if ( typesel == 2 )   % Get the contrast map.
    cmap = art_blue2yellowmap(1);   % cmap = colormap(cool) is also pretty good.
end
if typesel == 3
    cmap = art_icehotmap(1);
end



% LOAD A SINGLE VOLUME AT A TIME AND CONVERT TO UINT8 FOR STORAGE
% Reads a scan at a time, and sets up a uint8 image, or a movie frame, for it.
disp('Loading data - this may take a few minutes for a lot of scans')
% Scale the reference image to mean intensity of 1000.
   layout = layout*1000/meanimage;
   h = waitbar(0,['Reading images'], 'Name','Please wait');
for iscan = firstscan:lastscan
    total = (lastscan-firstscan+1); position = (iscan-firstscan+1);
    proportion = position/total;
    waitbar(proportion,h,['Reading image ',num2str(position),' of ',num2str(total)]);
    
    %% for dynamic reference, use the volume before as reference
    % if this is first volume, reference will be itself
    % Note: if first scan to display is 32, reference will be 31
    % despite not being displayed
    if refsel == 3
        ref.nscan = max(1,iscan - firstscan);       % biggest of (iscan - firstscan) or number 1
        ref.f = deblank(F(ref.nscan,:));    
        ref.V = spm_vol(ref.f);
        ref.Y = spm_read_vols(ref.V);
        Yref = ref.Y;
        [layout,nil] = art_montage(ref.Y,Orient,slicesel,CloseUp);
        Yrmax = max(max(max(ref.Y)));
        Yrmin = min(min(min(ref.Y)));
        ref.Automask = art_automask(ref.V.fname,-1,0);
        maskcount = sum(sum(sum(ref.Automask)));  %  Number of voxels in mask.
        sumref = sum(sum(sum(ref.Automask.*ref.Y)));
        meanimage = sumref/maskcount;
        layout = layout*1000/meanimage;
    end
    
    %% process current image now
    nscan = iscan - firstscan + 1;
    f =deblank(F(iscan,:));
    V = spm_vol(f);
    Y = spm_read_vols(V);  
    % Program colormap scaling assumes mean is 1000.
        Y = Y*1000/meanimage;
    history(iscan,1:4) = art_centroid(Y);  %  Collect time histories
    [temp1,nil] = art_montage(Y,Orient,slicesel,CloseUp);  % temp is double 
    
    

    
    
    if mode == 1   %  Slider mode-  load imageblock
        if typesel == 1   % For raw data, we'll divide by 64 for the movie, anyway.
            temp = uint16(temp1);   % Prepares non-integer data for bitshift operation.
            imageblock(:,:,nscan) = uint8( bitshift(uint8(bitshift(temp,-3)),-2)) ;   % Range 0-2040
        elseif  typesel == 2     % For contrast data, compare to reference scan.
            temp = uint16(max(1.6*(temp1-layout)+254,0));  % clips the bottom
            temp = min(temp,510);  % clips the top
            imageblock(:,:,nscan) = uint8( bitshift(temp,-3));   % Range -250 to +250 -> 64.
        else  % typesel == 3   %  For high contrast data, compare to reference scan
            % Note: Since 256/6.4 = 40, the data range will be -40 to +40.
            % This range is used on colorbar tick marks on the output.
            temp = uint16(max(6.4*(temp1-layout)+254,0));  % clips the bottom
            temp = min(temp,510);  % clips the top
            imageblock(:,:,nscan) = uint8( bitshift(temp,-3));   % Range -40 to +40 -> 64.
        end
    else   %   mode == 0,   Movie mode- load the movie image frames
        if typesel == 1   % For raw data, we'll divide by 64 for the movie, anyway.
            temp = uint16(temp1);   % Prepares non-integer data for bitshift operation.
            %  SHOULDN'T THIS INDEX BELOW BE NSCAN INSTEAD OF 1?
            imageblock(:,:,1) = uint8( bitshift(uint8(bitshift(temp,-3)),-2)) ;   % Range 0-2040
        elseif  typesel == 2     % For contrast data, compare to reference scan.
            temp = uint16(max(1.6*(temp1-layout)+254,0));  % clips the bottom
            temp = min(temp,510);  % clips the top
            imageblock(:,:,1) = uint8( bitshift(temp,-3));   % Range -250 to +250 -> 64.
        else  % typesel == 3   %  For high contrast, compare to reference scan
            temp = uint16(max(6.4*(temp1-layout)+254,0));  % clips the bottom
            temp = min(temp,510);  % clips the top
            imageblock(:,:,1) = uint8( bitshift(temp,-3));   % Range -40 to +40 -> 64.
        end
        layout8 = min(63,imageblock);  %  Guarantees it fits into movie uint8 format.
        M(nscan) = im2frame(layout8,cmap);
    end
    
    if export == 1   % Write out contrast volumes in AnalyzeFormat
        Y = Y - Yref + 512;
        Y = max(1,Y);
        % Prepare the header for the filtered volume.
           %V = spm_vol(P(i-1).fname);
           v = V;
           [dirname, sname, sext ] = fileparts(V.fname);
           sfname = [ 'c', sname ];    % c pre-pended for contrast.
           filtname = fullfile(dirname,[sfname sext]);
           v.fname = filtname;
        spm_write_vol(v,Y); 
    end
end
delete(h)       % DELETE the waitbar; don't try to CLOSE it.

%% find out bad slices
parsebadslice = spm_input('Parse & Display bad slices?',1,'m',' Yes | No', [ 1 0 ], 0);
if parsebadslice == 1
    [badslices badorient] = art_slice_check(F);
    
    % check orientation correspond
    if (Orient == 1 & badorient ~= 3) parsebadslice = 0;
    elseif  (Orient == 2 & badorient ~= 1) parsebadslice = 0;
    elseif (Orient == 3 & badorient ~= 2) parsebadslice = 0;
    end
    
    if parsebadslice == 0
        textorient{1} = 'Axial';
        textorient{2} = 'Sagittal';
        textorient{3} = 'Coronal';
        badtextorient{1} = 'Sagittal';
        badtextorient{2} = 'Coronal';
        badtextorient{3} = 'Axial';
        warning('Bad slices are displayed ONLY in the orientation data was collected.');
        warning(['You selected ' textorient{Orient} ' orintation but data was collected in ' badtextorient{badorient}]);
    end
end



%% DISPLAY IN MOVIE OR SLIDER FORMAT
%----------------------------------------------------------
ha =figure('Position',[100 100 830 830]);  % Create the movie or slider figure.
figure(ha);
colormap(cmap);
if mode==0   %  Movie Mode and Time History
   h=findobj('Tag','ToDelete');
   if ~isempty(h)
      delete(h);
   end;
   movie(ha,M,nloops,frate,[15 15 0 0])   % Default is frate = 4 frames/sec.
   %  Show the time history plots at the end of the movie.
   subplot(4,1,1);
   plot(history(firstscan:lastscan,1));
   title('Scan History');
   ylabel('Intensity');
   subplot(4,1,2);
   plot(history(firstscan:lastscan,2)); 
   limlow = mean(history(firstscan:lastscan,2)) - 0.3;  % 30% voxel from the mean
   ylim([ limlow  limlow+0.6 ]);
   ylabel('x-movement (voxels)');
   subplot(4,1,3);
   plot(history(firstscan:lastscan,3));
   limlow = mean(history(firstscan:lastscan,3)) - 0.3;
   ylim([ limlow  limlow+0.6 ]);
   ylabel('y-movement (voxels)');
   subplot(4,1,4);
   plot(history(firstscan:lastscan,4));
   limlow = mean(history(firstscan:lastscan,4)) - 0.3;
   ylim([ limlow  limlow+0.6 ]);
   ylabel('z-movement (voxels)');
   xlabel(['Relative Scan number. Relative Scan 1 is Scan ' num2str(firstscan-1)]);
elseif mode==1   %  Slider Mode
   if Slimit == 1   %  Slimit is number of scans processed.
      min_step=0.5;
      max_step=1;
      min_slide=0;
      max_slide=0.5;
   elseif Slimit == 2
      min_step=0.5;
      max_step=1;
      min_slide=0;
      max_slide = Slimit - 1;
   elseif Slimit < 10
      min_step=1/(Slimit-1);
      max_step=1;
      min_slide=0;
      max_slide = Slimit - 1;
   else
      min_step=1/(Slimit-1);
      max_step=10/(Slimit-1);
      min_slide = 0;
      max_slide = Slimit - 1;
   end
   h=findobj('Tag','ToDelete');
   if ~isempty(h)
      delete(h);
   end;
   
   if parsebadslice == 1, badslices = cell2struct(badslices, 'slices', 1);
   else badslices = [];
   end
   
   figwin = ha;
   m_struct=struct('movie',imageblock,'filename',F,'first',firstscan,...
       'typesel',typesel,'orient',Orient,'locate',nil, 'parsebadslice',parsebadslice,'badslices', badslices);
   s=uicontrol('Style','slider','Parent',figwin,...      
		    'Position',[245 80 338 30],...
		    'Min',min_slide,'Max',max_slide,...
		    'SliderStep',[min_step max_step],...
                    'Callback','art_movie(''Scroll'');',...
		    'Userdata',m_struct,'String','Frame number');
   if typesel == 2 | typesel == 3  % Draw the colormap for the contrast case.
       figbar = axes('position',[ 0.93 0.3 0.03 0.4]);
       darray = [63:-1:0];
       image(darray');
       if typesel == 2
         set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+160 +80 0 -80 -160],'XTickLabel',[]);
      else  % typesel == 3
          set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+40 +20 0 -20 -40],'XTickLabel',[]);
      end
   end
   set(0,'CurrentFigure',figwin);
   set(0,'ShowHiddenHandles','on')%%%%%%%%%%%%I added this
   fig = axes('position',[0.07 0.15 0.8 0.8],'Parent',figwin);
   I = imageblock(:,:,1);
   image(I,'Parent',fig,'Tag','ToDelete');
   axis image;
   axis off;
   frame=sprintf('%s',deblank(F(firstscan,:)));  % Gets the path and file name
   t=title('x','FontSize',14,'Interpreter','none','Tag','ToDelete');
   t=title(frame,'FontSize',14,'Interpreter','none','Tag','ToDelete');
   
   % fix filename text to adapt to window
	un = get(t,'units');
    set(t, 'units','normalized');
    ext=get(t,'extent');
    set(t, 'units',un);
    set(t,'Fontsize',14/(ext(3)-ext(1)));


end


case('scroll')
%==========================================================
global PRINTSTR
if isempty(PRINTSTR)
   PRINTSTR='print -dpsc2 -append spm.ps';
end;
g=get(gcbo,'Value');
m_struct=get(gcbo,'Userdata');
imageblock=m_struct.movie;
Or=m_struct.orient;
firstscan=m_struct.first;
typesel = m_struct.typesel;
F=m_struct.filename;
[ htemp, currfig ] = gcbo;
figwin= figure(currfig);  % spm_figure('FindWin','Graphics');
if typesel == 2 | typesel == 3   % Draw the colorbar for the contrast case.
    figbar = axes('position',[ 0.93 0.3 0.03 0.4]);
    darray = [63:-1:0];
    image(darray');
      if typesel == 2
         set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+160 +80 0 -80 -160],'XTickLabel',[]);
      else  % typesel == 3
          set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+40 +20 0 -20 -40],'XTickLabel',[]);
      end
end
figax = findobj(figwin,'Tag','FigAx');
if isempty(figax)
    figax = axes('position',[0.07 0.15 0.8 0.8],'Parent',figwin);
    set(figax,'Tag','FigAx');
    axis(figax,'off');
end
axes(figax);
% if isempty(figwin)
%    figwin=spm_figure('Create','Graphics','Graphics');
% end
h=findobj('Tag','ToDelete');
%%H  = gca;
%j=get(H,'children');
if ~isempty(h)
    delete(h);
    %delete(j(1,1))
end;

figure(currfig);
nscan = size(imageblock,3);
gscan = 1 + floor(g+0.5);
if (gscan > nscan) gscan = nscan; end
I=imageblock(:,:,gscan);
image(I,'Parent',figax);
axis(figax,'image','off'); 
set(figax,'Tag','FigAx');
g2scan = gscan + firstscan - 1;  
framename = deblank(F(g2scan,:));
t=title('z','FontSize',14,'Interpreter','none','Tag','ToDelete'); %sets Interpreter
t=title(framename,'FontSize',14,'Interpreter','none','Tag','ToDelete');
un = get(t,'units');
set(t, 'units','normalized');
ext=get(t,'extent');
set(t, 'units',un);
set(t,'Fontsize',14/(ext(3)-ext(1)));

% outline slices with artifacts
if m_struct.parsebadslice == 1                       % if the user wants to see bad slices
    badslices = m_struct.badslices;
    tempbadslices = struct2cell(badslices);
    if any(tempbadslices{gscan})                        % if any bad slice for this volume
        for bd = 1:length(tempbadslices{gscan})         % for each bad slice
            [x y w h] = art_slice2pos(tempbadslices{gscan}(bd), m_struct.locate);
            rectangle('Position',[x y w h], 'LineWidth',3, 'EdgeColor','r');
        end
    end
end

%======================================================================== 
otherwise
%========================================================================
warning('Unknown action string')
%=======================================================================
end;
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
