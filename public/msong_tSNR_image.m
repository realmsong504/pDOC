function [tSNR_image] = msong_tSNR_image(f, mask_name)
%  f:   3D fMRI file array or a 4D file
% mask_name: brain_mask_file

mask_hdr = spm_vol(mask_name);
file_img = spm_read_vols(mask_hdr);
mask_brain = file_img;
mask_brain = mask_brain>0;

n_fMRI = size(f,1);

if(n_fMRI==1)
    % 4D file
    fMRI_file_hdr = spm_vol(fMRI_4D_file);
    TC_total = spm_read_vols(fMRI_file_hdr);
    volumesize = fMRI_file_hdr(1,1).dim;
    T  = size(fMRI_file_img,4);
else
    % 3D file array
    T = n_fMRI;
    fMRI_1_hdr = spm_vol(f(1,:));
    %fMRI_1_img = spm_read_vols(fMRI_1_hdr);
    volumesize = fMRI_1_hdr.dim;
    
    TC_total=zeros(volumesize(1),volumesize(2),volumesize(3),T);
    
    for t=1:T
        filename=f(t,:);
        file_hdr = spm_vol(filename);
        file_img = spm_read_vols(file_hdr);
        Outdata = file_img;
        %[Outdata,VoxDim] = f_ReadImgFile(filename);
        TC_total(:,:,:,t)=Outdata;
    end
    
    clear Outdata;
end

if size(mask_brain) ~= volumesize
    error('the wrong size of mask file');
end


%% compute the correlation coefficients between the ROI's time course and
% other voxels in the whole brain
tSNR_image=zeros(volumesize(1),volumesize(2),volumesize(3));




% % out of the brain
% index_out_of_brain = find(mask_brain==0);
% z = ceil( index_out_of_brain / volumesize(1) / volumesize(2) );
% y = ceil( (index_out_of_brain - (z-1) * volumesize(1) * volumesize(2) ) / volumesize(1) );
% x = index_out_of_brain - (z-1) * volumesize(1) * volumesize(2)  - (y-1)*volumesize(1);
% sigma_i = [];
% for i = 1: numel(index_out_of_brain)
%     timecourse = squeeze(TC_total(x(i),y(i),z(i),:));
%     sigma_i(i) = std(timecourse);
% end
% sigma_i = unique(sigma_i);
% sigma_N = median(sigma_i);

% within the brain
index = find(mask_brain);
z = ceil( index / volumesize(1) / volumesize(2) );
y = ceil( (index - (z-1) * volumesize(1) * volumesize(2) ) / volumesize(1) );
x = index - (z-1) * volumesize(1) * volumesize(2)  - (y-1)*volumesize(1);
% compute tSNR for each voxel within the brain
for i = 1: numel(index)
    timecourse = squeeze(TC_total(x(i),y(i),z(i),:));
    
    mean_S = mean(timecourse);
    sigma_N = std(timecourse);
    
    SNR = mean_S/sigma_N;
  
    tSNR_image( index(i) )=SNR;
    
end
clear TC_total;

% save tSNR
[fMRI_dir, subject_file] = fileparts(f(1,:));

rst_dir = fullfile(fMRI_dir, 'tSNR');
if(~exist(rst_dir,'dir'))
    mkdir(rst_dir);
end

result_filename = sprintf('tSNR.nii');
tSNR_hdr = mask_hdr;
tSNR_hdr.fname = fullfile(rst_dir, result_filename);
tSNR_hdr.dt = [16 0]; % datatype: float32
spm_write_vol(tSNR_hdr, tSNR_image);



