

fMRI_4D_file = 'E:\MRI_970\fMRI\sub020\4D_fMRI\SER00003_epi_bold_tra_64_20231105161621_301.nii';
target_dir = 'E:\MRI_970\fMRI\sub020\fMRI';
prefix = 'JX_970_';

[T]=f_4D_to_3D(fMRI_4D_file, target_dir, prefix);
fprintf('finished.\n');