

clear all;
clc;

% public_dir = pwd;
% addpath(public_dir);

subject_directory='K:\beizong\20180730_DOC\test';
subject_filename = 'subject_batch.txt';

[temp, log_name] = fileparts(subject_filename);
log_file = sprintf('log_%s.txt', log_name);
log_path = fullfile(subject_directory,log_file);
log_fid = fopen(log_path,'w');

subject_path = fullfile(subject_directory, subject_filename);
subject_fid = fopen(subject_path);

subject_prognosis_cell = textscan(subject_fid, '%s %s %s %s');

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
public_function_dir = fullfile(program_dir, 'public');
if(exist(public_function_dir, 'dir'))
    addpath(public_function_dir);
else
    error('public function does not exist.');
end

n_subject_prognosis = size(subject_prognosis_cell{1},1)-1;   % total, good_prognosis
for i =1: n_subject_prognosis
    patient_directory = subject_prognosis_cell{1}{i+1};
    patient_etiology =  subject_prognosis_cell{2}{i+1};
    patient_incidence_age =  str2double(subject_prognosis_cell{3}{i+1});
    patient_duration_of_DOC =  str2double(subject_prognosis_cell{4}{i+1});
    
    log_fid = fopen(log_path,'a');
    if( log_fid>0)
        fprintf(log_fid, '******\r\n');
        %     fprintf(log_fid, '\tEtiology:%s\r\n', patient_etiology);
        %     fprintf(log_fid, '\tIncidence_age:%f\r\n', patient_incidence_age);
        %     fprintf(log_fid, '\tDuration_of_unconsciousness:%f\r\n', patient_duration_of_DOC);
        fprintf(log_fid, '\tpatient_directory:''%s''\r\n', patient_directory);
    else
        fprintf(log_fid, '******\r\n');
        %     fprintf(log_fid, '\tEtiology:%s\r\n', patient_etiology);
        %     fprintf(log_fid, '\tIncidence_age:%f\r\n', patient_incidence_age);
        %     fprintf(log_fid, '\tDuration_of_unconsciousness:%f\r\n', patient_duration_of_DOC);
        fprintf(log_fid, '\tpatient_directory:''%s''\r\n', patient_directory);
        
    end
    
    
    if(exist(patient_directory,'dir'))
        f_DOC_prognosication_rsfMRI_clinical(patient_directory,...
            patient_etiology, patient_incidence_age, patient_duration_of_DOC);
    else
        % only using clinical characteristics
        pDOC_warning();
        f_DOC_prognosication_clinical(patient_etiology, patient_incidence_age, patient_duration_of_DOC);
        
    end
    close all;
    
    
end
% % close log fid
% fclose(log_fid);
% fclose(subject_fid);