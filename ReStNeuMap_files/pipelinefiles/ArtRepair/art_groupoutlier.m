function art_groupoutlier(ConImageNames, GroupMaskName,Groupscale, OutputDir)
%  FUNCTION art_groupoutlier
%  >> art_groupoutlier  to run by GUI
%     
%  Program runs the global quality metrics for a contrast image from all
%  subjects. Creates a summary over all subjects of GQ scores per
%  per subject, visually displays scores of all subjects, and
%  recommends good subgroups for group analyses.
%
%  User MUST specify (peak/contrast_sum) to make the scaling correct!
%  Find this value by running >>art_percentscale on a single subject.
%
%  GUI INPUTS
%    Select a set of single subject con images. Use same syntax as making an SPM group study. 
%    Enter peak/contrast sum. Get this by running art_precentscale on one subject.
%      It is usually the same for all regressors, for all subjects.
%  OUTPUT is written to current working directory, and displayed.
%    This text file and jpg image files summarize all subjects together.
%
%  BATCH INPUT  (as called from art_groupcheck)
%  art_groupoutlier(ConImageNames, GroupMaskName,Groupscale, OutputDir)
%    ConImageNames is cell array of contrast images names
%    GroupMaskName is full path name of one mask image for all subjects.
%       Usually this is the mask image of the group result.
%       If GroupMaskName = 0, each subject uses its own mask.
%    Groupscale is 3 element vector with peak, contrastsum, and bmean.
%    OutputDir specifies where output images and files will be written.
%
%  BUG: Sometimes the figure legend will cover a data point.
%  Compatible with SPM5 and SPM2.
%  paul mazaika - added SPM8, May 2009
%  supports SPM12, Dec2014


% Set some reference guides for assumed single subject values
% Values are in percent signal change
% We'll learn more about these values in the future.
% REFERENCE values are used to draw the reference box
REFW  = 0.07;    % for block GoNoGo design
REFM  = 0.07;    % for exec control contrast experiment
REFSTD = 0.25;   % for 1% noise, difference of 50 sample estimates.
% Cluster center of data (ROBUSTM, ROBUSTW) is estimated in the code.

% Set high intersubject variability, used only in Figures.
UNIFHIGH = 0.2;  %  was 0.17 

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin == 0
     %clear all;
     OutputDir = pwd;   % Get user's current working directory
     if strcmp(spm_ver,'spm5')
         Rimages = spm_select(Inf,'image','Select single subject con images' );
     else  %  spm2
         Rimages  = spm_get(Inf,'.img','Select single subject con images');
     end
     %  pk_con value is the peak/contrast sum for the regressor of interest.
     pkcon_value = spm_input('Enter peak/(contrast_sum)',1,'e');%,1.13,1); 
     [temp1, ConImageName,cext ] = fileparts(Rimages(1,:));
     [temp, ResultsFolder ] = fileparts(temp1);
     %MaskPath = ResultsFolder;
     UseGroupMask = 0;
     for i = 1:size(Rimages,1)
         temp = fileparts(Rimages(i,:));
         sjResults{i} = temp;
         temp2 = fileparts(temp);
         sjDirX{i}=temp2;
     end
     %ConImageName = [ ConImageName  cext];
     ScaleFactor(1) = pkcon_value;
     ScaleFactor(2) = 1;  % art_summary only needs ratio to be right.
     % ScaleFactor(3) =bmean is found for each image
