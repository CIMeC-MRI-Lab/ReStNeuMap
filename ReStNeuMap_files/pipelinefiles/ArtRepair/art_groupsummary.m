function [GQout,GQmean, Resout] = art_groupsummary(ImageFullName,MaskFullName,OutputFolder,Figname,Fignum,AutoParams);
% FUNCTION art_groupsummary    (v1)
% For manual GUI:
%    >>art_groupsummary    will use GUI to ask for images
%
% SUMMARY
%  Summarizes the overall quality of estimates produced during group level
%  GLM. Finds a histogram over all the voxels in the brain of the group mean 
%  estimates on each voxel. Finds the mean and standard deviation of the
%  histogram (the Global Quality scores). Calculates the mean of sqrt(ResMS) 
%  averaged over all the voxels in the brain. Results
%  are expressed in percent signal change, 
%
%  This program is similar to art_summary for single subjects, except
%  it must ask for a scale factor including a mean since there is no
%  constant term in a group study. Another difference is that
%  residuals at the group level are scaled into percent signal change
%  with the same conversion as the con images themselves, since these
%  group level residuals represent variance between subject estimates
%  that were produced with that scaling.
%
% GUI INPUTS if no arguments are supplied
%  User chooses con results image(s) from an SPM Group Results folder.
%  User enters scale factor: peak/contrastsum)*100/bmean
%     Find this using art_percentscale on a single subject.
%  User chooses a mask image (usually in the same Results folder)
%  Program assumes the SPM.mat, ResMS and constant-term beta image are in
%     the same Results folder.
%  OutputFolder is for GlobalMeasure text summary is set
%     automatically to the SPM Results folder.
%     
% OUTPUTS
%  [ GQout, GQmean, Resout ] are Global Quality standard deviation and
%    mean, and the mean of sqrt(ResMS) over the brain.,
%    For multiple con image inputs, GQout is for the last one.
%  Writes an output text file 'GlobalGroupQuality.txt' in OutputFolder,
%    with mean, std, and RMS value of each image.
%  Plots a histogram of estimated results (in percent signal change)
%    for each input image.
%  If the Matlab/Statistics toolbox is installed, and the code
%  at the end of this program is uncommented:
%    Plots a cumulative distribution of estimate/residual for all
%    the voxels in the image.
%
% FUNCTIONS
%  Program normalizes to percent, by using the average value of
%  the last beta image within the specified mask.This value is scaled by
%  P/C, where P is the peak value of the design regressor, and C is the
%  RMS of nonzero coefficients in the contrast definition.
%  Makes an inner mask, and outer mask from head mask by finding
%  a shell at the boundary of the mask, approx. 10 mm thick
%      (1 voxel thick when voxel size is > 2.5 mm, 2 voxels thick
%       when voxel size is < 2.5 mm.).
%
% Paul Mazaika, Jan. 2009. adapted from art_summary.
% supports SPM12, Dec2014.

% For calling from another function (not currently used)
%    [GQout,GQmean,Resout]=art_groupsummary(ImageFullName, MaskFullName, OutputFolder,Figname,Fignum,AutoParams);
% Required inputs
%  Figname specifies name of histogram image
%     In GUI mode, set to the name of Results folder.
%  Fignum specifies the first figure number to be plotted.
%     In GUI mode, set to 50.
%  AutoParams:  a 1x2 array, 
%     Hopefully, set correctly from SPM.mat using art_redo.
%     peak_value:    peak value of the design regressor
%     contrast_value:  sum of positive parts of contrast definition.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin > 0
    Rimages = ImageFullName; 
    imgmask = MaskFullName; 
    [ResultsFolder, temp ] = fileparts(Rimages(1,:));
    %  Art_redo only sends one contrast image to check.
    %   But this is not relevant for  group case.
    peak_value = 1;  contrast_value(1) = 1;
    if exist('AutoParams')
        peak_value = AutoParams(1); contrast_value(1) = AutoParams(2);
    end
elseif nargin == 0   %  GUI interface if no arguments
    if strcmp(spm_ver,'spm5')
        Rimages  = spm_select(Inf,'image','select group level con image(s)');
    else   % spm2
        Rimages  = spm_get(Inf,'.img','select group level con image(s)');
    end
    [ResultsFolder, temp ] = fileparts(Rimages(1,:));

    % Mask may be the SPM generated mask, or could be a user mask.
    if strcmp(spm_ver,'spm5')
        imgmask  = spm_select(Inf,'image','select Mask image'); % ' ',ResultsFolder);
    else  % spm2
        imgmask  = spm_get(Inf,'mask.img','select Mask image');
    end
    peak_value = spm_input('Enter peak/constrast*100/bmean ',1); 
    
    [ResultsFolder, temp ] = fileparts(Rimages(1,:));
    OutputFolder = ResultsFolder;
    [temp, ResultsName ] = fileparts(ResultsFolder);
    Fignum = 50;
    Figname = ResultsName;
    spm_input('!DeleteInputObj');
