function art_addmargin
% Function  art_addmargin
%
%  Helper function for art_global. For a set of indices to be repaired, 
%     returns a list of indices to be deweighted. The list is
%     returned as outdw_idx. The list will be written to file when the
%     art_global REPAIR button is pushed.
%  The logic is:
%     1. All repaired scans will be deweighted.
%     2. If a sequence of repaired scans leaves very uneven values
%        at each end, then a margin of scans (up to 7) on each side
%        is listed for deweighting.
%     3. If a sequence of repair indices has the same motion and global
%        intensity values at each end, then no margin is added.
%  The function draws deweighting bars in green on the top figure, 
%     and returns outdw_idx.
% -----------------------------
% Paul Mazaika, Aug. 2006
% v2.3 May 2009. Bug fix if all!! scans repaired. 

% -------------------
% Default tolerance level for margins
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
%  equivalet to setting ydiffmove = 1 and ydiffg = 1) for the
%  margin tests, and provide two scaling factors to tune them.

   ydiffmove = 1.3; % try 1.0 for subjects with intervals of low noise
                    % try 2.0 for severely noisy subjects  
   ydiffg  =   1.3; % was 1      % scales the global intensity test
                    % Case 4555 likes 2, while 7910 likes 1.

                    
% -------------------
% Interrogate GUI
% -------------------

handles = guihandles;
g = guidata(gcf);
curr_thresh = str2num(get(handles.threshnum, 'String'));
curr_threshmv = str2num(get(handles.threshnummv, 'String'));
nscans = size(g,1);
delta = squeeze(g(:,2));
mv_data(:,1:6) = g(:,3:8);
gx = squeeze(g(:,1));
%repair1_flag = getappdata(gcbo,'data2');
out_idx = round(str2num(get(handles.indexedit, 'String')));

% Derive the current proposed repairs;
% zscoreA = (gx - mean(gx))./std(gx);  % in case Matlab zscore is not available
% glout_idx = (find(abs(zscoreA) > curr_thresh))';
% mvout_idx = (find(delta > curr_threshmv))';
% % Current set of scans to be repaired.
% out_idx = unique([glout_idx  mvout_idx]);
% if (repair1_flag == 1) out_idx = unique([1 out_idx]); end

% Find reasonable margins
xout = zeros(1,nscans); 
xout(out_idx) = 2;
% Determine whether ends are to be repaired
if xout(1) == 2
    repL = 1; else repL = 0; end
if xout(nscans) == 2
    repR = 1; else repR = 0; end

% Find sets of consecutive scans to be repaired
j = repL; k = 0; xendL(1) = 0; xendR(1) = 0;
for i = 1:nscans-1
    if xout(i) == 0 & xout(i+1) == 2
        j = j+1;
        xendL(j) = i;
    end
    if xout(i) == 2 & xout(i+1) == 0
        k=k+1;
        xendR(k) = i+1;
    end
end
% Number of central clusters
nclust = k; % if repR == 0 and repL == 0
nclust = k - repR - repL;  % if repR == 1
   
% For each cluster not at the end, if end values are close, 
%      then no margins are needed.
for iclust = repL+1:nclust+repL
    for imarg = 0:7
        if xendL(iclust)-imarg < 1 | xendR(iclust)+imarg > nscans
            break
        elseif xout(xendL(iclust)-imarg) > 0 | xout(xendR(iclust)+imarg) > 0
            break
        end
        [ ta, tb ] = posdiff(xendL(iclust)-imarg,xendR(iclust)+imarg,mv_data,gx,imarg);
        if   ta < ydiffmove & tb < ydiffg;
            break
        else   % mark for deweighting
            xout(xendL(iclust)-imarg) = 1;
            xout(xendR(iclust)+imarg) = 1;
        end
    end
end 
%  Case when Left End is repaired
if repL == 1
    for imarg = 0:7
        if  xendR(1)+imarg > nscans
            break
        elseif  xendR(1)+imarg < 1
            break
        elseif  xout(xendR(1)+imarg) > 0
            break
        end
        [ ta, tb ] = posdiff(1,xendR(1)+imarg,mv_data,gx,imarg);  % NOT CORRECT
        if   ta < ydiffmove & tb < ydiffg;
            break
        else   % mark for deweighting
            xout(xendR(1)+imarg) = 1;
        end
    end
end
% Case when Right End is repaired
if repR == 1
    for imarg = 0:7
        if xendL(length(xendL))-imarg < 0
            break
        elseif  xout(xendL(length(xendL))-imarg) > 0
            break
        end
        [ ta, tb ] = posdiff(xendL(length(xendL))-imarg,nscans,mv_data,gx,imarg); % NOT CORRECT
        if   ta < ydiffmove & tb < ydiffg;
            break
        else   % mark for deweighting
            xout(xendL(iclust)-imarg) = 1;
        end
    end
end
% Fill in singleton openings
for i = 2:nscans-1
    if xout(i-1) > 0 & xout(i+1) > 0
        xout(i) = 1;
    end
end

% Update deweightlist (which is not shown in a text box)
outdw_idx = find(xout > 0);
set(handles.deweightlist, 'String', int2str(outdw_idx));


% Update top chart for deweighting indices
subplot(5,1,1)
outerase = [1:nscans];
axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];
for i = 1:nscans
    line((outerase(i)*ones(1, 2)), axes_height, 'Color', 'w');
end
% Refresh the global intensity plot
plot(gx,'b');
ylabel('Global Avg. Signal');
xlabel('Red vertical lines are to repair. Green vertical lines are to deweight.');
title('ArtifactRepair GUI to repair outliers and identify scans to deweight');
% Draw the scans recommended for deweighting
for i = 1:length(outdw_idx)
    line((outdw_idx(i)*ones(1, 2)), axes_height, 'Color', 'g');
end
% Draw the scans recommended for repairing
for i = 1:length(out_idx)
    line((out_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end

%---------------------------------------------------------------
function [ mvpx, gp ] = posdiff(m,n,mv_data,gx,imarg);
% Returns clutter estimates of how the HPfilter interacts with repair region.
% First, finds ~mm displacement and percent global intensity difference
%    between the ends of the repair region.
% Then, it estimates the clutter overlap factor of the whitening dip 
%    onto the strength of the abnormal region that will be repaired.
% Finally, those numbers in mm and global percent are scaled into a
%    percent noise value on a voxel, relative to thermal noise.
% Rotational mv_data is in degrees, assumes 65 mm radius.
yd = (mv_data(m,1) - mv_data(n,1))^2 +...
    (mv_data(m,2) - mv_data(n,2))^2 +...
    (mv_data(m,3) - mv_data(n,3))^2 +...
    1.28*(mv_data(m,4) - mv_data(n,4))^2 +...
    1.28*(mv_data(m,5) - mv_data(n,5))^2 +...
    1.28*(mv_data(m,6) - mv_data(n,6))^2;    
yd = sqrt(yd);
% Overlap interaction term (assumed s=9, single voxel noise is 2%)
odiff = ( 1 - imarg^2/80)/4;
mvpx = 8*yd*odiff;  % assumes 8% change in intensity/mm.
gpct = abs(gx(m) - gx(n))/(gx(n));
gp = 10*gpct*odiff;  % assumes 10% change in voxel/global intensity.
 