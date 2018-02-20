function [ mutual_info, ROI_name_cell] = msong_calculate_Zmap_brainnetwork_overlay(ROI_file, Zmap_directory, f_BN_img, mask_img, method_type)
%
%  ROI_file:
%  Zmap_directory: Z map
%  f_BN_img: brainnetwork filename
%  mask_img:

n_ROI_file = size(ROI_file, 1);
mutual_info = zeros(n_ROI_file,1);
ROI_name_cell = cell(n_ROI_file,1);

% f_BN_hdr = spm_vol(BN_filename);
% f_BN_img = spm_read_vols(f_BN_hdr);
f_BN_img = f_BN_img.*mask_img;
BN_img = f_BN_img;

BN_img(find(isnan(BN_img)))= 0;
%mask_index = find(BN_img~=0);

parts = msong_strsplit('_', method_type);


for j =1:n_ROI_file
    %fprintf('\n\t computing correlation for %s ...\n', ROI_file(j,:));
    result_filename = sprintf('%02d',j);
    f1 = spm_select('FPList', Zmap_directory,  strcat('^', result_filename ,'.*\.nii$'));
    f1_hdr = spm_vol(f1);
    f1_map = spm_read_vols(f1_hdr);
    
    %     wROI_total_img = zeros(size(BN_img));
    %     for t=1: n_ROI_file
    %         if(t~=j)
    %             f_ROI_hdr = spm_vol(ROI_file(t,:));
    %             f_ROI_img = spm_read_vols(f_ROI_hdr);
    %             wROI_total_img = wROI_total_img + f_ROI_img;
    %         end
    %     end
    %     wROI_total_img = wROI_total_img.*BN_img;
    %     wROI_voxel_index = find(wROI_total_img>0);
    
    % summary  the  ROI regions
    % 0826
    %             if(max(f1_v)>0)
    %                 %f1_v = f1_v./max(f1_v);
    %                 %f1_v = f1_v./max(f1_v);
    %                 %f1_s= sum(f1_v(find(f1_v>0)));
    %                 mutual_info(j) =  median(f1_v(find(f1_v>0)));%f1_s./BN_s;
    %             else
    %                 f1_v = zeros(size(f1_v));
    %                 f1_s= 0;
    %                 mutual_info(j) = 0;
    %             end
    
    % 0830
    %f1_v = f1_map(wROI_voxel_index);
    %mutual_info(j) =median(f1_v(:));
    
    
    %% mutual information
    %mutual_info(j) = mi(f1_map,BN_img);
    
    %% pearson's correlation
    switch char(parts{1})
        case 'PearsonCorr'
            if(numel(parts)>1)
                threshold_str = char(parts{2});
                threshold_str2 = threshold_str(5:end);
                threshold = str2double(threshold_str2);
            else
                threshold = 0;
            end
            mask_index = find(abs(BN_img)>threshold);
            f1_v = f1_map(mask_index);
            BN_v = BN_img(mask_index);
            R = corrcoef(f1_v, BN_v);
            mutual_info(j) = R(1,2);
        case 'MutualInfo'
            fprintf('MutualInfo\n');
        otherwise
            fprintf('otherwise\n');
            mutual_info(j)=0;
    end
    
    
    
    %             %% intersection using Z map
    %             Z_threshold = 0.1;
    %             fZ_map_index2 = find(f1_map>=Z_threshold );
    %             f1_BN = zeros(size(f1_map));
    %             f1_BN(fZ_map_index2) = 1;
    %             intersection = f1_BN.* BN_img;
    %             n_intersection = length(find(intersection(:)>0));
    %             n_BN = length(find(BN_img(:)>0));
    %             mutual_info(j) = n_intersection/n_BN;
    
    
    
    %             BN_img2 = double(BN_img);
    %             BN_v = BN_img2(wROI_voxel_index);
    %             BN_v_index = find(BN_v>0);
    %             BN_s = sum(BN_v(BN_v_index));
    %             mutual_info(j) = f1_s./BN_s;
    
    %
    %% output
    ROI_cell = msong_strsplit(filesep, ROI_file(j,:));
    ROI_str = deblank(char(ROI_cell{end}));
    %ROI_str2 = msong_strsplit('.nii', char(ROI_str));
    normalize_flag = ROI_str(1);
    if(strcmp(normalize_flag, 'w'))
        ROI_name = ROI_str(5:end-4);
    else
        ROI_name = ROI_str(4:end-4);
    end
    ROI_name_cell{j} = ROI_name;
    %ROI_name_all{total_n_ROI_file + j } = ROI_name;
    %fprintf('\n\t%s:%f\n',ROI_name ,  mutual_info(j));
end