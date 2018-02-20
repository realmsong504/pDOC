function [] = f_DOC_prognosication_clinical(patient_etiology, patient_incidence_age, patient_duration_of_DOC)


tic;

%% progonosication
[label_probability] = f_prognostication_clinical_to_outcome(patient_etiology, patient_incidence_age, patient_duration_of_DOC);
fprintf('Predicted result\r\n');
fprintf('\t probability_of_consciousness_recovery:%4.2f\r\n', label_probability(2));

%% delete patient_file
fclose('all');

fprintf('Calculation is over!\n');

toc;


