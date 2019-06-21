function alpha_slicetiming(imgFile, sliceTimeOrder, sliceTimeInterScanInterval)
% function m_slicetiming
%     for SPM5 and SPM2
% Creates a slice order array, as required for spm_slice_timing in spm5
% paul 07/2008

global m_fileId;
% Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));

m_realnames = imgFile;
m_nimages = size(m_realnames,1);
firstvol = spm_vol(m_realnames(1,:));
m_nslices = firstvol(1).dim(3);
%logit(m_fileId, ['NSlices =' int2str(m_nslices)]);

% Construct slice-order array (same code as for spm_slice_timing in spm2)
%if spm_ver =='spm5'
% if strcmp(spm_ver,'spm5')==1
    if sliceTimeOrder == 1       % ascending
        m_sliceorder = [1:m_nslices];
    elseif sliceTimeOrder == 2   % descending
        m_sliceorder =[m_nslices:-1:1];
    elseif sliceTimeOrder == 3   % interleave 
        m_sliceorder = [ 1:2:m_nslices  2:2:m_nslices ];
    else
        disp('Error calling m_slicetiming function')
    end
%else  % spm2 version, only need to send the ascend, descend flag.
%    m_sliceorder = sliceTimeOrder;
%end


m_refslice = floor(m_nslices/2);
m_iscanint = sliceTimeInterScanInterval
m_nslices
m_acqtime = m_iscanint - m_iscanint/m_nslices;
%m_acqtime = 1.9333
m_timing = [];
m_timing(1) = m_acqtime / (m_nslices - 1);
m_timing(2) = m_iscanint - m_acqtime;
% (The way we do it, m1 = m2 = m_scanint / m_nslices.)

% Display vars
%m_realnames
m_sliceorder
m_refslice
m_timing

spm_slice_timing(m_realnames, m_sliceorder, m_refslice, m_timing);
return;