elseif nargin > 0
    % inputs for groupoutlier5
       %Rimages = char(sjDirX);
       %Maskpath = ResultsFolder;
       % other variables are passed as arguments
    Rimages = char(ConImageNames);  % ConImageNames is a cell array
    if GroupMaskName == 0
        UseGroupMask = 0;   % each single subj. contrast uses its own mask
    else
        UseGroupMask = 1;   % group mask is applied to each contrast
        disp('Using same group mask for all contrasts.')
    end
    [temp1, ConImageName,cext ] = fileparts(char(ConImageNames{1}));
    [temp, ResultsFolder ] = fileparts(temp1);
    %MaskPath = ResultsFolder;
    for i = 1:length(ConImageNames)
         temp = fileparts(char(ConImageNames{i}));
         sjResults{i} = temp;
         temp2 = fileparts(temp);
         sjDirX{i}=temp2;
    end
    %ConImageName = [ ConImageName  cext];
    pkcon_value = Groupscale(1);
     ScaleFactor(1) = Groupscale(1);
     ScaleFactor(2) = Groupscale(2);     % only use is send to art_summary
     ScaleFactor(3) = Groupscale(3);
    % other variables are passed as arguments
end


X = zeros(length(sjDirX), 5);
NumSubj = length(sjDirX);
% Global Quality of Estimates
for i = 1:length(sjDirX)
    %Resultspath = fullfile(sjDirX{i},ResultsFolder);
    if UseGroupMask == 0
        %Maskpath    = fullfile(sjDirX{i},ResultsFolder);
        Maskpath = char(sjResults{i});
        if strcmp(spm_ver,'spm5')
            MaskImage = spm_select('FPList',Maskpath,'^mask.*\.img$');
        else   % spm2 logic
            MaskImage   = fullfile(Maskpath,'mask.img');
        end
    elseif UseGroupMask == 1
        MaskImage = GroupMaskName;
    end
    if nargin == 0
        ConImage    = Rimages(i,:);% fullfile(Resultspath, ConImageName);
    elseif nargin > 0
        ConImage = char(ConImageNames{i});
    end
    if nargin == 0 & i == 1  % Use first one to scale all (approximation).
        ScaleFactorX = art_percentscale(ConImage,MaskImage);
        ScaleFactor(3) = ScaleFactorX(3);
    end
    OutputPath  = sjDirX{i};
    % Last two arguments write Figure 71 with title 'GroupSelect'.
    [g,r, s] = art_summary(ConImage,MaskImage,OutputPath,'GroupSelect',71,ScaleFactor);
    X(i,2) = g;   % width (stdev)
    X(i,3) = r;   % mean
    X(i,4) = s;   % Resout, Mean of sqrt(ResMS)number
    %             for art_redo/art_summary, it is mean of Res image.
    X(i,1) = i;   % an index number
end
% Get the NAME of the subject
for i = 1:NumSubj
    [ a, b, c ] = fileparts(sjDirX{i});
    [ a1, b1, c1 ] = fileparts(a);
    [ a2, b2, c2 ] = fileparts(a1);
    Y{i} = [ b2 '/' b1 '/' b ];
end

% Use median as a robust measure of GQmean.
% The Matlab Statistics toolbox includes the trimmean function.
groupmean = mean(X(:,3));
medianofgroup = median(X(:,3));
%trim50 = trimmean(X(:,3),50);
ROBUSTM = medianofgroup;

% Find a measure of the horizontal location of the main cluster
allwidths = X(:,2);
allsort = sort(allwidths); 
ROBUSTW = allsort(round(length(allsort)/4));

% Estimate the standard deviation of confound score. Add variances
% for distance of mean from zero, and the boost in variance relative
% to the variance ROBUSTW for an estimated single subject.
%. ASSUMES SINGLE SUBJECT has true mean of zero.
for i = 1:NumSubj
    % Currently, not used. Assumes that zero is correct.
    X(i,5) = sqrt(X(i,3)^2 + max(0,(X(i,2)^2 - ROBUSTW^2)));
end
% Estimate the confound score, using an assumed mean from robust estimate.
for i = 1:NumSubj
    %X(i,6) = sqrt((X(i,3)-ROBUSTM)^2 + max(0,(X(i,2))^2 - ROBUSTW^2));
    % total variance includes intersubject, est, and confound
    X(i,6) = sqrt((X(i,3)-ROBUSTM)^2 + max(0,(X(i,2))^2 ));
end

