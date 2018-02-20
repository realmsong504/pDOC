function [label_probability] = f_calculate_label_probability_clinical(testing_score, training_score, training_label, label_threshold)

%% calculate the consciousness probability using clinical characteristics only)
%
% msong@nlpr.ia.ac.cn

width_section = 3;

if(nargin<6)
    label_threshold =2;
    
    %%
    low_label_index = find(training_label <= label_threshold);  % GOS 1,2 : non_recovery
    high_label_index = find(training_label > label_threshold);  % GOS 3,4,5 : recovery
    
    low_training_score = training_score(low_label_index);
    high_training_score = training_score(high_label_index);
    
    %%  prediction and awaken ratio ( section computation)
    section = [2:width_section:25];
    n_section = numel(section) +1;
    index_awaken_subject = high_label_index ;
    label_awaken_subject = zeros(numel(training_score),1);
    label_awaken_subject(index_awaken_subject) = 1;
    [prediction_sort, ind] = sort(training_score);
    %awaken_ratio_array = zeros(n_section, 1);
    awaken_count_array = zeros(n_section, 2);

    start_point = prediction_sort(1);
    for i = 1: n_section
        if(i~=n_section)
            end_point = section(i);
        else
            end_point = prediction_sort(end);
        end
        i_section_subject = (training_score<end_point) & (training_score >= start_point) ;
        i_section_awaken = i_section_subject.* label_awaken_subject;
        n_awaken = sum(i_section_awaken(:));
        n_nonawaken = numel(find(i_section_subject>0)) - n_awaken;
        awaken_count_array(i, 1) = n_nonawaken;
        awaken_count_array(i, 2) = n_awaken;
        start_point = end_point;
    end
    awaken_ratio_array = awaken_count_array(:,2)./sum(awaken_count_array,2);
    
    b= isnan(awaken_ratio_array) ;
    c=~b;
    d =find(c,1,'last');
    
    for i=d: numel(awaken_ratio_array)
        awaken_ratio_array(i) = 1;
    end
    
   
    index = find(section<=testing_score, 1, 'last');
    index = index +1;
    
    
    probability = awaken_ratio_array(index);
    label_probability(1) = 1;  % recovery
    label_probability(2) = probability;
    
    %print('-djpeg',fullfile(result_dir,  'prognostication_result'));
    
else
    fprintf('Not support mulitple label\n');
    label_probability(1) = -1;  % recovery
    label_probability(2) = 0;
end




