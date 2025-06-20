function [] = f_pDOC_prognosication_using_individual_aMPFC_DMPFC(work_dir)

% addpath('K:\work\2017_DOC_0_prognosis\pDOC\20230315\pDOC\');
% addpath('K:\work\2017_DOC_0_prognosis\pDOC\20230315\pDOC\public');

% work_dir = 'Z:\DOC_MRI_dongruan\20250509_zhang_junshan\analysis\zhang_junshan\fMRI';%'Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI';

% program_location = which('pDOC');
% [program_dir] = fileparts(program_location);
% program_dir_public = fullfile(program_dir, 'public');
% program_dir_public_ind = fullfile(program_dir_public, 'individual_ROI');
% addpath(program_dir_public_ind);


target_dir2 = fileparts(work_dir);
[target_dir3, subject_no] = fileparts(target_dir2); % analysis
new_work_dir = fullfile(target_dir3, sprintf('%s_individual', subject_no),'fMRI');

if(~exist(new_work_dir, 'dir'))
    mkdir(new_work_dir);
else
    warning('%s exists.', new_work_dir);
end

% new aMPFC ROI & FC map "01_w01_aMPFC_DMN_Zmap.nii"
fprintf('create_individual_aMPFC_ROI_and_FC_Zmap\n');
f_create_individual_aMPFC_ROI(work_dir,new_work_dir);
% new DMPFC & FC map "01_w01_DMPFC_ExecuContr_Zmap.nii"
fprintf('create_individual_DMPFC_ROI_and_FC_Zmap\n');
f_create_individual_dMPFC_ROI(work_dir,new_work_dir);

%% copy EPI directory
EPI_directory = fullfile(work_dir, 'EPI');
target_EPI_directory = fullfile(new_work_dir, 'EPI');
copyfile(EPI_directory, target_EPI_directory,'f');
% override the aMPFC
target_DMN_ROI_directory = fullfile(new_work_dir, 'EPI','brain_ROI_DOC', 'DMN');
w01_aMPFC =  spm_select('FPList',new_work_dir,[strcat('^w01_aMPFC.*\.nii$')]);
copyfile(w01_aMPFC(1,:), target_DMN_ROI_directory,'f');
% override the DMPFC
target_ExecuContr_ROI_directory = fullfile(new_work_dir, 'EPI','brain_ROI_DOC', 'ExecuContr');
w01_DMPFC =  spm_select('FPList',new_work_dir,[strcat('^w01_DMPFC.*\.nii$')]);
copyfile(w01_DMPFC(1,:), target_ExecuContr_ROI_directory,'f');

%% copy result_6BN directory
result_6BN_directory = fullfile(work_dir, 'result_6BN');
target_result_6BN_directory = fullfile(new_work_dir, 'result_6BN');
copyfile(result_6BN_directory, target_result_6BN_directory,'f');
% override the aMPFC FC Zmap
target_DMN_Zmap_directory = fullfile(new_work_dir, 'result_6BN', 'DMN');
w01_aMPFC =  spm_select('FPList',new_work_dir,[strcat('^01_w01_aMPFC.*\.nii$')]);
copyfile(w01_aMPFC(1,:), target_DMN_Zmap_directory,'f');
% override the DMPFC FC Zmap
target_ExecuContr_Zmap_directory = fullfile(new_work_dir, 'result_6BN', 'ExecuContr');
w01_DMPFC =  spm_select('FPList',new_work_dir,[strcat('^01_w01_DMPFC.*\.nii$')]);
copyfile(w01_DMPFC(1,:), target_ExecuContr_Zmap_directory,'f');

%% copy headmotion.txt
target_headmotion_directory = new_work_dir;
headmotion_file =  spm_select('FPList',work_dir,'^rp.*\.txt$');
copyfile(headmotion_file(1,:), target_headmotion_directory,'f');

%% copy afni directory
afni_directory = fullfile(work_dir, 'afni');
target_afni_directory = fullfile(new_work_dir, 'afni');
copyfile(afni_directory, target_afni_directory,'f');

%% copy mean fMRI file
mean_fMRI =  spm_select('FPList',work_dir,[strcat('^mean.*\.nii$')]);
copyfile(mean_fMRI(1,:), new_work_dir,'f');

%% copy tSNR directory
tSNR_directory = fullfile(work_dir, 'tSNR');
target_tSNR_directory = fullfile(new_work_dir, 'tSNR');
copyfile(tSNR_directory,target_tSNR_directory, 'f');


%% re-compuate
[patient_directory] = fullfile(target_dir3, sprintf('%s_individual', subject_no));
[parent_dir, patient_name] = fileparts(patient_directory);

% write filelist to be processed
directory = parent_dir;
filelist=sprintf('%s.txt', patient_name);
patient_filelist = fullfile(directory, filelist);
t_fid=fopen(patient_filelist,'w');
fprintf(t_fid, '%s\r\n', patient_name);
fclose(t_fid);

% read previous log file
log_file = spm_select('FPList',target_dir2,[strcat('^log.*\.txt$')]);
log_file_fid = fopen(log_file(1,:),'r');
log_file_cell = textscan(log_file_fid, '%s','delimiter',newline);
log_file_cell2 = log_file_cell{1};
patient_etiology_str = log_file_cell2{3};
k = strfind(patient_etiology_str,':');
patient_etiology = patient_etiology_str(k+1:end);
patient_incidence_age_str = log_file_cell2{4};
k = strfind(patient_incidence_age_str,':');
patient_incidence_age = str2double(patient_incidence_age_str(k+1:end));
patient_duration_of_DOC_str =log_file_cell2{5};
k = strfind(patient_duration_of_DOC_str,':');
patient_duration_of_DOC = str2double(patient_duration_of_DOC_str(k+1:end));
fclose(log_file_fid);

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

%%
fprintf('prognosication_with_individual_ROI\n');

%% Spm8 preprocessing batch
subject_list_file = patient_filelist;
%f_spm8batch_BB_EPI2fMRI_SC(subject_list_file);
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
fprintf(log_fid, '\t image_score:%4.2f\r\n', label_probability(3));
fprintf(log_fid, '\t clinical_score:%4.2f\r\n', label_probability(4));

% close log fid
fclose(log_fid);

%% delete patient_file
fclose('all');
delete(patient_filelist);
delete(clinical_characteristics_path);

fprintf('Calculation for individual_ROI is over!\n');



