function [] = f_create_individual_aMPFC_ROI(work_dir, target_dir)
%% work_dir: Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI
%  target_dir: 'fMRI_2' or a new directory Z:\zhangxiuhong\analysis\
%clear;
%clc;

addpath('K:\work\2017_DOC_0_prognosis\pDOC\20230315\pDOC\public');

%work_dir = 'Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI';
if(nargin<2)
    target_dir2 = fileparts(work_dir); % TR2
    [target_dir2, subject_no] = fileparts(target_dir2); % analysis
    target_dir = fullfile(target_dir2, sprintf('%s_individual', subject_no),'fMRI');
end

if(~exist(target_dir, 'dir'))
    mkdir(target_dir);
else
    warning('%s exists.',target_dir);
end

work_dir_EPI = fullfile(work_dir,'EPI');

%% check if waMPFC exists in work_dir
waMPFC =  spm_select('FPList',[work_dir_EPI],[strcat('^waMPFC.*\.nii$')]);

if(~isempty(waMPFC))
    fprintf('waMPFC exists\n');
else
    fprintf('waMPFC NOT exists\n');
    jobs = {};
    f_EPI = spm_select('FPList', work_dir_EPI,  '^EPI.*\.nii$') ;
    f_aMPFC = spm_select('FPList', work_dir_EPI,  '^aMPFC_in_BN_atlas.*\.nii$');
    
    if(isempty(f_aMPFC))
        f_aMPFC = spm_select('FPList', pwd,  '^aMPFC_in_BN_atlas.*\.nii$');
        fprintf('copy aMPFC_in_BN_atlas.nii\n');
        copyfile(f_aMPFC(1,:), work_dir_EPI, 'f');
    end
    
    f_wEPI = spm_select('FPList', work_dir_EPI,  '^wEPI.*\.nii$') ;
    [BB, vx]= spm_get_bbox(f_wEPI);
    
    f_aMPFC2  = spm_select('FPList', work_dir_EPI,  '^aMPFC_in_BN_atlas.*\.nii$');
    
    jobs{1}.spatial{1}.normalise{1}.write.subj.matname  = editfilenames(f_EPI,'suffix','_sn','ext','.mat');
    jobs{1}.spatial{1}.normalise{1}.write.subj.resample = cellstr(f_aMPFC2);
    jobs{1}.spatial{1}.normalise{1}.write.roptions.vox  = vx;
    jobs{1}.spatial{1}.normalise{1}.write.roptions.bb  = BB;
    jobs{1}.spatial{1}.normalise{1}.estwrite.roptions.interp = 0;   % nearest neighbour
    spm_jobman('run',jobs);        % execute the batch
    fprintf('created waMPFC_in_BN_atlas.nii\n');
end


%%
% aMPFC
brain_ROI_DOC_DMN = fullfile(work_dir_EPI, 'brain_ROI_DOC', 'DMN');
w01_aMPFC =  spm_select('FPList',[brain_ROI_DOC_DMN],[strcat('^w01_aMPFC.*\.nii$')]);
w01_aMPFC_hdr = spm_vol(w01_aMPFC);
w01_aMPFC_map = spm_read_vols(w01_aMPFC_hdr);

% DMN_T10
brainnetwork_6_DMN = fullfile(work_dir_EPI, 'brainnetwork_6');
wDMN_T10 =  spm_select('FPList',[brainnetwork_6_DMN],[strcat('^wDMN_T10.*\.nii$')]);
wDMN_T10_hdr = spm_vol(wDMN_T10);
wDMN_T10_map = spm_read_vols(wDMN_T10_hdr);
wDMN_T10_map = wDMN_T10_map>0.5;

% waMPFC
f_aMPFC3  = spm_select('FPList', work_dir_EPI,  '^waMPFC_in_BN_atlas.*\.nii$');
f_aMPFC3_hdr = spm_vol(f_aMPFC3);
f_aMPFC3_map = spm_read_vols(f_aMPFC3_hdr);
f_aMPFC3_map = f_aMPFC3_map>0;

