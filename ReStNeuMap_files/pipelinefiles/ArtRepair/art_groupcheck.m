function art_groupcheck(Action)
% FUNCTION art_groupcheck  - v4 
%  
% FUNCTIONS:  
%       Allows a user to perform visual quality checks on contrast images
%   associated with a user-supplied group level SPM.mat file. These checks 
%   can compare con and ResMS values for all subjects on a voxel, or
%   view contrast estimates over all voxels for every subject, or
%   run Global Quality scores to help detect outlier subjects.
%
% INPUTS
% Choose group level SPM.mat file
%   If files at the full path name no longer exist, program prompts for the
%   current location of the con file of the first image. Program assumes
%   this same path change applies to all files in the group design.
%   These con files will be used for the analysis.
% Input the scale factor to percent signal change if you wish to override
%   the program suggestion. (See below for the method.) The suggestion
%   is pretty reliable.
% Choose method of viewing: 
%     1. All subjects on one voxel of interest
%     2. Contrast image for every subject, same format as art_movie,
%          but with scale range from -2% to +2%.
%     3. Identify subject outliers with the art_groupoutlier program.
% If viewing by images:
%     Choose Orientation:  Transverse, Sagittal, or Coronal
%     Select All slices (Recommended), or 25 close-up slices
%         In close-up mode, about 20-25 consecutive slices are shown in a
%         montage at twice the image size per slice. Select the desired
%         center slice of the montage.
%     Select ResMS weighting option: Yes or No.
%         No:  Shows contrast images for each subject. Helpful to
%              see if a normalization were peculiar for a subject.
%         Yes: Each contrast image is masked by the group ResMS, and
%              each voxel is weighted according to both the
%              single subject and group ResMS values at the  voxel,
%              This highlights voxel areas more likely to have high
%              group activations because of low variance.
% If viewing by voxel:
%       Input voxel coordinates (in mm) in the format: X Y Z
%
% PERCENT SIGNAL CHANGE CONVERSION
% The contrast image itself would be in percent signal change, IF
%     1.the mean image over the mask were 100, and
%     2.the peak of the design regressor were 1, and.
%     3.there were only one session included.(contrast sum = 1)
% The user can find these values from the result for a single
% subject using art_percentscale. Use the same con image as will be used
% in the group analysis. The peak and contrast sum are the same for
% all subjects. The mean value varies a bit from subject to subject,
% and is often 145-160 for Lucas Center scans. An average value will do here.
% The scale factor to convert the con images to percent is:
%     percentscale = (peak/(constrast sum))*(100/(meanvalue))
% Then
%     con (in percent sig change) = percentscale*con(image)
% This scales the groupcheck results for con images into percent signal change.
%
% OUTPUTS
%   If viewed by images:
%   - An interactive slider display with all frames of the montage movie,
%     where each frame shows the contrast image from one subject.
%   If viewed by voxel:
%     Overlayed bar graphs of the contrast and sqrt(ResMS) values for each 
%     subject at the user-specified voxel, with the contrast values in the
%     top 3/4 of the graph and the resMS values in the bottom 1/4. There is
%     also an editable text field from which the user can select new
%     mm coordinates.
%   If viewed by Global Quality scores, type >>help art_groupoutlier
%     for more information.
%     
% Jenny Drexler, August 2007.
% pkm, v.4, Mar 2009  adds scaling, and option for art_groupoutlier
% bug fix in file reading, M. Schmitgen. 2013.
% pkm, supports SPM12. Dec14
% pkm, supports .nii format, Aug15.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SIZE LIMIT - This parameter can be adjusted for a particular computer.
%   Matlab data is read as type double, then compressed to 8 bits.
%   400 volumes of (64x64x30) is 50 MB stored as type uint8.
%   An experiment session may contain 300-600 volumes.
%   The number of volumes affects the loading speed.
MAXSIZE = 510340;   %  About 50 MB is allowed into program storage.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end

