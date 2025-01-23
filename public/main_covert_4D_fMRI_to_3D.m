clear;
clc;

% total_directory = 'Z:\Vision_training_JS\MRI970_2_20241209_weihai\SUB011_jixiang';
% subject_directory_list = dir(total_directory);
% subject_directory_list{1} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\006-007_20230812_fmri_data_xuxiangyun_liqiuyu\analysis\liqiuyue';
% subject_directory_list{2} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\008-009_20230917_fmri_data_liujingjing_songwenxuan\analysis\wangjingjing';
% subject_directory_list{3} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\008-009_20230917_fmri_data_liujingjing_songwenxuan\analysis\songwenxuan';
% subject_directory_list{4} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\010-011_20231029_fmri_data_liangyuanyuan_zhanghongchang\analysis\zhanghongchang';
% subject_directory_list{5} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\010-011_20231029_fmri_data_liangyuanyuan_zhanghongchang\analysis\liangyuanyuan';
% subject_directory_list{6} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\012_20231119_fmri_data_lihongwei\analysis\lihongwei';
% subject_directory_list{7} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\013-014_20240107_zhangjunhui_wangqingming\analysis\zhangjunhui';
% subject_directory_list{8} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\013-014_20240107_zhangjunhui_wangqingming\analysis\wangqingming';
% subject_directory_list{9} = 'Z:\anesthesia_tiantan\raw_data\20230513-20240121_fmri_data\015-016_20240121_zhangyinguang_yinshuo\analysis\zhangyinguang';
subject_directory_list{1} = 'Z:\Vision_training_JS\MRI970_2_20241209_weihai\SUB011_jixiang\analysis';

for i_dir = 1: size(subject_directory_list,2)
    %subject_directory = 'D:\BaiduNetdiskDownload\tiantanmazui\mri_data\mri_data\004-005_20230722_fmri_data_yangtao_zhouyan\analysis\zhouyan';
%     subject_directory_name = subject_directory_list(i_dir).name;
%     subject_directory = fullfile(total_directory, subject_directory_name);
%     fprintf('%s\n', subject_directory);

    subject_directory = subject_directory_list{i_dir};
    fprintf('%s\n', subject_directory);
    
    [BOLD_directory] = msong_select_subdirectory('subdir', subject_directory,  '^j.*');
    n_BOLD_directory = size(BOLD_directory, 1);
    if(n_BOLD_directory <1)
        error('%s,No BOLD directory',subject_directory);
    end
    
    for i = 1: n_BOLD_directory
        
        %%
        fMRI_4D_file_directory = strtrim(BOLD_directory(i,:));
        %fprintf('%s\n', fMRI_4D_file_directory);
        %fMRI_4D_file = 'ma_bo_ep2d_bold_rest_1-2_22.nii';
        fMRI_4D_file = spm_select('FPList', fMRI_4D_file_directory,  '.*\.nii$');
        %fMRI_4D_file = fMRI_4D_file(1,:);
        if(size(fMRI_4D_file, 1)<1)
            warning('%d:%s,No 4D nii file',i,fMRI_4D_file_directory);
            continue;
        end
        
        %%
        target_dir = fMRI_4D_file_directory; %'E:\MRI_970\fMRI\sub020\fMRI';
        [~,prefix] = fileparts(fMRI_4D_file_directory);%'03_ep2d_bold_rest_1-2';
        
        fMRI_4D_file_path = fMRI_4D_file;
        target_dir_path = fullfile(target_dir, 'fMRI');
        if(~exist(target_dir_path, 'dir'))
            mkdir( target_dir, 'fMRI');
        end
        [T]=f_4D_to_3D(fMRI_4D_file_path, target_dir_path, prefix);
        fprintf('\t%d:%s\n',i, fMRI_4D_file_path);
    end
end

fprintf('finished.\n');