%%
wDMN_aMPFC_Region = msong_extract_max_overlap_region(w01_aMPFC_map, wDMN_T10_map.*f_aMPFC3_map);

%% PCC-based DMN
%DMN_directory = 'Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI\result_6BN\DMN';
DMN_directory = fullfile(work_dir, 'result_6BN','DMN');
wDMN_PCC =  spm_select('FPList',[DMN_directory],[strcat('^02_w02_PCC.*\.nii$')]);
wDMN_PCC_hdr = spm_vol(wDMN_PCC);
wDMN_PCC_map = spm_read_vols(wDMN_PCC_hdr);

%%
peak_in_aMPFC = wDMN_aMPFC_Region.* wDMN_PCC_map;
maxVal = max(peak_in_aMPFC(:));
linearIndex = find(peak_in_aMPFC == maxVal, 1);  % 如果有多个最大值，取第一个
[maxX,maxY,maxZ] = ind2sub(size(peak_in_aMPFC), linearIndex);

%% create a ROI file
% 获取矩阵大小
sz = size(wDMN_PCC_map);

% 初始化输出矩阵
new_ROI_img = zeros(sz);

% 计算膨胀范围，确保不越界
xRange = max(1, maxX-1) : min(sz(1), maxX+1);
yRange = max(1, maxY-1) : min(sz(2), maxY+1);
zRange = max(1, maxZ-1) : min(sz(3), maxZ+1);

% 赋值为1
new_ROI_img(xRange, yRange, zRange) = 1;

new_ROI_img = new_ROI_img.*(wDMN_PCC_map>0);

% %% rename w01_aMPFC
% oldName = w01_aMPFC(1,:);
% [pathStr, name, ext] = fileparts(oldName);
% newName = fullfile(pathStr, ['0_', name, ext]);
% 
% % 重命名文件
% status = movefile(oldName, newName);
% 
% % 检查是否成功
% if status
%     fprintf('aMPFC rename：%s\n', newName);
% else
%     warning('Fail to rename aMPFC in f_create_individual_aMPFC_ROI.m\n');
% end

%% write individual aMPFC ROI file
new_w01_aMPFC_hdr = w01_aMPFC_hdr;
new_w01_aMPFC_hdr.fname = fullfile(target_dir,'w01_aMPFC.nii');
new_w01_aMPFC_hdr.dt = [16 0]; % datatype: float32   %% spm datatype
spm_write_vol(new_w01_aMPFC_hdr, new_ROI_img);

%%
%fMRI_4D_file = 'Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI\afni\BP_rhmw_TR2.nii';
fMRI_4D_dir = fullfile(work_dir,'afni');
fMRI_4D_file = spm_select('FPList',[fMRI_4D_dir],[strcat('^BP_rhmw.*\.nii$')]);

ROI_file = new_w01_aMPFC_hdr.fname;

%mask_file = 'Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI\EPI\wmaskEPI_V2mm_float32.nii';
mask_file_dir = fullfile(work_dir,'EPI');
mask_file = spm_select('FPList',[mask_file_dir],[strcat('^wmaskEPI_V2mm_float32.*\.nii$')]); 

[cor_Z, cor_R, cor_P, TC_ROI, N_ROI] = f_ROIconnectivity_simple_4D(fMRI_4D_file(1,:), ROI_file,  mask_file(1,:));
[ROI_dir_temp, ROI_name] = fileparts(ROI_file);
result_filename = sprintf('%02d_%s_%s_Zmap.nii', 1, ROI_name, 'DMN');
cor_Z_hdr = new_w01_aMPFC_hdr;
%result_directory2 = target_dir;
cor_Z_hdr.fname = fullfile(target_dir, result_filename);
cor_Z_hdr.dt = [16 0]; % datatype: float32
spm_write_vol(cor_Z_hdr, cor_Z);

fprintf('finish recreating the ROI of aMPFC and computing the FC\n');


