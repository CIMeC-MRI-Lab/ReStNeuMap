%% melodic call
function melodic()  

    processDir = evalin('base','processDir');
    spmdir = evalin('base','spmdir');
    rsnmDir = evalin('base','rsnmDir');

    clearvars -except input1 input2 spmdir atldir processDir rsnmDir

    % Variables inizialization
    filesT1=dir(fullfile(processDir, 's*-T1.nii'));
    system('gunzip lowpassfilteredAROMA.nii.gz');
    movefile('lowpassfilteredAROMA.nii', processDir);
    % Check coregistration anatomical-functional images
    cd processDir;
    fwaitb = waitbar(0,'ReStNeuMap is processing your data. Please wait...');
    waitbar(0.3,fwaitb);
    spm_check_registration([filesT1.name,',1'],['lowpassfilteredAROMA.nii,1']);
    saveas(gcf,[processDir,filesep,'checkreg_output.png']);
    % Run melodic
    melodicInput = fullfile(processDir, filesep, 'lowpassfilteredAROMA.nii');
    fprintf("ReStNeuMap is now running melodic and saving outputs in:")
    fprintf(pwd);
    system(['melodic -i ', melodicInput, ' --report']);
    waitbar(0.7,fwaitb);
    melodicPath = what('./lowpassfilteredAROMA.ica');
    melodicDir = melodicPath.path;
    assignin('base','melodicDir',melodicDir);
    waitbar(0.9,fwaitb);
    % Check that melodic has converged
    myFile = dir(fullfile(processDir, filesep, 'lowpassfilteredAROMA.ica/melodic_IC.nii.gz'));
    fullFileName = fullfile(myFile.folder,filesep,myFile.name);
    isfilevalid(fullFileName);

    close(fwaitb)
end
% Check file validity function
function [fileval]=isfilevalid(fullFileName)
if exist(fullFileName, 'file') > 0
    fprintf('\n Melodic run in free modality completed successfully \n')
else
    error ('\n Melodic run in free modality did not converge \n')
end
end