% IMAGE GRAPH LIMIT. - Max and min of contrast image display is 2%. 
GRAPHSCALE = 75;   


% GET THE USER'S INPUTS
if (nargin==0)  % For calling in line with arguments
    % prompt user to select SPM design
    if strcmp(spm_ver,'spm5')
        origSPM  = spm_select(1,'SPM.mat','Select SPM group design'); 
    else  % spm2 version
        origSPM  = spm_get(1,'SPM.mat','Select SPM group design');
    end
    dirSPM = fileparts(origSPM);
    cd(dirSPM);
    load SPM;
    % load contrast image names
    for(i=1:SPM.nscan(1))
        F{i} = SPM.xY.P{i}(1:end-2);
    end
    nFsize = size(F,2);
    % STORE DESIGN MATRIX
    groupdesign = SPM.xX.X;
    
    if ~exist(F{1},'file')
        % if contrast images cannot be found, they have been moved
        disp('Image file paths have changed since SPM.mat was created.')
        disp(['Please select replacement image for ' F{1}])
        % prompt user to select new path of first scan
        askstring = ['Path has changed. Select con file to replace the one displayed.'];
        if strcmp(spm_ver,'spm5')
            Pnew = spm_select(1, 'image', askstring); 
         else  % spm2 version
            Pnew = spm_get(1,'*img', askstring );
        end
        Pold = F{1};
        % Remove comma in names (sometimes occurs in SPM5)
           Pnew = strtok(Pnew,',');
           Pold = strtok(Pold,',');
        S = char(Pnew, Pold);
        S(1,:) = strjust(S(1,:), 'right');
        S(2,:) = strjust(S(2,:), 'right');
        % compare paths to find new path prefix
        for(i=1:size(S,2))
            if strcmp(S(1, i:size(S, 2)), S(2, i:size(S, 2)))
                PnewPrefix = strtrim(S(1, 1:i));
                PoldPrefix = strtrim(S(2, 1:i));
                break;
            end
        end
        % find new paths for all images
        for(j=1:nFsize)
            F{j} = strrep(F{j}, PoldPrefix, PnewPrefix);
        end
    end
    for(i=1:nFsize)
        % if path updates didn't work, prompt user for each image that
        % could not be found
        if ~exist(F{i})
            disp([F{i} ' does not exist. Please select new image path.']);
            askstring = ['Select replacement image'];
            if strcmp(spm_ver,'spm5')
                F = cellstr(spm_select(1, 'image', askstring)); 
            else  % spm2 version
                F = cellstr(spm_get(1, '*img', askstring));
            end
        end
    end
    
    % Find the percent scaling factors automatically. 
    % Set the mask by the group level 'mask.img,1' image
    % Set flag to .img or .nii filetype.
    imgtype=2;
    if exist(fullfile(dirSPM,'mask.img'))
        GroupMaskName = fullfile(dirSPM,'mask.img');
        imgtype=1;
    else
        GroupMaskName = fullfile(dirSPM,'mask.nii');
    end
    ScaleFactors1 = art_percentscale(char(F{1}),GroupMaskName);
    ScaleFactors2 = art_percentscale(char(F{2}),GroupMaskName);
    bmeanavg = 0.5*(ScaleFactors1(3) + ScaleFactors2(3));
    suggestscale = (ScaleFactors1(1)/ScaleFactors1(2))*100/bmeanavg;
    % Give user a chance to fix it.
    disp(' ')
    disp('A suggested scaling into percent signal change is shown.')
    disp('User may change the value to override the suggestion.');
    percentscale = 1;
    percentscale = spm_input('Enter (peak/constrast)*100/bmean',1,'e',num2str(suggestscale),1);
    
    % prompt user for viewing option
    View = spm_input('View by:', ...
        1, 'm', ' Con and ResMS values for all subjects at one voxel location | Image of contrast result for every subject | Global Quality scores and suggested subject outliers', [1, 0, 2]);
    if (View == 1) % voxel of interest
        % load single subject resMS image names
        for(i=1:nFsize)
            [Path, ConImg] = fileparts(F{i});
            if (imgtype==1) subjResMS{i} = spm_vol([Path '/ResMS.img']);
            else subjResMS{i} = spm_vol([Path '/ResMS.nii'])
        end

        % get image dimensions
        Q = spm_vol(F{1});
        Q1 = spm_read_vols(Q);
        [ NX, NY, NZ ] = size(Q1);
        dim(1) = NX; dim(2) =NY; dim(3) = NZ;
        
        % prompt user for voxel coordinates in mm
        xyz = spm_input('Enter X Y Z coords in mm',1,'e',[],3);
        x_mm=xyz(1);
        y_mm=xyz(2);
        z_mm=xyz(3);

        % Read the images and extract the information on a voxel
        intensity=zeros(nFsize,1);
        intensityRes=zeros(nFsize,1);
        for filenumber=1:nFsize 
            Q2 = spm_vol(F{filenumber});
            Q1 = spm_read_vols(Q2);
            % find transformation for converting to voxel coordinates
            transformation(1, :) = Q2.mat(1, 1:3);
            transformation(2, :) = Q2.mat(2, 1:3);
            transformation(3, :) = Q2.mat(3, 1:3);
            translation = [Q2.mat(1, 4);
                           Q2.mat(2, 4);
                           Q2.mat(3, 4);];
            % convert user input from mm to voxel coordinates
            mmcoord = [x_mm; y_mm; z_mm;] - translation;
            voxcoord = transformation\mmcoord;
            x = round(voxcoord(1));
            y = round(voxcoord(2));
            z = round(voxcoord(3));
            % get contrast and ResMS values
            intensity(filenumber) = Q1(x,y,z);
            if isnan(Q1(x,y,z))
                disp('WARNING: NaN voxel in Contrast image')
                words = [ F{filenumber} ];
                disp(words);
            end
            QRes1 = spm_read_vols(spm_vol(subjResMS{filenumber}));
            intensityRes(filenumber) = sqrt(QRes1(x,y,z));
            if isnan(QRes1(x,y,z))
                disp('WARNING: NaN voxel in ResMS image')
                words = [ F{filenumber} ];
                disp(words);
            end
        end
        
        % Scale information to percent signal change
        intensity    = percentscale*intensity;
        intensityRes = percentscale*intensityRes;
        % HAVE INFORMATION WE NEED. intensity and groupdesign.
        dummy = 1;

        %Display Figure
        contrastplot = figure('Position', [360,500,650,400]);
        subplot('Position', [.1, .3, .8, .6]);
        xx = [1:nFsize];      

        K = 0.75; % variable for bar sizing

        % produce ResMS bar graph
        barResMS = bar(xx, intensityRes, 'FaceColor', [.6 .9 1], 'EdgeColor', [.2 .5 .6]);
        set(barResMS, 'BarWidth', K/4);
        axesResMS = gca;
        set(axesResMS, 'YAxisLocation', 'right', 'YColor', [.2 .5 .6], 'TickDir', 'out', 'TickLength', [0 1]);
        ylabel('Subject sqrt(ResMS) (% signal change)');
        xlabel('Subject Number');
        %title('Contrast and ResMS Values by Subject');
        titlewords = ['Contrast and sqrt(ResMS) Values by Subject, Location ',num2str(x_mm,2),' ',num2str(y_mm,2),' ',num2str(z_mm,2) ];
        title(titlewords)
        % produce Contrast bar graph
        axesContrast = axes('Position', get(axesResMS, 'Position'));
        barContrast = bar(xx, intensity, 'FaceColor', [.4 .8 .6], 'EdgeColor', [.2 .6 .4]);
        set(barContrast, 'BarWidth', K);
        set(axesContrast, 'Color', 'none', 'XTickLabel',[], 'YColor', [.2 .6 .4]);
        ylabel('Contrast Value (% signal change)');
        set(axesContrast, 'XLim', get(axesResMS, 'XLim'));
        % expand Contrast Y-axis by 1/3 on the bottom (so that the bottom
        % 1/4 of the contrast graph is empty space)
        axesContrastLims = get(axesContrast, 'YLim');
        axesContrastrange = axesContrastLims(2) - axesContrastLims(1);
        newLims = [(axesContrastLims(1) - axesContrastrange/3) axesContrastLims(2)];
        set(axesContrast, 'YLim', newLims);
        % expland ResMS Y-axis by a factor of 4, so that the bars are all
        % contained in the bottom 1/4 of the figure
        set(axesResMS, 'YLim', (4.2*get(axesResMS, 'YLim')))

        % create editable text box
        hnewvoxel = uicontrol('Units', 'normalized',...
            'Style','edit',...
            'Max', 1, 'Min', 1,...
            'String', 'Select New Coordinates',...
            'Position', [.3,.05,.4,.1],...
            'Callback', {@newvoxel_Callback, F, subjResMS,percentscale});
        Action = 'voxel';
        
    elseif View == 0  % view by image for each subject
        f = deblank(F{1});
        V = spm_vol(f);
        Y = spm_read_vols(V);
        sdims = size(Y);
        % Get the image dimensions. Set bounds on the number of scans allowed.
        [ sy, si ] = sort(sdims);  % si(1) is the minimum dimension
        sor = 1;   % default preference for axial.
        if ( sy(2)==sy(3) & (sy(2) == 64 | sy(2) == 128 ))
            disp('Looks like a raw image!')
            if ( si(1) == 1 ) disp('  Sagittal slices'); sor = 2; end
            if ( si(1) == 2 ) disp('  Coronal slices');  sor = 3; end
            if ( si(1) == 3 ) disp('  Axial slices');    sor = 1; end
        end
        Orient= spm_input('Select slice orientation',...
            1,'m','axial|sagittal|coronal',[ 1 2 3], sor);  % Orient=1 for transverse, etc.
        if ( Orient == 1 ) slnum = sdims(3); end
        if ( Orient == 2 ) slnum = sdims(1); end
        if ( Orient == 3 ) slnum = sdims(2); end
        mdims = prod(sdims);
        mxscans = round(MAXSIZE/mdims) * 100;
        MAXSCAN = mxscans;
        % Get the images and define the viewing montage.
        CloseUp = 0;    % Usually want all slices for results.
