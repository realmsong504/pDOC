function [overlay_matrix, subject_name] = msong_load_7BN_result(subjectlist_path,network_name, mode, result_suffix)

%  mode: 1, max overlay ratio, i.e., the first element;
%            2, mdian overlay ratio, i.e., the median element
%            3, mimimum overlay ratio, i.e., the last element
if(nargin<4)
    result_suffix = 'PearsonCorr';
end

if(nargin<3)
    mode = 1;
end


if(nargin<2)
    network_name = {...
    'DMN'; ...
    'ExecuContr';...
    'Salience';...
    'Sensorimotor';...
    'Auditory'; ...
    'Visual';...
    };  
end
if(~exist(subjectlist_path, 'file'))
    error('%s NOT exist',subjectlist_path);
else
    NC_directory = fileparts(subjectlist_path);
end

overlay_matrix = [];
subject_name = cell(1,1);
NC_fid=fopen(subjectlist_path,'r');
NC_index=0;
while 1
    NC_tline = fgetl(NC_fid);
    if ~ischar(NC_tline), break, end
    NC_index = NC_index+1;
    NC_subject_no = NC_tline;
    %fprintf('%d\n', NC_index);
    subject_name{NC_index} = NC_subject_no;
    NC_pathstr = fullfile(NC_directory, NC_tline);
    
    fprintf('Processing %d %s\n',NC_index, NC_subject_no);
    NC_subject_directory = fullfile(NC_directory, NC_subject_no);
    
    %NC_fMRI_directory = fullfile(NC_subject_directory,'fMRI_EPI2individual');
    
    [BOLD_directory] = msong_select_subdirectory('subdir', NC_subject_directory,  '^BOLD.*');
    [BOLD_directory2] = msong_select_subdirectory('subdir', NC_subject_directory,  '^fMRI.*');
    [BOLD_directory3] = msong_select_subdirectory('subdir', NC_subject_directory,  'fMRI_EPI2individual');
    if(size(BOLD_directory, 1)>0)
        NC_fMRI_directory = deblank(BOLD_directory(1,:));
    end
    if(size(BOLD_directory2, 1)>0)
        NC_fMRI_directory = deblank(BOLD_directory2(1,:));
    end
    if(size(BOLD_directory3, 1)>0)
        NC_fMRI_directory = deblank(BOLD_directory3(1,:));
    end    
    NC_fMRI_directory = deblank(NC_fMRI_directory);
    %sMRI_directory =  fullfile(directory,'3D_T1');
    if(~exist(NC_fMRI_directory, 'dir'))
        error(fprintf('fMRI directory: %s does not exist. \n', NC_fMRI_directory));
    end
    
    
    NC_result_directory = fullfile(NC_fMRI_directory, 'result_6BN');
    
    NC_BN_overlay = zeros(size(network_name, 1),1);
    NC_BN_network = cell( size(network_name, 1),1);
    %% result excel
    NC_result_input_directory = fullfile(NC_result_directory, '1_overlay_result');
    NC_input_path = fullfile(NC_result_input_directory, strcat('overlay_result_', result_suffix, '.txt'));
    if(~exist(NC_input_path ,'file'))
        error('%s does NOT exist', NC_input_path);
    end
    NC_input_cell = importdata(NC_input_path, '\n', size(network_name, 1)*3);
    
    for i =1:3:size(network_name, 1)*3
%        NC_subjectID_network = msong_strsplit('_', NC_input_cell{i});
%         NC_BN_network{(i+2)/3} = char(NC_subjectID_network{end});  % the maximum overlay ratio
%         temp = msong_strsplit(' ', NC_input_cell{i+2});

        NC_subjectID_network = msong_strsplit('_', NC_input_cell{i});
        %subject_name = char(NC_subjectID_network{1});
        %NC_BN_network = NC_subjectID_network{end};
        NC_BN_network{(i+2)/3} = char(NC_subjectID_network{end});
        NC_BN_ROI = msong_strsplit(' ', NC_input_cell{i+1});
        NC_BN_ROI = strtrim(NC_BN_ROI);
        [NC_BN_ROI2 ROI_index2]= sort(NC_BN_ROI);
        temp = msong_strsplit(' ', NC_input_cell{i+2});
        temp2 = temp(ROI_index2);
        temp4  = zeros(1, size(temp2,2));
        if(strcmp(NC_BN_ROI2{1},''))
            NC_BN_ROI3 = cell(1, size(NC_BN_ROI2,2)-1);
            temp3  = cell(1, size(NC_BN_ROI2,2)-1);
            temp4  = zeros(1, size(temp3,2));
            for j = 2: size(NC_BN_ROI2,2)
                NC_BN_ROI3(j-1) = cellstr(NC_BN_ROI2{j});
                temp3(j-1) = cellstr(temp2{j});
                temp4(j-1) = str2num(temp3{j-1});
            end
            NC_BN_ROI2 = NC_BN_ROI3;
        end

        switch mode
            case 1  % maximum 
                   NC_BN_overlay((i+2)/3) = max(temp4(:));  % the maximum overlay ratio
            case 2  %  median
                   NC_BN_overlay((i+2)/3) = median(temp4(:));  % the maximum overlay ratio
            case 3  % mimmum
                   NC_BN_overlay((i+2)/3) = min(temp4(:));  % the minimum overlay ratio
        end
    end
    [G_show, G_index] = msong_cell_sort(NC_BN_network, network_name);
    NC_BN_overlay2(G_index) = NC_BN_overlay;
    overlay_matrix = cat(1, overlay_matrix, NC_BN_overlay2);
end

