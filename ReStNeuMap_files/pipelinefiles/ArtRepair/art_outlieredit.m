function art_outlieredit
% Function art_outlieredit   (v.2.2)
%    
% Helper function to art_global.  Grabs the edited outlier
% list from the edit box, then redraws the top subplot graphical
% outlier display. 
% ------------------------------
% Jeff Cooper, Nov. 2002
% Paul Mazaika, Aug. 2006  - for replot top chart for v.2
%    fix plot v2.2.


%-------------------
% Interrogate GUI
% ------------------

handles = guihandles;
g = guidata(gcf);
out_string = get(handles.indexedit, 'String');
new_idx = round(str2num(out_string));
curr_thresh = str2num(get(handles.threshnum, 'String'));

% Set total repaired scans to the edit list
out_idx = new_idx;
outdw_idx = new_idx;

g = squeeze(g(:,1));
% zscoreA = (g - mean(g))./std(g);  % in case Matlab zscore is not available
% glout_idx = (find(abs(zscoreA) > curr_thresh))';

% % Update graphics
% subplot(5,1,2);
% cla;
% plot(zscoreA));
% ylabel('std away from mean');
% 
% thresh_x = 1:length(g);
% thresh_y = curr_thresh*ones(1,length(g));
% line(thresh_x, thresh_y, 'Color', 'r');
% 
% axes_lim = get(gca, 'YLim');
% axes_height = axes_lim(1):1:axes_lim(2);
% for i = 1:length(new_idx)
%     line((new_idx(i)*ones(1, length(axes_height))), axes_height, 'Color', 'r');
% end

% Update top chart to show all scans to be repaired
subplot(5,1,1)
axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];
outerase = [1:length(g)];
for i = 1:length(outerase)
    line((outerase(i)*ones(1, 2)), axes_height, 'Color', 'w');
end
plot(g,'b');
ylabel('Global Avg. Signal');
xlabel('Red vertical lines are to repair. Green vertical lines are to deweight.');
title('ArtifactRepair GUI to repair outliers and identify scans to deweight')
for i = 1:length(outdw_idx)
    line((outdw_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end