%         if slnum > 9   % 9 is for the HiResolution case.
%             CloseUp = spm_input('All Slices or ~20 close-up slices',1, ' All | Close-up', [ 0 1 ], 1 );
%         else  %  No need to ask if there are fewer than 25 slices total.
%             CloseUp = 1;
%         end
        if CloseUp == 1
            centerslice = round(slnum/2);
            slicesel = spm_input([num2str(slnum) ' slices. Pick montage center' ],1,'n',num2str(centerslice));   % array of integers
            slicesel = max(1,slicesel - 12);  %  slicesel is now the first slice.
        else
            slicesel = 1;    % Start at first slice for All slice case
        end

        %resMSweighting= spm_input('ResMS weighting?',1, ' No | Yes ', [ 0 1 ] );
        resMSweighting = 0;  % residual weighted images are not helpful yet.
        if(resMSweighting)
            %load group ResMS image
            ResMS_img = spm_read_vols(spm_vol(SPM.VResMS.fname));
            %load single subject ResMS images
            for(i=1:nFsize)
                [Path, ConImg] = fileparts(F{i});
                if (imgtype==1) img1 = spm_vol([Path '/ResMS.img']);
                else img1 = spm_vol([Path '/ResMS.nii'])
                subjResMS{i} = spm_read_vols(img1);
            end
        end

        mode = 1;
        export = 0;
        
        f = deblank(F{1});
        V = spm_vol(f);
        nFsize = size(F,2);
        Action = 'Load'; nnnn = 6;
    elseif View == 2   % Global Quality scores
        % Note user override scaling is NOT available here.
        Groupscale(1) = ScaleFactors1(1);  % peak
        Groupscale(2) = ScaleFactors1(2);
        Groupscale(3) = bmeanavg;
        OutputDir = dirSPM;   % write output diagnostics to group results folder
        disp('Output diagnostics will be written to folder with SPM.mat.')
        art_groupoutlier(F, GroupMaskName, Groupscale, OutputDir);
        %groupoutlier5(sjDirX, ResultsFolder,ConImageName, dirSPM,Groupscale, OutputDir);
        %    F is cell array of contrast images
        %    ResultsFolder is folder in subject path with con image and mask image.
        %    GroupMaskNameMask is the conjunction group mask
        %    OutputDir specifies where output images and files will be written.
        Action = 'groupoutlier';
    end
