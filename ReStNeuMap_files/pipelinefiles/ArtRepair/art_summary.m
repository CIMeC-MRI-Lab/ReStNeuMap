function [GQout,GQmean,Resout] = art_summary(ImageFullName,MaskFullName,OutputFolder,Figname,Fignum,AutoParams);
% FUNCTION art_summary    (v3.1) Dec 2014
% For manual GUI:
%    >>art_summary    will use GUI to ask for images
%
% SUMMARY
%  Summarizes the overall quality of estimates produced during GLM
%  estimation for a single subject. Finds a histogram of all the
%  estimates over the whole head measured in percent signal change, 
%  and calculates the model residual averaged over the whole head.
%
%  Accurate estimates of percent signal change require that the user
%  know specific design information on the peak of the design regressor
%  and definition of the contrast. The program suggests a peak value
%  and user may override it. The suggestion is pretty reliable.
%
% GUI INPUTS if no arguments are supplied
%  User chooses con (or beta) results image(s) from an SPM Results folder.
%  User enters peak value of design regressor  (a value will be suggested)
%     The peak value can be found by SPM->Review Design->Explore.
%     Observe the peak value in the upper left graphics image. For ER designs
%     where events overlap, select the value that matches a single event.
%  User chooses a mask image (usually in the same Results folder)
%     IMPORTANT: To compare accuracies between different Results folders,
%        be sure to use the same mask for all cases.
%  Program assumes the SPM.mat, ResMS and constant-term beta image are in
%     the same Results folder.
%  OutputFolder is for GlobalMeasure text summary is set
%     automatically to the SPM Results folder.
% OUTPUTS
%  [ GQout, GQmean, Resout ] are the Global Quality scores and the mean 
%    of sqrt(ResMS) over all the voxels in the brain,
%    in units of percent signal change.
%    For multiple con image inputs, GQout is for the last one.
%  Writes an output text file 'GlobalMeasure.txt' in the OutputFolder,
%    with mean, std, and RMS value of each image.
%  Plots a histogram of estimated results (in percent signal change)
%    for each input image.
%  If the Matlab/Statistics toolbox is installed, and the code
%  at the end of this program is uncommented:
%    Plots a cumulative distribution of estimate/residual for all
%    the voxels in the image.
%
% ARGUMENT INPUTS for calling from another function 
%    [GQout,GQmean,Resout] = art_summary(ImageFullName, MaskFullName, OutputFolder,Figname,Fignum,AutoParams);
% Program is called by art_redo and art_groupoutlier
% Additional inputs are required when called from another function.
%  Figname specifies name of histogram image
%     In GUI mode, set to the name of Results folder.
%  Fignum specifies the first figure number to be plotted.
%     In GUI mode, it is set to 50.
%  AutoParams:  a 1x3 array, 
%     peak_value:    peak value of the design regressor
%     contrast_value:  sum of positive parts of contrast definition.
%     bmean:    mean of constant term image from last beta
%
% FUNCTIONS
%  Program normalizes to percent, by using the average value of
%  the last beta image within the specified mask.This value is scaled by
%  P/C, where P is the peak value of the design regressor, and C is the
%  sum of positive coefficients in the contrast definition.
%  Makes an inner mask, and outer mask from head mask by finding
%  a shell at the boundary of the mask, approx. 10 mm thick
%      (1 voxel thick when voxel size is > 2.5 mm, 2 voxels thick
%       when voxel size is < 2.5 mm.).
%
% Paul Mazaika, Sept. 2006.
% v2.1  added GQout and Resout function outputs.  pkm Jan 2007
%       small read changes for SPM5
% v2.2  added scaling by peak value and contrast RMS,
%       added those parameters as inputs for automatic mode..
%       removed dependency on Matlab Statistics Toolbox.   pkm july07 
% v2.3  scale GQ for nargin > 0. Constrain peak to be positive.
% v3    call art_percentscale for scaling, pkm feb09
% v3.1  supports SPM12, Dec2014 pkm. Support .nii format, Aug2015.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end
    

if nargin > 0
    % Assumed to handle one image at a time.
    Rimages = ImageFullName; 
    imgmask = MaskFullName; 
    [ResultsFolder, temp ] = fileparts(Rimages(1,:));
    %  Art_redo and art_groupoutlier only send one contrast image to check.
    
elseif nargin == 0   %  GUI interface if no arguments
    if strcmp(spm_ver,'spm5')
        Rimages  = spm_select(Inf,'image','select con image(s)');
        %Rimages  = spm_get(Inf,'.img','select con image(s)');  spm2
        [ResultsFolder, temp ] = fileparts(Rimages(1,:));
        imgmask  = spm_select(Inf,'image','select Mask image',[],ResultsFolder,'^mask.*');
    else  % spm2
        Rimages  = spm_get(Inf,'.img','select con image(s)');  spm2
        [ResultsFolder, temp ] = fileparts(Rimages(1,:));
        imgmask  = spm_get(Inf,'mask.img','select Mask image');
    end
    OutputFolder = ResultsFolder;
    [temp, ResultsName ] = fileparts(ResultsFolder);
    Fignum = 50;
    Figname = ResultsName;
    %imgmask  = spm_select(Inf,'image','select Mask image',[],ResultsFolder,'^mask.*');