% Print a TABLE of subject results
disp('Output images and text file will be written to this folder:')
disp(OutputDir)
disp(' ')
pkconwords = ['User entered value for peak/contrast_sum: ',num2str(pkcon_value)];
disp(pkconwords)
disp(' ')
disp('  INDIVIDUAL SUBJECT PROPERTIES (ordered as input)')
disp('  Index   GQwidth    GQmean     RESavg     GQrms')
%disp(X);
for i = 1:NumSubj
    fprintf(1,'\n%5d   %8.4f   %8.4f   %8.4f   %8.4f', round(X(i,1)),X(i,2),...
        X(i,3),X(i,4),X(i,6));
end
disp(' ')
subj.GQdata = X;
subj.name = Y;
%save subjectsummarystruct subj

% Find and display two robust measures of bias.
disp(' ')
disp(' ESTIMATES OF GQmean averaged over the Group')
disp(' Mean, Median and 50% trimmed mean of subject GQmeans ')
disp(groupmean)
disp(medianofgroup)
disp(trim50)
disp('Robust mean = average of median and trimmed mean')
disp(ROBUSTM)


% Define ideal point and GQmean = 0 line.
cnormm = [ -REFM REFM ];
cnormw = [ REFW  REFW  ];
didealstdev = [  REFSTD  REFW REFW  REFSTD ];
didealmean  = [ -REFM -REFM REFM REFM ];
% Draw GQ figure for subject
figure(72);
ahcw = X(:,2);
ahcm = X(:,3);
robw = [ 0  max(ahcw+0.1)];
robm = [ ROBUSTM ROBUSTM ];
%plot(ahcm,ahcw,'kd',...
%    robm,robw,'k:',cnormm,cnormw,'r--',didealmean,didealstdev,'r-.');
h11=plot(ahcm,ahcw,'kd');
hold on;
plot(robm,robw,'k:',cnormm,cnormw,'r--',didealmean,didealstdev,'r-.');
set(h11,'LineStyle','none');
set(h11,'Marker','o','MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerSize',8.0);
legend('Subjects','Robust mean','Ref. subject variability','Ref. lack of power','Location','Best','boxoff');
%plot(ahcm,ahcw,'rd',cnormm,cnormw,'gs',csinglem,csinglew,'bs');
%legend('Subjects','"Ideal"','No confounds','Location','Best');
ylim([ 0 max(ahcw+0.1)]);
%axes_lim = get(gca, 'YLim');
%axes_height = [ axes_lim(1) axes_lim(2)];
axis equal; 
%line([0 0], [ROBUSTM max(ahcw+0.1)], 'Color', 'k','LineStyle',':');
title('Global Quality scatterplot, by subject')
xlabel('Global Mean: Mean of histogram (percent signal change)');
ylabel('Global Quality: Stdev of histogram (percent signal change)');
hold off;

%  Make a Pretty Figure
fh = figure(82);
ylim([ 0 max(ahcw+0.1)]);
h1 = plot(ahcm,ahcw);
hold on;
h2 = plot(robm,robw);
h4 = plot(cnormm,cnormw);
h3 = plot(didealmean,didealstdev);
% set background white
set(fh,'color','white');
set(h1,'LineStyle','none');
set(h1,'Marker','o','MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerSize',8.0);
set(h3,'LineStyle','-.','LineWidth',1.0,'Color','Red');
set(h3,'Marker','none');
set(h2,'LineStyle',':','Color','Black');
set(h2,'Marker','none');
set(h4,'LineStyle','--','LineWidth',1.0,'Color','Red');
set(h4,'Marker','none');
% remove plot box
set(gca,'Box','off');
axis equal;
h5=legend('Subjects','Robust mean','Ref. subject variability','Ref. lack of power','Location','Best');
set(h5,'Location','Best','FontSize',12);
%set(gca,'TickDir','out','XTick',[0:10],'YTick',[1:5]);
set(gca,'TickDir','out');
xlabel('Global Mean (percent signal change)','FontSize',14);
ylabel('Global Standard Deviation of Histogram (pct sig ch)','FontSize',14,'Rotation',90);
title('Global Quality scatterplot, by subject','FontSize',16)
% save for LateX. Mac converts postscript to pdf
% This looks much cleaner than .jpg.
%saveas(fh,'FruitflyPopulation','epsc');
% save for Word
%saveas(fh,'FruitflyPopulationWord','jpg');
hold off


