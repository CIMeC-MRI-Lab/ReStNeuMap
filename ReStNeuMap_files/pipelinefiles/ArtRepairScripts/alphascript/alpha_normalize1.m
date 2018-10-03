function alpha_normalize1(template_file,sourceFile,method)
%====================================================================================
%====================================================================================
% This version compatible with SPM5 and SPM2
% Otherwise the same as m_normalize1

opt = 1;        % 1 = determine parameters only
                % 2 = write normalized only
                % 3 = determine params & write

% Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));

% template to normalize to
%template_file = '/usr/fmri_progs/matlab/spm2/vanilla/templates/T1.mnc';
	template_file = template_file;

% anatomical image to determine and normalize
%anat_file = '[''/gablab/ochsner/disk0/coherence/'' s{i} ''/anat/s3:ax/V001.img'']';
anat_file = sourceFile;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%if method == 1
%	boundingBox = [-78 -112 -50; 78 76 85];
%elseif method == 2
%	boundingBox = [-91 -127 -73; 91 91 109];
%end

	boundingBox = [-91 -127 -73; 91 91 109];

% make sure defaults are present in workspace
spm_defaults;
global defaults

%CIBSRbox = defaults.normalise.write.bb;
CIBSRnormalize = struct('smosrc',8,'smoref',0,'regtype','mni','cutoff',25,'nits',16,'reg',1,'graphics',1);
CIBSRwrite = struct('interp',1,'wrap',[0 0 0],'vox',[2 2 2],'bb',NaN,'preserve',0);



% begin loop over subjects
%for i = 1:length(s)

%clear SPM;
%cd(fullfile('/gablab/', myname, disk, study, s{i}));
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf(['Beginning normalization on subject ' s{i}]);
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

%anat_handle = spm_vol(eval(anat_file));
%matname = [spm_str_manip(eval(anat_file),'sd') '_sn.mat'];
template_handle = spm_vol(template_file);
anat_handle = spm_vol(anat_file);
matname = [spm_str_manip(anat_file,'sd') '_sn.mat'];



if spm_ver == 'spm5'
   spm_normalise(template_handle, anat_handle, matname, '', '', CIBSRnormalize);
   spm_write_sn(anat_handle, matname, CIBSRwrite);
else  %  spm2
   spm_normalise(template_handle, anat_handle, matname, '', '', defaults.normalise.estimate);
   spm_write_sn(anat_handle, matname, defaults.normalise.write);
end 



%end % subject loop

% FORMAT params = spm_normalise(VG,VF,matname,VWG,VWF,flags)
% VG        - template handle(s)
% VF        - handle of image to estimate params from
% matname   - name of file to store deformation definitions
% VWG       - template weighting image
% VWF       - source weighting image
% flags     - flags.  If any field is not passed, then defaults are assumed.
%             smosrc - smoothing of source image (FWHM of Gaussian in mm).
%                      Defaults to 8.
%             smoref - smoothing of template image (defaults to 0).
%             regtype - regularisation type for affine registration
%                       See spm_affreg.m (default = 'mni').
%             cutoff  - Cutoff of the DCT bases.  Lower values mean more
%                       basis functions are used (default = 30mm).
%             nits    - number of nonlinear iterations (default=16).
%             reg     - amount of regularisation (default=0.1)
% ________________________________


% FORMAT VO = spm_write_sn(V,prm,flags,msk)
% V         - Images to transform (filenames or volume structure).
% matname   - Transformation information (filename or structure).
% flags     - flags structure, with fields...
%           interp   - interpolation method (0-7)
%           wrap     - wrap edges (e.g., [1 1 0] for 2D MRI sequences)
%           vox      - voxel sizes (3 element vector - in mm)
%                      Non-finite values mean use template vox.
%           bb       - bounding box (2x3 matrix - in mm)
%                      Non-finite values mean use template bb.
%           preserve - either 0 or 1.  A value of 1 will "modulate"
%                      the spatially normalised images so that total
%                      units are preserved, rather than just
%                      concentrations.
% msk       - An optional cell array for masking the spatially
%             normalised images (see below).
%
% Warped images are written prefixed by "w".
%
% Non-finite vox or bounding box suggests that values should be derived
% from the template image.
%
% Don't use interpolation methods greater than one for data containing
% NaNs.
