function [ROI_signal] = f_ExtractMultipleROISingal_4D(ROI_file, fMRI_4D_path)

n_ROI = size(ROI_file,1 );
%fprintf('there are %d ROIs\n', n_ROI);

% 
if(~exist(fMRI_4D_path, 'file'))
    error('in reading 4D fMRI: %s NOT exist.', fMRI_4D_path);
end

fMRI_file_hdr = spm_vol(fMRI_4D_path);
fMRI_file_img = spm_read_vols(fMRI_file_hdr);
T  = size(fMRI_file_img,4);

ROI_signal = zeros(n_ROI, T);

for i= 1: n_ROI
    % read the ROI file
    ROI_file_1 = ROI_file(i,:);
    ROI_hdr_1 = spm_vol(ROI_file_1);
    ROI_img_1 = spm_read_vols(ROI_hdr_1);
    ROI_1 = find_voxel(ROI_img_1);
    N_ROI_1=size(ROI_1,1);
    if N_ROI_1 == 0
        error('number of voxels in %d ROI = 0', i);
    end
    
    % compute the mean time courses of ROI
    TC_ROI_1=zeros(T,1);
    for k=1:N_ROI_1
        TC_ROI_1=TC_ROI_1+squeeze(fMRI_file_img(ROI_1(k,1),ROI_1(k,2),ROI_1(k,3),:));
    end
    TC_ROI_1=TC_ROI_1/N_ROI_1;
    
    %
    ROI_signal(i,:) = TC_ROI_1';

end

