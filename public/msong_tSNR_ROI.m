function [tSNR_value] = msong_tSNR_ROI(f, ROI_file)
%  calcualte tSNR in a single ROI_file
%  f:   3D fMRI file array or a 4D file
%  ROI_file: ROI_file

ROI_hdr = spm_vol(ROI_file);
file_img = spm_read_vols(ROI_hdr);
ROI_brain = file_img;
ROI_brain = ROI_brain>0;

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

if size(ROI_brain) ~= volumesize
    error('the wrong size of ROI file');
end


%% compute the correlation coefficients between the ROI's time course and
% other voxels in the whole brain
tSNR_vector=zeros(numel(find(ROI_brain)),1);

% within the brain
index = find(ROI_brain);
z = ceil( index / volumesize(1) / volumesize(2) );
y = ceil( (index - (z-1) * volumesize(1) * volumesize(2) ) / volumesize(1) );
x = index - (z-1) * volumesize(1) * volumesize(2)  - (y-1)*volumesize(1);
% compute tSNR for each voxel within the brain
for i = 1: numel(index)
    timecourse = squeeze(TC_total(x(i),y(i),z(i),:));
    
    mean_S = mean(timecourse);
    sigma_N = std(timecourse);
    
    SNR = mean_S/sigma_N;
  
    tSNR_vector(i)=SNR;
    
end
clear TC_total;

tSNR_value = mean(tSNR_vector);