end
Maska = spm_vol(imgmask);
Mask = spm_read_vols(Maska);
Mask = round(Mask);    % sometimes computed masks have roundoff error

if nargin == 0  % find the scale factors automatically
    for jj = 1:size(Rimages,1)
         ScaleFactors = art_percentscale(Rimages(1,:),imgmask);
         contrast_value(jj) = ScaleFactors(2);
    end
    jpeakmode = ScaleFactors(1);
    bmean = ScaleFactors(3);
    % User can override peak value.
    peak_value = spm_input('Enter peak value of design regressor',1,'e',num2str(jpeakmode,3),1);
    spm_input('!DeleteInputObj');
else   % AutoParams were passed in as arguments
    ScaleFactors = AutoParams;
    peak_value = AutoParams(1); contrast_value(1) = AutoParams(2); bmean = AutoParams(3);
end
    

% Find the ResMS and last beta image in Results folder with the Images
   R = spm_vol(Rimages);
   nimages = size(R,1);
   %Resimage = fullfile(ResultsFolder,'ResMS.img'); 
   if exist(fullfile(ResultsFolder,'ResMS.img'))
        Resimage = fullfile(ResultsFolder,'ResMS.img');
   else
        Resimage = fullfile(ResultsFolder,'ResMS.nii');
   end
   

% Find inner region (imask) and shell region (smask) of Mask.
% Want the shell to be about 10mm, so erode the mask by a step
% or two depending on the voxel size
if Maska.mat(2,2) < 2.5
    SHELL = 2;
else
    SHELL = 1;
end
%  Shell is the number of voxels thickness in the shell.
%  Shell = 1 seems to produce a two voxel thick shell.
if SHELL == 1
    imask = floor(smooth3(Mask)+0.02);
    smask = Mask & (1-imask);
else   %   case SHELL = 2
    iimask = floor(smooth3(Mask)+0.02);
    imask = floor(smooth3(iimask)+0.02);
    smask = Mask & (1-imask);
end
ilisti = find(imask==1);
ilists = find(smask==1);
ilista = find(Mask==1);
clear Mask smask imask
 
% Find the estimated residual stdev on each voxel
% Undo the MeanSquare for ResMS
    PRes = spm_vol(Resimage);
    Yres = spm_read_vols(PRes);
    Yres = 100*sqrt(Yres)/bmean; 
        
