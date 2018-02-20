function [temporal_mask]=f_calculate_headmotion_FD(headmotion_txt , headmotion_threshold, varargin)
% calculate the headmotion FD according to the rp*.txt after SPM realignment
% the removing points include the present, the one volume preceding, and the followingtwo volumes 
% headmotion_txt : the rp*.txt after SPM
% headmotion_threshold : FD threshold, default 0.5mm
% 

warning on;
if rem(length(varargin),2)
    error('Not enough input arguments.');
end

if(isdir(headmotion_txt))
    work_dir = headmotion_txt;
    headmotion_txt = spm_select('FPList', work_dir, '^rp.*\.txt$');
end

if(~exist(headmotion_txt, 'file'))
    error('%s NOT exists.', headmotion_txt);
end

[headmotion] = readheadmotiontxt(headmotion_txt);

[max_headmotion, index_HM] = max(headmotion(:));
if(max_headmotion> 5*headmotion_threshold)
    warning('*****************************');
    warning('Too large head motion T=%d:  %s', index_HM, max_headmotion);
    warning('*****************************');
end

T = size(headmotion,1);
FD = zeros(T,1);  temporal_mask = ones(T,1);
FD(1)  = 0;

% FD
for t =2 : T
    temp = headmotion(t,:);
    temp0 = headmotion(t-1,:);
    hd_diff = abs(temp - temp0);
    hd_diff(4) = hd_diff(4)*50;
    hd_diff(5) = hd_diff(5)*50;
    hd_diff(6) = hd_diff(6)*50;
    abs_hd_diff = abs(hd_diff);
    FD(t) = sum(abs_hd_diff(:));
end

index = find(FD>headmotion_threshold);

for i = 1: numel(index)
    temporal_mask(index(i)-1) = 0;
    temporal_mask(index(i)) = 0;
    temporal_mask(index(i)+1) = 0;
    temporal_mask(index(i)+2) = 0;
end

if(numel(temporal_mask)>T)
    temporal_mask = temporal_mask(1:T);
end



