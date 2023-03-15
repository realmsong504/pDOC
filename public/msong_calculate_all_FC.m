function [NC_FC] = msong_calculate_all_FC(subjectlist_path, overlay_method)
% NC_FC:  structure
% NC_FC.FC_matrix
% NC_FC.FC_name
% NC_FC.subject_name
if(nargin<2)
    overlay_method = 'PearsonCorr';
end

if(nargin<1)
    error('NO subjectlist');
end
network_name = {...
    'DMN'; ...
    'ExecuContr';...
    'Salience';...
    'Sensorimotor';...
    'Auditory'; ...
    'Visual';...
    };


[directory, NC_subject_no] = fileparts(subjectlist_path);

%%  NC
NC_FC.FC_matrix = [];
NC_FC.FC_name ={};
NC_FC.subject_name = {};

FC_matrix = [];
FC_name = {};

fprintf('reading FC: %s\n', NC_subject_no);
NC_fMRI_directory = [];
NC_subject_directory = subjectlist_path;

[BOLD_directory] = msong_select_subdirectory('subdir', NC_subject_directory,  '^BOLD.*');
[BOLD_directory2] = msong_select_subdirectory('subdir', NC_subject_directory,  '^fMRI.*');
[BOLD_directory3] = msong_select_subdirectory('subdir', NC_subject_directory,  '^fmri.*');

if(size(BOLD_directory, 1)>0)
    NC_fMRI_directory = deblank(BOLD_directory(1,:));
end
if(size(BOLD_directory2, 1)>0)
    NC_fMRI_directory = deblank(BOLD_directory2(1,:));
end
if(size(BOLD_directory3, 1)>0)
    NC_fMRI_directory = deblank(BOLD_directory3(1,:));
end

if(~exist(NC_fMRI_directory, 'dir'))
    fprintf('fMRI directory: %s does not exist. \n', NC_fMRI_directory)
    error('error');
end
work_dir= strtrim(NC_fMRI_directory);
result_directory = fullfile(work_dir, 'ROI_signal');
if(~exist(result_directory,'dir'))
    error('%s NOT exist.',result_directory);
end
result_mat = fullfile(result_directory, sprintf('%s_ROI22.mat', NC_subject_no));
if(~exist(result_mat, 'file'))
    result_mat = spm_select('FPList',result_directory,[strcat( '.*ROI22\.mat$')]);
end

S = load(result_mat, 'ROI_signal');
ROI_signal = S.ROI_signal;
[ROI_FC_matrix] = corrcoef(ROI_signal');

EPI_directory = fullfile(work_dir, 'EPI');
ROI_dir = fullfile(EPI_directory, 'brain_ROI_DOC');                       %   the path of the ROI file
ROI_file = [];
for i=1: numel(network_name)
    temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '^w.*\.nii$')]);
    if(numel(temp)==0)
        temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '.*\.nii$')]);
    end
    ROI_file = strvcat(ROI_file,temp);
end

index = 0;

for i = 1: size(ROI_file,1)-1
    
    for i2 = i+1: size(ROI_file, 1)
        index = index +1;
        
        %parts_1 = msong_strsplit( '\', char(ROI_file(i,:)));
        [ROI_dir, ROI_name_1] = fileparts(ROI_file(i,:));
        [temp, network_name_1] = fileparts(ROI_dir);
        %ROI_name_1  = char(ROI_file(i,:));
        
        %parts_2 = msong_strsplit( '\', char(ROI_file(j,:)));
        [ROI_dir, ROI_name_2]  = fileparts(ROI_file(i2,:));
        [temp,network_name_2] = fileparts(ROI_dir);
        
%         for j = 1: size(ROI_file,1)
%             [temp_path, ROI_filename] = fileparts(strtrim(ROI_file(j,:)));
%             [temp, network_name_1] = fileparts(temp_path);
%             a = strfind(ROI_filename, ROI_name_1);
%             if(numel(a)>0)
%                 break;
%             end
%         end
%         ROI_1 = j;
%         
%         for j = 1: size(ROI_file,1)
%             [temp_path, ROI_filename] = fileparts(strtrim(ROI_file(j,:)));
%             [temp,network_name_2] = fileparts(temp_path);
%             a = strfind(ROI_filename, ROI_name_2);
%             if(numel(a)>0)
%                 break;
%             end
%         end
%         ROI_2 = j;
        
%        ROI_FC = ROI_FC_matrix(ROI_1, ROI_2);
        ROI_FC = ROI_FC_matrix(i, i2);
        FC_matrix(index,1) = ROI_FC;
        FC_name{index,1} = strcat(network_name_1,'_', ROI_name_1(5:end), ':',network_name_2,'_', ROI_name_2(5:end));
    end
end
subject_name = NC_subject_no;


NC_FC.FC_matrix = FC_matrix;
NC_FC.FC_name =FC_name;
NC_FC.subject_name = subject_name;

