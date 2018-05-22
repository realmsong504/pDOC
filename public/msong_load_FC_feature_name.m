function [FC_feature_name] = msong_load_FC_feature_name(FC_feature_filepath)
% FC_feature_filepath: a text file, a row for a FC (including ROI_1, ROI_2) 

FC_feature_name = {};
index = 0;
if(exist(FC_feature_filepath,'file'))
    FC_feature_name_all = importdata(FC_feature_filepath);
    n_FC_feature = size(FC_feature_name_all, 1);
    for i =1: n_FC_feature
        i_feature = FC_feature_name_all{i};
        if(~strcmp(i_feature(1), '%'))
            index = index +1 ;
            ROIs = msong_strsplit(',', i_feature);
            ROI_1 = ROIs{1};
            ROI_2 = ROIs{2};
            FC_feature_name{index,1} = ROI_1;
            FC_feature_name{index,2} = ROI_2;
        end
    end
else
    error('%s not exist.', FC_feature_filepath);
    FC_feature_name = {''};
end
