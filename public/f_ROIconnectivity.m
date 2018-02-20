function [cor_R, cor_Z, cor_P,TC_ROI, N_ROI] = f_ROIconnectivity(ROI_file, func_dir, func_name, mask_name, volumesize, T, datatype)

%warning off MATLAB:divideByZero

% the mask 
[mask_brain,VoxDim] = f_ReadImgFile(mask_name);
if size(mask_brain) ~= volumesize
    error('the wrong size of mask file');
end

% read the ROI file
[Outdata,VoxDim] = f_ReadImgFile(ROI_file);
Outdata = Outdata .* mask_brain;
ROI=[];
for i=1:size(Outdata,1)
    for j=1:size(Outdata,2)
        for k=1:size(Outdata,3)
            if abs(1-Outdata(i,j,k))< 1e-1
                ROI=[ROI;i j k];
            end
        end
    end
end
% 'number of voxels in ROI'
N_ROI=size(ROI,1);
if N_ROI == 0
    error('number of voxels in ROI = 0');
end
fprintf('\nnumber of voxels in ROI = %d',N_ROI);
clear Outdata;



%-----------------------------------------------------------------------
% read the time courses of the whole brain and save them as a 4D matrix
if func_name(end-4:end)=='.BRIK';
    [TC_total] = readBRIKfile(func_name,volumesize,T,datatype);
else
    fprintf('reading filename');
    TC_total=zeros(volumesize(1),volumesize(2),volumesize(3),T);
    funcfile=dir(func_name);
    if size(funcfile,1)==T
        for t=1:T
            filename=strcat(func_dir,'\',funcfile(t).name);
            [Outdata,VoxDim] = f_ReadImgFile(filename);
            TC_total(:,:,:,t)=Outdata;
        end
    else
        error('the wrong number of functional files');
    end
    clear Outdata;
end

%-----------------------------------------------------------------------
% dividing the 4D matrix into 3 parts cross x axes: 
% dealing with one part at once
TC=zeros(10,volumesize(2),volumesize(3),T);         %  *************************
TC=TC_total(1:10,:,:,:);
save TC1.mat TC;

TC=zeros(10,volumesize(2),volumesize(3),T);
TC=TC_total(11:20,:,:,:);
save TC2.mat TC;

TC=zeros(10,volumesize(2),volumesize(3),T);
TC=TC_total(21:30,:,:,:);
save TC3.mat TC;

TC=zeros(10,volumesize(2),volumesize(3),T);
TC=TC_total(31:40,:,:,:);
save TC4.mat TC;

TC=zeros(10,volumesize(2),volumesize(3),T);
TC=TC_total(41:50,:,:,:);
save TC5.mat TC;

TC=zeros(11,volumesize(2),volumesize(3),T);
TC=TC_total(51:61,:,:,:);
save TC6.mat TC;

clear TC;


% compute the mean time courses of ROI
TC_ROI=zeros(T,1);
for k=1:size(ROI,1)
    TC_ROI=TC_ROI+squeeze(TC_total(ROI(k,1),ROI(k,2),ROI(k,3),:));
end
clear TC_total;
TC_ROI=TC_ROI/size(ROI,1);

% compute the correlation coefficients between the ROI's time course and
% other voxels in the whole brain
cor_R=zeros(volumesize(1),volumesize(2),volumesize(3));
cor_Z=zeros(volumesize(1),volumesize(2),volumesize(3));
cor_P=zeros(volumesize(1),volumesize(2),volumesize(3));

x=0;
for n=1:6           % *****************************************
    filename=strcat('TC',num2str(n),'.mat');
    load(filename);
    for i=1:size(TC,1)
        x = x + 1;
        for j=1:size(TC,2)
            for k=1:size(TC,3)
                if mask_brain(x,j,k)>0.5
                    timecourse=squeeze(TC(i,j,k,:));
                    if(timecourse==mean(timecourse)*ones(size(timecourse)))
                        R=[0 0;0 0];
                        P=[1 1; 1 1];
                    else
                        [R,P]=corrcoef(TC_ROI,timecourse);
                        r=R(1,2);
                        cor_R(x,j,k)=r;
                        p=P(1,2);
                        cor_P(x,j,k)=p;
                        Z=0.5*log((1+r)/(1-r));   % Fisher's Z transformation
                        cor_Z(x,j,k)=Z;
                    end
                end
            end
        end
    end
    delete(filename);
end


            