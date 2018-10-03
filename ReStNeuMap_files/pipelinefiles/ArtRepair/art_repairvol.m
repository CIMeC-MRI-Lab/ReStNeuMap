function art_repairvol(varargin)
% Function art_repairvol(varargin)    (v.2 and SPM5)
%
% Helper function for art_global.m for SPM2. Repairs and writes new image
% volumes according to specification from art_global. New files are 
% written with 'v' prepended to their names. Output images maintain the
% same scale factor as the input images to prevent potential
% scaling problems if outputs are used by FSL. Also writes two text files
% to the images folder:
%   art_repaired.txt    names of volumes changed during repair
%   art_deweighted.txt  names of volumes suggested by art_global 
%                       to be deweighted during SPM estimation.
% GoRepair = 1 runs interpolation repair, = 0 will ask for method.
%
% User will be asked to select a repair method. Choices are:
%  -Interp replaces each outlier scan with a linear interpolation between
%      the two nearest non-outlier scans. Equivalent to interpolation
%      for spikes, and is often a smoother fix than mean insertion for
%      for consecutive outlier scans. RECOMMENDED CHOICE.
%  -Despike replaces each outlier scan with an average of the 
%      scans immediately before and after the outlier (or the nearest
%      two scans if the outlier is the first or last scan.)
%      Works well for isolated spike volumes.
%  -Mean insertion replaces each outlier scan with a mean image 
%      constructed from all scans in the session. 
%
% This version is designed to be less affected by read-write file 
% permissions, but it uses more space. All old scans remain as is.
% ---------------------------------
% Jeff Cooper, November 2002
% Fixed interpolation method, and SPM2 update. Paul Mazaika, August 2004.
% Fixed for robust writing, and "v" naming. Paul Mazaika, November 2004.
% Version 2 adds Interp choice, outputs a text list of repaired volumes,
%    leaves image scaling alone. Paul Mazaika, August 2006.
% V2.1 SPM5 version amends file writing from copy_hdr to use same file type.
%   Gets name from V.fname. Changed private flag, for better or worse.
% v2.2  minor tweak to clean up spm_input  July 2007

% ----------------------
% Interrogate GUI
% ----------------------

%keyboard;
handles = guihandles;
rng = str2num(get(handles.rangenum, 'String'));
out_idx = round(str2num(get(handles.indexedit, 'String')));
outdw_idx = round(str2num(get(handles.deweightlist, 'String')));
if nargin == 0
    % Callbacks don't like argument list, so pass P through getappdata.
    P = getappdata(gcbo, 'data');
    GoRepair = 0;
else
    % In batch mode, Repair button callback is not started so gcbo=[].
    % So pass the data in using the argument list.
    Pa = varargin;
    GoRepair = 1;
    P = char(cell2mat(Pa));
end

dummy = 1;

% ----------------------
% Data editing
% ----------------------
%keyboard;
inputdir = cd;
%
cd(fileparts(P(1,:)));
% Save lists of repaired scans, and scans to deweight for later use
save art_repaired.txt out_idx -ascii
save art_deweighted.txt outdw_idx -ascii

intfig = spm('CreateIntWin', 'on');
if GoRepair == 0
    inter_method = spm_input('Which repair method?', 1, 'b', 'Interp|Despike|Mean', [3;2;1], 1);
    spm_input('!DeleteInputObj');
else
    inter_method = 3;
end

meth_string = '';
if inter_method == 1
    meth_string = 'mean insertion';
    % remove outliers in question from mean calculation
    meanP = P;
    meanP(out_idx,:) = [];
    %for i = 1:length(out_idx)
    %    meanP(out_idx(i),:) = [];
    %end
    art_spm_mean_ui(meanP);
    % Don't forget that this "mean" image is created with spm_add and 
    % scalefactors in the image headers.  Which means we need to copy
    % the header later on to make sure spm_global is using proper
    % scalefactors to read the data.
    mean_img = fullfile(pwd, 'mean.img');
    mean_hdr = fullfile(pwd, 'mean.hdr');
    Vm = spm_vol(mean_img);
    vm = Vm;
    Ym = spm_read_vols(Vm);
end
if inter_method == 2
    meth_string = 'despike';
end
if inter_method == 3
    meth_string = 'interpolation';
end

fprintf('\n Repaired scans will be saved with the prefix "v"');
fprintf('\n  in the same directory. (V means volume repair.)\n');
fprintf('\n The scans with indices %s are being repaired by %s.\n', num2str(out_idx), meth_string);
fprintf('\n A list of outlier scans will be saved in the same directory');
fprintf('\n in the file art_repaired.txt.\n');
fprintf('\n A list of scans to deweight will be saved in the same directory');
fprintf('\n in the file art_deweighted.txt.\n');
if (size(P,1) < 3)
     error('Cannot interpolate images: fewer than three scans.');
     return;
end

% Find the correct scans
allscan = [ 1: size(P,1) ];
for k = 1:length(out_idx)
    allscan(out_idx(k)) = 0;
