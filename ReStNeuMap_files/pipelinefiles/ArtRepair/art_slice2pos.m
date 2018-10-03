function [x y width height] = art_slice2pos(slice,locate)
% this function accepts the 'locate' variable from art_movie.
%
% INPUT:
% slice - the slice number  to find position of,
% locate - values of the displayed layout
%               locate(1) = plane (axial, saggital, coronal)
%               locate(2) = number of rows
%               locate(3) = number of columns
%               locate(4) = slice resolution in X direction
%               locate(5) = slice resolution in Y direction
%
% OUTPUT
% [x y width height] - ready to use variables for positioning the red
% rectangle for a bad slice
%
% v.1 by Dorian Pustina, October 2012

xresol = locate(5);
yresol = locate(4);
rows = locate(2);
cols = locate(3);

% find the row column location for this slice in the picture
row = ceil(slice/cols);     % row number the slice should be in
artrow = row; % artrow = abs(rows-row)+1;   % row it is in starting from below
col = slice-((row-1)*cols);  % column number the slice should be in calculated
                            % as remainder of division between slice and one
                            % row less of where should have been

artcol = col; % artcol = abs(cols-col)+1;;      % column number it is in starting from below
if artcol == 0 artcol = 1; end


% define final position variables
x = xresol*(artcol-1)+1;        % the x position for this slice
y = yresol*(artrow-1)+1;            % the y position for this slice

width = xresol-1;
height = yresol-1;