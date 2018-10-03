function STDvol = art_slice_STD(P, orient, nscans, pq, Automask, vx, vy, vz)
% This function takes a list of filenames P and calculates a volume of the
% standard deviation of the timeseries without taking in consideration bad
% slices during calculation.
% D. Postina - 2012

for i = 1:nscans
    thisvol = spm_read_vols(P(i));
    Yn2 = squeeze(thisvol);
    Y = ( 1 - Automask).*Yn2;
    
    if ( orient == 1 )
        py = mean(mean(Y,3),2);
        for j = 1:vx
            if py(j) > pq(j)    % drop slice from variance calculation
                allvols(i,j,:,:) = NaN;
            else
                allvols(i,j,:,:) = Yn2(j,:,:);
            end
        end
    end;
    
    if ( orient == 2 )
        py = mean(mean(Y,1),3);
        for j = 1:vy
            if py(j) > pq(j)    % drop slice from variance calculation
                allvols(i,:,j,:) = NaN;
            else
                allvols(i,:,j,:) = Yn2(:,j,:);
            end
        end
    end;
    
    if ( orient == 3 )
        py = mean(mean(Y,1),2);
        for j = 1:vz
            if py(j) > pq(j)    % drop slice from variance calculation
                allvols(i,:,:,j) = NaN;
            else
                allvols(i,:,:,j) = Yn2(:,:,j);
            end
        end
    end;
end
temp = art_nanstd(allvols);
STDvol(:,:,:) = temp(1,:,:,:);
clear allvols;




function [fff_std] = art_nanstd(data);
%
%   [f_std] = nanstd(data);
%
%Function which calculates the std (not NaN) of data containing
%NaN's.  NaN's are excluded completely from calculation.

[m,n] = size(data);

for index = 1:n;
    not_nans = find(isnan(data(:,index)) == 0);
        if length(not_nans) > 0;
            f_std(index) = std(data(not_nans,index));
        else
            f_std(index) = NaN;
        end
end

% we have the 1xN array of STDs, lets put them in the volume
fff_std = zeros(1,size(data,2),size(data,3),size(data,4));
fff_std(:) = f_std(:);