end

% Find the ResMS and last beta image in Results folder with the Images
   R = spm_vol(Rimages);
   nimages = size(R,1);
   Resimage = fullfile(ResultsFolder,'ResMS.img');
%   betaimages = spm_get('files',ResultsFolder,'beta*.img');  
%   lastbeta = size(betaimages,1);
%   Normimage = betaimages(lastbeta,:);
   %words = [' Normalizing by ', Normimage]; disp(words);


% Group case does not scale by last beta, so this is irrelevant.
% The last beta image in the Results folder is the SPM-estimated
% constant term. Scale all images by the average value of the last
% beta image with the head mask to get percentage.
% Find the normalization coefficient
 %   Pb = spm_vol(Normimage);
    Maska = spm_vol(imgmask);
 %   Xb = spm_read_vols(Pb);
    Mask = spm_read_vols(Maska);
    Mask = round(Mask);    % sometimes computed masks have roundoff error
% Find the global mean within the mask
 %   bmean = sum(Xb(find(Mask==1))); 
    bvox = length(find(Mask==1));   % number of voxels in mask
 %   bmean = bmean/bvox;           % mean of beta in the mask
    %words = ['Mean value of last beta: ', num2str(bmean,3) ];
    %disp(words);
 %   clear Xb


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
    imask = Mask & imask;  % in case a hole was filled
    smask = Mask & (1-imask);
else   %   case SHELL = 2
    iimask = floor(smooth3(Mask)+0.02);
    imask = floor(smooth3(iimask)+0.02);
    imask = Mask & imask;  % in case a hole was filled
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
    Yres = sqrt(Yres)*peak_value; % was 100/bmean for single subject; 

        
% Compute stats on the images
for i = 1:nimages+1
    if (i < nimages+1)
        % Scale the images into percentage. 
        P = spm_vol(Rimages(i,:));
        X = spm_read_vols(P);
        X = peak_value*X;  %100*X/bmean;
        %X = (peak_value/contrast_value(i))*X;  % v2.2 change
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
    %if i < nimages+1
    scalewords = [ ' Uses scale value of (peak value/contrast_sum)*100/bmean =  ',num2str(peak_value) ];
    disp(scalewords)
    if  i == nimages + 1
        disp(' Statistics of sqrt(ResMS)/(scale value) averaged over the image.')
    end
    disp(' Voxels/1000   Mean      Std       RMS   Trimmean  90%ile   %Vox > 1%  AbsMax')
    %disp(' Voxels/1000   Mean      Std       RMS,  for total, inner, and outer regions')
    %disp(totinout)
    totalstat = [tsize/1000 tmean tstd trms ttrim t90 tlarge tmax;...
                 isize/1000 imean istd irms itrim i90 ilarge imax;...
                 ssize/1000 smean sstd srms strim s90 slarge smax];
    disp(totalstat)
    
    fid = fopen(fullfile(OutputFolder,'GlobalGroupQuality.txt'),'at');
    if i < nimages+1
        fprintf(fid,'\n%s\n',Rimages(i,:)); 
        fprintf(fid,'%s\n',scalewords);
    else
        fprintf(fid,'%s\n',Resimage);
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
        
%         %To draw an image with only the total statistics
%         figure(200)
%         uua = X(ilista);
%         uupa = hist(uua,vec);
%         plot(vec,uupa,'b-',vecp2,pv,'r--');
%         currname = R(i,:);
%         [ temp1, temp2 ] = fileparts(currname.fname);
%         xtitle = [  'Histogram of Estimated Results for ' temp2 '  ' Figname ];
%         title(xtitle)
%         widthval = [ 'StDev = ' num2str(tstd,3) ];
%         xlabela = ['Estimated Result (Pct signal change)   ' widthval];
%         xlabel(xlabela)
%         ylabel('Number of voxels')
%         meanval  = [ 'Mean  ' num2str(tmean,3) ];
%         legend('All voxels', meanval);
        
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
    if i == nimages
        GQmean = tmean;
        Exceed = tlarge;
        GQout = tstd;
    end
end

% For compare_repair script, return two values
% GQout = tstd;   % Standard Deviation was saved for last non-Res image.
Resout = tmean;   % Mean of Res image, which was last one processed.

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

 





