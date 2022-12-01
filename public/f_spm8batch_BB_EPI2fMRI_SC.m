function [] = f_spm8batch_BB_EPI2fMRI_SC(subject_list_file)

%% Spm8 preprocessing batch
%--------------------------------------------------------------------------
%  subject_list_file : a full path of a text file that lists the subjects
% msong@nlpr.ia.ac.cn

%%

[directory filelist]= fileparts(subject_list_file);


MRI_type = '3T';

switch MRI_type
    case '3T'
        TR = 2;   
    case '1.5T'
        TR = 2.5;
    otherwise
        TR = 2;   %default
end


%%  EPI-ROI directory
program_location = which('pDOC');
[program_dir] = fileparts(program_location);
source_directory = fullfile(program_dir, 'EPI');
network_name = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));

%%
filelist_str=subject_list_file;
fid=fopen(filelist_str,'r');
index=0;

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg'); % useful in SPM8 only

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    index=index+1;
    tline = strtrim(tline);
    [subject_label subject_name] = fileparts(tline);
    
    subject_directory = fullfile(directory, subject_label, subject_name);  
    fprintf('Processing %d %s\n',index, subject_name);
    
    fMRI_directory= [];
    [BOLD_directory] = msong_select_subdirectory('subdir', subject_directory,  '^BOLD.*');
    [BOLD_directory2] = msong_select_subdirectory('subdir', subject_directory,  '^fMRI.*');
    [BOLD_directory3] = msong_select_subdirectory('subdir', subject_directory,  '^fmri.*');
    
    if(size(BOLD_directory, 1)>0)
        fMRI_directory = strtrim(BOLD_directory(1,:));
    end
    if(size(BOLD_directory2, 1)>0)
        fMRI_directory = strtrim(BOLD_directory2(1,:));
    end
    if(size(BOLD_directory3, 1)>0)
        fMRI_directory = strtrim(BOLD_directory3(1,:));
    end
    
    if(~exist(fMRI_directory, 'dir'))
        error('fMRI directory: %s does not exist.', fMRI_directory);
    end
    
    work_dir= strtrim(fMRI_directory);
    cd(work_dir);
    
    %% change fMRI filename
    fMRI_file = spm_select('FPList', work_dir,  '.*\.nii$');
    for i =1: size(fMRI_file,1)
        rmean_map_hdr = spm_vol(fMRI_file(i,:));
        rmean_map = spm_read_vols(rmean_map_hdr);
        mask_hdr = rmean_map_hdr;
        fname_prefix = char(editfilenames(fMRI_file(i,:),'prefix', 'pDOC_'));
        mask_hdr.fname = char(editfilenames(fname_prefix,'suffix', sprintf('_%03d',i)));
        spm_write_vol(mask_hdr, rmean_map);
    end    
    
    %% change Bounding box
    fMRI_file = spm_select('FPList', work_dir,  '^pDOC_.*\.nii$') ;
    for i =1: size(fMRI_file,1)
        rmean_map_hdr = spm_vol(fMRI_file(i,:));
        rmean_map = spm_read_vols(rmean_map_hdr);
        [BB vx] = spm_get_bbox(fMRI_file(i,:));
        mask_hdr = rmean_map_hdr;
        mask_hdr.fname = char(editfilenames(fMRI_file(i,:),'prefix', 'bb_'));
        img_dim = mask_hdr.dim;
        
        AA  = img_dim.* abs(vx) - abs(vx);
        BB = [(-1)*AA/2; AA/2];
        mask_hdr.mat = [...
            vx(1)     0     0    (BB(1,1) - abs(vx(2)))/sign(vx(1));...
            0     vx(2)     0  BB(1,2) - abs(vx(2));...
            0     0     vx(3)   BB(1,3) - abs(vx(3));...
            0     0     0     1];
        spm_write_vol(mask_hdr, rmean_map);
    end
    
    %% DELETE the first 5 frames
    %fprintf('checking & deleting the 5 %s analysis file\n',tline);
    filename_1ist_bb_pDOC = spm_select('FPList', work_dir,  '^bb_pDOC.*\.nii$') ;
    filename_1 = filename_1ist_bb_pDOC(1,:);
    if(size(filename_1, 1)>0)
        f1_hdr = spm_vol(filename_1);
        img_dim = f1_hdr.dim;
        n_slices = img_dim(3);
