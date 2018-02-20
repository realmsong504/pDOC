function [TC_meanWholeB] = f_RemoveHeadMotion_Wholemean_2(func_dir,func_name,motionfile_name,mask_file,T)
% removing the head motion effect and constant term and linear drift by using multiple regression
% func_dir: the directory of the 3D functional files with the format of 'K:\MS\Normal\N012'
% func_name is the name of 3D functional files with the format of 'K:\MS\Normal\N012\swrafunc*.hdr'
% T is the number of the time points, i.e. the number of the 3D functional
% files


% read the head motion parameters
[HeadMotion] = readheadmotiontxt(motionfile_name);
%HeadMotion = HeadMotion(11:end,:);
if size(HeadMotion,1) ~= T
    error('wrong time points in head motion file');
end

mask_filename='000';

% read the mask brain
% [Mask,VoxDim] = f_ReadImgFile(mask_file); % the image region within the brain
% NumVoxel_Mask = sum(Mask(:));

% msong 2010-8-9:
mask_hdr = spm_vol(mask_file);
Mask = spm_read_vols(mask_hdr);
Mask = Mask>0;
dim = mask_hdr.dim;
NumVoxel_Mask = length(find(Mask(:)>0));


% read the time courses
funcfile = dir(func_name);

if size(funcfile,1) == T
    
    % read the 3D files and form a 4D matrix
    fprintf('read the 3D files and form a 4D matrix \n');
    TC_total = zeros(dim(1),dim(2),dim(3),T);
    TC_meanWholeB = [];
    for t = 1:T
        filename = fullfile(func_dir,funcfile(t).name);
        %[Outdata,VoxDim] = f_ReadImgFile(filename);
        filename_hdr = spm_vol(filename);
        filename_img = spm_read_vols(filename_hdr);
        Outdata = filename_img;
        TC_total(:,:,:,t)=Outdata;
        % computing the mean value in mask brain
        temp = Outdata.*Mask;
        TC_meanWholeB = [TC_meanWholeB; sum(temp(:))/NumVoxel_Mask];
        if abs(TC_meanWholeB) < 1E-8
            s = strcat('the mean of time point ', num2str(t), 'is zero');
            fprintf(s,'\n');
%             error(s);
        end
    end
    clear Outdata;
elseif funcfile(1).name(end-4:end) == '.BRIK'
    filename = funcfile(1).name;
    volumesize = [dim(1) dim(2) dim(3)];
    [TC_total] = readBRIKfile(filename,volumesize,T,'float32');
    TC_meanWholeB = [];
    for t = 1:T
        % computing the mean value in mask brain
        Outdata = TC_total(:,:,:,t);
        temp = Outdata.*Mask;
        TC_meanWholeB = [TC_meanWholeB; sum(temp(:))/NumVoxel_Mask]
        if abs(TC_meanWholeB) < 1E-8
            s = strcat('the mean of time point ', num2str(t), 'is zero');
            fprintf(s,'\n');
%             error(s);
        end
    end
    clear Outdata;
else
    error('wrong number of files');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% multiple regression
fprintf('multiple regression \n');
% X = [HeadMotion(:,1) HeadMotion(:,2) HeadMotion(:,3) HeadMotion(:,4) HeadMotion(:,5) HeadMotion(:,6)];
X = [ones(T,1) (1:T)' TC_meanWholeB HeadMotion(:,1) HeadMotion(:,2) HeadMotion(:,3) HeadMotion(:,4) HeadMotion(:,5) HeadMotion(:,6)];

% removing the constant, linear term, the mean of whole brain and head motion effect
for i = 1:size(TC_total,1)
    for j = 1:size(TC_total,2)
        for k = 1:size(TC_total,3)
            TC = squeeze(TC_total(i,j,k,:));
            if TC == zeros(T,1)
            else
                beta = X\TC;
                TC = TC - X*beta;
                TC_total(i,j,k,:) = TC;
            end
        end
    end
end

% rewrite the new 3D files
fprintf('rewrite the new 3D files \n');
if funcfile(1).name(end-4:end) == '.BRIK'
    temp = funcfile(1).name(end-24:end-10);
    for t = 1:T
        if t < 10
            newfilename =  strcat(func_dir,'\rhmw_',temp,'_00',num2str(t));
        elseif t < 100
            newfilename =  strcat(func_dir,'\rhmw_',temp,'_0',num2str(t));
        elseif t < 1000
            newfilename =  strcat(func_dir,'\rhmw_',temp,'_',num2str(t));
        end
        %f_WriteImgFile(TC_total(:,:,:,t),newfilename,[61 73 61],[3 3 3],'float32');
        newfile_hdr = mask_hdr;
        newfile_hdr.fname = newfilename;
        spm_write_vol(newfile_hdr, TC_total(:,:,:,t));

    end
else
    for t = 1:T
        temp_filename=funcfile(t).name;
        position=findstr('_',temp_filename);
        position=position(end);
        b_filename=temp_filename(1:position-1);
        ln_filename=length(temp_filename);
        temp=temp_filename(position+1:ln_filename-4);
        temp2=sprintf('%.3d',str2num(temp));
        newfilename = sprintf('%s\\rhmw_%s_%s.nii',func_dir,b_filename,temp2);
        %f_WriteImgFile(TC_total(:,:,:,t),newfilename,[61 73 61],[3 3 3],'float32');
        newfile_hdr = mask_hdr;
        newfile_hdr.fname = newfilename;
        spm_write_vol(newfile_hdr, TC_total(:,:,:,t));

    end
end

clear TC_total;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