% Compute stats on the images
for i = 1:nimages+1
    if (i < nimages+1)
        % Scale the images into percentage. 
        P = spm_vol(Rimages(i,:));
        X = spm_read_vols(P);
        X = 100*X/bmean;
        X = (peak_value/contrast_value(i))*X;  % v2.2 change
        %X = (peak_value/contrast_value)*X;  % v2.2 change
        disp(Rimages(i,:));
    else  % (i == nimages+1)
        X = Yres; 
        disp(Resimage); 
    end 
    % Find mean and standard deviation of inner, shell, and total regions.
    %ilist = find(imask==1);
    isize = length(ilisti);
    imean = mean(X(ilisti));
    istd =  std(X(ilisti));
    %itrim = trimmean(X(ilisti),10);  % clips high 5% and low 5%
    [ itrim, i90 ] = clipstats10(X(ilisti));
    imax = max(abs(X(ilisti)));
    %i90 = prctile(X(ilisti),90)-itrim;     % dist of 90th percentile from mean
    ilarge = 100*length(find(abs(X(ilisti)>1)))/length(ilisti);  % percent voxels > 1 in size
    irms = sqrt(istd*istd + imean*imean);
    %ilist = find(smask==1);
    ssize = length(ilists);
    smean = mean(X(ilists));
    sstd  = std(X(ilists));
    srms = sqrt(sstd*sstd + smean*smean);
    %strim = trimmean(X(ilists),10);  % clips high 5% and low 5%
    [ strim, s90 ] = clipstats10(X(ilists));
    smax = max(abs(X(ilists)));
    %s90 = prctile(X(ilists),90)-strim;     % dist of 90th percentile from mean
    slarge = 100*length(find(abs(X(ilists)>1)))/length(ilists);  % percent voxels > 1 in size
    %ilist = find(Mask==1);
    tsize = length(ilista);
    tmean = mean(X(ilista));
    tstd  = std(X(ilista));
    trms = sqrt(tstd*tstd + tmean*tmean);
    %ttrim = trimmean(X(ilista),10);  % clips high 5% and low 5%
    [ ttrim, t90 ] = clipstats10(X(ilista));
    tmax = max(abs(X(ilista)));
    %t90 = prctile(X(ilista),90)-ttrim;     % dist of 90th percentile from mean
    tlarge = 100*length(find(abs(X(ilista)>1)))/length(ilista);  % percent voxels > 1 in size
    %totinout = [ tsize/1000 tmean tstd trms;...
    %    isize/1000 imean istd irms;  ssize/1000 smean sstd srms];
    %totals2 = [ tlarge ttrim t90 tmax;  ilarge itrim i90 imax;  slarge strim s90 smax ];
    %disp(' %Vox > 1%    Trimmean  90%ile    AbsMax,   for total, inner, and outer regions')
    %disp(totals2)
    disp(' Statistics for Total, Inner and Outer Regions')
    if i < nimages+1
        scalewords = [ ' Uses peak value ',num2str(peak_value),',  contrast sum of ',num2str(contrast_value(i)),...
            '  and mean value over mask of ',num2str(bmean,3) ];    
    elseif i == nimages+1
        scalewords = [ ' Calculated for sqrt(ResMS) divided by mean value over mask of  ',num2str(bmean,3) ];
    end
    disp(scalewords)
    disp(' Voxels/1000   Mean      Std       RMS   Trimmean  90%ile   %Vox > 1%  AbsMax')
    %disp(' Voxels/1000   Mean      Std       RMS,  for total, inner, and outer regions')
    %disp(totinout)
    totalstat = [tsize/1000 tmean tstd trms ttrim t90 tlarge tmax;...
                 isize/1000 imean istd irms itrim i90 ilarge imax;...
                 ssize/1000 smean sstd srms strim s90 slarge smax];
    disp(totalstat)
    
    fid = fopen(fullfile(OutputFolder,'GlobalQuality.txt'),'at');
    if i < nimages+1
        fprintf(fid,'\n%s\n',Rimages(i,:)); 
        fprintf(fid,'%s\n',scalewords);
    else
        fprintf(fid,'%s\n',Resimage);
        fprintf(fid,'%s\n',scalewords);
    end
    %fprintf(fid,'%s\n',' %Vox > 1%    Trimmean   90ile    AbsMax');
    %fprintf(fid,'%9.4f %9.4f %9.4f %9.4f\n',totals2');
    %fprintf(fid,'%s\n',' Voxels/1000   Mean      Std       RMS');
    %fprintf(fid,'%9.4f %9.4f %9.4f %9.4f\n',totinout');
    fprintf(fid,'%s\n',' Voxels/1000   Mean      Std       RMS   Trimmean   90ile   %Vox > 1%  AbsMax');
    fprintf(fid,'%9.4f %9.4f %9.4f %9.4f%9.4f %9.4f %9.4f %9.4f\n',totalstat');
    fclose(fid);

    % Make histogram and cumulative distribution for image
    if i < nimages+1
        GQout = tstd;
        vec = [ -3:0.05:3 ];
        figure(Fignum + 2*(i - 1));
        uu = X(ilisti);
        uup = hist(uu,vec);
        uus = X(ilists);
        uups = hist(uus,vec);
        vecp2 = [ tmean tmean+0.001 ];
        pv(1) = 0; pv(2) = max(uup);
        plot(vec,uup,'b-',vec,uups,'b--',vecp2,pv,'r--');
        currname = R(i,:);
        [ temp1, temp2 ] = fileparts(currname.fname);
        xtitle = [  'Histogram of Estimated Results for ' temp2 '  ' Figname ];
        title(xtitle)
        widthval = [ 'StDev = ' num2str(tstd,3) ];
        xlabela = ['Estimated Result (Pct signal change)   ' widthval];
        xlabel(xlabela)
        ylabel('Number of voxels')
        meanval  = [ 'Mean  ' num2str(tmean,3) ];
        
        legend('Inner region','Outer region', meanval);
        hold off;
%       % Matlab function normplot is in Statistics Toolbox.
%       % To plot distribution relative to normal, use this code.
%           figure(Fignum +2*i-1);
%           Z = X(ilista)./Yres(ilista);
%           normplot(Z);
%           xtitle = ['Distribution of Observed Estimate/Residual for ' temp2 '  ' Figname ];
%           title(xtitle)
%           xlabela = ['Arbitrary Units'];
%           xlabel(xlabela)
%           ylabel('Cumulative Probability')
%         % -----------------------------------
    end
    if i == nimages   % Values to return
        GQmean = tmean;
        %Exceed = tlarge;
        GQout = tstd;
    end
end

% Third value to return
Resout = tmean;   % Mean of sqrt(ResMS) image, which was last one processed.

function [ trim10, dist90 ] = clipstats10(YY);
%  Finds trimmean and 90th percentile of data without Statistics toolbox. 
%  Likely slower and less robust, but this is a simple application.
%  Hard-coded for 10% clip. Not worrying about roundoff for large datasets.
zz = sort(YY);
lz = length(zz);
lz90 = zz(round(lz*0.9));    % 90th percentile point
lim5 = round(lz*0.05);       %  5th percentile point
lim95 = lz -lim5 +1;         % symmetric clipping for 95%ile point
trim10 = mean(zz(lim5:lim95));  % trimmed mean
dist90 = lz90 - trim10;         % distance between 90%ile and trimmean.

 





