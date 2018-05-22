function [ROI_feature_name] = msong_load_ROI_feature_name(ROI_feature_filepath)
% ROI_feature_filepath: a text file, a row for a ROI 

ROI_feature_name = {};
index = 0;
if(exist(ROI_feature_filepath,'file'))
    ROI_feature_name_all = importdata(ROI_feature_filepath);
    n_ROI_feature = size(ROI_feature_name_all, 1);
    for i =1: n_ROI_feature
        i_feature = ROI_feature_name_all{i};
        if(~strcmp(i_feature(1), '%'))
            index = index +1 ;
            ROI_feature_name{index,1} = i_feature;
        end
    end
else
    error('%s not exist.', ROI_feature_filepath);
    ROI_feature_name = {''};
end