end

spm_input('!DeleteInputObj');

switch lower(Action) 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case('load')

    if(View==0) % view by scan
        % INITIALIZE ARRAYS, REFERENCE IMAGE, AND COLORMAP
        % Adjust for number of scans and size limit
        % Last scan is minimum of size limited or end of group.
        firstscan = 1;
        lastscanM = firstscan + MAXSCAN - 1;  % Size limit for memory and program speed
        lastscanF = nFsize;       % Size limit by end of available files.
        lastscan = min( [ lastscanM lastscanF ] );
        Slimit = lastscan - firstscan + 1;   % Number of scans that will be processed.

        % Display the ResMS images
        % Use second contrast image as reference for sizing and scaling
        % purposes
        nbase = round(firstscan + 1);
        fref = deblank(F{nbase});
        V = spm_vol(fref);
        gap = 0;   %  No space allowed between image slices in the montage.
        % Read and draw the preview image.
        Yref = spm_read_vols(V);   % Y is type double, size 4MB for (79,95,68);
        Yref = percentscale*Yref;  % Scale reference to percent signal change.
        n = isnan(Yref);
        Yref(n)=0;

        if(resMSweighting)
            % replace NaNs with zeroes in group ResMS image
            n = isnan(ResMS_img);
            ResMS_img(n)=0;
            % replace NaNs with zeroes in single subject ResMS images
            for(i=1:nFsize)
                x = isnan(subjResMS{i});
                subjResMS{i}(x) = 0;
            end
            
            % Calculate average (i.e. RMS) single subject ResMS on a voxel
            % by voxel basis
            for(i=1:size(subjResMS{1}, 3))
                for(j=1:size(subjResMS{1}, 2))
                    for(k=1:size(subjResMS{1},1))
                        x=[];
                        for(n=size(subjResMS, 2))
                            x=[x; subjResMS{n}(k,j,i)];
                        end
                        avgsubjResMS(k, j, i) = norm(x)/sqrt(nFsize);
                    end
                end
            end
            
            % ResMask is the combination of the group ResMS and average
            % single subject ResMS
            ResMask = sqrt(ResMS_img + avgsubjResMS);
            
            % Divide the reference image by the ResMask 
            for(i=1:size(Yref, 3))
                for(j=1:size(Yref, 2))
                    for(k=1:size(Yref,1))
                        if(ResMask(k,j,i)==0) Yref(k,j,i) = 0;
                        else Yref(k,j,i)=Yref(k,j,i)/ResMask(k,j,i); end
                    end
                end
            end
            
            % set up montage displays for ResMS image
            [layoutrms, nil] = art_montage(ResMask, Orient, slicesel, CloseUp);

            Resmax = max(max(layoutrms));
            Resmin = min(min(layoutrms));

            % replace zeroes in the display of the ResMask with high values
            % so that the image displayed shows the effect of the ResMS
            % weighting (darker voxels in the ResMask are emphasized in the
            % weighted contrasts)
            for(i=1:size(layoutrms, 1))
                for(j=1:size(layoutrms, 2))
                    if(layoutrms(i,j) == 0) layoutrms(i,j) = Resmax; end
                end
            end

            %figure 1 is the ResMask
            figure(1);
            clf;
            imagesc(layoutrms,[ Resmin Resmax]); colormap(gray) 
            drawnow;
            disp('Total ResMS image has been read and displayed.')
        end

        % set up display of reference image in order to determine max and
        % min values for scaling purposes.
        [layout,nil] = art_montage(Yref,Orient,slicesel,CloseUp);
        Yrmax=max(max(layout));
        Yrmin=min(min(layout));

        % Set up the arrays. Size of the image was determined in function art_montage.
        [ xs, ys ] = size(layout);
        % Dimension imageblock on the fly, else "zeros" command makes type double.
        imageblock = uint8(zeros(xs,ys,Slimit));  % Size is 50MB for 100 scans of uint8 data.
        temp = uint16(zeros(xs,ys));
        temp1 = zeros(xs,ys);
        layout8 = uint8(zeros(xs,ys));
        history = zeros(lastscan,4);  %  Track some global properties

        % Set the colormap
        cmap = colormap(gray);   % Size cmap is 64, so must map imageblock values to 0-63.
        if(resMSweighting) cmap = art_activationmap3(1);
        %else cmap = art_blue2yellowmap(1);   end % cmap = colormap(cool) is also pretty good.
        %else cmap = art_activationmap2(1);   end % cmap = colormap(cool) is also pretty good.
        else cmap = art_activationmap3(1);   end % cmap = colormap(cool) is also pretty good.

        % LOAD A SINGLE VOLUME AT A TIME AND CONVERT TO UINT8 FOR STORAGE
        % Reads a scan at a time, and sets up a uint8 image, or a movie frame, for it.
        disp('Loading data - this may take a few minutes for a lot of scans')
        scale = 510/(Yrmax-Yrmin + 1);
        scale = GRAPHSCALE; %75;  % DISABLED AUTO SCALING. EXTREMES OF GRAPH ARE 2%.
        scale_str = sprintf('Colormap display range is [-2,+2] using scale factor of %3g', scale);
        disp(scale_str);
        % Scale the reference image to baseline intensities [ 0 510 ].
        for iscan = firstscan:lastscan
            nscan = iscan - firstscan + 1;
            % load contrast image
            f =deblank(F{iscan});
            V = spm_vol(f);
            Y = spm_read_vols(V);
            % Replace all NaNs in contrast image with zeroes
            n = isnan(Y);
            Y(n)=0;
            % Divide contrast image by the ResMask. Ignore (i.e. set to
            % zero) the contrast image where the ResMask is zero
            if(resMSweighting)
                for(i=1:size(Y, 3))
                    for(j=1:size(Y, 2))
                        for(k=1:size(Y,1))
                            if(ResMask(k,j,i)==0) Y(k,j,i) = 0;
                            else Y(k,j,i)=Y(k,j,i)/ResMask(k,j,i); end
                        end
                    end
                end
            end
            %scale contrast image and convert to 2D montage
            % Scale in percent signal change.
            Y=Y*scale*percentscale;
            history(iscan,1:4) = art_centroid(Y);  %  Collect time histories
            [temp1,nil] = art_montage(Y,Orient,slicesel,CloseUp);  % temp is double
            %temp1 = round(tempz);
            
            % convert values to fit 0-64 colormap scale
            % Range [ -150, +150 ] -> [ 1, 63 ]
            temp = uint16(max(1.6*(temp1)+254,0));  % clips the bottom
            temp = min(temp,510);  % clips the top
            imageblock(:,:,nscan) = uint8( bitshift(temp,-3));   % Range -150 to +150 -> 1-63.
            
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
        
        % Display slider figure
        ha =figure('Position',[100 100 830 830]);  % Create the slider figure.
        figure(ha);
        colormap(cmap);
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
        figwin = ha;
        % set up fields for slider callback
        m_struct=struct('movie',imageblock,'filename',struct('names',F),'first',firstscan,...
            'orient',Orient);
        s=uicontrol('Style','slider','Parent',figwin,...
            'Position',[245 80 338 30],...
            'Min',min_slide,'Max',max_slide,...
            'SliderStep',[min_step max_step],...
            'Callback','art_groupcheck(''Scroll'');',...
            'Userdata',m_struct,'String','Frame number');
        figbar = axes('position',[ 0.93 0.3 0.03 0.4]);
        darray = [63:-1:0];
        image(darray');
        %set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+160 +80 0 -80 -160],'XTickLabel',[]);
        set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+2 +1 0 -1 -2],'Xtick',1,'XTickLabel','PERCENT');
        set(0,'CurrentFigure',figwin);
        set(0,'ShowHiddenHandles','on')
        fig = axes('position',[0.07 0.15 0.8 0.8],'Parent',figwin);
        I = imageblock(:,:,1);
        image(I,'Parent',fig,'Tag','ToDelete');
        axis image;
        axis off;
        frame=sprintf('%s',deblank(F{firstscan}));  % Gets the path and file name
        t=title('x','FontSize',14,'Interpreter','none','Tag','ToDelete'); %sets Interpreter
        t=title(frame,'FontSize',14,'Interpreter','none','Tag','ToDelete');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case('scroll') % if user clicks on slider
        global PRINTSTR
        if isempty(PRINTSTR)
            PRINTSTR='print -dpsc2 -append spm.ps';
        end;
        g=get(gcbo,'Value');
        m_struct=get(gcbo,'Userdata');
        imageblock = m_struct.movie;
        Or=m_struct.orient;
        firstscan=m_struct.first;
        F = m_struct.filename;
        [ htemp, currfig ] = gcbo;
        figwin= figure(currfig);  % spm_figure('FindWin','Graphics');
        figbar = axes('position',[ 0.93 0.3 0.03 0.4]);
        darray = [63:-1:0];
        image(darray');
        %set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+160 +80 0 -80 -160],'XTickLabel',[]);
        set(figbar,'Ytick',[1 17 33 48 64],'YTickLabel',[+2 +1 0 -1 -2],'XTickLabel',[]);
        fig = axes('position',[0.07 0.15 0.8 0.8],'Parent',figwin);
        h=findobj('Tag','ToDelete');
        if ~isempty(h)
            delete(h);
        end;

        figure(currfig);
        nscan = size(imageblock,3);
        gscan = 1 + floor(g+0.5);
        if (gscan > nscan) gscan = nscan; end
        I=imageblock(:,:,gscan);
        image(I,'Tag','ToDelete');
        axis image;
        g2scan = gscan + firstscan - 1;
        framename = deblank(F(g2scan).names);
        t=title('y','FontSize',14,'Interpreter','none','Tag','ToDelete'); %sets Interpreter
        t=title(framename,'FontSize',14,'Interpreter','none','Tag','ToDelete');
        axis off;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case('voxel') % if in voxel mode, callback doesn't need to do anything
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case('groupoutlier') % callback doesn't need to do anything
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    otherwise
        warning('Unknown action string')
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function newvoxel_Callback is called when the user inputs new coordinates
% in the voxel display
function newvoxel_Callback(hObject,eventdata,F, subjResMS,percentscale)
user_input = get(hObject,'String');
Q1 = spm_read_vols(spm_vol(F{1}));
nFsize = size(F, 2);
% convert user input to coordinates
[ NX, NY, NZ ] = size(Q1);
dim(1) = NX; dim(2) =NY; dim(3) = NZ;
[xstr, remain]=strtok(user_input, ' ');
x_mm=str2double(xstr);
[ystr, remain]=strtok(remain, ' ');
y_mm=str2double(ystr);
z_mm=str2double(strtok(remain, ' '));

