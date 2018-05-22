function [NC_FC] = msong_load_FC_result(subjectlist_path, FC_regions_name, overlay_method)
% NC_FC:  structure
% NC_FC.FC_matrix
% NC_FC.FC_name
% NC_FC.subject_name
if(nargin<3)
    overlay_method = 'PearsonCorr';
end

if(nargin<2)
    error('NO FC regions name');
end
network_name = {...
    'DMN'; ...
    'ExecuContr';...
    'Salience';...
    'Sensorimotor';...
    'Auditory'; ...
    'Visual';...
    };

if(~exist(subjectlist_path, 'file'))
    error('%s NOT exist',subjectlist_path);
else
    directory = fileparts(subjectlist_path);
end


%%  NC
NC_FC.FC_matrix = [];
NC_FC.FC_name ={};
NC_FC.subject_name = {};

FC_matrix = [];
NC_fid=fopen(subjectlist_path,'r');
NC_index=0;
FC_name = {};
while 1
    NC_tline = fgetl(NC_fid);
    if ~ischar(NC_tline), break, end
    NC_index = NC_index+1;
    NC_subject_no = strtrim(NC_tline);
    
    fprintf('Processing %d %s\n',NC_index, NC_subject_no);
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
    
    for i = 1: size(FC_regions_name,1)
        
        parts_1 = msong_strsplit( '\', char(FC_regions_name{i,1}));
        network_name_1 = char(parts_1{1});
        ROI_name_1  = char(parts_1{2});
        
        parts_2 = msong_strsplit( '\', char(FC_regions_name{i,2}));
        network_name_2 = char(parts_2{1});
        ROI_name_2  = char(parts_2{2});
        
        for j = 1: size(ROI_file,1)
            [temp_path, ROI_filename] = fileparts(strtrim(ROI_file(j,:)));
            a = strfind(ROI_filename, ROI_name_1);
            if(numel(a)>0)
                break;
            end
        end
        ROI_1 = j;
        
        for j = 1: size(ROI_file,1)
            [temp_path, ROI_filename] = fileparts(strtrim(ROI_file(j,:)));
            a = strfind(ROI_filename, ROI_name_2);
            if(numel(a)>0)
                break;
            end
        end
        ROI_2 = j;
        
        ROI_FC = ROI_FC_matrix(ROI_1, ROI_2);
        FC_matrix(NC_index, i) = ROI_FC;
        FC_name{1, i} = strcat(network_name_1,'.', ROI_name_1, '--',network_name_2,'.', ROI_name_2);
    end
    subject_name{NC_index,1} = NC_subject_no;
   
end

NC_FC.FC_matrix = FC_matrix;
NC_FC.FC_name =FC_name;
NC_FC.subject_name = subject_name;

