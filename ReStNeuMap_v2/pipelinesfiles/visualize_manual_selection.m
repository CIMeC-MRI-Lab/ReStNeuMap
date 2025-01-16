%%%% This script extracts the corresponding network components manually feeded
%%%% by the user
clearvars -except input1 input2 spmdir atldir rsnmDir processDir melodicDir templateDir

fprintf('ReStNeuMap is overlaying manually selected Independent Components. Please wait. \n');

% Split melodic_2_T1.nii to get each Independent Component and dir
% anatomical skull stripped image
spm_file_split([melodicDir, '/melodic_2_T1.nii']);
ICs = dir([melodicDir, '/melodic_2_T1_*.nii']);
T1file=dir('skullstrippedT1.nii');
disp(filename{1})

for i=1:numel(manual_ICs)
    manualIC = string(manual_ICs(i));
    assignin('base', 'manualIC', manualIC);
    disp(manualIC);
    if numel(num2str(manualIC))==1
        manualIC_new = strcat('0000',manualIC);
    elseif numel(num2str(manualIC))==2
        manualIC_new = strcat('000',manualIC);
    end
    
    
for j=1:length(ICs)
    IC_name = ICs(j).name;
    if contains(IC_name,num2str(manualIC_new))
        new_IC = fullfile(melodicDir,IC_name);
        cur_IC_image = spm_vol(new_IC);
        cur_IC_mat = [];
        cur_IC_mat = spm_read_vols(spm_vol(cur_IC_image));
        cur_IC_mat(cur_IC_mat <2.5) = 0;
        out = cur_IC_mat(:,:,:);
        input_file = convertStringsToChars([processDir, filesep, T1file.name]);
        temp = spm_vol(input_file);
        out_map = temp;
        out_folderPath = what(filename{1});
        out_folder = out_folderPath.path;
        output_file = convertStringsToChars(strcat(out_folder,filesep,filename{1},'_manual_',manualIC_new,'.nii'));
        out_map.fname = output_file;
        out_map.dt = [16 1];
        spm_write_vol(out_map,out);
    end
end

% Overlay the new Independent Component on anatomical image
template = strcat(templateDir,filesep,filename{1},'_2_T1.nii');
IC_on_T1 = convertStringsToChars(strcat(out_folder,filesep,filename{1},'_manual_',manualIC_new,'_on_T1.nii.gz'));
IC_on_T1_png = convertStringsToChars(strcat(out_folder,filesep,filename{1},'_manual_',manualIC_new,'_on_T1.png'));
system(['$FSLDIR/bin/overlay 1 0 ', input_file, ' -a ', template, ' 0.1 1 ', output_file, ' 0.1 10 ', IC_on_T1]);
system(['$FSLDIR/bin/slicer ', IC_on_T1, ' -t -n -u -l ./gt_rc_DG.lut -S 2 7000 ' IC_on_T1_png]);

% Add labels
cc_vals = importdata(strcat(out_folder,filesep,'r',filename{1},'.txt'));

if numel(num2str(manualIC))==1
    manualIC_new = erase(manualIC,manualIC_new);
elseif numel(num2str(manualIC))==2
    manualIC_new = erase(manualIC,manualIC_new);
end

manualIC_new = str2num(manualIC_new);
cc_col = cc_vals(:,1);
for k=1:length(cc_vals)
    if cc_col(k)==manualIC_new
        cc_val_row = cc_vals(cc_vals(k),:);
        cc_val = cc_val_row(3);
        
        image = imread(IC_on_T1_png);
        [y x z] = size(image);

        label = strcat(string(filename),': manually selected Independent Component n°',string(manualIC_new),'   r=',num2str(cc_val), '    (red=ICs, green=template, yellow=overlap)');
        figure();
        set(0, 'DefaultFigureVisible', 'off');
        imagesc(image); 
        hold on;
        text(1000, 100, label, 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'w');
        set(gca,'XTick',[], 'YTick', [])
        set(gca,'LooseInset',get(gca,'TightInset'));
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        saveas(gcf,IC_on_T1_png);
        hold off;
        close(figure);
    end
end

    
end

