function alpha_coregprep(anatImg,segmentTemplate)


%Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));


anatImg_handle = spm_vol(anatImg);
segmentTemplategray_handle = spm_vol(segmentTemplate.gray);
segmentTemplateWhite_handle = spm_vol(segmentTemplate.white);
segmentTemplateCSF_handle = spm_vol(segmentTemplate.csf);

opts.tm = [segmentTemplategray_handle; segmentTemplateWhite_handle; segmentTemplateCSF_handle];
opts.ngaus    = [2 2 2 4];
opts.warpreg  = 1;
opts.warpco   = 25;
opts.biasreg  = 0.0001;
opts.biasfwhm = 70;
opts.regtype  = 'subj';
opts.fudge    = 5;
opts.samp     = 3;
opts.msk      = '';
opts.usecom  = 0;

fprintf('%-4s\n',['Starting bias correction and gray matter segmentation']);
p = spm_preproc(anatImg_handle,opts);
fprintf('%-4s\n',['Preparing to write images']);
[po,pin] = spm_prep2sn(p)

fprintf('%-4s\n',['Writing images']);
output = struct('biascor',0,'GM',[0 0 1],'WM',[0 0 0],'CSF',[0 0 0],'cleanup',1);
spm_preproc_write(po,output);


return;



%Identify spm version
%[ dummy, spm_ver ] = fileparts(spm('Dir'));
%
%anatSegment_handle = spm_vol(anatSegment);
%segmentTemplate_handle = spm_vol(segmentTemplate);
%
%opts.tpm   = char(...
%				   '/fs/fmrihome/fMRItools/matlab/spm2/vanilla/pediatricCCHMC/CCHMC2_girls_5-18/gray.img',...
%				   '/fs/fmrihome/fMRItools/matlab/spm2/vanilla/pediatricCCHMC/CCHMC2_girls_5-18/white.img',...
%				   '/fs/fmrihome/fMRItools/matlab/spm2/vanilla/pediatricCCHMC/CCHMC2_girls_5-18/csf.img');
%opts.ngaus    = [2 2 2 4];
%opts.warpreg  = 1;
%opts.warpco   = 25;
%opts.biasreg  = 0.0001;
%opts.biasfwhm = 70;
%opts.regtype  = 'subj';
%opts.fudge    = 5;
%opts.samp     = 3;
%opts.msk      = '';
%opts.usecom  = 0;
%
%fprintf('%-4s\n',['Starting VBM']);
%p = cg_vbm(anatSegment_handle,opts);
%fprintf('%-4s\n',['Preparing to write images']);
%[po,pin] = spm_prep2sn(p)
%
%job.output.BIAS = struct('native',1,'descalp',1,'warped',1);
%job.output.GM = struct('native',1,'descalp',1,'warped',1,'modulated',1);
%job.output.WM = struct('native',1,'descalp',1,'warped',1,'modulated',1);
%job.output.CSF = struct('native',1,'descalp',1,'warped',1,'modulated',1);
%job.output.extopts = struct('vox',[1 1 1],'bb',[-91 -127 -74; 91 91 109],'cleanup',2,'mrf',0.3,'usepriors',0,'writeaffine',0);
%
%fprintf('%-4s\n',['Writing images']);
%cg_vbm_write(po,job,pin);
%
%
%if method == 3
%	V0 = spm_select('FPList',[SubjectDir anatDir],'^m.*\.img');
%	fprintf('%-4s\n',['Starting gray/white segmentation']);
%	spm_segment(V0,segmentTemplate_handle);
%	fprintf('%-4s\n',['Finished gray/white segmentation']);
%end
%
return;