cd(OutputDir);   % prints images to this folder
figname = ['SubjectGQScatterplot.jpg'];
saveas(gcf,figname);


% Try two sorts: One by variance alone.
% The second also tries to keep the subgroup bias zero.
% Both sorts use ROBUSTM as the reference mean value.
for  sortmethod = 1:2
    

if sortmethod == 1 
    % SORT the subjects by GQ magnitude, Assuming ROBUST mean.
    sqvar = X(:,6);
    [svar, isort ] = sort(sqvar);
elseif sortmethod == 2
    % Order subjects by mean square error, Assuming ZERO mean.
    %   and resort the means along with the variances
    sqvar = X(:,6);  % 6 is ROBUST MEAN, 5 IS ZERO mean
    isort = dualsort(sqvar,X(:,3));
    svar = sqvar(isort);
end
cc = X(isort,3);   % keep track of biases on sorted subjects
NumSubj = size(X,1);
xax = [ 1: NumSubj ];
% Make a low and high uniform variable, in stdev
unif2 = svar(1)*ones(NumSubj,1);  % Starts with GQ scores
unifhi = UNIFHIGH*ones(NumSubj,1);
combo2 = sqrt(svar.*svar+unif2.*unif2);
combohi = sqrt(svar.*svar+unifhi.*unifhi);
limhi = ROBUSTM + REFW*ones(NumSubj,1);
limlo = ROBUSTM - REFW*ones(NumSubj,1);
% Next consider the effects of bias per subject.
% The observed bias from group to group is 0.012 or so.
zeroline = zeros(NumSubj+1,1);
zax = [0:NumSubj];
if sortmethod == 1; figure(73); end
if sortmethod == 2; figure(75); end
clf;
h22 = plot(xax,svar,'ro-');
hold on;
plot( xax,combohi,'k-');
h23 = plot(xax,cc,'bo-');
plot( ...
       xax,limlo,'b:',xax,limhi,'b:',zax,zeroline,'k-');
set(h22,'LineStyle','-','Color','Red');
set(h22,'Marker','o','MarkerFaceColor',[0.8 0 0],'MarkerEdgeColor',[0.8 0 0],'MarkerSize',6.0);
set(h23,'LineStyle','-','Color','Blue');
set(h23,'Marker','o','MarkerFaceColor',[0 0 0.8],'MarkerEdgeColor',[0 0 0.8],'MarkerSize',6.0);
title('Each Subjects Global Quality scores, sorted by total variance')
if sortmethod == 2
    title('Each Subjects Global Quality scores, sorted keeping bias near zero')
end
xlabel('Subject ID sorted')
legend('GQ Total Stdev','Plus high intersubject','GQMean',...
        '2-sigma limit on mean','Location','NorthWest');
figname = ['SubjectsSortedbyGQ.jpg'];
saveas(gcf,figname);

% Find variance of mean, for each subgroup size, N
sumvar(1) = svar(1)^2;
sumbar(1) = cc(1);
sumunif(1) = unif2(1)^2;
sumhi(1) = unifhi(1)^2;
sumchi(1) = sumvar(1)+sumhi(1);
for i = 2:NumSubj
    sumvar(i) = sumvar(i-1) + svar(i)^2;
    sumbar(i) = sumbar(i-1) + cc(i);
    sumunif(i)= sumunif(i-1) + unif2(i)^2;
    sumhi(i)  = sumhi(i-1) + unifhi(i)^2;
    sumchi(i) = sumvar(i) + sumhi(i);
