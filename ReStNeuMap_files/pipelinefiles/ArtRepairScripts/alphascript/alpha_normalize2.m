function alpha_normalize2(method,paramFile,imgFile)
%====================================================================================
%====================================================================================
% Compatible with SPM5 and SPM2

% Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));

%---------------------------------------------------
% User-defined parameters for this analysis
%---------------------------------------------------
% _sn.mat file to use as normalization parameters
%param_file = '[sjDir{i} ''mean*_sn.mat'']';
param_file = paramFile;

opt = 2;
%opt = 1;        % 1 = determine parameters only
                % 2 = write normalized only
                % 3 = determine params & write


%imgprefix = '[''ascan'' int2str(sess) ''.V*'']';
    % imgprefix defines the functional filenames you want to run this
    % analysis on.  Create your own, but here are some
    % common examples:
    %
    % If imgprefix = '[''V*'']', then the program will operate on
    % all files in your functional directory (specified
    % above) with names like 'V*.img'.
    %
    % If imgprefix = '[''V*.'' int2str(sess)]', then the program
    % will, for EACH session s, select files that have names
    % like 'V*.s.img' (i.e., session 1's files will be all
    % 'V*.1.img', session 2's files will be all 'V*.2.img',
    % etc.)
    %
    % If imgprefix = '[''/subdir/V*.'' int2str(sess)]', then the
    % program will select, for each session, all the files
    % in the subdirectory named subdir of your functional
    % directory with names like 'V*.s.img'
    %
    % If imgprefix = '[''/subdir'' int2str(sess) ''/V*.'' int2str(sess)]', 
    % then the program will select files as follows: for
    % session 1, all files in the 'subdir1' subdirectory
    % named V*.1.img; for session 2, all files in the
    % 'subdir2' subdirectory named V*.2.img, and so on, etc.
    
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
CIBSRwrite = struct('interp',1,'wrap',[0 0 0],'vox',[2 2 2],'bb',NaN,'preserve',0);

%cache imgprefix
%base_imgprefix = imgprefix;

% begin loop over subjects
%for i = 1:length(s)

%clear SPM;
%cd(fullfile('/gablab/', myname, disk, study, s{i}));
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf(['Beginning normalization on subject ' s{i}]);
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');




% Get filenames for functional scans
%===========================================================================
%clear scans;
%for sess = 1:nsess
%    fprintf('\nloading image files for SCAN%g\n', sess);
%    imgprefix = eval(base_imgprefix);
%    [scan_dir, imgprefix]= fileparts(fullfile('/gablab/', myname, disk, study, s{i}, funcdir, [imgprefix '.img']));
%    scans{sess} = spm_get('files', scan_dir, [imgprefix '.img']);
%end
%scans = char(scans);
scans = imgFile;
% do the writing
% ---------------------------------------
%spm_write_sn(scans, eval(param_file), defaults.normalise.write);



if spm_ver == 'spm5'
   spm_write_sn(scans, param_file, CIBSRwrite);
else  %  spm2
   spm_write_sn(scans, param_file, defaults.normalise.write);
end 




%end % subject loop


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
