function [prefix]=f_temporalMask_fMRI3D_series(fMRI_3D_series, temporal_mask, fMRI_3D_prefix, varargin)
% scrub the 4D fMRI with temporal_mask from the headmotion FD according to the rp*.txt after SPM realignment
% fMRI_3D_series : 4D fMRI
% temporal_mask : f_calculate_headmotion_FD(headmotion_txt , headmotion_threshold, varargin)
% fMRI_3D_prefix : new 3D fMRI prefix, default: S_

T = size(fMRI_3D_series,1);
if(nargin<3)
    fMRI_3D_prefix = 'S_';
end

if(numel(temporal_mask)~=T)
    error('numel(temporal_mask) = %d ~= %d.',numel(temporal_mask), T);
end

% temporal mask
index = find(temporal_mask==1);
if(numel(index)<1)
    error('numel(find(temporal_mask==1) = %d, too large head motion.',numel(index));
end

for i = 1: numel(index)
    [work_dir, fMRI_filename, ext] = fileparts(fMRI_3D_series(index(i),:));
    i_filename = fullfile(work_dir, strcat(fMRI_3D_prefix, fMRI_filename, ext));
    copyfile(fMRI_3D_series(index(i),:), i_filename);
end
prefix = fMRI_3D_prefix;