end
for i = 1:NumSubj
    stdmean(i) = sqrt(sumvar(i)/(i*i));
    subgpmean(i) = sumbar(i)/i;
    stdunif2mean(i) = sqrt(sumunif(i)/(i*i));
    stdchi(i) = sqrt(sumchi(i)/(i*i));
end

% Find subgroups, over half the group in size, 
% with means within 2-sigma of target value ROBUSTM
if sortmethod == 1  | 2    % target value is robust mean
    subgpmean1 = subgpmean - ROBUSTM;
    bias2mean = sqrt(subgpmean1.*subgpmean1);
end
groupchoice(1:NumSubj) = 0;
for i = round(NumSubj/2):NumSubj
    if bias2mean(i) < (REFW)/sqrt(i);
        groupchoice(i) = 1;
    end
end
gc = find(groupchoice == 1);
lengc = zeros(length(gc),1);

% Draw limits of reasonable values for group mean (within 2-sigma)
biashi(1,2:NumSubj) = ROBUSTM + REFW./sqrt(xax(2:NumSubj));
biaslo(1,2:NumSubj) = ROBUSTM - REFW./sqrt(xax(2:NumSubj));

if sortmethod == 1; figure(74); end
if sortmethod == 2; figure(76); end
clf;
plot(xax(2:NumSubj),stdmean(2:NumSubj),'r',xax(2:NumSubj),stdchi(2:NumSubj),'k-',...
    xax(2:NumSubj),stdunif2mean(2:NumSubj),'g--',...
    xax,subgpmean,'b-',xax(2:NumSubj),biashi(2:NumSubj),'b:',xax(2:NumSubj),biaslo(2:NumSubj),'b:',zax,zeroline,'k-');
title('Predicted Subgroup Performance: Global StdErr ordered by variance only');
if sortmethod == 2
    title('Predicted Subgroup Performance: Global StdErr while forcing zero bias')
end
xlabel('Number of subjects in subgroup');
ylabel('Expected standard error of the mean');
legend('GQ Total','Plus high intersubject',...
    'Uniform Only','SubGroup Mean','2-sigma limits on mean');
% Add good subgroup choices and a best choice based on min stdev
[ dummy,index ] = min(stdmean);
gbest = index;
hold on;
if sortmethod == 1 | 2
    for i = 1:length(gc)
        line((gc(i)*ones(1, 2)), [ subgpmean(gc(i)) stdmean(gc(i)) ], ...
            'Color','k','Marker','o','LineStyle',':');
    end
    line((gbest*ones(1, 2)), [ subgpmean(gbest) stdmean(gbest) ], ...
            'Color','k','Marker','o','LineStyle','-');
end
hold off;
figname = ['PredictedGroupAccuracy.jpg'];
saveas(gcf,figname);

% Make a TABLE of sorted subjects, number in group, expected performance
for i = 1:NumSubj
    gpsel.id(i)     = isort(i);
    gpsel.name(i)   = Y(isort(i));
    gpsel.GQ1(i)    = stdmean(i);
    gpsel.GQ3(i)    = stdchi(i);
    gpsel.GQ2(i)    = subgpmean(i);
end
gpsel.select(1:NumSubj) = 0;
for i = 1:length(gc)
    gpsel.select(gc(i)) = gc(i);
end
gpsel.select(gbest) = gbest;
gptable = [ gpsel.select', gpsel.GQ1' gpsel.GQ3'...
            gpsel.GQ2'  gpsel.id' ];

disp(' ')
disp('    PREDICTED SUBGROUP PERFORMANCE')
if sortmethod == 1
    disp(' SUBGROUP SELECTIONS BASED ON MINIMUM VARIANCE ONLY')
elseif sortmethod == 2
    disp(' RECOMMENDED: SUBGROUP SELECTIONS WITH MEAN NEAR ROBUST MEAN')
end
disp(' Group    Group      Group      Group       Individual')
disp('  Size    StdErr     StdEHi      Mean     Index      Subject')
for i = 1:NumSubj
    fprintf(1,'\n%5d   %8.4f   %8.4f   %8.4f   %5d   %s', gptable(i,1),gptable(i,2),...
        gptable(i,3),gptable(i,4),gptable(i,5),gpsel.name{i});
