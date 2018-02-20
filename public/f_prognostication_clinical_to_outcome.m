function [label_probability] = f_prognostication_clinical_to_outcome(patient_etiology, patient_incidence_age, patient_duration_of_DOC)
% train PLS prognositication model
% msong@nlpr.ia.ac.cn

zscore_flag =1;

%% Training model:
%
%       USE ALL DOC patients to train the model
%
%% %%%%%%%%%%%%%%
fprintf('load training sample...\n');

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
training_data_file = fullfile(program_dir, 'model', 'training_data.mat');
load(training_data_file);
overlay_matrix_all  = X_HDX;   % imaging feature & clinical characteristics
y = HDX_T1_3;
GOS = f_regulate_GOS(GOS_pro2);


%%  PLS predict T0 only with  disease  \ age \ duration
overlay_matrix_temp = overlay_matrix_all(:, end-3:end) ;

if(zscore_flag)
    [X, mean_X_750, std_X_750]= zscore(overlay_matrix_temp);
else
    X = overlay_matrix_temp;
end

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
imaging_feature_name = {};
%variable_name = imaging_feature_name;
variable_name{size(imaging_feature_name,2)+1} = 'Incidence_age';
variable_name{size(imaging_feature_name,2)+2} = 'Duration_of_DOC';
variable_name{size(imaging_feature_name,2)+3} = 'Etiology_trauma';
variable_name{size(imaging_feature_name,2)+4} = 'Etiology_anoxia';

index_T1_awaken = GOS>=3;
index_awaken_subject = index_T1_awaken;
label_awaken_subject = zeros(numel(y),1);
label_awaken_subject(index_awaken_subject) = 1;

%% use the model from 750 to NEW SAMPLE to predict CRS T1
%-------------------------------------------------------------------------------------------------------------------------------------------

%% HDX disease cause
if(strcmpi(patient_etiology,'Trauma'))
    HDX_disease_cause_3_1 = 1;
    HDX_disease_cause_3_2 = 0;
elseif (strcmpi(patient_etiology,'Stroke'))
    HDX_disease_cause_3_1 = 0;
    HDX_disease_cause_3_2 = 0;
elseif (strcmpi(patient_etiology,'Anoxia'))
    HDX_disease_cause_3_1 = 0;
    HDX_disease_cause_3_2 = 1;
end


%% predict
X_HDX =  cat(2,  ...
    patient_incidence_age, patient_duration_of_DOC,...
    HDX_disease_cause_3_1, HDX_disease_cause_3_2...
    );

if(zscore_flag)
    X_HDX2 = (X_HDX - repmat( mean_X_750, [size(X_HDX,1) 1]))./repmat(std_X_750, [size(X_HDX,1) 1]);
else
    X_HDX2 = X_HDX;
end

yfit_HDX = [ones(size(X_HDX2,1),1) X_HDX2]*beta;

testing_score = yfit_HDX;
training_score = yfit_all(ncomp2+1, :)';
training_label = GOS;

[label_probability] = f_calculate_label_probability_clinical(testing_score, training_score, training_label);


fig6 = figure('Name', 'Prognositication with clinical characteristics only','NumberTitle','off','Tag','fig_results');
set(fig6,'units','centimeters','position',[3 3 25 10],'color','w');
hold on;

%%
subplot(1,2,1);  hold on;
title('Prognositication with clinical characteristics only');

width_section = 3;
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
awaken_count_array = zeros(n_section, 2);

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
b= isnan(awaken_ratio_array) ;
c=~b;
d =find(c,1,'last');

for i=d: numel(awaken_ratio_array)
    awaken_ratio_array(i) = 1;
end

tick_labels = msong_tick_labels(section);

hold on;
barh(awaken_ratio_array, 'FaceColor', [1 1 0.5] );%'y'
plot(awaken_ratio_array,[1: numel(awaken_ratio_array)], ':^r','LineWidth',2,'markerfacecolor','r');
set(gca, 'YTick',[1: numel(awaken_ratio_array)]);
set(gca, 'YTickLabel',tick_labels);
ylabel('Predicted Score');
xlabel('Consciousness Recovery Probability');
xlim([0, 1.1]);
my_ylim = ylim();
ylim(my_ylim);
dashline(ones(size([0:0.1:4]))*awaken_ratio_array(4),[0:0.1:4], 2,2,2,2, 'color',[.75 .75 .75]);
dashline(ones(size([0:0.1:5]))*awaken_ratio_array(5),[0:0.1:5], 2,2,2,2, 'color',[.75 .75 .75]);
dashline(ones(size([0:0.1:6]))*awaken_ratio_array(6),[0:0.1:6], 2,2,2,2, 'color',[.75 .75 .75]);
if(awaken_ratio_array(7)>0)
    dashline(ones(size([0:0.1:7]))*awaken_ratio_array(7),[0:0.1:7], 2,2,2,2, 'color',[.75 .75 .75]);
end
text(awaken_ratio_array(4)+0.015, 4-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(4)*100),'FontSize',8);
text(awaken_ratio_array(5)+0.015, 5-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(5)*100),'FontSize',8);
text(awaken_ratio_array(6)+0.015, 6-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(6)*100),'FontSize',8);
hold off;

subplot(1,2,2);  hold on;
axis off;
text(0,0.75,  sprintf('Patient'),'FontSize',12);
text(0.05,0.65,  sprintf('\tEtiology = %s', patient_etiology),'FontSize',10);
text(0.05,0.6,  sprintf('\tIncidence age = %4.1f years', patient_incidence_age),'FontSize',10);
text(0.05,0.55,  sprintf('\tDuration of unconsciousness = %4.1f months', patient_duration_of_DOC),'FontSize',10);

dashline([0:0.1:1],ones(size([0:0.1:1]))*(0.45), 1,1,1,1, 'color',[.75 .75 .75]);
index = find(section<=testing_score, 1, 'last');
index = index +1;
probabiltiy = awaken_ratio_array(index);
follow_up_result = 'Consciousness recovery probability';
fprintf('%s =%4.2f\n', follow_up_result, probabiltiy);
text(0,0.35,  sprintf('Predicted Result'),'FontSize',12);
text(0.05,0.25,  sprintf('\tPredicted score = %4.2f', testing_score),'FontSize',10);
text(0.05,0.2,  sprintf('\t%s = ', follow_up_result),'FontSize',10);
text(0.75,0.2,  sprintf('%4.2f',  probabiltiy),'FontSize',10,'color','red');
hold off;

