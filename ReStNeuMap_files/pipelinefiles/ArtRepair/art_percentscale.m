function ScaleFactors = art_percentscale(ImageFullName,MaskFullName);
% FUNCTION art_percentscale
% For manual GUI:
%    >> art_percentscale 
% For calling from another function
%    ScaleFactors = art_percentscale(ImageFullName, MaskFullName);
%
% SUMMARY
%  For a single subject's contrast image, finds the scale factors
%  that convert a contrast image into percent signal change.
%  Assumes that there is the SPM.mat file, a mask image, and 
%   a last beta image in the same folder, that represents
%   the constant term in the GLM.
%  Assumes that all peaks in the design matrix are the same.
% INPUT
%  A contrast image from a single subject
%  (In batch format only) A mask image, e.g. a group level mask instead.
% OUTPUT
%  ScaleFactor(1) is Peak_value
%  ScaleFactor(2) is contrast_sum
%  ScaleFactor(3) is Mean of image over head mask.
%
%  FUNCTIONS
%      The peak value of the design regressor is found from the
%  SPM.mat file. See the FMRIPercentSignalChange document.
%  To check the peak, start SPM, and push the Review Design button. On the menu,
%  choose Explore. Select a design regressor and look at the peak value
%  on the graph in the upper left corner. For ER designs, choose the peak
%  of a single event rather than any overlapping events. For block designs,
%  any value on top of the block is accurate enough. 
%  To see the contrast definition, push the Results button. Select
%  a contrast and observe the coefficients. Find the sum of the positive coefficients,
%  e.g. 2 for [ 1 -1 1 -1 0 ] or 1 for [ 1 -1 0 0 ]. The program
%  will try to find these values from the SPM.mat file. 
%      Program normalizes to percent, by using the average value of
%  the last beta image within the specified mask.
%
% Paul Mazaika, Feb 2009.
% supports SPM12, Dec2014. pkm
% supports .nii format, Aug2015 pkm.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin > 0
    Rimages = ImageFullName;  
    imgmask = MaskFullName; 
    [ResultsFolder, temp ] = fileparts(Rimages(1,:)); 
elseif nargin == 0   %  GUI interface if no arguments
    if strcmp(spm_ver,'spm5')
        Rimages  = spm_select(Inf,'image','select single subject con image(s)');
    else   % spm2
        Rimages  = spm_get(Inf,'.img','select single subject con image(s)');
    end
    [ResultsFolder, temp ] = fileparts(Rimages(1,:));
    [temp, ResultsName ] = fileparts(ResultsFolder);
    % We ask for the mask, but might prefer to find mask automatically
      aMaskimages = spm_select('List',ResultsFolder,'^mask.*\.img$'); % for SPM5
      imgmask = fullfile(ResultsFolder,aMaskimages);
%     if strcmp(spm_ver,'spm5')
%         %imgmask  = spm_select(Inf,'mask.img','select Mask image'); 
%         imgmask  = spm_select(Inf,'image','select Mask image',[],ResultsFolder,'^mask.*');
%     else  % spm2
%         imgmask  = spm_get(Inf,'mask.img','select Mask image');
%     end
    spm_input('!DeleteInputObj');
end

% For either case, try to get automatic scaling
% Set the parameters to estimate percent signal change.(v2.2)
% First, see if we can estimate the peak regressor for the GUI suggestion:
% Assumes all the peaks of all design regressors are the same.
try     %  v2.2 logic
    % Try to find the peak value of design regressor, and the
    % the contrast sum for each contrast, assuming SPM.mat is there.
    SPMfile = fullfile(ResultsFolder,'SPM.mat');
    load(SPMfile);
    upu = SPM.xX.X(:,1);
    jpeak =[];
    for j = 2:length(upu)-1
        if ( upu(j) > upu(j-1) & upu(j) >= upu(j+1) & upu(j) > 0)  % peak in timeseries
            jpeak = [ jpeak upu(j) ];
        end
    end
    %jpeak = round(100*jpeak);       
    %jpeakmode = 0.01*mode(jpeak);   % 'mode' not in Matlab 6.5
    [ jpa, jpb ] = max(hist(jpeak,[0:0.01:max(jpeak)]));
    jpeakmode = 0.01*(jpb-1);
    for qqi = 1:size(Rimages,1)
        ConImage = Rimages(qqi,:);
        [ upx, upy, upz ] = fileparts(ConImage);
        lenCon = length(upy);
        %  Just in case the user is entering beta or spm images...
        if ('con' == upy(1:3) )   % scale the con images
            ConNum = str2num(upy(lenCon-2:lenCon));
            uu = SPM.xCon(ConNum).c;
            lenuu = find(uu > 0);
            contrast_value(qqi) = sum(uu(lenuu));  % sum of positive contrast coefficients
        elseif ('bet' == upy(1:3) )   %  beta image
            contrast_value(qqi) = 1;  % OK for beta
        end
    end
    if isempty(jpeakmode)
        disp('art_percentscale: No peaks found. Check SPM.mat file.')
        return
    else
        disp('Automatically estimated peak and contrast scaling.'); end
catch  % couldn't generate automatic scaling for some reason
    disp('art_percentscale: Could not find SPM.mat file, or other problem');
    return
end

% Find the ResMS and last beta image in Results folder with the Images
   %R = spm_vol(Rimages);
   %nimages = size(R,1);
   betaimages = spm_select('List',ResultsFolder,'^beta.*\.img$'); % for SPM5
   lastbeta = size(betaimages,1);
   Normimage = betaimages(lastbeta,:);
   words = [' Normalizing by ', Normimage]; disp(words);

% The last beta image in the Results folder is the SPM-estimated
% constant term. Scale all images by the average value of the last
% beta image with the head mask to get percentage.
% Find the normalization coefficient
    Normimagep = fullfile(ResultsFolder,Normimage);
    Pb = spm_vol(Normimagep);
    Xb = spm_read_vols(Pb);
    Maska = spm_vol(imgmask);
    Mask = spm_read_vols(Maska);
    Mask = round(Mask);    % sometimes computed masks have roundoff error
% Find the global mean within the mask
    bmean = sum(Xb(find(Mask==1))); 
    bvox = length(find(Mask==1));   % number of voxels in mask
    bmean = bmean/bvox;             % mean of beta in the mask
    clear Xb

ScaleFactors(1) = jpeakmode;
ScaleFactors(2) = contrast_value(1);   
ScaleFactors(3) = bmean;
ratio = (jpeakmode/contrast_value(1))*100/bmean;
words1 = ['Peak value    = ',num2str(jpeakmode,3)];
words2 = ['Contrast sum  = ',num2str(contrast_value(1))];
words3 = ['Mean value    = ',num2str(bmean)];
words4 = ['(peak/contrast_sum)*100/bmean  = ',num2str(ratio)];
disp(words1)
disp(words2)
disp(words3)
disp(words4)
end