% Read the images and extract the information on a voxel
intensity=zeros(nFsize,1); %length(SPM.xY.P));
intensityRes=zeros(nFsize,1);
for filenumber=1:nFsize  %length(SPM.xY.P)
    Q2 = spm_vol(F{filenumber});
    Q1 = spm_read_vols(Q2);
    %get transformation to convert mm input to voxel coordinates
    transformation(1, :) = Q2.mat(1, 1:3);
    transformation(2, :) = Q2.mat(2, 1:3);
    transformation(3, :) = Q2.mat(3, 1:3);
    translation = [Q2.mat(1, 4);
        Q2.mat(2, 4);
        Q2.mat(3, 4);];
    % convert user input to voxel coordinates
    mmcoord = [x_mm; y_mm; z_mm;] - translation;
    voxcoord = transformation\mmcoord;
    x = round(voxcoord(1));
    y = round(voxcoord(2));
    z = round(voxcoord(3));
    
    intensity(filenumber) = Q1(x,y,z);
    if isnan(Q1(x,y,z))
        disp('WARNING: NaN voxel in Contrast image')
        words = [ F{filenumber} ];
        disp(words);
    end
    QRes1 = spm_read_vols(spm_vol(subjResMS{filenumber}));
    intensityRes(filenumber) = sqrt(QRes1(x,y,z));
    if isnan(QRes1(x,y,z))
        disp('WARNING: NaN voxel in ResMS image')
        words = [ F{filenumber} ];
        disp(words);
    end
