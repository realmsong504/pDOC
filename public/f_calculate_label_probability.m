function [label_probabiltiy] = f_calculate_label_probability(subject_list_file, testing_score, training_score, training_label, label_threshold)

%% calculate the probability of each cluster that are by thresholding the training label)
%
% msong@nlpr.ia.ac.cn

width_section = 3;

[directory, subject_name] = fileparts(subject_list_file);
subject_directory = fullfile(directory, subject_name);

fMRI_directory= [];
[BOLD_directory] = msong_select_subdirectory('subdir', subject_directory,  '^BOLD.*');
[BOLD_directory2] = msong_select_subdirectory('subdir', subject_directory,  '^fMRI.*');
[BOLD_directory3] = msong_select_subdirectory('subdir', subject_directory,  '^fmri.*');

if(size(BOLD_directory, 1)>0)
    fMRI_directory = BOLD_directory(1,:);
end
if(size(BOLD_directory2, 1)>0)
    fMRI_directory = BOLD_directory2(1,:);
end
if(size(BOLD_directory3, 1)>0)
    fMRI_directory = BOLD_directory3(1,:);
end

if(~exist(fMRI_directory, 'dir'))
    error(fprintf('fMRI directory: %s does not exist. \n', fMRI_directory));
end

result_dir = fullfile(fMRI_directory, 'reports');
if(~exist(result_dir, 'dir'))
    mkdir(fMRI_directory, 'reports');
end


if(nargin<6)
    label_threshold =2;
    
    %%
    low_label_index = find(training_label <= label_threshold);  % GOS 1,2 : non_recovery
    high_label_index = find(training_label > label_threshold);  % GOS 3,4,5 : recovery
    
    %%  prediction and awaken ratio ( section computation)
    section = [2:width_section:25];
    n_section = numel(section) +1;
    index_awaken_subject = high_label_index ;
    label_awaken_subject = zeros(numel(training_score),1);
    label_awaken_subject(index_awaken_subject) = 1;
    [prediction_sort, ind] = sort(training_score);
    %awaken_ratio_array = zeros(n_section, 1);
    awaken_count_array = zeros(n_section, 2);
    fig6 = figure('Name', 'Prognositication with rs-fMRI and clinical characteristics','NumberTitle','off','Tag','fig_results');
    set(fig6,'units','centimeters','position',[3 3 25 10],'color','w');
    hold on;
    start_point = prediction_sort(1);
    % smaller than or equal to section(1)
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
    tick_labels = msong_tick_labels(section);
    
    subplot(1,2,1);  hold on;
    barh(awaken_ratio_array, 'c');
    title('Prognositication with rs-fMRI and clinical characteristics');
    plot(awaken_ratio_array,[1: numel(awaken_ratio_array)], ':^r','LineWidth',2,'markerfacecolor','r');
    set(gca,'YTick',[1: numel(awaken_ratio_array)]); ylabel('Predicted Score');
    set(gca,'YTickLabel',tick_labels); xlabel('Consciousness Recovery Probability');
    xlim([0, 1.1]);
    my_ylim = ylim();
    ylim(my_ylim);
    dashline(ones(size([0:0.1:4]))*awaken_ratio_array(4),[0:0.1:4], 2,2,2,2, 'color',[.75 .75 .75]);
    dashline(ones(size([0:0.1:5]))*awaken_ratio_array(5),[0:0.1:5], 2,2,2,2, 'color',[.75 .75 .75]);
    dashline(ones(size([0:0.1:6]))*awaken_ratio_array(6),[0:0.1:6], 2,2,2,2, 'color',[.75 .75 .75]);
    dashline(ones(size([0:0.1:7]))*awaken_ratio_array(7),[0:0.1:7], 2,2,2,2, 'color',[.75 .75 .75]);
    text(awaken_ratio_array(4)+0.015, 4-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(4)*100),'FontSize',8);
    text(awaken_ratio_array(5)+0.015, 5-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(5)*100),'FontSize',8);
    text(awaken_ratio_array(6)+0.015, 6-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(6)*100),'FontSize',8);
    
    %title(sprintf('%s\n', 'Recover Rate in PLA Army General Hospital'));
    
    hold off;
    
    subplot(1,2,2);  hold on;
    text_descend = 0.15;
    axis off;
    text(0,1-text_descend,  sprintf('Patient name : %s', subject_name),'FontSize',12);
    clinical_characteristics_path = fullfile(subject_directory, 'clinical_characteristics.txt');
    [age, duration, etiology] = f_read_clinical_characteristics(clinical_characteristics_path);
    switch etiology
        case 1
            etiology_str = 'Trauma';
        case 2
            etiology_str = 'Stroke';
        case 3
            etiology_str = 'Anoxia';
    end
    
    text(0.05,0.9-text_descend,  sprintf('\tEtiology = %s', etiology_str),'FontSize',10);
    text(0.05,0.85-text_descend,  sprintf('\tIncidence age = %4.1f years', age),'FontSize',10);
    text(0.05,0.8-text_descend,  sprintf('\tDuration of unconsciousness = %4.1f months', duration),'FontSize',10);
    
    dashline([0:0.1:1],ones(size([0:0.1:1]))*(0.7-text_descend), 1,1,1,1, 'color',[.75 .75 .75]);
    
    [headmotion, T_FD] = f_head_motion_evaluation(subject_list_file);
    for j =4:6
        headmotion(:,j) = headmotion(:,j).*50;
    end
    T = size(headmotion,1);
    ratio_T = T_FD./T*100;
    text(0,0.65-text_descend, sprintf('fMRI quality: ', T_FD, ratio_T),'FontSize',12);
    text(0.05,0.55-text_descend, sprintf('\ttotal T = %d', T),'FontSize',10);
    text(0.05,0.5-text_descend, sprintf('\teffective T = %d; %4.2f%% of the total volumes', T_FD, ratio_T),'FontSize',10);
    
    dashline([0:0.1:1],ones(size([0:0.1:1]))*(0.45-text_descend), 1,1,1,1, 'color',[.75 .75 .75]);
    
    index = find(section<=testing_score, 1, 'last');
    index = index +1;
    
    probabiltiy = awaken_ratio_array(index);
    follow_up_result = 'Consciousness recovery probability';
    fprintf('%s: p=%4.2f\n', follow_up_result, probabiltiy);
    text(0,0.35-text_descend,  sprintf('Predicted Result'),'FontSize',12);
    text(0.05,0.25-text_descend,  sprintf('\tPredicted score = %4.2f', testing_score),'FontSize',10);
    text(0.05,0.2-text_descend,  sprintf('\t%s = ', follow_up_result),'FontSize',10);
    text(0.8,0.2-text_descend,  sprintf('%4.2f',  probabiltiy),'FontSize',10,'color','red');
    hold off;
    
    label_probabiltiy(1) = 1;  % recovery
    label_probabiltiy(2) = probabiltiy;
    
    print(fig6, '-djpeg',fullfile(result_dir,  'prognostication_result'));
    
else
    fprintf('Not support mulitple label\n');
    label_probabiltiy(1) = -1;  % recovery
    label_probabiltiy(2) = 0;
end




