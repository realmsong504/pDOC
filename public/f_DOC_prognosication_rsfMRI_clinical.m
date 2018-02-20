function [] = f_DOC_prognosication_rsfMRI_clinical(patient_directory,patient_etiology, patient_incidence_age, patient_duration_of_DOC)


tic;

[patient_directory] = f_regulate_patient_directory(patient_directory);
[parent_dir, patient_name] = fileparts(patient_directory);

% write filelist to be processed
directory = parent_dir;
filelist=sprintf('%s.txt', patient_name);
patient_filelist = fullfile(directory, filelist);
t_fid=fopen(patient_filelist,'w');
fprintf(t_fid, '%s\r\n', patient_name);
fclose(t_fid);

% write clinical characteristics 
clinical_characteristics_file = 'clinical_characteristics.txt';
clinical_characteristics_path = fullfile(patient_directory, clinical_characteristics_file);
clinical_characteristics_fid = fopen(clinical_characteristics_path,'w');
fprintf(clinical_characteristics_fid, 'age:%f\r\n', patient_incidence_age);
fprintf(clinical_characteristics_fid, 'duration:%f\r\n', patient_duration_of_DOC);
fprintf(clinical_characteristics_fid, 'etiology:%s\r\n', lower(patient_etiology));
fclose(clinical_characteristics_fid);

% write a log file
log_file = sprintf('log_%s.txt', patient_name);
log_path = fullfile(patient_directory,log_file);
log_fid=fopen(log_path,'w');
% save input parameter
fprintf(log_fid, '******\r\n');
fprintf(log_fid, 'Input paramter\r\n');
fprintf(log_fid, '\tEtiology:%s\r\n', patient_etiology);
fprintf(log_fid, '\tIncidence_age:%f\r\n', patient_incidence_age);
fprintf(log_fid, '\tDuration_of_unconsciousness:%f\r\n', patient_duration_of_DOC);
fprintf(log_fid, '\tpatient_directory:''%s''\r\n', patient_directory);

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
%% Spm8 preprocessing batch
subject_list_file = patient_filelist;
f_spm8batch_BB_EPI2fMRI_SC(subject_list_file);
cd(program_dir);

%% data quality evaluation (head motion & tSNR)
f_data_quality_evaluation(subject_list_file);

%%  Six brain network calculation &  plot scatter figure for each network
f_6BN_calculation(subject_list_file);

%% plot rador figure for patient
f_show_individual_rador(subject_list_file);

%% show whole brain connectivity for each ROI
f_show_brain_network_SeedPoint_individual(subject_list_file, 1);   % 1: DMN

%% progonosication
[label_probability]= f_prognostication_to_newSample(subject_list_file);
fprintf(log_fid, '******\r\n');
fprintf(log_fid, 'Predicted result\r\n');
fprintf(log_fid, '\t probability_of_consciousness_recovery:%4.2f\r\n', label_probability(2));

% close log fid
fclose(log_fid);

%% delete patient_file
fclose('all');
delete(patient_filelist);
delete(clinical_characteristics_path);

fprintf('Calculation is over!\n');

toc;


