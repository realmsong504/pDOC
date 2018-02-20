function [new_patient_directory] = f_regulate_patient_directory(patient_directory)
% obtain a full path of patient directory
% msong@nlpr.ia.ac.cn

if(strcmp(patient_directory(end), filesep))
    patient_directory = patient_directory(1:end-1);
end
new_patient_directory = patient_directory;

[patient_dir, patient_name] = fileparts(patient_directory);

if(strcmpi(patient_name, 'fMRI'))
    new_patient_directory = patient_dir;
end

if(strcmpi(patient_name, 'BOLD'))
    new_patient_directory = patient_dir;
end
