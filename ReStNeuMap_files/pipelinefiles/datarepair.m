function [] = fix_preproc()
smoothname = [ '^masksmInputDetFiltReg.*\.nii$'  ];
imgFile = spm_select('FPList',pwd, smoothname);
P{1} = imgFile;
Pnames = P{1};
P = char(P);
art_repairvol_dz(P);


list_dir = dir('vmasksmInputDetFiltReg_00*');
list_files = '';

for i = 1:length(list_dir)
cur_files = dir([list_dir(i).name]);
list_files = [list_files,{cur_files.name}];
end

list_files_tran=transpose(list_files);


%reptoconv=ls('vmasksmInputDetFiltReg_00*');
spm_file_merge(list_files_tran,'vmasksm4D_mask.nii');
%%%movefile('vmasksm4D_mask*','ProcessDir'); Lisa's fix
!vmasksm4D=vmasksm4D_mask*
!mv vmasksm4D_mask* ./ProcessDir/$vmasksm4D


filtname = [ '^InputDetFiltReg.*\.nii$'  ];
imgFile_f = spm_select('FPList',pwd, filtname);
Q{1} = imgFile_f;
Pnames = Q{1};
Q = char(Q);
art_repairvol_dz(Q);

list_dir = dir('vInputDetFiltReg_00*');
list_files = '';

for i = 1:length(list_dir)
cur_files = dir([list_dir(i).name]);
list_files = [list_files,{cur_files.name}];
end

list_files_tran=transpose(list_files);


%filttoconv=ls('vInputDetFiltReg_00*');
spm_file_merge(list_files_tran,'vInputDetFiltReg_4D.nii');
%%%movefile('vInputDetFiltReg_4D.nii','MNIProcessDir'); Lisa's fix
!mv vInputDetFiltReg_4D.nii ./ProcessDir

% a.string='move fixed files';
% reptoconv=ls('vmasksmInputDetFiltReg_00*');
% a.reptoconv=strcat(reptoconv,',1');
% matlabbatch = batch_jobwrapsmandmv(a);
% try
%         spm_jobman('initcfg')
%         spm('defaults', 'FMRI');
%         spm_jobman('serial', matlabbatch);
% end
% end

