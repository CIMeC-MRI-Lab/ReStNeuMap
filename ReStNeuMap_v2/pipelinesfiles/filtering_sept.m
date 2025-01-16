%%%% This script computes WM and CSF mask average signal from head motion
%%%% corrected volumes

InputIm = spm_read_vols(spm_vol('c4D.nii'));
WMmask = dir('rc2*.nii');
WMmask = spm_read_vols(spm_vol(WMmask.name));
CSFmask = dir('rc3*.nii');
CSFmask = spm_read_vols(spm_vol(CSFmask.name));

% Select 3D head motion corrected volumes
procfile = dir('ua*_00*.nii');

avg_WM = zeros(size(InputIm,4),1);
avg_CSF = zeros(size(InputIm,4),1);
for t = 1:size(InputIm,4)
    funcvol = spm_read_vols(spm_vol(procfile(t+4,1).name));
    avg_WM(t,1) = mean(funcvol(WMmask>0.9));
    avg_CSF(t,1) = mean(funcvol(CSFmask>0.9));
end

% Median filtering, detrending of head motion parameters
mov = dir ('rp*.txt');
mov = Read_1D (mov.name,1);
mov = mov(5:size(mov,1),:);
movmed = medfilt1(mov,2);

t = (1:length(movmed))';
opol = 4;
movmed = detrend(movmed);

for i = 1:size(movmed,2)
    [p,s,mu] = polyfit(t,movmed(:,i),opol);
    f_y = polyval(p,t,[],mu);
    movmed_det(:,i) = movmed(:,i) - f_y;
end

% Median filtering, detrending of WM average time series
avg_WM = detrend(avg_WM);
WM_med = medfilt1(avg_WM,2);
[p,s,mu] = polyfit(t,WM_med,opol);
f_y = polyval(p,t,[],mu);
WM_med_det = WM_med - f_y;
[mdl,mdlint,mdl_WM_resid] = regress(WM_med_det, movmed_det(:,i));


% Median filtering, detrending of CSF average time series
avg_CSF = detrend(avg_CSF);
CSF_med = medfilt1(avg_CSF,2);
[p,s,mu] = polyfit(t,CSF_med,opol);
f_y = polyval(p,t,[],mu);
CSF_med_det = CSF_med - f_y;
[mdl,mdlint,mdl_CSF_resid] = regress(CSF_med_det ,movmed_det(:,i));

InputDetFilt_reg = zeros(size(InputIm,1),size(InputIm,2),size(InputIm,3),size(InputIm,4));
TimeSer = zeros(size(InputIm,4),1);
for i = 1:size(InputIm,1)
    for j = 1:size(InputIm,2)
        for k = 1:size(InputIm,3)
            for l = 1:size(TimeSer,1)
                TimeSer(l,1)=InputIm(i,j,k,l);
            end
            TimeSer = detrend(TimeSer);
            TimeSermed = medfilt1(TimeSer,2);
            [p,~,mu] = polyfit(t,TimeSermed,opol);
            f_y = polyval(p,t,[],mu);
            TimeSerDet = TimeSermed - f_y;
            nuisances = [movmed_det,mdl_WM_resid,mdl_CSF_resid];
            [mdl,mdlint,TimeSerDetFilt_resid] = regress(TimeSerDet,nuisances);
            InputDetFilt_reg(i,j,k,:) = TimeSerDetFilt_resid+mean2(InputIm(i,j,k,:));
        end
    end
end

% Write 3D file from previous time series
Input = dir('ua*_00005.nii');
Input = spm_vol(Input.name);

for t = 1:size(InputIm,4)
    funcfile = sprintf('InputDetFiltReg_00%d.nii',t);
    InputOut = Input;
    InputOut.fname = funcfile;
    spm_write_vol(InputOut,InputDetFilt_reg(:,:,:,t));
end

% Create brain mask using the T1 segmentation results
segmfile = dir('rc*.nii');
frame = spm_vol(segmfile(1,1).name);
gm = spm_read_vols(spm_vol(segmfile(1,1).name));
wm = spm_read_vols(spm_vol(segmfile(2,1).name));
csf = spm_read_vols(spm_vol(segmfile(3,1).name));
brainmask = +(or(or(gm,wm),csf));

% Mask median filtered/detrended of functional imaging data
numberofvol = dir('In*.nii');
for k = 1:size(numberofvol,1)
    formatfile = 'InputDetFiltReg_00%d.nii';
    str = sprintf(formatfile,k);
    funcvolout = spm_vol(str);
    funcvol_dat = spm_read_vols(funcvolout).*brainmask;
    funcvolout.fname = strcat('mask',str);
    spm_write_vol(funcvolout,funcvol_dat);
end
list_dir = dir('maskInputDetFiltReg_00*');
list_files = '';

% Convert 3D to 4D preprocessed files
for i = 1:length(list_dir)
    cur_files = dir([list_dir(i).name]);
    list_files = [list_files,{cur_files.name}];
end

list_files_tran = transpose(list_files);
spm_file_merge(list_files_tran,'maskdetfilt4D.nii'); 

