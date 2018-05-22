function [NC_network] = msong_load_ROI_result(subjectlist_path,network_name, overlay_method)
% NC_network:  structure
% network{j}.overlay_ratio_matrix
% network{j}.ROI_name
% network{j}.subject_name
if(nargin<3)
    overlay_method = 'PearsonCorr';
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
    directory = fileparts(subjectlist_path);
end


%%  NC

for j = 1: size(network_name, 1)
        network{j}.overlay_ratio_matrix = [];
        network{j}.ROI_name = {};
        network{j}.name = '';
        network{j}.subject_name = {};
end

overlay_matrix = [];
NC_fid=fopen(subjectlist_path,'r');
NC_index=0;
while 1
    NC_tline = fgetl(NC_fid);
    if ~ischar(NC_tline), break, end
    NC_index = NC_index+1;
    NC_subject_no = strtrim(NC_tline);
    
    %fprintf('Processing %d %s\n',NC_index, NC_subject_no);
    NC_fMRI_directory = [];
    NC_subject_directory = fullfile(directory, NC_subject_no);
    
    [BOLD_directory] = msong_select_subdirectory('subdir', NC_subject_directory,  '^BOLD.*');
    [BOLD_directory2] = msong_select_subdirectory('subdir', NC_subject_directory,  '^fMRI.*');
    if(size(BOLD_directory, 1)>0)
        NC_fMRI_directory = deblank(BOLD_directory(1,:));
    end
    if(size(BOLD_directory2, 1)>0)
        NC_fMRI_directory = deblank(BOLD_directory2(1,:));
    end
    
    if(~exist(NC_fMRI_directory, 'dir'))
        error(sprintf('%s fMRI directory: %s does not exist. \n', NC_subject_no, NC_fMRI_directory));
    end
    
    
    NC_result_directory = fullfile(NC_fMRI_directory, 'result_6BN');
    

    %% result excel
    NC_result_input_directory = fullfile(NC_result_directory, '1_overlay_result');
    NC_input_path = fullfile(NC_result_input_directory, strcat('overlay_result_',overlay_method,'.txt'));
    if(~exist(NC_input_path ,'file'))
        error('%s does NOT exist', NC_input_path);
    end
    NC_input_cell = importdata(NC_input_path, '\n', size(network_name, 1)*3);
    
    for i =1:3:size(network_name, 1)*3
        NC_subjectID_network = msong_strsplit('_', NC_input_cell{i});
        subject_name = char(NC_subjectID_network{1});
        NC_BN_network = char(NC_subjectID_network{end});
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
        
        for j = 1: size(network_name, 1)
            if(strcmp(network_name{j}, NC_BN_network))
                break;
            end
        end
        temp_overlay = network{j}.overlay_ratio_matrix;
        network{j}.overlay_ratio_matrix = cat(1, temp_overlay, temp4);
        temp_ROI_name = network{j}.ROI_name;
        network{j}.ROI_name = cat(1, temp_ROI_name, NC_BN_ROI2);
        network{j}.name = NC_BN_network;
        temp_subject_name = network{j}.subject_name;
        network{j}.subject_name = cat(1, temp_subject_name, subject_name);

    end

end
NC_network = network;