%function [matlabbatch]=batch_jobwrapsmandmv(a)
%disp(a.string)
%-----------------------------------------------------------------------
% Job saved on 11-Mar-2016 11:15:08 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%%
%matlabbatch{1}.spm.util.cat.vols = {
 %                                     a.reptoconv  
%                                     'vmasksmInputDetFiltReg_001.nii,1'
%                                     'vmasksmInputDetFiltReg_0010.nii,1'
%                                     'vmasksmInputDetFiltReg_00100.nii,1'
%                                     'vmasksmInputDetFiltReg_00101.nii,1'
%                                     'vmasksmInputDetFiltReg_00102.nii,1'
%                                     'vmasksmInputDetFiltReg_00103.nii,1'
%                                     'vmasksmInputDetFiltReg_00104.nii,1'
%                                     'vmasksmInputDetFiltReg_00105.nii,1'
%                                     'vmasksmInputDetFiltReg_00106.nii,1'
%                                     'vmasksmInputDetFiltReg_00107.nii,1'
%                                     'vmasksmInputDetFiltReg_00108.nii,1'
%                                     'vmasksmInputDetFiltReg_00109.nii,1'
%                                     'vmasksmInputDetFiltReg_0011.nii,1'
%                                     'vmasksmInputDetFiltReg_00110.nii,1'
%                                     'vmasksmInputDetFiltReg_00111.nii,1'
%                                     'vmasksmInputDetFiltReg_00112.nii,1'
%                                     'vmasksmInputDetFiltReg_00113.nii,1'
%                                     'vmasksmInputDetFiltReg_00114.nii,1'
%                                     'vmasksmInputDetFiltReg_00115.nii,1'
%                                     'vmasksmInputDetFiltReg_00116.nii,1'
%                                     'vmasksmInputDetFiltReg_00117.nii,1'
%                                     'vmasksmInputDetFiltReg_00118.nii,1'
%                                     'vmasksmInputDetFiltReg_00119.nii,1'
%                                     'vmasksmInputDetFiltReg_0012.nii,1'
%                                     'vmasksmInputDetFiltReg_00120.nii,1'
%                                     'vmasksmInputDetFiltReg_00121.nii,1'
%                                     'vmasksmInputDetFiltReg_00122.nii,1'
%                                     'vmasksmInputDetFiltReg_00123.nii,1'
%                                     'vmasksmInputDetFiltReg_00124.nii,1'
%                                     'vmasksmInputDetFiltReg_00125.nii,1'
%                                     'vmasksmInputDetFiltReg_00126.nii,1'
%                                     'vmasksmInputDetFiltReg_00127.nii,1'
%                                     'vmasksmInputDetFiltReg_00128.nii,1'
%                                     'vmasksmInputDetFiltReg_00129.nii,1'
%                                     'vmasksmInputDetFiltReg_0013.nii,1'
%                                     'vmasksmInputDetFiltReg_00130.nii,1'
%                                     'vmasksmInputDetFiltReg_00131.nii,1'
%                                     'vmasksmInputDetFiltReg_00132.nii,1'
%                                     'vmasksmInputDetFiltReg_00133.nii,1'
%                                     'vmasksmInputDetFiltReg_00134.nii,1'
%                                     'vmasksmInputDetFiltReg_00135.nii,1'
%                                     'vmasksmInputDetFiltReg_00136.nii,1'
%                                     'vmasksmInputDetFiltReg_00137.nii,1'
%                                     'vmasksmInputDetFiltReg_00138.nii,1'
%                                     'vmasksmInputDetFiltReg_00139.nii,1'
%                                     'vmasksmInputDetFiltReg_0014.nii,1'
%                                     'vmasksmInputDetFiltReg_00140.nii,1'
%                                     'vmasksmInputDetFiltReg_00141.nii,1'
%                                     'vmasksmInputDetFiltReg_00142.nii,1'
%                                     'vmasksmInputDetFiltReg_00143.nii,1'
%                                     'vmasksmInputDetFiltReg_00144.nii,1'
%                                     'vmasksmInputDetFiltReg_00145.nii,1'
%                                     'vmasksmInputDetFiltReg_00146.nii,1'
%                                     'vmasksmInputDetFiltReg_00147.nii,1'
%                                     'vmasksmInputDetFiltReg_00148.nii,1'
%                                     'vmasksmInputDetFiltReg_00149.nii,1'
%                                     'vmasksmInputDetFiltReg_0015.nii,1'
%                                     'vmasksmInputDetFiltReg_00150.nii,1'
%                                     'vmasksmInputDetFiltReg_00151.nii,1'
%                                     'vmasksmInputDetFiltReg_00152.nii,1'
%                                     'vmasksmInputDetFiltReg_00153.nii,1'
%                                     'vmasksmInputDetFiltReg_00154.nii,1'
%                                     'vmasksmInputDetFiltReg_00155.nii,1'
%                                     'vmasksmInputDetFiltReg_00156.nii,1'
%                                     'vmasksmInputDetFiltReg_00157.nii,1'
%                                     'vmasksmInputDetFiltReg_00158.nii,1'
%                                     'vmasksmInputDetFiltReg_00159.nii,1'
%                                     'vmasksmInputDetFiltReg_0016.nii,1'
%                                     'vmasksmInputDetFiltReg_00160.nii,1'
%                                     'vmasksmInputDetFiltReg_00161.nii,1'
%                                     'vmasksmInputDetFiltReg_00162.nii,1'
%                                     'vmasksmInputDetFiltReg_00163.nii,1'
%                                     'vmasksmInputDetFiltReg_00164.nii,1'
%                                     'vmasksmInputDetFiltReg_00165.nii,1'
%                                     'vmasksmInputDetFiltReg_00166.nii,1'
%                                     'vmasksmInputDetFiltReg_00167.nii,1'
%                                     'vmasksmInputDetFiltReg_00168.nii,1'
%                                     'vmasksmInputDetFiltReg_00169.nii,1'
%                                     'vmasksmInputDetFiltReg_0017.nii,1'
%                                     'vmasksmInputDetFiltReg_00170.nii,1'
%                                     'vmasksmInputDetFiltReg_00171.nii,1'
%                                     'vmasksmInputDetFiltReg_00172.nii,1'
%                                     'vmasksmInputDetFiltReg_00173.nii,1'
%                                     'vmasksmInputDetFiltReg_00174.nii,1'
%                                     'vmasksmInputDetFiltReg_00175.nii,1'
%                                     'vmasksmInputDetFiltReg_00176.nii,1'
%                                     'vmasksmInputDetFiltReg_00177.nii,1'
%                                     'vmasksmInputDetFiltReg_00178.nii,1'
%                                     'vmasksmInputDetFiltReg_00179.nii,1'
%                                     'vmasksmInputDetFiltReg_0018.nii,1'
%                                     'vmasksmInputDetFiltReg_00180.nii,1'
%                                     'vmasksmInputDetFiltReg_00181.nii,1'
%                                     'vmasksmInputDetFiltReg_00182.nii,1'
%                                     'vmasksmInputDetFiltReg_00183.nii,1'
%                                     'vmasksmInputDetFiltReg_00184.nii,1'
%                                     'vmasksmInputDetFiltReg_00185.nii,1'
%                                     'vmasksmInputDetFiltReg_00186.nii,1'
%                                     'vmasksmInputDetFiltReg_00187.nii,1'
%                                     'vmasksmInputDetFiltReg_00188.nii,1'
%                                     'vmasksmInputDetFiltReg_00189.nii,1'
%                                     'vmasksmInputDetFiltReg_0019.nii,1'
%                                     'vmasksmInputDetFiltReg_00190.nii,1'
%                                     'vmasksmInputDetFiltReg_00191.nii,1'
%                                     'vmasksmInputDetFiltReg_00192.nii,1'
%                                     'vmasksmInputDetFiltReg_00193.nii,1'
%                                     'vmasksmInputDetFiltReg_00194.nii,1'
%                                     'vmasksmInputDetFiltReg_00195.nii,1'
%                                     'vmasksmInputDetFiltReg_00196.nii,1'
%                                     'vmasksmInputDetFiltReg_00197.nii,1'
%                                     'vmasksmInputDetFiltReg_00198.nii,1'
%                                     'vmasksmInputDetFiltReg_00199.nii,1'
%                                     'vmasksmInputDetFiltReg_002.nii,1'
%                                     'vmasksmInputDetFiltReg_0020.nii,1'
%                                     'vmasksmInputDetFiltReg_00200.nii,1'
%                                     'vmasksmInputDetFiltReg_00201.nii,1'
%                                     'vmasksmInputDetFiltReg_00202.nii,1'
%                                     'vmasksmInputDetFiltReg_00203.nii,1'
%                                     'vmasksmInputDetFiltReg_00204.nii,1'
%                                     'vmasksmInputDetFiltReg_00205.nii,1'
%                                     'vmasksmInputDetFiltReg_00206.nii,1'
%                                     'vmasksmInputDetFiltReg_00207.nii,1'
%                                     'vmasksmInputDetFiltReg_00208.nii,1'
%                                     'vmasksmInputDetFiltReg_00209.nii,1'
%                                     'vmasksmInputDetFiltReg_0021.nii,1'
%                                     'vmasksmInputDetFiltReg_00210.nii,1'
%                                     'vmasksmInputDetFiltReg_00211.nii,1'
%                                     'vmasksmInputDetFiltReg_00212.nii,1'
%                                     'vmasksmInputDetFiltReg_00213.nii,1'
%                                     'vmasksmInputDetFiltReg_00214.nii,1'
%                                     'vmasksmInputDetFiltReg_00215.nii,1'
%                                     'vmasksmInputDetFiltReg_00216.nii,1'
%                                     'vmasksmInputDetFiltReg_00217.nii,1'
%                                     'vmasksmInputDetFiltReg_00218.nii,1'
%                                     'vmasksmInputDetFiltReg_00219.nii,1'
%                                     'vmasksmInputDetFiltReg_0022.nii,1'
%                                     'vmasksmInputDetFiltReg_00220.nii,1'
%                                     'vmasksmInputDetFiltReg_00221.nii,1'
%                                     'vmasksmInputDetFiltReg_00222.nii,1'
%                                     'vmasksmInputDetFiltReg_00223.nii,1'
%                                     'vmasksmInputDetFiltReg_00224.nii,1'
%                                     'vmasksmInputDetFiltReg_00225.nii,1'
%                                     'vmasksmInputDetFiltReg_00226.nii,1'
%                                     'vmasksmInputDetFiltReg_00227.nii,1'
%                                     'vmasksmInputDetFiltReg_00228.nii,1'
%                                     'vmasksmInputDetFiltReg_00229.nii,1'
%                                     'vmasksmInputDetFiltReg_0023.nii,1'
%                                     'vmasksmInputDetFiltReg_00230.nii,1'
%                                     'vmasksmInputDetFiltReg_00231.nii,1'
%                                     'vmasksmInputDetFiltReg_00232.nii,1'
%                                     'vmasksmInputDetFiltReg_00233.nii,1'
%                                     'vmasksmInputDetFiltReg_00234.nii,1'
%                                     'vmasksmInputDetFiltReg_00235.nii,1'
%                                     'vmasksmInputDetFiltReg_00236.nii,1'
%                                     'vmasksmInputDetFiltReg_00237.nii,1'
%                                     'vmasksmInputDetFiltReg_00238.nii,1'
%                                     'vmasksmInputDetFiltReg_00239.nii,1'
%                                     'vmasksmInputDetFiltReg_0024.nii,1'
%                                     'vmasksmInputDetFiltReg_00240.nii,1'
%                                     'vmasksmInputDetFiltReg_00241.nii,1'
%                                     'vmasksmInputDetFiltReg_00242.nii,1'
%                                     'vmasksmInputDetFiltReg_00243.nii,1'
%                                     'vmasksmInputDetFiltReg_00244.nii,1'
%                                     'vmasksmInputDetFiltReg_00245.nii,1'
%                                     'vmasksmInputDetFiltReg_00246.nii,1'
%                                     'vmasksmInputDetFiltReg_00247.nii,1'
%                                     'vmasksmInputDetFiltReg_00248.nii,1'
%                                     'vmasksmInputDetFiltReg_00249.nii,1'
%                                     'vmasksmInputDetFiltReg_0025.nii,1'
%                                     'vmasksmInputDetFiltReg_00250.nii,1'
%                                     'vmasksmInputDetFiltReg_00251.nii,1'
%                                     'vmasksmInputDetFiltReg_00252.nii,1'
%                                     'vmasksmInputDetFiltReg_00253.nii,1'
%                                     'vmasksmInputDetFiltReg_00254.nii,1'
%                                     'vmasksmInputDetFiltReg_00255.nii,1'
%                                     'vmasksmInputDetFiltReg_00256.nii,1'
%                                     'vmasksmInputDetFiltReg_00257.nii,1'
%                                     'vmasksmInputDetFiltReg_00258.nii,1'
%                                     'vmasksmInputDetFiltReg_00259.nii,1'
%                                     'vmasksmInputDetFiltReg_0026.nii,1'
%                                     'vmasksmInputDetFiltReg_00260.nii,1'
%                                     'vmasksmInputDetFiltReg_00261.nii,1'
%                                     'vmasksmInputDetFiltReg_00262.nii,1'
%                                     'vmasksmInputDetFiltReg_00263.nii,1'
%                                     'vmasksmInputDetFiltReg_00264.nii,1'
%                                     'vmasksmInputDetFiltReg_00265.nii,1'
%                                     'vmasksmInputDetFiltReg_00266.nii,1'
%                                     'vmasksmInputDetFiltReg_00267.nii,1'
%                                     'vmasksmInputDetFiltReg_00268.nii,1'
%                                     'vmasksmInputDetFiltReg_00269.nii,1'
%                                     'vmasksmInputDetFiltReg_0027.nii,1'
%                                     'vmasksmInputDetFiltReg_00270.nii,1'
%                                     'vmasksmInputDetFiltReg_00271.nii,1'
%                                     'vmasksmInputDetFiltReg_0028.nii,1'
%                                     'vmasksmInputDetFiltReg_0029.nii,1'
%                                     'vmasksmInputDetFiltReg_003.nii,1'
%                                     'vmasksmInputDetFiltReg_0030.nii,1'
%                                     'vmasksmInputDetFiltReg_0031.nii,1'
%                                     'vmasksmInputDetFiltReg_0032.nii,1'
%                                     'vmasksmInputDetFiltReg_0033.nii,1'
%                                     'vmasksmInputDetFiltReg_0034.nii,1'
%                                     'vmasksmInputDetFiltReg_0035.nii,1'
%                                     'vmasksmInputDetFiltReg_0036.nii,1'
%                                     'vmasksmInputDetFiltReg_0037.nii,1'
%                                     'vmasksmInputDetFiltReg_0038.nii,1'
%                                     'vmasksmInputDetFiltReg_0039.nii,1'
%                                     'vmasksmInputDetFiltReg_004.nii,1'
%                                     'vmasksmInputDetFiltReg_0040.nii,1'
%                                     'vmasksmInputDetFiltReg_0041.nii,1'
%                                     'vmasksmInputDetFiltReg_0042.nii,1'
%                                     'vmasksmInputDetFiltReg_0043.nii,1'
%                                     'vmasksmInputDetFiltReg_0044.nii,1'
%                                     'vmasksmInputDetFiltReg_0045.nii,1'
%                                     'vmasksmInputDetFiltReg_0046.nii,1'
%                                     'vmasksmInputDetFiltReg_0047.nii,1'
%                                     'vmasksmInputDetFiltReg_0048.nii,1'
%                                     'vmasksmInputDetFiltReg_0049.nii,1'
%                                     'vmasksmInputDetFiltReg_005.nii,1'
%                                     'vmasksmInputDetFiltReg_0050.nii,1'
%                                     'vmasksmInputDetFiltReg_0051.nii,1'
%                                     'vmasksmInputDetFiltReg_0052.nii,1'
%                                     'vmasksmInputDetFiltReg_0053.nii,1'
%                                     'vmasksmInputDetFiltReg_0054.nii,1'
%                                     'vmasksmInputDetFiltReg_0055.nii,1'
%                                     'vmasksmInputDetFiltReg_0056.nii,1'
%                                     'vmasksmInputDetFiltReg_0057.nii,1'
%                                     'vmasksmInputDetFiltReg_0058.nii,1'
%                                     'vmasksmInputDetFiltReg_0059.nii,1'
%                                     'vmasksmInputDetFiltReg_006.nii,1'
%                                     'vmasksmInputDetFiltReg_0060.nii,1'
%                                     'vmasksmInputDetFiltReg_0061.nii,1'
%                                     'vmasksmInputDetFiltReg_0062.nii,1'
%                                     'vmasksmInputDetFiltReg_0063.nii,1'
%                                     'vmasksmInputDetFiltReg_0064.nii,1'
%                                     'vmasksmInputDetFiltReg_0065.nii,1'
%                                     'vmasksmInputDetFiltReg_0066.nii,1'
%                                     'vmasksmInputDetFiltReg_0067.nii,1'
%                                     'vmasksmInputDetFiltReg_0068.nii,1'
%                                     'vmasksmInputDetFiltReg_0069.nii,1'
%                                     'vmasksmInputDetFiltReg_007.nii,1'
%                                     'vmasksmInputDetFiltReg_0070.nii,1'
%                                     'vmasksmInputDetFiltReg_0071.nii,1'
%                                     'vmasksmInputDetFiltReg_0072.nii,1'
%                                     'vmasksmInputDetFiltReg_0073.nii,1'
%                                     'vmasksmInputDetFiltReg_0074.nii,1'
%                                     'vmasksmInputDetFiltReg_0075.nii,1'
%                                     'vmasksmInputDetFiltReg_0076.nii,1'
%                                     'vmasksmInputDetFiltReg_0077.nii,1'
%                                     'vmasksmInputDetFiltReg_0078.nii,1'
%                                     'vmasksmInputDetFiltReg_0079.nii,1'
%                                     'vmasksmInputDetFiltReg_008.nii,1'
%                                     'vmasksmInputDetFiltReg_0080.nii,1'
%                                     'vmasksmInputDetFiltReg_0081.nii,1'
%                                     'vmasksmInputDetFiltReg_0082.nii,1'
%                                     'vmasksmInputDetFiltReg_0083.nii,1'
%                                     'vmasksmInputDetFiltReg_0084.nii,1'
%                                     'vmasksmInputDetFiltReg_0085.nii,1'
%                                     'vmasksmInputDetFiltReg_0086.nii,1'
%                                     'vmasksmInputDetFiltReg_0087.nii,1'
%                                     'vmasksmInputDetFiltReg_0088.nii,1'
%                                     'vmasksmInputDetFiltReg_0089.nii,1'
%                                     'vmasksmInputDetFiltReg_009.nii,1'
%                                     'vmasksmInputDetFiltReg_0090.nii,1'
%                                     'vmasksmInputDetFiltReg_0091.nii,1'
%                                     'vmasksmInputDetFiltReg_0092.nii,1'
%                                     'vmasksmInputDetFiltReg_0093.nii,1'
%                                     'vmasksmInputDetFiltReg_0094.nii,1'
%                                     'vmasksmInputDetFiltReg_0095.nii,1'
%                                     'vmasksmInputDetFiltReg_0096.nii,1'
%                                     'vmasksmInputDetFiltReg_0097.nii,1'
%                                     'vmasksmInputDetFiltReg_0098.nii,1'
%                                     'vmasksmInputDetFiltReg_0099.nii,1'
%                                    };
%matlabbatch{1}.spm.util.cat.name = 'vmasksm4D_mask.nii';
%matlabbatch{1}.spm.util.cat.dtype = 0;
%matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('3D to 4D File Conversion: Concatenated 4D Volume', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','mergedfile'));
%matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {'ProcessDir'};
%end