end

% HAVE THE VALUES WE NEED in intensity(1:nFsize).and groupdesign.
% Scale information to percent signal change
    intensity    = percentscale*intensity;
    intensityRes = percentscale*intensityRes;
dummy = 1;

% Display figure
clf;
subplot('Position', [.1, .3, .8, .6]);
title(['Voxel coordinates  ' user_input]);
xx = [1:nFsize];

K = 0.75;

barResMS = bar(xx, intensityRes, 'FaceColor', [.6 .9 1], 'EdgeColor', [.2 .5 .6]);
set(barResMS, 'BarWidth', K/4);
axesResMS = gca;
set(axesResMS, 'YAxisLocation', 'right', 'YColor', [.2 .5 .6], 'TickDir', 'out', 'TickLength', [0 1]);
ylabel('Subject ResMS StdDev');
xlabel('Subject Number');
titlewords = ['Contrast and ResMS Values by Subject, Location ',num2str(x_mm,2),' ',num2str(y_mm,2),' ',num2str(z_mm,2) ];
title(titlewords)
%title('Contrast and ResMS Values by Subject');
axesContrast = axes('Position', get(axesResMS, 'Position'));
barContrast = bar(xx, intensity, 'FaceColor', [.4 .8 .6], 'EdgeColor', [.2 .6 .4]);
set(barContrast, 'BarWidth', K);
set(axesContrast, 'Color', 'none', 'XTickLabel',[], 'YColor', [.2 .6 .4]);
ylabel('Contrast Value (% signal change)');
set(axesContrast, 'XLim', get(axesResMS, 'XLim'));
axesContrastLims = get(axesContrast, 'YLim');
axesContrastrange = axesContrastLims(2) - axesContrastLims(1);
newLims = [(axesContrastLims(1) - axesContrastrange/3) axesContrastLims(2)];
set(axesContrast, 'YLim', newLims);
set(axesResMS, 'YLim', (4.2*get(axesResMS, 'YLim')));

hnewvoxel = uicontrol('Units', 'normalized',...
    'Style','edit',...
    'Max', 1, 'Min', 1,...
    'String', 'Select New Coordinates',...
    'Position', [.3,.05,.4,.1],...
    'Callback', {@newvoxel_Callback, F, subjResMS,percentscale});
Action = 'voxel';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
