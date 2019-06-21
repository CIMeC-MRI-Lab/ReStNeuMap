function alpha_coreg(coregistrationTemplate,source,imgFile)
%====================================================================================
%====================================================================================

opt = 1;        % 1 = coregister only
                % 2 = reslice only
                % 3 = coregister & reslice

% this is the image to coregister to
target_file = '[coregistrationTemplate]';
%'[''/gablab/ochsner/disk0/coherence/'' s{i} ''/func/meanascan1.V001.img'']';

% this is the image that is coregistered
source_file = '[source]';
%'[''/gablab/ochsner/disk0/coherence/'' s{i} ''/anat/s3:ax/V001.img'']';

% these are other images that are registered with the same
% registration as the source file.  Can be left empty.
%other_files = '[]';
other_files = imgFile;

    % example of empty other_files
    %   other_files = '[]';
    %
    % other_files defines the functional filenames you want to run this
    % analysis on.  Create your own, but here are some
    % common examples:
    %
    % If other_files = '[''V*'']', then the program will operate on
    % all files in your functional directory (specified
    % above) with names like 'V*.img'.
    %
    % If other_files = '[''V*.'' int2str(sess)]', then the program
    % will, for EACH session s, select files that have names
    % like 'V*.s.img' (i.e., session 1's files will be all
    % 'V*.1.img', session 2's files will be all 'V*.2.img',
    % etc.)
    %
    % If other_files = '[''/subdir/V*.'' int2str(sess)]', then the
    % program will select, for each session, all the files
    % in the subdirectory named subdir of your functional
    % directory with names like 'V*.s.img'
    %
    % If other_files = '[''/subdir'' int2str(sess) ''/V*.'' int2str(sess)]', 
    % then the program will select files as follows: for
    % session 1, all files in the 'subdir1' subdirectory
    % named V*.1.img; for session 2, all files in the
    % 'subdir2' subdirectory named V*.2.img, and so on, etc.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% make sure defaults are present in workspace
spm_defaults;
global defaults

%cache other_files
%base_other_files = other_files;

% begin loop over subjects
%for i = 1:length(s)

%clear SPM;
%cd(fullfile('/gablab/', myname, disk, study, s{i}));
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf(['Beginning coregistration on subject ' s{i}]);
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
%fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');


target_handle = spm_vol(eval(target_file));
source_handle = spm_vol(eval(source_file));
% get other_files names
%clear full_other_files;
%for sess = 1:nsess
%    fprintf('\nloading other image files for SCAN%g\n', sess);
%    other_files = eval(base_other_files);
%    [scan_dir, other_files]= fileparts(fullfile('/gablab/', myname, disk, study, s{i}, funcdir, [other_files '.img']));
%    full_other_files{sess} = spm_get('files', scan_dir, [other_files '.img']);
%end
full_other_files = imgFile;
full_other_files = char(full_other_files);
other_handles = spm_vol(full_other_files);


coreg_flags = defaults.coreg.estimate;
reslice_flags = defaults.coreg.write;
reslice_flags.mean = 0;
reslice_flags.which = 1;

if opt==1 | opt==3
    x = spm_coreg(target_handle, source_handle, coreg_flags);
    M = inv(spm_matrix(x));
    if isempty(other_handles)
        MM = zeros(4,4,size(source_handle.fname, 1));
        MM(:,:,1) = spm_get_space(deblank(source_handle.fname));
        spm_get_space(deblank(source_handle.fname), M*MM(:,:,1));
    else
        all_files = char(source_handle.fname, other_handles.fname);
        MM = zeros(4,4, size(all_files, 1));
        for j=1:size(all_files,1),
			MM(:,:,j) = spm_get_space(deblank(all_files(j,:)));
		end;
		for j=1:size(all_files,1),
			spm_get_space(deblank(all_files(j,:)), M*MM(:,:,j));
		end;
    end
end

if opt==2 | opt==3
    if isempty(other_handles)
        files = source_handle.fname;
    else
        files = char(source_handle.fname, other_handles.fname);
    end
    spm_reslice(files, reslice_flags);
end


end % subject loop

% FORMAT x = spm_coreg(VG,VF,params)
% VG - handle for first image (see spm_vol).
% VF - handle for second image.
% x - the parameters describing the rigid body rotation.
%     such that a mapping from voxels in G to voxels in F
%     is attained by:  VF.mat\spm_matrix(x(:)')*VG.mat
% flags - a structure containing the following elements:
%          sep      - optimisation sampling steps (mm)
%                     default: [4 2]
%          params   - starting estimates (6 elements)
%                     default: [0 0 0  0 0 0]
%          cost_fun - cost function string:
%                      'mi'  - Mutual Information
%                      'nmi' - Normalised Mutual Information
%                      'ecc' - Entropy Correlation Coefficient
%                      'ncc' - Normalised Cross Correlation
%                      default: 'nmi'
%          tol      - tolerences for accuracy of each param
%                     default: [0.02 0.02 0.02 0.001 0.001 0.001]
%          fwhm     - smoothing to apply to 256x256 joint histogram
%                     default: [7 7]
%


% FORMAT spm_reslice(P,flags)
%
% P     - matrix of filenames {one string per row}
%         All operations are performed relative to the first image.
%         ie. Coregistration is to the first image, and resampling
%         of images is into the space of the first image.
%
% flags    - a structure containing various options.  The fields are:
%
%         mask   - mask output images (1 for yes, 0 for no)
%                  To avoid artifactual movement-related variance the realigned
%                  set of images can be internally masked, within the set (i.e.
%                  if any image has a zero value at a voxel than all images have
%                  zero values at that voxel).  Zero values occur when regions
%                  'outside' the image are moved 'inside' the image during
%                  realignment.
%
%         mean   - write mean image (1 for yes, 0 for no)
%                  The average of all the realigned scans is written to
%                  mean*.img.
%
%         interp - the B-spline interpolation method. 
%                  Non-finite values result in Fourier interpolation.  Note that
%                  Fourier interpolation only works for purely rigid body
%                  transformations.  Voxel sizes must all be identical and
%                  isotropic.
%
%         which   - Values of 0, 1 or 2 are allowed.
%                  0   - don't create any resliced images.
%                        Useful if you only want a mean resliced image.
%                  1   - don't reslice the first image.
%                        The first image is not actually moved, so it may not be
%                        necessary to resample it.
%                  2   - reslice all the images.
%
%             The spatially realigned images are written to the orginal
%             subdirectory with the same filename but prefixed with an 'r'.
%             They are all aligned with the first.
%__________________________________________________________________________
%
% Inputs
% A series of *.img conforming to SPM data format (see 'Data Format').  The 
% relative displacement of the images is stored in their ".mat" files.
%
% Outputs
% The routine uses information in these ".mat" files and writes the
% realigned *.img files to the same subdirectory prefixed with an 'r'
% (i.e. r*.img).
%__________________________________________________________________________