end
disp(' ')


%  DETECT, COUNT, AND LOG THE ARTIFACTS
if sortmethod == 1
    %disp('Writing results file to current directory')
    tstamp = clock;
    filen = ['OutlierSubjects',date,'Time',num2str(tstamp(4)),num2str(tstamp(5)),'.txt'];
    logname = fullfile(OutputDir,filen);
    logID = fopen(logname,'wt');
    fprintf(logID,'Outlier Subjects Analysis from art_groupoutlier program (feb09):  \n  %s\n');

    % Print a LIST of con images for this analysis
    fprintf(logID,'\n  LIST OF INPUTS (Single Subject Images)');   
    for i = 1:size(Rimages,1)
        fprintf(logID,'\n%3d  %s',i, Rimages(i,:)); 
    end
    
    fprintf(logID,'\n %s',pkconwords)

    % Print a TABLE of subject results
    fprintf(logID,'\n\n  INDIVIDUAL SUBJECT PROPERTIES (ordered as input)');
    fprintf(logID,'\n  Index   GQwidth    GQmean     RESavg     GQrms');
    for i = 1:NumSubj
        fprintf(logID,'\n%5d   %8.4f   %8.4f   %8.4f  %8.4f ', round(X(i,1)),X(i,2),...
            X(i,3),X(i,4),X(i,6));
    end
    
    % Print the robust estimates of the global mean
    fprintf(logID,'\n\n  ROBUST ESTIMATES of the GLOBAL MEAN ');
    fprintf(logID,'\n  Mean   Median  50% Trimmean    RobustMean');
    fprintf(logID,'\n %8.4f   %8.4f   %8.4f   %12.4f', ...
            groupmean, medianofgroup, trim50, ROBUSTM);
    fprintf(logID,'\n Robust mean is average of median and 50 pct trimmemd mean');
end

% Print a table of recommended subgroups

fprintf(logID,'\n\n    PREDICTED SUBGROUP PERFORMANCE');
if sortmethod == 1
    fprintf(logID,'\n Subgroups chosen with minimum variance only    ');
elseif sortmethod == 2
    fprintf(logID,'\n Subgroups chosen to prefer group mean near robust mean    ');
end
fprintf(logID,'\n    Groups with small group means show the group size.');
fprintf(logID,'\n Group    Group      Group      Group       Individual');
fprintf(logID,'\n  Size    StdErr     StdEHi      Mean     Index      Subject') ;   
for i = 1:NumSubj
    fprintf(logID,'\n%5d   %8.4f   %8.4f   %8.4f   %5d   %s', gptable(i,1),gptable(i,2),...
        gptable(i,3),gptable(i,4),gptable(i,5),gpsel.name{i});
end

if sortmethod == 2
    fclose(logID); 
end

end  %  sortmethod loop


%------------------------------------------------------------------
function G = dualsort(A,B)
%  Balances choosing smaller variances with maintaining zero mean
%  A is vector of variances (always positive)
%  B is vector of means.
%  G is vector of index numbers for the dualsort order

%  Set a balancing parameter
%  BAL = 1 means Ordinary sort on variance alone
%  BAL = 1000  means just zero bias is considered
   BAL = 1.4;
  
n = length(A);
C = zeros(1,n);
meansum = 0;
for i = 1:n
    y = find(C==0);
    ymin = min(A(y));
    ylim = ymin*BAL + 0.00001;
    z = zeros(1,n);
    for j = 1:length(y)
        z(y(j)) = abs(meansum + B(y(j)));
    end
    meantemp = 1000;
    for j = 1:length(y)
        if A(y(j)) < ylim & z(y(j)) < meantemp
            jtemp = y(j);
            meantemp = z(y(j));
        end
    end
    C(jtemp) = i;
    meansum = meansum + B(jtemp);
end
[ gt, G ] = sort(C);


 





