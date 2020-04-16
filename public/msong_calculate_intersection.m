function [ratio_intersection] = msong_calculate_intersection(f1, f2)
%%
% ratio_intersection will be small when there is disortation in mean fMRI
% f1: wmask_file
% f2: rmask_file, expected brain 

f1_hdr = spm_vol(f1);
f1_map = spm_read_vols(f1_hdr);
f1_map(find(isnan(f1_map)))= 0;

f2_hdr = spm_vol(f2);
f2_map = spm_read_vols(f2_hdr);
f2_map(find(isnan(f2_map)))= 0;

%% intersection
intersection = f1_map.* f2_map;
n_intersection = length(find(intersection(:)>0));
n_BN = length(find(f2_map(:)>0));
ratio_intersection = n_intersection/n_BN;