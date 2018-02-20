function [] = f_show_patient_features(subject_list_file, p_feature, NC_feature,variable_name)

% show imaging feature and clinical charactersitics for a DOC patient
% msong@nlpr.ia.ac.cn


brain_map_image = fullfile(pwd, 'model', 'brain_feature.jpg');

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


fig5 = figure('Name', 'Patient features','NumberTitle','off');
set(fig5,'units','centimeters','position',[3 3 30 10],'color','w');

%%
subplot(1,2,1);  hold on;
imshow(brain_map_image);
hold off;

subplot(1,2,2);  hold on;
axis off;
for i=1: size(variable_name,2)-4
    NC_min = min(NC_feature(:,i));
    NC_max = max(NC_feature(:,i));
    NC_mean = mean(NC_feature(:,i));
    NC_std = std(NC_feature(:,i));
    text(0,0.9-0.08*i,  sprintf('%s = %4.2f; \t Normal control: %4.2f¡À%4.2f', char(variable_name{i}), p_feature(i), NC_mean, NC_std), 'FontSize',10);
end

dashline([0:0.1:1],ones(size([0:0.1:1]))*(0.9-0.08*i - 0.04), 1,1,1,1, 'color',[.75 .75 .75]);

i = i+1;
parts = msong_strsplit('_',  char(variable_name{i}));
age = char(parts{2});
age(1) = 'A';
text(0,0.8-0.08*i,  sprintf('%s = %4.1f years',age, p_feature(i)),'FontSize',10);

i = i+1;
parts = msong_strsplit('_',  char(variable_name{i}));
duration = char(parts{1});
text(0,0.8-0.08*i,  sprintf('%s = %4.1f months', duration, p_feature(i)),'FontSize',10);

i=i+1;
if(p_feature(i)>0 && p_feature(i+1)==0)  % tauma
    etiology = 'Trauma';
elseif (p_feature(i)==0 && p_feature(i+1)==0)  % stroke
    etiology = 'Stroke';
else
    etiology = 'Anoxia';
end
text(0,0.8-0.08*i,  sprintf('Etiology = %s', etiology),'FontSize',10);
hold off;

print(fig5, '-djpeg',fullfile(result_dir,  'patient_features'));

