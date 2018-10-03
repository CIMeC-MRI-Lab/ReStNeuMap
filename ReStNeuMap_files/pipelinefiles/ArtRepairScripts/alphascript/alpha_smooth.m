function alpha_smooth(P, s)
%====================================================================================
%====================================================================================

% Compatible with SPM5 and SPM2
n     = size(P,1);
spm_progress_bar('Init',n,'smoothing','scans completed')
for i = 1:n
	Q = deblank(P(i,:));
	[pth,nm,xt] = fileparts(deblank(Q));
	U = fullfile(pth,['s' nm xt]);
	spm_smooth(Q,U,s);
	spm_progress_bar('Set',i);
end

spm_progress_bar('Clear');