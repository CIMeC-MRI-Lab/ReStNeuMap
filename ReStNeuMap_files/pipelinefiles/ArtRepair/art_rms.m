function varstats = art_rms(Images,MaskImage);
% FUNCTION art_rms(Images,MaskImage) 
%   >> art_rms     for GUI inputs
%
% Computes the RMS fluctuation image for a set of images, for all voxels
% within a head mask. Writes out the RMS image. Summarizes the result
% as average RMS fluctuation over the mask in percent signal change,
% as well as the mean RMS and mean image over the mask.
%  
% INPUTS
%    Images is a list of images, in a single session.
%    MaskImage. Specified by user or generated automatically.
% OUTPUTS  
%    RMS image, named rmsINPUT.img, where INPUT are the input image
%       names. No percent scaling is done on this image.
%    varstats: [ 1x3 array ]
%       Avg RMS variation over mask in percent signal change
%           = 100*(avg RMS variation/Imagemean)
%       Avg RMS variation over mask
%       Mean of all images over mask
%
% Runs through all the images sequentially like a pipeline.
%  Compatible with SPM5, SPM8 and SPM2 and SPM12.
%  Compatible with AnalyzeFormat and Nifti images.
%  v.2  May 2009  Paul Mazaika
%  v.3  supports SPM12 Dec2014 pkm.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end

startdir = pwd;
  
if nargin == 0
    if strcmp(spm_ver,'spm5')
        Pimages = spm_select(Inf,'image','Select images to find variation');
    else   % spm2
        Pimages  = spm_get(Inf,'.img','select images to find variation');
    end
    mask_flag = spm_input('Which global mean to use?', 1, 'm', ...
    'User choice mask with same dimensions as these images  | Auto ( Generates and uses ArtifactMask )',[1 2], 2);
    if mask_flag==1
         imagemask = spm_select(1, 'image', 'Select mask image of same dimensions'); 
         im = spm_vol(imagemask);
         maskY = spm_read_vols(im);
    elseif  mask_flag == 2
        disp('Generated mask image is written to file ArtifactMask.img.')
        Pnames = Pimages(1,:);
        maskY = art_automask(Pnames,-1,1);
    end
elseif nargin == 1
    Pimages = Images;
    maskY = art_automask(Pimages(1,:),-1,0);
elseif nargin == 2
    Pimages = Images;
    imagemask = MaskImage;
    im = spm_vol(imagemask);
    maskY = spm_read_vols(im);
end

fprintf('\n First image in series is: ');
fprintf('\n %s', Pimages(1,:));
fprintf('\n New RMS image will be written to image folder.');
fprintf('\n The RMS image has prefix "rms" .');
prechar = 'rms';
nscans = size(Pimages,1);
[NX, NY, NZ] = size(maskY);


% Initialize sum of squares array.
Ysum2 = zeros(NX,NY,NZ);
Ysum = zeros(NX,NY,NZ);
fprintf('\n Starting RMS image calculation...')

% Main Loop
for i = 1:nscans 
    P = spm_vol(Pimages(i,:));
    data = spm_read_vols(P);
    Ysum2 = Ysum2 + data.*data;
    Ysum = Ysum + data;
end
Ysum = Ysum/nscans;
Ysum2 = Ysum2/nscans - Ysum.*Ysum;
Ysum2 = sqrt(Ysum2);

% Prepare the header for the rms volume
V = P;  %spm_vol(Pimages(1));
v = V;
[dirname, sname, sext ] = fileparts(V.fname);
sfname = [ prechar, sname ];
filtname = fullfile(dirname,[sfname sext]);
v.fname = filtname;
spm_write_vol(v,Ysum2); 

% Find image mean
maskcount = sum(sum(sum(maskY)));  %  Number of voxels in mask.
msum = sum(sum(sum(Ysum.*maskY)));  %  Sum of mean image over mask
imgmean = msum/maskcount;
% Find mean of the RMS image
mstd = sum(sum(sum(Ysum2.*maskY)));  %  Sum of RMS image over mask.
stdmean = mstd/maskcount;

pctstd = 100*stdmean/imgmean;
words = [ '\n\n RMS variation, avg over mask in percent:  ', num2str(pctstd)];
fprintf(words)
words = [ '\n\n RMS in percent    actual RMS    image mean over mask'];
fprintf(words)
varstats = [ pctstd   stdmean  imgmean ];

%fprintf('\nDone with RMS image!\n');
cd(startdir)



