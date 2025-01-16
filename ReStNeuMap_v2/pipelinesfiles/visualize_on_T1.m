%%%% This script automatically extracts the 7 previously defined networks
%%%% by determining the component with highest spatial overlap with
%%%% corresponding network template (https://findlab.stanford.edu/functional_ROIs.html)
processDir = evalin('base','processDir');
spmdir = evalin('base','spmdir');
rsnmDir = evalin('base','rsnmDir');
melodicDir = evalin('base','melodicDir');
templateDir = evalin('base','templateDir');
pipelinefilesDir = evalin('base','pipelinefilesDir');

clearvars -except input1 input2 spmdir atldir melodicDir processDir rsnmDir pipelinefilesDir templateDir 

% Set directories
cc_files = dir([processDir,'/r*.txt']);
spm_file_split([melodicDir, '/melodic_2_T1.nii']);
ICs = dir([melodicDir, '/melodic_2_T1_*.nii']);

for i = 1:length(cc_files)
    cur_ccfile = [cc_files(i).folder, filesep, cc_files(i).name];
    [filepath,filename] = fileparts(cur_ccfile);
    filename(1)=[];
    cc_file = importdata(cur_ccfile);
    cc_file = sortrows(cc_file,[3],'descend');
    cc_file(4:end,:) = [];
    cc_file(:,2) = [];
    T1file=dir('skullstrippedT1.nii');
    
    % Save .nii image of top 3 ICs thresholded at 2.5
    for j = 1:length(cc_file)
        IC = cc_file(j,1);
        cur_IC = ICs(IC,:);
        cur_IC_image = spm_vol([cur_IC.folder,filesep,cur_IC.name]);
        cur_IC_mat = [];
        cur_IC_mat = spm_read_vols(spm_vol(cur_IC_image));
        cur_IC_mat(cur_IC_mat <2.5) = 0;
        out = cur_IC_mat(:,:,:);
        input_file = convertStringsToChars(strcat(processDir, filesep, T1file.name));
        temp=spm_vol(input_file);
        out_map=temp;
        output_file = convertStringsToChars(strcat(filename,num2str(j),'.nii'));
        out_map.fname= output_file;
        out_map.dt=[16 1];
        spm_write_vol(out_map,out);
    end
end

% Delete single ICs .nii files from folder
delete([melodicDir, '/melodic_2_T1_*.nii']); 
       
        
      




