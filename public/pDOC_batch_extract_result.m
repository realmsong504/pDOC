
clear all;
clc;

% only need to modify Line 6 & 7
subject_directory='L:\beizong\20180730_DOC\test';
subject_filename = 'subject_result_list.txt';

[temp, result_name] = fileparts(subject_filename);
result_file = sprintf('all_result_%s.txt', result_name);
result_path = fullfile(subject_directory,result_file);
t_fid = fopen(result_path,'w');

subject_path = fullfile(subject_directory, subject_filename);
subject_fid = fopen(subject_path);

patient_directory_cell = textscan(subject_fid, '%s');

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
public_function_dir = fullfile(program_dir, 'public');
if(exist(public_function_dir, 'dir'))
    addpath(public_function_dir);
else
    error('public function does not exist.');
end

patient_directory_list = patient_directory_cell{1,1};
n_subject_prognosis = length(patient_directory_list);   % total, good_prognosis

for i =1: n_subject_prognosis
    patient_directory = patient_directory_list{i};
    ROI_result = zeros(22,1);
    
    [patient_dir, fMRI_dir] = fileparts(patient_directory);
    if strcmpi(fMRI_dir, 'fMRI')
        patient_log_file_all = spm_select('FPList', patient_dir,  '^log.*\.txt$') ;
    else
        patient_log_file_all = spm_select('FPList', patient_directory,  '^log.*\.txt$') ;
    end
    patient_log_file = patient_log_file_all(end,:);
    
    if(exist(patient_log_file,'file'))
        % exist
        [log_dir, log_filename] = fileparts(patient_log_file);
        patient_name = log_filename(5:end);
        
        % read log file for name, age, duration, etiology
        patient_info_cell = msong_read_log_file(patient_log_file);
        
        % 22_ROI result
        ROI_result_directory = fullfile(patient_directory,'result_6BN','1_overlay_result');
        if(exist(ROI_result_directory,'dir'))
            
            % read 22 ROI result
            ROI_result_path = fullfile(ROI_result_directory, 'overlay_result_PearsonCorr_absT10.txt');
            ROI_result_cell = msong_read_overlay_result(ROI_result_path);
            ROI_name_cell = ROI_result_cell(:,1);
            ROI_overlay_cell = ROI_result_cell(:,2);
            [ROI_name_sort, ROI_sort_index] = sort(ROI_name_cell);
            
            % read functional connectivity matrix
            [FC_struct] = msong_calculate_all_FC(patient_dir);
            FC_matrix = FC_struct.FC_matrix;
            FC_name = FC_struct.FC_name;
            
            % write title line
            if( i==1)
                % write name, age, duration, etiology
                fprintf(t_fid, 'Name\tAge\tDuration\tEtilogy\tPLS_prediction\t');
                
                % write ROI name
                for ii= 1: numel(ROI_sort_index)
                    fprintf('%s \t', char(ROI_name_cell(ROI_sort_index(ii))));
                    fprintf(t_fid, '%s\t', char(ROI_name_cell(ROI_sort_index(ii))));
                end
                
                % write connectivity name
                for ii= 1: numel(FC_matrix)
                    fprintf('%s \t', char(FC_name{ii}));
                    fprintf(t_fid, '%s\t', char(FC_name{ii}));
                end                
                fprintf('\n');
                fprintf(t_fid,'\r\n');
            end
            
            % write log result
            fprintf(t_fid, '%s\t%s\t%s\t%s\t%f\t',patient_name, patient_info_cell{2,2},patient_info_cell{3,2},patient_info_cell{1,2},str2double(patient_info_cell{4,2}));
            
            for ii= 1: numel(ROI_sort_index)
                fprintf('%f \t',  str2double(ROI_overlay_cell{ROI_sort_index(ii)}));
                fprintf(t_fid, '%f \t', str2double(ROI_overlay_cell{ROI_sort_index(ii)}));
            end
            
            % write connectivity
            for ii= 1: numel(FC_matrix)
                %fprintf('%s \t', char(FC_name{ii}));
                fprintf(t_fid, '%f \t', FC_matrix(ii));
            end
            
            fprintf('\n');
            fprintf(t_fid,'\r\n');
        else
            % not exist.
            pDOC_warning('\t 22_ROI directory:',ROI_result_directory, 'not exists.');
        end
    else
        % not exist.
        pDOC_warning(patient_directory, ': log file does not exist.');
    end
    
    %     if( i==1)
    %         fprintf(result_fid, '******\r\n');
    %         %     fprintf(result_fid, '\tEtiology:%s\r\n', patient_etiology);
    %         %     fprintf(result_fid, '\tIncidence_age:%f\r\n', patient_incidence_age);
    %         %     fprintf(result_fid, '\tDuration_of_unconsciousness:%f\r\n', patient_duration_of_DOC);
    %         fprintf(result_fid, '\tpatient_directory:''%s''\r\n', patient_directory);
    %
    %     end
    
end

fclose(t_fid);
close all;

% % close log fid
% fclose(log_fid);
% fclose(subject_fid);