%         [temp, filename_1] = fileparts(filename_1);
%         length_filename_1 = length(filename_1);
%         prefix = filename_1(1:length_filename_1-4);
        for k=1:5
            temp_file=filename_1ist_bb_pDOC(k,:);
            delete(temp_file);
        end
    else
        filename_1 = spm_select('FPList', work_dir,  '^bb_pDOC.*_006\.nii$');
        if(size(filename_1,1)>0)
            f1_hdr = spm_vol(filename_1);
            img_dim = f1_hdr.dim;
            n_slices = img_dim(3);
        end
    end
    
    %% copy standard EPI
    fprintf('copy standard brain network atlas.\n');
    EPI_directory = fullfile(work_dir, 'EPI');
    if(~exist(EPI_directory, 'dir'))
        mkdir( work_dir, 'EPI');
    end
    copyfile(source_directory, EPI_directory,'f');
    
    %% WORKING DIRECTORY (useful for .ps only)
    %--------------------------------------------------------------------------
    clear jobs;
    jobs{1}.util{1}.cdir.directory = cellstr(work_dir);  % spm8
        
    f = spm_select('FPList', work_dir,  '^bb_pDOC.*\.nii$') ;
    f_EPI = spm_select('FPList', EPI_directory,  '^EPI.*\.nii$') ;
    f_7BN = spm_select('FPList', EPI_directory,  '^winner_7.*\.nii$') ;
    f_mask = spm_select('FPList', EPI_directory,  '^maskEPI_V2mm_float32.*\.nii$') ;
    
    %% SLICE TIMING
    %--------------------------------------------------------------------------
    jobs{2}.temporal{1}.st.scans{1} = cellstr(f);
    jobs{2}.temporal{1}.st.nslices = n_slices;
    jobs{2}.temporal{1}.st.tr = TR;
    jobs{2}.temporal{1}.st.ta = TR-TR/n_slices;
    if(mod(n_slices,2)~=0)
        jobs{2}.temporal{1}.st.so =[1:2:n_slices 2:2:n_slices-1];
    else
        jobs{2}.temporal{1}.st.so =[1:2:n_slices-1 2:2:n_slices];
    end
    jobs{2}.temporal{1}.st.refslice = 2;
    
    %% REALIGN
    %--------------------------------------------------------------------------
    jobs{3}.spatial{1}.realign{1}.estwrite.data{1} = editfilenames(f,'prefix','a');
    
    %% bounding box & vx
    [BB vx]= spm_get_bbox(f(1,:));
