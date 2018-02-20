function [label_probabiltiy]=f_prognostication_to_newSample(subject_list_file)

%% predict a outcome for a patient
%  subject_list_file : a full path of a text file that lists the subjects
% msong@nlpr.ia.ac.cn

%%
new_sample_filelist_str = subject_list_file;
all_test_subject_name = importdata(new_sample_filelist_str);
new_sample_directory = fileparts(new_sample_filelist_str);

method_type = 'PearsonCorr_absT10';
zscore_flag = 1;

program_location = which('pDOC');
[program_dir] = fileparts(program_location);

ROI_feature_filepath = fullfile(program_dir, 'model', 'ROI_feature_name.txt');
[ROI_feature_name] = msong_load_ROI_feature_name(ROI_feature_filepath);
FC_feature_filepath = fullfile(program_dir, 'model', 'FC_feature_name.txt');
[FC_regions_name] = msong_load_FC_feature_name(FC_feature_filepath);

network_filepath = fullfile(program_dir, 'EPI','network_name.txt');
all_network_name = msong_load_network_name(network_filepath);


%% Training model:
fprintf('load training sample...\n');

training_data_file = fullfile(program_dir, 'model', 'training_data.mat');
load(training_data_file);
overlay_matrix_temp  = X_HDX;
y = HDX_T1_3;
GOS = f_regulate_GOS(GOS_pro2);


%%  PLS predict T0 with BN \ disease  \ age \ duration
if(zscore_flag)
    [X, mean_X_750, std_X_750]= zscore(overlay_matrix_temp);
else
    X = overlay_matrix_temp;
end
%% Key POINT:   T1
%y = crs_total_score_T1_3;

ncomp = min(size(X,1)-1,size(X,2));
yfit_all = zeros(ncomp+1, size(X, 1));
yfit_all(1,:) = y';
res2 = zeros(ncomp, 1);
beta2 = zeros(ncomp, size(X,2)+1);

for i = 1: ncomp
    [XL,yl,XS,YS,beta,PCTVAR] = plsregress(X,y,i );
    yfit = [ones(size(X,1),1) X]*beta;
    yfit_all(i+1, :) = yfit';
    residuals = y - yfit;
    res2(i) = residuals'*residuals;
    beta2(i,:) = beta';
    %     figure('Name', sprintf('T0 component = %d', i));
    %     stem(residuals)
    %     xlabel('Observation');
    %     ylabel('Residual');
end

ncomp2 = 3;

[XL,yl,XS,YS,beta,PCTVAR] = plsregress(X,y,ncomp2 );

[imaging_feature_name]= msong_print_variable_name(ROI_feature_name, FC_regions_name);
variable_name = imaging_feature_name;
variable_name{size(imaging_feature_name,2)+1} = 'Incidence_age';
variable_name{size(imaging_feature_name,2)+2} = 'Duration_of_DOC';
variable_name{size(imaging_feature_name,2)+3} = 'Etiology_trauma';
variable_name{size(imaging_feature_name,2)+4} = 'Etiology_anoxia';

n_permutation = 1000;
p = msong_PLS_PermutationTest(X, y, yfit_all(ncomp2+1,:)', n_permutation);

%% use the model from 750 to NEW SAMPLE to predict prognosis
%
fprintf('load NEW sample...\n');

subject_directory = fullfile(new_sample_directory,  deblank(char(all_test_subject_name{1})));
clinical_characteristics_path = fullfile(subject_directory, 'clinical_characteristics.txt');

[MCS_test_network] = msong_load_ROI_result(new_sample_filelist_str, all_network_name, method_type);
[MCS_test_FC] = msong_load_FC_result(new_sample_filelist_str, FC_regions_name, method_type);

index = 0;
MCS_test_feature_ratios = [];
for i = 1: numel(ROI_feature_name)
    parts = msong_strsplit( '\', char(ROI_feature_name{i}));
    network_name = char(parts{1});
    ROI_name  = char(parts{2});
    index = index +1;
    
    % MCS
    for j = 1: numel(MCS_test_network)
        temp_name = char(MCS_test_network{j}.name);
        if(strcmp(temp_name, network_name))
            break;
        end
    end
    if(j>numel(MCS_test_network))
        error('network name error.');
    end
    BN_ROI_name = MCS_test_network{j}.ROI_name;
    MCS_overlay_ratio_matrix = MCS_test_network{j}.overlay_ratio_matrix;
    MCS_test_subject_list = MCS_test_network{j}.subject_name;
    
    for t = 1: size(BN_ROI_name,2)
        temp_name = char(BN_ROI_name{1,t});
        if(strcmp(temp_name,ROI_name))
            break;
        end
    end
    if(t>numel(BN_ROI_name))
        error('ROI name error.');
    end
    MCS_test_feature_ratios(:,index) = MCS_overlay_ratio_matrix(:,t);
end


n_MCS_test = size(MCS_test_feature_ratios, 1);

all_test_overlay_matrix = MCS_test_feature_ratios;
% FC 
FC_feature_test = MCS_test_FC.FC_matrix;
% total feature = ROI + FC
fMRI_features_HDX = cat(2, all_test_overlay_matrix, FC_feature_test);


n_test_subject = size(fMRI_features_HDX, 1);


[age, duration, etiology] = f_read_clinical_characteristics(clinical_characteristics_path);
HDX_disease_age_3 = age;
HDX_disease_duration_3 = duration;
HDX_disease_cause_3_raw = etiology;
if(max(HDX_disease_cause_3_raw(:))<1)
    HDX_disease_cause_3_3group = zeros(size(HDX_disease_cause_3_raw));
    HDX_disease_cause_3_1 = HDX_disease_cause_3_3group;
    HDX_disease_cause_3_2 = HDX_disease_cause_3_3group;
else
    HDX_disease_cause_3_3group = dummyvar(HDX_disease_cause_3_raw);
    HDX_disease_cause_3_1 = HDX_disease_cause_3_3group(:,[1]) ;
    if(size(HDX_disease_cause_3_3group,2)>2)
        HDX_disease_cause_3_2 = HDX_disease_cause_3_3group(:,[3]) ;
    else
        HDX_disease_cause_3_2 = zeros(size(HDX_disease_cause_3_1));
    end
end

%% predict
X_HDX =  cat(2, fMRI_features_HDX, ...
    HDX_disease_age_3, HDX_disease_duration_3,...
    HDX_disease_cause_3_1, HDX_disease_cause_3_2...
    );

if(zscore_flag)
    X_HDX2 = (X_HDX - repmat( mean_X_750, [size(X_HDX,1) 1]))./repmat(std_X_750, [size(X_HDX,1) 1]);
else
    X_HDX2 = X_HDX;
end

patient_feature = X_HDX;

yfit_HDX = [ones(size(X_HDX2,1),1) X_HDX2]*beta;

%% print patient's raw features and  NC 
NC_feature_file = fullfile(program_dir, 'model', 'NC_imaging_feature.mat');
load(NC_feature_file);
X_NC_750 = X_750;
X_NC_HDX  = X_HDX;

f_show_patient_features(subject_list_file, patient_feature, X_NC_750,variable_name);

%%  calculate the possibility
[label_probabiltiy] = f_calculate_label_probability(subject_list_file, yfit_HDX, yfit_all(ncomp2+1,:)', GOS, 2);


