function [cor_R, cor_Z, cor_P] = f_multiple_ROIconnectivity(ROI_file, func_dir, func_name, mask_name, volumesize, T, datatype)

%warning off MATLAB:divideByZero

mask_brain = f_ReadImgFile(mask_name);
if size(mask_brain) ~= volumesize
    error('the wrong size of mask file');
end

n_ROI = numel(ROI_file);
fprintf('there are %d ROIs\n', n_ROI);

cor_R=zeros(n_ROI);
cor_Z=zeros(n_ROI);
cor_P=zeros(n_ROI);

%-----------------------------------------------------------------------
% read the time courses of the whole brain and save them as a 4D matrix
if strcmp(func_name(end-4:end),'.BRIK')
    [TC_total] = readBRIKfile(func_name,volumesize,T,datatype);
else
    TC_total=zeros(volumesize(1),volumesize(2),volumesize(3),T);
    funcfile=dir(func_name);
    if size(funcfile,1)==T
        for t=1:T
            filename=strcat(func_dir,'\',funcfile(t).name);
            Outdata = f_ReadImgFile(filename);
            TC_total(:,:,:,t)=Outdata;
        end
    else
        error('the wrong number of functional files');
    end
    clear Outdata;
end


for i= 1: n_ROI-1
    % read the ROI file
    ROI_file_1 = ROI_file{i};
    ROI_data_1 = f_ReadImgFile(ROI_file_1);
    ROI_data_1 = ROI_data_1 .* mask_brain;
    ROI_1=find_voxel(ROI_data_1);
    % 'number of voxels in ROI_1
    N_ROI_1=size(ROI_1,1);
    if N_ROI_1 == 0
        error('number of voxels in ROI = 0');
    end
    %    fprintf('\nnumber of voxels in ROI_1 = %d',N_ROI_1);

    % compute the mean time courses of ROI
    TC_ROI_1=zeros(T,1);
    for k=1:N_ROI_1
        TC_ROI_1=TC_ROI_1+squeeze(TC_total(ROI_1(k,1),ROI_1(k,2),ROI_1(k,3),:));
    end
    TC_ROI_1=TC_ROI_1/N_ROI_1;

    for j= i+1 : n_ROI
        % read the ROI file
        ROI_file_2 = ROI_file{j};
        ROI_data_2 = f_ReadImgFile(ROI_file_2);
        ROI_data_2 = ROI_data_2 .* mask_brain;
        ROI_2=find_voxel(ROI_data_2);
        % 'number of voxels in ROI_1
        N_ROI_2=size(ROI_2,1);
        if N_ROI_2 == 0
            error('number of voxels in ROI = 0');
        end
        %        fprintf('\nnumber of voxels in ROI_2 = %d',N_ROI_2);

        % compute the mean time courses of ROI
        TC_ROI_2=zeros(T,1);
        for k=1:N_ROI_2
            TC_ROI_2=TC_ROI_2+squeeze(TC_total(ROI_2(k,1),ROI_2(k,2),ROI_2(k,3),:));
        end
        TC_ROI_2=TC_ROI_2/N_ROI_2;

        [R,P]=corrcoef(TC_ROI_1,TC_ROI_2);
        r=R(1,2);
        cor_R(i,j)=r;
        p=P(1,2);
        cor_P(i,j)=p;
        Z=0.5*log((1+r)/(1-r));   % Fisher's Z transformation
        cor_Z(i,j)=Z;
    end
end

cor_R = cor_R + cor_R' + eye(n_ROI);
cor_Z = cor_Z + cor_Z' + eye(n_ROI);
cor_P = cor_P + cor_P' + eye(n_ROI);