end
in_idx = find(allscan>0);

% First copy over the scans that require no repair.
% Hard to believe! Read-then-write is a more robust way to copy
% across some network permission configurations.
for j = 1:length(in_idx)
    curr = P(in_idx(j),:);
    V = spm_vol(P(in_idx(j),:));
    v = V;
    Y = spm_read_vols(V);
    [currpath, currname, currext] = fileparts(V.fname);
    copyname = ['v' currname currext];
    copy2 = fullfile(currpath, copyname);
    v.fname = copy2;   %  same name with a 'v' added
    v.private = [];    %  makes output files read-write.
    spm_write_vol(v,Y);
end
% Repair the outlier scans, and tag them as outliers.       
for i = 1:length(out_idx)
    fprintf('\nRepairing scan %g...\n', out_idx(i));
    curr = P(out_idx(i),:); 
    V = spm_vol(P(out_idx(i),:));
    v = V;
    Y = spm_read_vols(V);
    [currpath, currname, currext] = fileparts(V.fname);
    copyname = ['outlier_' currname currext];
    copyname_hdr = ['v' currname '.hdr'];
    copyname_img = ['v' currname currext];
    copy2 = fullfile(currpath, copyname);
    copy_hdr = fullfile(currpath, copyname_hdr);
    copy_img = fullfile(currpath, copyname_img);
    v.fname = copy2;
    v.private = [];  %  makes output files read-write.
    % No need to write image. It's listed in art_repaired.txt.
    %   spm_write_vol(v,Y);
    % Copy fast for linux....
      %system(['cp ' curr ' ' copy]);
      %system(['cp ' curr_hdr ' ' copy_hdr]);
    im_map = spm_vol(curr);

    if inter_method == 1;  % Replace outlier with mean image.
        %copyfile(mean_img, curr, 'f'); 
        %copyfile(mean_hdr, copy_hdr, 'f');
        v.fname = copy_img;  % was copy_hdr;
        spm_write_vol(v,Ym);
    end

    if inter_method == 2;  % Replace outlier with interpolated image.
        if out_idx(i) == 1 % Extrapolate for first scan
            im_in = spm_vol([P(2,:);P(3,:)]);
        elseif out_idx(i) == size(P,1) % Extrapolate for last scan
            im_in = spm_vol([P(out_idx(i)-2,:);P(out_idx(i)-1,:)]);
        else  %  Interpolate for most scans
            im_in = spm_vol([P(out_idx(i)-1,:);P(out_idx(i)+1,:)]);
        end
        Y1 = spm_read_vols(im_in(1));
        Y2 = spm_read_vols(im_in(2));
        Ym = (Y1 + Y2 )/2;
        v.fname = copy_img;  % was copy_hdr;
        spm_write_vol(v,Ym);
        % noscale_write_vol(v,Ym);
        %spm_write_vol(im_map,Ym);
        %spm_imcalc(im_in, im_map, '(i1+i2)/2'); Wrong answer on windows?!
    end
    % New method. Interpolate between nearest non-outlier scans.
    % Provides linear interpolation over extended outliers.
    if inter_method == 3;  % Replace outlier with interpolated image.
        
        % Find nearest non-outlier scan in each direction
        yyy = find(allscan>out_idx(i)); 
        if (length(yyy)>0) highside = min(yyy); else highside = 0; end
        yyy = find(allscan<out_idx(i) & allscan>0);
        if (length(yyy)>0) lowside = max(yyy); else lowside = 0; end
            
        if lowside == 0 % Extrapolate from first good scan
            im_in = spm_vol(P(highside,:));
            Y1 = spm_read_vols(im_in(1));
            Ym = Y1;
        elseif highside == 0 % Extrapolate from last good scan
            im_in = spm_vol(P(lowside,:));
            Y1 = spm_read_vols(im_in(1));
            Ym = Y1;
        else  %  Interpolate for most scans
            im_in = spm_vol([P(lowside,:);P(highside,:)]);
            lenint = highside - lowside;
            hiwt = (out_idx(i)-lowside)/lenint;
            lowwt = (highside - out_idx(i))/lenint;
            Y1 = spm_read_vols(im_in(1));
            Y2 = spm_read_vols(im_in(2));
            Ym = Y1*lowwt + Y2*hiwt;
        end
        v.fname = copy_img;  % was copy_hdr;
        spm_write_vol(v,Ym);
        % noscale_write_vol(v,Ym);
        %spm_write_vol(im_map,Ym);
        %spm_imcalc(im_in, im_map, '(i1+i2)/2'); Wrong answer on windows?!
    end
end
fprintf('\nDone!. Output files have prefix "v".\n');
close(intfig);

cd(inputdir);


% %---------------------------------------------------------------
% % Create and write image without the scale and offset steps  
% % This function is spm_write_vol without error checking and scaling.
% function noscale_write_vol(V,Y);
% V = spm_create_vol(V);
% for p=1:V.dim(3),
%     V = spm_write_plane(V,Y(:,:,p),p);
% end;
% V = spm_close_vol(V);




