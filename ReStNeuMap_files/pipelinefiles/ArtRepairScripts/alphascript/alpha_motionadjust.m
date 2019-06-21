function alpha_motionadjust(Images, Mgammas, Regressors)
%  MODIFIED FOR BIGASCRIPT. NO CHANGES.
%
% FORMAT motionadjust 
%   Support function for motionJ
% SUMMARY
%   Reads a set of images to motion adjust
%   Reads six images to use for regressors.
%   Reads a set of images to get their realignment .mat files.
%   Writes a set of motion adjusted images, with the letter 'm'
%      prepended to the file names.
% No original data is removed- the old images are all preserved.
%
% NOTES
%  1. Use art_movie to compare the input and adjusted images.
%  2..Use timestats to find RMS voxel variations over time series.
%  3. Use timecourse2 to show a time series of a voxel.
%  Compatible with SPM5 and SPM2
% Paul Mazaika, May 2007


% PARAMETERS
spm_defaults;


P = Images;  % spm_vol(Images);
A = spm_vol(Mgammas);
R = Regressors;        % may be an alternate way.


% Read in the six motion adjustment images.
A1 = spm_read_vols(A(1));
A2 = spm_read_vols(A(2));
A3 = spm_read_vols(A(3));
A4 = spm_read_vols(A(4));
A5 = spm_read_vols(A(5));
A6 = spm_read_vols(A(6));


% Main Loop - Adjust each image.
nscans = size(P,1);
voxelsize = R(1).mat;
vx = abs(voxelsize(1,1)); vy = voxelsize(2,2); vz = voxelsize(3,3);
imagedim = size(A1);

spm_progress_bar('Init',nscans,'Writing motion adjusted images','scans completed');		
for k = 1:nscans
        Y4 = spm_read_vols(P(k));
        %  WOULD BE GREAT IF P.MAT HAD THE INFORMATION HERE.
        % Get the voxel displacement for every voxel
        [ Xp, Yp, Zp ] = rmove(R(k).mat, imagedim, R(1).mat);
        % Apply corrections
        Y4 = Y4 - sin(Xp*2*pi/vx).*A1 - (1-cos(Xp*2*pi/vx)).*A2;
        Y4 = Y4 - sin(Yp*2*pi/vy).*A3 - (1-cos(Yp*2*pi/vy)).*A4;
        Y4 = Y4 - sin(Zp*2*pi/vz).*A5 - (1-cos(Zp*2*pi/vz)).*A6;
        
        % Prepare the header for the filtered volume.
           prechar ='m';
           V = spm_vol(P(k).fname);
           v = V;
           [dirname, sname, sext ] = fileparts(V.fname);
           sfname = [ prechar, sname ];
           filtname = fullfile(dirname,[sfname sext]);
           v.fname = filtname;
        spm_write_vol(v,Y4);  
        showprog = [' 3D Motion adjusted volume   ', sname, sext ];
        %disp(showprog); 
spm_progress_bar('Set',k);	
end
spm_progress_bar('Clear');	 

disp('Done with motion adjustment!')


function [ Xp, Yp, Zp ] = rmove(New,imagedim,Baseline);
%  P.mat transforms voxel coordinates to x,y,z position in mm.
%  New is P.mat for image, Baseline is P(1).mat for baseline image
%  dim is 3D vector of image size.
Mf = New - Baseline;
for i = 1:imagedim(1)
    for j = 1:imagedim(2)
        for k = 1:imagedim(3)
            Xp(i,j,k) = Mf(1,1)*i+Mf(1,2)*j+Mf(1,3)*k+Mf(1,4);
            Yp(i,j,k) = Mf(2,1)*i+Mf(2,2)*j+Mf(2,3)*k+Mf(2,4);
            Zp(i,j,k) = Mf(3,1)*i+Mf(3,2)*j+Mf(3,3)*k+Mf(3,4);
        end
    end
end

