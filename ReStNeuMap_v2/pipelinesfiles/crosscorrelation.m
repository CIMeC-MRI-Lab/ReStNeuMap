%%%% This script runs cross correlation on melodic output
function crosscorrelation()

    processDir = evalin('base','processDir');
    atldir = evalin('base','atldir');
    spmdir = evalin('base','spmdir');
    rsnmDir = evalin('base','rsnmDir');
    melodicDir = evalin('base','melodicDir');

    clearvars -except input1 input2 spmdir atldir melodicDir processDir rsnmDir

    fprintf('\n Now running cross correlation analysis. \n');

    pipelinesPath = what('pipelinefiles');
    pipelinefilesDir = pipelinesPath.path;
    assignin('base','pipelinefilesDir',pipelinefilesDir);
    mkdir(fullfile(pwd,'NetworkTemplates'));
    templatePath = what('NetworkTemplates');
    templateDir = templatePath.path;
    assignin('base','templateDir',templateDir);
    copyfile(atldir, templateDir);

    % T1w skull stripped image
    anatFile = dir(fullfile(processDir, filesep, 'skullstrippedT1.nii'));
    anatFile = fullfile(processDir, filesep, anatFile.name);
    % Functional images
    IC_mean = fullfile(melodicDir, filesep, 'mean.nii');
    melodicIC = strcat(melodicDir, filesep, 'melodic_IC.nii.gz');
    melodicIC_thr = strcat(melodicDir, filesep, 'melodic_IC_thr25.nii.gz');

    fwaitb = waitbar(0,'ReStNeuMap is processing your data. Please wait...');
    waitbar(0.3,fwaitb);

    % Threshold melodic_IC.nii at 2.5 z-score
    system(['$FSLDIR/bin/fslmaths ', melodicIC, ' -thr 2.5 ', melodicIC_thr]);
    melodicIC_thr=fullfile(melodicDir, filesep, 'melodic_IC_thr25.nii');
    waitbar(0.4,fwaitb);
    % Coregister avg152T1 to T1w using fslflirt
    system(['$FSLDIR/bin/flirt -in ' fullfile(pipelinefilesDir, 'avg152T1_brain.nii.gz') ' -ref ' anatFile ' -omat ' fullfile(melodicDir, 'avg152T1_2_T1.mat') ' -out ' fullfile(melodicDir, 'avg152T1_2_T1.nii.gz') ' -cost normcorr -searchcost normcorr -interp spline']);

    % Coregister melodic_mean to T1w using fslflirt
    system(['$FSLDIR/bin/flirt -in ' IC_mean ' -ref ' anatFile ' -omat ' fullfile(melodicDir, 'mean_2_T1.mat') ' -out ' fullfile(melodicDir,'mean_2_T1.nii') ' -cost normmi -searchcost normmi -interp spline' ]);

    % Apply the transformation to bring melodicIC to T1w
    system(['$FSLDIR/bin/flirt -in ' melodicIC_thr ' -ref ' anatFile ' -applyxfm -init ' fullfile(melodicDir, 'mean_2_T1.mat') ' ' ' -interp spline -out ' fullfile(melodicDir, 'melodic_2_T1.nii') ]);
    gunzip(fullfile(melodicDir, 'melodic_2_T1.nii.gz'));

    system(['$FSLDIR/bin/convert_xfm -omat ' fullfile(melodicDir, 'mean_2_T1_inv.mat') ' -inverse ' fullfile(melodicDir, 'mean_2_T1.mat')]);
    system(['$FSLDIR/bin/convert_xfm -omat ' fullfile(melodicDir, 'avg152T1_2_mean_conc.mat') ' -concat ' fullfile(melodicDir, 'mean_2_T1_inv.mat') ' ' fullfile(melodicDir, 'avg152T1_2_T1.mat')]);

    % Coregister avg152T1 to melodic_mean concatenating the transformations
    system(['$FSLDIR/bin/flirt -in ' fullfile(pipelinefilesDir, 'avg152T1_brain.nii.gz') ' -ref ' IC_mean ' -applyxfm -init ' fullfile(melodicDir, 'avg152T1_2_mean_conc.mat') ' -out ' fullfile(melodicDir, 'avg152T1_2_mean_conc.nii.gz')]);
    waitbar(0.5,fwaitb);
    % Load templates
    Prim_Visual=strcat(templateDir, filesep, 'Prim_Visual.nii');
    Sensorimotor=strcat(templateDir, filesep, 'Sensorimotor.nii');
    Language=strcat(templateDir, filesep, 'Language.nii');
    Speech_Arrest=strcat(templateDir, filesep, 'Speech_Arrest.nii');
    FPN=strcat(templateDir, filesep, 'FPN.nii');
    DMN=strcat(templateDir, filesep, 'DMN.nii');
    Visuospatial=strcat(templateDir, filesep, 'Visuospatial.nii');

    templateFiles=dir(fullfile(templateDir,filesep,'*.nii'));

    % Apply the transformation to bring network templates to T1w
    for ii = 1:length(templateFiles)
        baseTempFiles = templateFiles(ii).name;
        fullTempFiles = fullfile(templateDir, filesep, baseTempFiles);
        fprintf(1, 'Now reading %s\n', fullTempFiles);
        CoregT1fullTempFiles = strcat(erase(baseTempFiles,'.nii'), '_2_T1');
        system(['$FSLDIR/bin/flirt -in ', fullTempFiles, ' -ref ', anatFile, ' -applyxfm -init ' fullfile(melodicDir, 'avg152T1_2_T1.mat') ' -interp nearestneighbour -out ' strcat(pwd, filesep, CoregT1fullTempFiles)]);
    end
    waitbar(0.7,fwaitb);
    % Bring network templates to same melodic_IC space
    for jj = 1:length(templateFiles)
        baseTempFiles = templateFiles(jj).name;
        fullTempFiles = fullfile(templateDir, filesep, baseTempFiles);
        fprintf(1, 'Now reading %s\n', fullTempFiles);
        RfullTempFiles = strcat('r', baseTempFiles);
        system(['$FSLDIR/bin/flirt -in ', fullTempFiles, ' -ref ', IC_mean, ' -applyxfm -init ' fullfile(melodicDir, 'avg152T1_2_mean_conc.mat') ' -interp nearestneighbour -out ' strcat(pwd, filesep, RfullTempFiles)]);
    end

    rPrim_Visual=strcat(pwd, filesep, 'rprim_Visual.nii.gz');
    rSensorimotor=strcat(pwd, filesep, 'rSensorimotor.nii.gz');
    rLanguage=strcat(pwd, filesep, 'rLanguage.nii.gz');
    rSpeech_Arrest=strcat(pwd, filesep, 'rSpeech_Arrest.nii.gz');
    rFPN=strcat(pwd, filesep, 'rFPN.nii.gz');
    rDMN=strcat(pwd, filesep, 'rDMN.nii.gz');
    rVisuospatial=strcat(pwd, filesep, 'rVisuospatial.nii.gz');
    waitbar(0.8,fwaitb);
    
    % Compute cross correlation using fslcc
    rtemplateFiles = dir(fullfile(pwd,filesep,'r*.nii.gz'));
    for k = 1:length(rtemplateFiles)
        templateCoreg = strcat(pwd, filesep, rtemplateFiles(k).name);
        [folder, templateName, extension] = fileparts(templateCoreg);
        %ccOutput = convertStringsToChars(strcat(extractBefore(templateName,'.nii'),'.txt'));
        ccOutput = strcat(extractBefore(templateName,'.nii'),'.txt');
        system(['$FSLDIR/bin/fslcc --nodemean --noabs -t -1 -m ', templateCoreg, ' ', melodicIC_thr, ' ', templateCoreg, ' >', ccOutput]);
    end

    myDir = pwd;
    myFiles = dir(fullfile(myDir,'*.txt')); %gets all .txt files in struct
    myFiles=myFiles(~ismember({myFiles.name},{'path.txt','path2fslstats.txt'}));
    for kk = 1:length(myFiles)
      baseFileName = myFiles(kk).name;
      fullFileName = fullfile(myDir, baseFileName);
      isfilevalid(fullFileName);
    end

    delete(fullfile(pwd, filesep, 'r*.nii'));
    waitbar(0.95,fwaitb);
end

% Check file validity function
function [fileval]=isfilevalid(fullFileName)
    file = dir(fullFileName);
    if file.bytes == 0
        error ('Empty Cross Correlation files')
    end
end
 