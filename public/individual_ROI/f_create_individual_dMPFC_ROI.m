function [] = f_create_individual_dMPFC_ROI(work_dir, target_dir)
%% work_dir: Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI
%  target_dir: 'fMRI_2' or a new directory Z:\zhangxiuhong\analysis\
%clear;
%clc;

addpath('K:\work\2017_DOC_0_prognosis\pDOC\20230315\pDOC\public');

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

% DMPFC
brain_ROI_DOC_DMN = fullfile(work_dir_EPI, 'brain_ROI_DOC', 'ExecuContr');
w01_DMPFC =  spm_select('FPList',[brain_ROI_DOC_DMN],[strcat('^w01_DMPFC.*\.nii$')]);
w01_DMPFC_hdr = spm_vol(w01_DMPFC);
w01_DMPFC_map = spm_read_vols(w01_DMPFC_hdr);

% ExecuContr_T10
brainnetwork_6_DMN = fullfile(work_dir_EPI, 'brainnetwork_6');
wExecuContr_T10 =  spm_select('FPList',[brainnetwork_6_DMN],[strcat('^wExecuContr_T10.*\.nii$')]);
wExecuContr_T10_hdr = spm_vol(wExecuContr_T10);
wExecuContr_T10_map = spm_read_vols(wExecuContr_T10_hdr);
wExecuContr_T10_map = wExecuContr_T10_map>0.5;

%%
wExecuContr_DMPFC_Region = msong_extract_max_overlap_region(w01_DMPFC_map, wExecuContr_T10_map);

%% PCC-based DMN
DMN_directory = fullfile(work_dir, 'result_6BN','DMN');
wDMN_PCC =  spm_select('FPList',[DMN_directory],[strcat('^02_w02_PCC.*\.nii$')]);
wDMN_PCC_hdr = spm_vol(wDMN_PCC);
wDMN_PCC_map = spm_read_vols(wDMN_PCC_hdr);

wDMN_PCC_map = (-1)*wDMN_PCC_map;

%%
peak_in_DMPFC = wExecuContr_DMPFC_Region.* wDMN_PCC_map;
maxVal = max(peak_in_DMPFC(:));
linearIndex = find(peak_in_DMPFC == maxVal, 1);  % 如果有多个最大值，取第一个
[maxX,maxY,maxZ] = ind2sub(size(peak_in_DMPFC), linearIndex);

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

new_ROI_img = new_ROI_img.*(wDMN_PCC_map>0).*wExecuContr_T10_map;

% %% rename w01_DMPFC
% oldName = w01_DMPFC(1,:);
% [pathStr, name, ext] = fileparts(oldName);
% newName = fullfile(pathStr, ['0_', name, ext]);
% 
% % 重命名文件
% status = copyfile(oldName, newName);
% 
% % 检查是否成功
% if status
%     fprintf('DMPFC rename：%s\n', newName);
% else
%     error('Fail to rename DMPFC in f_create_individual_DMPFC_ROI.m\n');
% end

%% write individual DMPFC ROI file
new_w01_DMPFC_hdr = w01_DMPFC_hdr;
new_w01_DMPFC_hdr.fname = fullfile(target_dir,'w01_DMPFC.nii');
new_w01_DMPFC_hdr.dt = [16 0]; % datatype: float32   %% spm datatype
spm_write_vol(new_w01_DMPFC_hdr, new_ROI_img);

%%
fMRI_4D_dir = fullfile(work_dir,'afni');
fMRI_4D_file = spm_select('FPList',[fMRI_4D_dir],[strcat('^BP_rhmw.*\.nii$')]);

mask_file_dir = fullfile(work_dir,'EPI');
mask_file = spm_select('FPList',[mask_file_dir],[strcat('^wmaskEPI_V2mm_float32.*\.nii$')]); %'Z:\DOC_MRI_dongruan\20250409\zhangxiuhong\analysis\TR2\fMRI\EPI\wmaskEPI_V2mm_float32.nii';

ROI_file = new_w01_DMPFC_hdr.fname;
[cor_Z, cor_R, cor_P, TC_ROI, N_ROI] = f_ROIconnectivity_simple_4D(fMRI_4D_file(1,:), ROI_file,  mask_file(1,:));
[ROI_dir_temp, ROI_name] = fileparts(ROI_file);
result_filename = sprintf('%02d_%s_%s_Zmap.nii', 1, ROI_name, 'ExecuContr');
cor_Z_hdr = new_w01_DMPFC_hdr;
result_directory2 = target_dir;
cor_Z_hdr.fname = fullfile(result_directory2, result_filename);
cor_Z_hdr.dt = [16 0]; % datatype: float32
spm_write_vol(cor_Z_hdr, cor_Z);

fprintf('finish recreating the ROI of DMPFC and computing the FC\n');

