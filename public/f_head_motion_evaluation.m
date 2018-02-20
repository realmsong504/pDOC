function [headmotion, T] = f_head_motion_evaluation(subject_list_file)

%  head motion evaluation with scrubbing
% T  : number of volumes after scrubbing
% msong@nlpr.ia.ac.cn

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

work_dir = deblank(fMRI_directory);

headmotion_txt = spm_select('FPList', work_dir, '^rp.*\.txt$');
[headmotion] = readheadmotiontxt(headmotion_txt);

% after scrub
fMRI_4D_directory = fullfile(work_dir, 'afni');
if(~exist(fMRI_4D_directory,'dir'))
    error(fMRI_4D_directory, 'nonexist.');
end
fMRI_4D_file = spm_select('FPList', fMRI_4D_directory, strcat('^BP_rhmw_.*\.nii$'));
fMRI_file_hdr = spm_vol(fMRI_4D_file);
fMRI_file_img = spm_read_vols(fMRI_file_hdr);
volumesize = fMRI_file_hdr(1,1).dim;
T  = size(fMRI_file_img,4);


