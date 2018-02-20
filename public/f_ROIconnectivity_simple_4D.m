function [cor_Z, cor_R, cor_P, TC_ROI,  N_ROI] = f_ROIconnectivity_simple_4D(fMRI_4D_file, ROI_file,  mask_file)

% the mask
file_hdr = spm_vol(mask_file);
file_img = spm_read_vols(file_hdr);
mask_brain = file_img;
mask_brain = mask_brain>0;

% fMRI_4D
%fprintf('\nreading 4D fMRI file...\n');
fMRI_file_hdr = spm_vol(fMRI_4D_file);
fMRI_file_img = spm_read_vols(fMRI_file_hdr);
volumesize = fMRI_file_hdr(1,1).dim;
T  = size(fMRI_file_img,4);

if size(mask_brain) ~= volumesize
    error('the wrong size of mask file');
end

% read the ROI file
ROI_hdr = spm_vol(ROI_file);
ROI_img = spm_read_vols(ROI_hdr);


ROI_img = ROI_img .* mask_brain;
ROI = find_voxel(ROI_img);
% 'number of voxels in ROI'
N_ROI=size(ROI,1);

if N_ROI == 0
    error('number of voxels in ROI = 0');
else
    fprintf('\tnumber of voxels in ROI = %d\n', N_ROI);
end
%fprintf('\tnumber of voxels in ROI = %d\n',N_ROI);


% compute the mean time courses of ROI
TC_ROI=zeros(T,1);
for k=1:size(ROI,1)
    TC_ROI=TC_ROI+squeeze(fMRI_file_img(ROI(k,1),ROI(k,2),ROI(k,3),:));
end
TC_ROI=TC_ROI/N_ROI;

% compute the tSNR for the ROI
timecourse = TC_ROI;
mean_S = mean(timecourse);
sigma_N = std(timecourse);
SNR = mean_S/sigma_N;
%fprintf('\tfunctional connectivity: tSNR in ROI = %4.2f\n', SNR);


% compute the correlation coefficients between the ROI's time course and
% other voxels in the whole brain
cor_R=zeros(volumesize(1),volumesize(2),volumesize(3));
cor_Z=zeros(volumesize(1),volumesize(2),volumesize(3));
cor_P=zeros(volumesize(1),volumesize(2),volumesize(3));

%fprintf('\tcomputing correlation...\n');

index = find(mask_brain);
z = ceil( index / volumesize(1) / volumesize(2) );
y = ceil( (index - (z-1) * volumesize(1) * volumesize(2) ) / volumesize(1) );
x = index - (z-1) * volumesize(1) * volumesize(2)  - (y-1)*volumesize(1);
for i = 1: numel(index)
    timecourse = squeeze(fMRI_file_img(x(i),y(i),z(i),:));
    if(timecourse==mean(timecourse)*ones(size(timecourse)))
        R=[0 0;0 0];
        P=[1 1; 1 1];
    else
        [R,P]=corrcoef(TC_ROI,timecourse);
    end
    r=R(1,2);
    cor_R( index(i) ) = r;
    p=P(1,2);
    cor_P( index(i) ) = p;
    Z=0.5*log((1+r)/(1-r));   % Fisher's Z transformation
    cor_Z( index(i) )=Z;
end

