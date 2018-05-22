function [network_name] = msong_load_network_name(network_filepath)
% network_filepath: a text file, a row for a network

network_name = {};
index = 0;
if(exist(network_filepath,'file'))
    network_name_all = importdata(network_filepath);
    n_network = size(network_name_all, 1);
    for i =1: n_network
        i_feature = network_name_all{i};
        if(~strcmp(i_feature(1), '%'))
            index = index +1 ;
            network_name{index,1} = i_feature;
        end
    end
else
    error('%s not exist.', network_filepath);
    network_name = {''};
end
