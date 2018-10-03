function art_threshup
% Function art_threshup      (v.2.2)
%
% Helper function to art_global.  Grabs the saved global data
% from the main figure and extracts the relevant current
% threshold info from the displayed current thresholds, then 
% decreases both thresholds by a small increment, re-calculates
% the outlier list, and redraws the text list and graphical
% outlier display.  
% ------------------------------
% Jeff Cooper, Nov. 2002
% Minor changes.  Paul Mazaika, Aug. 2004
% Updated for motion. Paul Mazaika, Aug. 2006.
%  fix plots v2.2
%  v3 pkm.  Adjust global intensity thresh by 0.05%.  mar 2009

% -------------------
% Defaults
% -------------------
incr = 0.1;      % For global intensity in z-score (obsolete)
incrpct = 0.05;  % For global intensity in percent
incrmv = 0.05;   % For scan to scan motion

% -------------------
% Interrogate GUI
% -------------------

handles = guihandles;
g = guidata(gcf);
curr_thresh = str2num(get(handles.threshnum, 'String'));
curr_threshpct = str2num(get(handles.threshnumpct, 'String'));
curr_threshmv = str2num(get(handles.threshnummv, 'String'));

pctmap = curr_threshpct/curr_thresh;
incr = incrpct/pctmap;

% -------------------
% Main action
% -------------------

%keyboard;
delta = squeeze(g(:,2));
g = squeeze(g(:,1));
new_thresh = curr_thresh + incr;
zscoreA = (g - mean(g))./std(g);  % in case Matlab zscore is not available
glout_idx = (find(abs(zscoreA) > new_thresh))';

new_threshmv = curr_threshmv + incrmv;
mvout_idx = (find(delta > new_threshmv))';

% Outliers from both motion and global intensity
out_idx = unique([glout_idx  mvout_idx]);
outdw_idx = out_idx;

% Update text
set(handles.threshnum, 'String', num2str(new_thresh));
set(handles.threshnumpct, 'String', num2str(new_thresh*pctmap));
set(handles.threshnummv, 'String', num2str(new_threshmv));

% Update edit text box
set(handles.indexedit, 'String', int2str(out_idx));
set(handles.deweightlist, 'String', int2str(outdw_idx));

% Update graphics for global intensity
subplot(5,1,2);
cla;
zscoreA = (g - mean(g))./std(g);  % in case Matlab zscore is not available
plot(abs(zscoreA));
ylabel('Std away from mean');

thresh_x = 1:length(g);
thresh_y = new_thresh*ones(1,length(g));
line(thresh_x, thresh_y, 'Color', 'r');

axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];

for i = 1:length(glout_idx)
    line((glout_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end

% Update graphics for movement
subplot(5,1,4);
cla;
plot(delta);
ylabel('Motion (mm/TR)');
xlabel('Scan to scan movement (~mm). Rotation assumes 65 mm from origin');
thresh_x = 1:length(g);
thresh_y = new_threshmv*ones(1,length(g));
line(thresh_x, thresh_y, 'Color', 'r');

axes_lim = get(gca, 'YLim');
axes_height = [ axes_lim(1)  axes_lim(2)];
for i = 1:length(mvout_idx)
    line((mvout_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end

% Update top chart for deweighting indices
subplot(5,1,1)
outerase = [1:length(delta)];
for i = 1:length(outerase)
    line((outerase(i)*ones(1, length(axes_height))), axes_height, 'Color', 'w');
end
plot(g,'b');
ylabel('Global Avg. Signal');
xlabel('Red vertical lines are to repair. Green vertical lines are to deweight.');
title('ArtifactRepair GUI to repair outliers and identify scans to deweight')
axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];
for i = 1:length(outdw_idx)
    line((outdw_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end