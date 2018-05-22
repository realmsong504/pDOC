function [variable_name]= msong_print_variable_name(ROI_feature_name, FC_regions_name)

variable_name = {};
index = 0;
for i = 1 : size(ROI_feature_name ,1)
    parts = msong_strsplit( '\', char(ROI_feature_name{i}));
    network_name = char(parts{1});
    ROI_name  = char(parts{2});
    index = index +1;
    if(strcmp(ROI_name, 'middle_cingulate'))
        ROI_name= 'MCC';
    end
    variable_name{index} = sprintf('%s.%s', network_name, ROI_name);
end

for  i = 1 : size(FC_regions_name ,1)
    parts_1 = msong_strsplit( '\', char(FC_regions_name{i,1}));
    network_name_1 = char(parts_1{1});
    ROI_name_1  = char(parts_1{2});
    
    parts_2 = msong_strsplit( '\', char(FC_regions_name{i,2}));
    network_name_2 = char(parts_2{1});
    ROI_name_2  = char(parts_2{2});
    
    if(strcmp(ROI_name_1, 'middle_cingulate'))
        ROI_name_1= 'MCC';
    end
    
    if(strcmp(ROI_name_2, 'middle_cingulate'))
        ROI_name_2= 'MCC';
    end
    index = index +1;
    variable_name{index} = sprintf('%s.%s - %s.%s', network_name_1, ROI_name_1,...
        network_name_2, ROI_name_2);
end
