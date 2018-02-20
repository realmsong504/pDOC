function [] = f_show_individual_rador(subject_list_file)

% plot rador figure for patient
% msong@nlpr.ia.ac.cn

ratio_mode = 1;  %1, maximum ; 2, median;  3, minimum
method_type = 'PearsonCorr_absT10';

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
network_name = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));

NC_network_overlay_file = fullfile(program_dir, 'model', 'NC_network_overlay.mat');
load(NC_network_overlay_file);


%%
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

% fprintf('load NC...\n');
NC_index=size(NC_overlay_matrix, 1);
radar_colors = repmat('r', NC_index, 1);
radar_labels = ones(NC_index, 1);

overlay_matrix = NC_overlay_matrix;
new_sample_filelist_str = subject_list_file;

[all_test_overlay_matrix, subject_name] = msong_load_7BN_result(new_sample_filelist_str, network_name,ratio_mode, method_type);

n_test_subject = size(all_test_overlay_matrix, 1);
index = 0;
for i = 1 : n_test_subject
    index=index+1;
    subjectID_index=1;
    radar_colors2 = cat(1, radar_colors, repmat('b', subjectID_index,1));
    radar_labels2  = cat(1, radar_labels, ones(subjectID_index, 1)*(0));
    subjectID_overlay_matrix = all_test_overlay_matrix(i, :);
    overlay_matrix2 = cat(1, overlay_matrix, subjectID_overlay_matrix);
    subject_no = char(subject_name{i});
    fig_radar = figure('Name',strcat(subject_no,' '),'NumberTitle','off');
    msong_radarplot(overlay_matrix2, radar_colors2, network_name, ones(1,numel(network_name)), radar_labels2, subject_no);
    print(fig_radar,'-djpeg',fullfile(result_dir,  'rador_plot'));
    
end


