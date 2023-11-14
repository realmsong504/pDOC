function [T]=f_4D_to_3D(fMRI_4D_file, target_dir, prefix,varargin)
%
%

if(~exist(fMRI_4D_file, 'file'))
    error('%s NOT exist.',fMRI_4D_file);
end

fMRI_file_hdr = spm_vol(fMRI_4D_file);
fMRI_file_img = spm_read_vols(fMRI_file_hdr);
T  = size(fMRI_file_img,4);
work_dir = target_dir;

for i=1:T
    i_hdr = fMRI_file_hdr(1,1);
    if(T<1000)
        i_hdr.fname = fullfile(work_dir,sprintf('%s_%03d.nii', prefix, i));
    elseif T<10000
        i_hdr.fname = fullfile(work_dir,sprintf('%s_%04d.nii', prefix, i));
    else
        i_hdr.fname = fullfile(work_dir,sprintf('%s_%05d.nii', prefix, i));
    end
    i_hdr.descrip='';
    i_map = squeeze(fMRI_file_img(:,:,:,i));
    spm_write_vol(i_hdr, i_map);
end