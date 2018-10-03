function art_clipmvmt
% Function  art_clipmvmt
%
%  Helper function for art_global. Finds all images total motion > 3 mm
%  from baseline image (usually image 001). Total motion is defined
%  as RMS sum of translations plus rotations assuming a voxel 65mm from
%  the origin. New red vertical lines are added to the top plot in
%  art_global, and the scans are added to the list to be repaired.
% -------------------
%  Rough analysis to set the default movement threshold test.
%        Motion regressors are used to compensate for
%  subject mmotion. SPM suggests using 12 regressors, linear and
%  quadratic in each realignment parameter. Often just 6 linear 
%  regressors are used in practice. Motion regressors are theoretically
%  valid for "small motions". How big is small? Suppose the residual
%  motion error is periodic with voxel size (as in Grootoonk (2000), and
%  Mazaika, HBM meeting 2007). Then a linear or quadratic model
%  will be reasonably OK for 1/4 to 1/2 a voxel. Motion excursions much larger
%  than that won't fit the motion regression model. We assume as a default
%  that voxel size is 4 mm, and set the motion threshold at 3 mm.
%  Then motion regressors should work pretty well on the remaining
%  unrepaired data.
% -----------------------------
% Paul Mazaika, July. 2007  (v2.2 for spm2 and spm5)

%  The user can change the motion default size right here:
     MVMTTHRESHOLD = 3; % millimeters

                    
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


deltam = zeros(nscans,1);  % Mean square displacement from first scan
for i = 1:nscans
    deltam(i,1) = (mv_data(i,1))^2 +...
            (mv_data(i,2))^2 +...
            (mv_data(i,3))^2 +...
            1.28*(mv_data(i,4))^2 +...
            1.28*(mv_data(i,5))^2 +...
            1.28*(mv_data(i,6))^2;
    deltam(i,1) = sqrt(deltam(i,1));
end

% Name the scans with big displacements
clipout_idx = find(deltam(:,1) > MVMTTHRESHOLD)';

% Update clip movement list (which is not shown in a text box)
set(handles.clipmvmtlist, 'String', int2str(clipout_idx));

% Combine with existing repair list
out_idx = union(out_idx, clipout_idx);
set(handles.indexedit, 'String', int2str(out_idx));



% % Update top chart to include clip movement indices
subplot(5,1,1)
% outerase = [1:nscans];
axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];
% for i = 1:nscans
%     line((outerase(i)*ones(1, length(axes_height))), axes_height, 'Color', 'w');
% end
% Refresh the global intensity plot
plot(gx,'b');
ylabel('Global Avg. Signal');
xlabel('Red vertical lines are to repair. Green vertical lines are to deweight.');
title('ArtifactRepair GUI to repair outliers and identify scans to deweight');
% % Draw the scans recommended for deweighting
% for i = 1:length(outdw_idx)
%     line((outdw_idx(i)*ones(1, length(axes_height))), axes_height, 'Color', 'g');
% end
% Draw the scans recommended for repairing
for i = 1:length(out_idx)
    line((out_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end




 