%     AA  = img_dim.* abs(vx) - abs(vx);
%     BB = [(-1)*AA/2; AA/2];
        
    
    %% NORMALIZE Estimate & write to EPI and brainnetwork
    %--------------------------------------------------------------------------
    jobs{3}.spatial{2}.normalise{1}.estwrite.subj.source = cellstr(f_EPI);
    jobs{3}.spatial{2}.normalise{1}.estwrite.subj.resample = [cellstr(f_EPI); cellstr(f_mask); cellstr(f_7BN)];
    jobs{3}.spatial{2}.normalise{1}.estwrite.eoptions.template = editfilenames(f(1,:),'prefix','meana');
    jobs{3}.spatial{2}.normalise{1}.estwrite.roptions.preserve = 0;
    jobs{3}.spatial{2}.normalise{1}.estwrite.roptions.bb = BB;
    jobs{3}.spatial{2}.normalise{1}.estwrite.roptions.vox = vx;
    jobs{3}.spatial{2}.normalise{1}.estwrite.roptions.interp = 0;   % nearest neighbour
    
    %% NORMALIZE Write to ROI
    %--------------------------------------------------------------------------
    
    ROI_dir = fullfile(EPI_directory , 'brain_ROI_DOC');                       %   the path of the ROI file
    ROI_file = [];
    
    for i=1: numel(network_name)
        temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '.*\.nii$')]);
        %ROI_file{i} = cellstr(temp);
        ROI_file = strvcat(ROI_file,temp);
    end
    
    BN_dir = fullfile(EPI_directory , 'brainnetwork_6');                       %   the path of the ROI file
    temp = spm_select('FPList',[BN_dir],[strcat( '.*\.nii$')]);
    ROI_file = strvcat(ROI_file,temp);

    jobs{3}.spatial{3}.normalise{1}.write.subj.matname  = editfilenames(f_EPI,'suffix','_sn','ext','.mat');
    jobs{3}.spatial{3}.normalise{1}.write.subj.resample = cellstr(ROI_file);
    jobs{3}.spatial{3}.normalise{1}.write.roptions.vox  = vx;
    jobs{3}.spatial{3}.normalise{1}.write.roptions.bb  =BB;
    jobs{3}.spatial{3}.normalise{1}.estwrite.roptions.interp = 0;   % nearest neighbour
    
    %% SMOOTHING
    %--------------------------------------------------------------------------
    jobs{3}.spatial{4}.smooth.data = editfilenames(f,'prefix','ra');
    jobs{3}.spatial{4}.smooth.fwhm = [6 6 6];
    
    %% coreg EPI to mean fMRI:  20180910
    jobs{4}.spatial{1}.coreg{1}.estwrite.ref = editfilenames(f(1,:),'prefix','meana');
    jobs{4}.spatial{1}.coreg{1}.estwrite.source = cellstr(f_EPI);
    jobs{4}.spatial{1}.coreg{1}.estwrite.other = cellstr(f_mask);
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.cost_fun = 'nmi';
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.sep = [4 2];
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.fwhm = [7 7];
    jobs{4}.spatial{1}.coreg{1}.estwrite.roptions.interp = 0;
    jobs{4}.spatial{1}.coreg{1}.estwrite.roptions.wrap = [0 0 0];
    jobs{4}.spatial{1}.coreg{1}.estwrite.roptions.mask = 0;
    jobs{4}.spatial{1}.coreg{1}.estwrite.roptions.prefix = 'r';
    
    %% RUN JOBS
    %save('DOC.mat','jobs');
    %spm_jobman('interactive',jobs); % open a GUI containing all the setup
    spm_jobman('run',jobs);        % execute the batch
    
    %% compute the overlay ratio for wmaskEPI_V2mm_float32.nii and rmaskEPI_V2mm_float32.nii
    wmask_file = char(editfilenames(f_mask,'prefix','w'));
    rmask_file = char(editfilenames(f_mask,'prefix','r'));
    [ratio_intersection] = msong_calculate_intersection(wmask_file, rmask_file);
    fprintf('intersection between mask & brain: %4.3f\n', ratio_intersection);
    

    %% remove whole brain and head motion
    fprintf('removing the head motion and whole brain mean.\n');
    func_name = strcat(work_dir,filesep, 'sra*.nii');
    motionfile_name = strcat(work_dir,filesep, 'rp_*.txt');
    file = dir(motionfile_name);
    motionfile_name = fullfile(work_dir,file.name);
    mask_file =  char(editfilenames(f_mask,'prefix','w'));
    T = size(f,1);
    [TC_mean] = f_RemoveHeadMotion_Wholemean_2(work_dir,func_name,motionfile_name,mask_file,T);
    
    %% scrub fMRI timeseries with too large headmotion
    headmotion_txt = motionfile_name;
    headmotion_threshold = 1.5;
    [temporal_mask]=f_calculate_headmotion_FD(headmotion_txt , headmotion_threshold);
    prefix = '^rhmw_';
    fMRI_3D_series = spm_select('FPList', work_dir,  sprintf('%s.*\\.nii$',prefix));
    prefix=f_temporalMask_fMRI3D_series(fMRI_3D_series, temporal_mask);

    %% band pass filter
    %prefix = '^S_';
    fprintf('band pass filtering...\n');
    fMRI_data = spm_select('FPList', work_dir,  sprintf('%s.*\\.nii$',prefix));
    %%,'brain_mask', 0
    low_cutoff = 0.01;
    high_cutoff = 0.08;
    prefix = f_ideal_bandpass_filter(fMRI_data,'TR', TR,  'low_cutoff', low_cutoff, 'high_cutoff', high_cutoff,'brain_mask',  mask_file);
    
    
    %% series 3D into 4D
    filter_result_directory = fullfile(work_dir, 'afni');
    if(~exist(filter_result_directory,'dir'))
        mkdir(work_dir, 'afni');
    end
    clear jobs;
    jobs{1}.util{1}.cdir.directory = cellstr(filter_result_directory);
    jobs{2}.util{1}.cat.vols = cellstr(spm_select('FPList', work_dir,  sprintf('%s.*\\.nii$',prefix)));
    jobs{2}.util{1}.cat.name = fullfile(filter_result_directory,strcat('BP_rhmw_', subject_name,'.nii'));
    jobs{2}.util{1}.cat.dtype = 0;  % SAME with original image
    %spm_jobman('interactive',jobs); % open a GUI containing all the setup
    spm_jobman('run',jobs);        % execute the batch
 
   
    %%  funcional connectivity in individual space
    fprintf('\n Functional connectivity analysis.\n');
    result_directory = fullfile(work_dir, 'result_6BN');
    if(~exist(result_directory,'dir'))
        mkdir(work_dir, 'result_6BN');
    end
    
    mask_file =  char(editfilenames(f_mask,'prefix','w'));
    mask_hdr = spm_vol(mask_file);
   
    
    for i=1: numel(network_name)
       fprintf('\n computing %s_%s ...\n', tline, char(network_name{i}));
       ROI_file = [];
       temp = spm_select('FPList',[fullfile(ROI_dir, network_name{i})],[strcat( '^w.*\.nii$')]);
        ROI_file = strvcat(ROI_file,temp);
        
        n_ROI_file = size(ROI_file, 1);
        
        result_directory2 = fullfile(result_directory, char(network_name{i}));
        if(~exist(result_directory2,'dir'))
            mkdir(result_directory, char(network_name{i}));
        end
    
        for j =1:n_ROI_file
            fprintf('\n\t ROI: %s ...\n', ROI_file(j,:));

            fMRI_4D_file = fullfile(filter_result_directory,strcat('BP_rhmw_', subject_name,'.nii'));

            [cor_Z, cor_R, cor_P, TC_ROI,  N_ROI] = f_ROIconnectivity_simple_4D(fMRI_4D_file, ROI_file(j,:),  mask_file);
            [ROI_dir_temp, ROI_name] = fileparts(ROI_file(j,:));
            result_filename = sprintf('%02d_%s_%s_Zmap.nii', j, ROI_name, char(network_name{i}));
            cor_Z_hdr = mask_hdr;
            cor_Z_hdr.fname = fullfile(result_directory2, result_filename);
            cor_Z_hdr.dt = [16 0]; % datatype: float32
            spm_write_vol(cor_Z_hdr, cor_Z);

        end
 
    end
    
    
    
end

fclose(fid);
%

