%%%%%% This script calls all necessary network visualization scripts
function networkvisualization()
    processDir = evalin('base','processDir');
    spmdir = evalin('base','spmdir');
    rsnmDir = evalin('base','rsnmDir');
    melodicDir = evalin('base','melodicDir');
    templateDir = evalin('base','templateDir');
    pipelinefilesDir = evalin('base','pipelinefilesDir');
    
    clearvars -except input1 input2 spmdir atldir melodicDir processDir rsnmDir pipelinefilesDir templateDir

    visualize_on_T1;
    % Copy LUT files from pipelinefiles
    copyfile(fullfile(pipelinefilesDir, filesep, 'gt_rc_DG.lut'));
    copyfile(fullfile(pipelinefilesDir, filesep, 'gt_rc_DG_template.lut'));
    fid=fopen('path.txt','wt');
    fprintf(fid,[fileparts(pipelinefilesDir),'/pipelinefiles/overlay_slicer.sh']);
    fclose(fid);
    GRYstatus=system('pathvar=$(cat path.txt); cp $pathvar .; bash overlay_slicer.sh');

    % Run last two scripts necessary for output images with labels
    label2appendSP;
end