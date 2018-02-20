function [] = f_data_quality_evaluation(subject_list_file)

% fMRI quality evaluation for DOC data. It includes two parts:
% (1) head motion
% (2) tSNR
% msong@nlpr.ia.ac.cn

[directory, subject_name] = fileparts(subject_list_file);
subject_directory = fullfile(directory, subject_name);


%% (1) head motion

[headmotion, T_FD] = f_head_motion_evaluation(subject_list_file);

for j =4:6
    headmotion(:,j) = headmotion(:,j).*50;
end

T = size(headmotion,1);

fig=figure('Name',strcat(subject_name,'_headmotion_curve'));
set(fig,'units','centimeters','position',[3 3 30 20],'color','w');


titles = {...
    'x\_translation';
    'y\_translation';
    'z\_translation';
    'x\_rotation';
    'y\_rotation';
    'z\_rotation';
    };
colors = {...
    'r';...
    'k';...
    'b';...
    'm';...
    'g';...
    'c'};
subplot(3,1,1);grid; hold on;
title(strcat( subject_name,' : head motion'));

xlim([1 T+1]);
for i = 1:6
    plot([1:T],headmotion(:,i),char(colors{i}),  'LineWidth', 3);
end
legend(char(titles),'Location','EastOutside'); hold off;

subplot(3,1,2); axis off; xlim([0 1]);
ratio_T = T_FD./T*100;
text(0,0.5, sprintf('effective T = %d; %4.2f%% of the raw fMRI volumes', T_FD, ratio_T),'FontSize',18);


%% (2) tSNR
program_location = which('pDOC');
[program_dir] = fileparts(program_location);
network_name = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));
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

EPI_directory = fullfile(fMRI_directory,'EPI');
ROI_dir = fullfile(EPI_directory, 'brain_ROI_DOC');                       %   the path of the ROI file

tSNR_dir = fullfile(fMRI_directory, 'tSNR');

subplot(3,1,3); hold on; grid;
if(~exist(tSNR_dir, 'dir'))  % not exist

    %%  EPI-ROI directory
    brain_mask_directory = fullfile(fMRI_directory, 'EPI');
    brain_mask_file = fullfile(brain_mask_directory, 'wmaskEPI_V2mm_float32.nii');
    if(~exist(brain_mask_file, 'file'))
        error('Brain mask not exist.');
    end
    
    f = spm_select('FPList', fMRI_directory,  '^bb.*\.nii$') ;
    if(size(f,1)==0)
        f = spm_select('FPList', fMRI_directory,  sprintf('^%s.*\\.nii$', upper(subject_name))) ;
    end
    
    [tSNR_image] = msong_tSNR_image(f, brain_mask_file);
    
end


% tSNR have been calculated
tSNR_image_filepath = spm_select('FPList',tSNR_dir,[strcat( '^tSNR.*\.nii$')]);
total_n_ROI_file = 0;
ROI_name_all = {};
for i=1: numel(network_name)
    %fprintf('\n%d_%s ...\n', i, char(network_name{i}));
    
    %% ROI
    ROI_file = [];
    temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '^w.*\.nii$')]);
    ROI_file = strvcat(ROI_file,temp);
    n_ROI_file = size(ROI_file, 1);
    
    %%
    [tSNR_ROI] = f_ExtractMultipleROISingal_4D(ROI_file, tSNR_image_filepath);
    M{i} = tSNR_ROI;
    
    %% sort and write to the result file
    for j = 1: n_ROI_file
        [ROI_dir2, ROI_filename] = fileparts(strtrim(ROI_file(j,:)));
        parts = msong_strsplit('_', ROI_filename);
        ROI_filename2 = char(parts{2});
        ROI_name_all{total_n_ROI_file + j } = ROI_filename2;
    end
    
    N(total_n_ROI_file+1 : total_n_ROI_file+n_ROI_file) = i;
    total_n_ROI_file = total_n_ROI_file + n_ROI_file;
end

G = cell(total_n_ROI_file,1);
M2 = zeros(total_n_ROI_file,1);
index_ROI = 0;
for i=1: numel(M)
    temp = M{i};
    for j =1: numel(temp)
        M2(index_ROI+j) = temp(j);
        G{index_ROI+j} = network_name{i};
    end
    index_ROI =index_ROI +j;
    
end

%figure('Name',strcat(subject_name,'_scatter'),'NumberTitle','off');
gscatter(N,M2,N);  hold on;
xlabel('');
ylabel('tSNR');
title(strcat( subject_name,' : tSNR'));
set(gca,'Xtick',1:numel(network_name),'XTickLabel', network_name);


legend(gca,'off');
hold on;
% print the maximum and minmum ROI
for i=1: numel(M)
    temp = M{i};
    %temp = msong_z2r(temp);
    ROI_index = find(N==i);
    %max
    [ma, ma_index] = max(temp);
    show_ROI_name = char(ROI_name_all(ROI_index(ma_index)));
    show_ROI_name2 = strrep(show_ROI_name, '_','\_');
    text(i+0.05, ma, show_ROI_name2 );
    %min
    [mi, mi_index] = min(temp);
    show_ROI_name = char(ROI_name_all(ROI_index(mi_index)));
    show_ROI_name2 = strrep(show_ROI_name, '_','\_');
    text(i+0.05, mi, show_ROI_name2 );
    
end
hold off;

print(fig,'-djpeg',fullfile(result_dir,  'headMotion_tSNR'));


