function [] = f_6BN_calculation(subject_list_file)
%%  brain network computation
%--------------------------------------------------------------------------
% msong@nlpr.ia.ac.cn

%%
fprintf('Brain network calculation......\n');


%%
[directory filelist]= fileparts(subject_list_file);

output_parameter = 2;   % 1: individual network value without any show    2: individual network value with boxplot show
overlay_method = 'PearsonCorr_absT10';  % 'PearsonCorr'  ;

overlay_matrix = [];
radar_colors = [];
radar_labels =[];
discriminate_labels=[];

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
network_name = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));


%%  subject to compute
filelist_str=subject_list_file;
fid=fopen(filelist_str,'r');
index=0;


while 1
    
    tline = fgetl(fid);
    tline = deblank(tline);
    if ~ischar(tline), break, end
    index=index+1;
    subject_no = deblank(tline);
    pathstr = fullfile(directory, subject_no);
    
    fprintf('Processing %d %s\n',index, subject_no);
    subject_directory = fullfile(directory, subject_no);   
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
    
    result_directory = fullfile(fMRI_directory, 'result_6BN');
    EPI_directory = fullfile(fMRI_directory,'EPI');
    
    %% mask file
    f_mask = spm_select('FPList', EPI_directory,  '^maskEPI_V2mm_float32.*\.nii$') ;
    mask_file =  char(editfilenames(f_mask,'prefix','w'));
    mask_hdr = spm_vol(mask_file);
    mask_img = spm_read_vols(mask_hdr);
    mask_index = find(mask_img>0);
    
    %% result excel
    result_output_directory = fullfile(result_directory, '1_overlay_result');
    if(~exist(result_output_directory ,'dir'))
        mkdir(result_directory, '1_overlay_result');
    end
    output_path = fullfile(result_output_directory, strcat('overlay_result_', overlay_method, '.txt'));
    t_fid=fopen(output_path,'w');
    
    %%
    M = cell(numel(network_name),1);
    N = 0;
    ROI_name_all = {};
    BN_overlay2 = zeros(1,numel(network_name)); % for showing rador
    
    ROI_dir = fullfile(EPI_directory, 'brain_ROI_DOC');                       %   the path of the ROI file
    total_n_ROI_file =0;
    wBN_dir = fullfile(EPI_directory, 'brainnetwork_6');
    
    
    for i=1: numel(network_name)
        fprintf('\n%s_%s ...\n', tline, char(network_name{i}));
        fprintf(t_fid, '%s_%s\r\n', tline, char(network_name{i}));
        
        
        %% reference brainnetwork
        f_BN = spm_select('FPList', wBN_dir,  strcat('w', char(network_name{i}),'\.nii$'));
        f_BN_hdr = spm_vol(f_BN);
        f_BN_img = spm_read_vols(f_BN_hdr);
        
        %% ROI
        ROI_file = [];
        temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '^w.*\.nii$')]);
        ROI_file = strvcat(ROI_file,temp);
        n_ROI_file = size(ROI_file, 1);
        Zmap_directory = fullfile(result_directory, char(network_name{i}));
        
        %%
        [ mutual_info, ROI_name_cell] = msong_calculate_Zmap_brainnetwork_overlay(ROI_file, Zmap_directory,f_BN_img, mask_img, overlay_method);
        
        %% sort and write to the result file
        for j = 1: n_ROI_file
            ROI_name_all{total_n_ROI_file + j } = char(ROI_name_cell{j});
        end
        
        M{i} = mutual_info;
        N(total_n_ROI_file+1 : total_n_ROI_file+n_ROI_file) = i;
        total_n_ROI_file = total_n_ROI_file + n_ROI_file;
        [B, ROI_sort_index] = sort(mutual_info,'descend');
        for ii= 1: numel(ROI_sort_index)
            fprintf('%s \t', char(ROI_name_cell(ROI_sort_index(ii))));
            fprintf(t_fid, '%s \t', char(ROI_name_cell(ROI_sort_index(ii))));
        end
        fprintf('\n');
        fprintf(t_fid,'\r\n');
        for ii= 1: numel(ROI_sort_index)
            fprintf('%f \t', mutual_info(ROI_sort_index(ii)));
            fprintf(t_fid, '%f \t', mutual_info(ROI_sort_index(ii)));
        end
        fprintf('\n');
        fprintf(t_fid, '\r\n');
        
    end
    fclose(t_fid);
    
    
    %% extract ROI_signal
    subject_name= tline;
    subject_directory = fullfile(directory,  subject_name);
    fprintf(' ROI signal extracting :%s\n', subject_name);
   
    work_dir= strtrim(fMRI_directory);
    fMRI_4D_directory = fullfile(work_dir, 'afni');
    %%  funcional connectivity in individual space
    EPI_directory = fullfile(work_dir, 'EPI');
    ROI_dir = fullfile(EPI_directory, 'brain_ROI_DOC');                       %   the path of the ROI file
    
    ROI_file = [];
    for i=1: numel(network_name)
        temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '^w.*\.nii$')]);
        ROI_file = strvcat(ROI_file,temp);
    end
    n_ROI_file = size(ROI_file,1);
    fMRI_4D_path = fullfile(fMRI_4D_directory, strcat('BP_rhmw_', subject_name,'.nii'));
    [ROI_signal] = f_ExtractMultipleROISingal_4D(ROI_file, fMRI_4D_path);
    
    result_directory = fullfile(work_dir, 'ROI_signal');
    if(~exist(result_directory,'dir'))
        mkdir(result_directory);
    end
    result_mat = fullfile(result_directory, sprintf('%s_ROI%d.mat', subject_name,n_ROI_file));
    save(result_mat, 'ROI_signal');
    
    ROI_file_mat = fullfile(result_directory, sprintf('%s_ROI%d_filename.mat', subject_name,n_ROI_file));
    save(ROI_file_mat, 'ROI_file');
    
    %% show ROI overlay result
    if(output_parameter == 2)
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
        
        R = msong_z2r(M2);
        
        fig_scatter = figure('Name',strcat(subject_no,'_scatter_plots'),'NumberTitle','off');
        gscatter(N,R,N);  hold on;
        xlabel('');
        ylabel('Overlay ratio');
        ylim([-1 1]) ;
        
        t = title(strcat( subject_no,' : scatter plots for each brain network'));
        set(t,'Interpreter','none');
        
        set(gca,'Xtick',1:numel(network_name),'XTickLabel', network_name);
        dashline([0:0.1:numel(network_name)], ones(size([0:0.1:numel(network_name)]))*0, 1,1,1,1, 'color',[.75 .75 .75]);
        dashline([0:0.1:numel(network_name)], ones(size([0:0.1:numel(network_name)]))*0.2, 1,1,1,1, 'color',[.75 .75 .75]);
        dashline([0:0.1:numel(network_name)], ones(size([0:0.1:numel(network_name)]))*0.4, 1,1,1,1, 'color',[.75 .75 .75]);
        dashline([0:0.1:numel(network_name)], ones(size([0:0.1:numel(network_name)]))*0.6, 1,1,1,1, 'color',[.75 .75 .75]);
        dashline([0:0.1:numel(network_name)], ones(size([0:0.1:numel(network_name)]))*0.8, 1,1,1,1, 'color',[.75 .75 .75]);
        
        legend(gca,'off');
        hold on;
        % print the maximum and minmum ROI
        for i=1: numel(M)
            temp = M{i};
            temp = msong_z2r(temp);
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
            
            BN_overlay2(i) = ma;
        end
        hold off;
        
        print(fig_scatter , '-djpeg',fullfile(result_dir,  'ROI_template_overlay'));
        
    end
end

fclose(fid);

