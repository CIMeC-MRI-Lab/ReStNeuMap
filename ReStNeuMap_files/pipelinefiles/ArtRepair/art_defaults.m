function art_defaults
% List of parameter settings used for tuning algorithm performance
%
% ------------------------
% art_global
%  Default values for outliers
% ------------------------
% When std is very small, set a minimum threshold based on expected physiological
% noise. Scanners have about 0.1% error when fully in spec. 
% Gray matter physiology has ~ 1% range, ~0.5% RMS variation from mean. 
% For 500 samples, expect a 3-sigma case, so values over 1.5% are
% suspicious as non-physiological noise. Data within that range are not
% outliers. Set the default minimum percent variation to be suspicious...
%      Percent_thresh = 1.3; 
% For typical subjects with uniform breathing, might be as low as 1.0.
%
% Alternatively, deviations over 2*std are outliers, if std is not very small.
%      z_thresh = 2;  % Currently not used for default.
% Large intravolume motion may cause image reconstruction
% errors, and fast motion may cause spin history effects.
% Guess at allowable motion within a TR. For good subjects,
% would like this value to be as low as 0.3.  
%     mv_thresh = 0.5;  % try 0.3 for subjects with intervals with low noise
                        % try 1.0 for severely noisy subjects   

% -------------------
% art_threshdown, art_threshup
%  Default increment for adjusting thresholds
% -------------------
%     incrpct = 0.05;  % For global intensity in percent signal change
%     incrmv = 0.05;   % For scan to scan motion
%
% -------------------
% art_addmargin
%  Default tolerance level for margins
% -------------------
%  Rough analysis:  Consider the overlap of dip in HPfilter onto
%  the repair region. Its signal contribution is (1/6)*M*d*s*(1-i^2/s^2),
%  where M is %signal change on voxel over the repair, d is the depth
%  of the whitening function, s is its length (assume s=8), and i is
%  margin distance from end of repair. The usual noise contribution is
%  d*2*sqrt(s), assuming single voxel noise is 2%. We need to add margin
%  when  M > 4/(1-i^2/s^2), to keep the repair region from dominating.
%
%  Roughly, M varies 8%/mm for transition of grey to white voxel,
%  assuming a 4mm voxel and 30% difference in grey and white signals.
%  This sets a mm threshold for expected clutter signal on a voxel from
%  repair region. Roughly, M varies 10X(??) the global signal variation
%  during a physiology event. We'll start with these estimates (i.e.
%  equivalent to setting ydiffmove = 1 and ydiffg = 1) for the
%  margin tests, and provide two scaling factors to tune them.
%   ydiffmove = 1.3; % try 1.0 for subjects with intervals of low noise
                     % try 2.0 for severely noisy subjects  
%   ydiffg  =   1.3; % was 1      % scales the global intensity test
%
% ----------------------
% art_automask
%  Search limits to adaptively set a mask threshold
% ----------------------
% Adaptive Threshold Logic depends on estimated error rate outside the head.
% Fraction of points outside the head that pass the threshold must be small.
% For each slice, set the slice to zero if the fraction of mask points on
% the slice is smaller than parameter FMR.
%   FMR = 0.015;   % False Mask Percentage. 
%   Searches between 20% and 40% of peak value in image.
 