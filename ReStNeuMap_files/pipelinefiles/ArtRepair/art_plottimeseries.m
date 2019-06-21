function outseries = art_plottimeseries(Qimages,voxel)
% function outseries = art_plottimeseries(Images,voxel)
% >> art_plottimeseries  for GUI input
%  
%  Obtains the timecourse of a voxel from a set of images.
%  Specified by voxel coordinates, not in mm.
%
%  GUI input
%     Program asks for images
%     Program asks for voxel coordinates
%  Argument input: outseries = art_plottimeseries(Images,voxel)
%     Images: Set of images, with full path names
%     voxel:  [ 1x3 array ], all positive integers
%  Outputs
%     Returns 'outseries', the timeseries itself
%     If nargin==0, plots timeseries and saves a file with data.
%
%  Called as a diagnostic by art_despike function
%  Paul Mazaika - Jun 2009 adds SPM8
%  supports SPM12, Dec2014 pkm.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end


if nargin > 0
    xyz = voxel;
else  %  GUI input
    % GUI for imagesif strcmp(spm_ver,'spm5')
    if strcmp(spm_ver,'spm5')
        Qimages = spm_select(Inf,'image','Select images for timeseries');
    else   % spm2
        Qimages  = spm_get(Inf,'.img','select images for timeseries');
    end
    % GUI for voxel location (in voxel)
    xyz = spm_input('Enter I J K voxel coords (in voxels)',1,'e',[],3);
end
coord=round(xyz)';
Q = spm_vol(Qimages);
nimages = size(Q,1);
Q1 = spm_read_vols(Q(1));
[ NX, NY, NZ ] = size(Q1);
dim(1) = NX; dim(2) =NY; dim(3) = NZ;
%dim=SPM.xY.VY(1).dim
x=coord(1);
y=coord(2);
z=coord(3);

intensity=zeros(nimages,1); %length(SPM.xY.P));
for filenumber=1:nimages  %length(SPM.xY.P)
    Q1 = spm_read_vols(Q(filenumber));
    intensity(filenumber) = Q1(x,y,z);
end
outseries = intensity;

if nargin == 0
    timename=['timecourse' num2str(x) num2str(y) num2str(z) '.txt']
    figure(20)
    plot(intensity)
    labl = ['Voxel coordinates  ' num2str(coord)];
    xlabel(labl);
    strint = 'intensity';
    save(timename,strint,'-ASCII') %-ASCII
end