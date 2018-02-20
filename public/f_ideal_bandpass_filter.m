function [prefix]=f_ideal_bandpass_filter(fMRI_data , varargin)
% bandpass filter for fMRI using ideal filter
% FUNCTION [] = f_regression_removing_noise(fMRI_data,brain_mask, brain_mask_filename, filter_type, filter_parameter,...);
%   fMRI_data                 - a list of filenames of fMRI timeseries.
%   brain_mask                - a hit for if using brain mask .
%   brain_mask_filename  - a filename for brain mask. Aternatively, "0": not use default mask. "default": use default mask
%   filter_type                   - either 'TR', 'low_cutoff', 'high_cutoff'
%   filter_parameter          - corresponding value, TR(second), low_cutoff(Hz), high_cutoff(Hz)
%   RESULT:   (1) result filename prefix: "BP" (band pass)
%

warning off;
if rem(length(varargin),2)
    error('Not enough input arguments.');
end

filelist = fMRI_data;
if ischar(filelist), filelist = cellstr(filelist); end

T = length(filelist);

%% read the 1st fMRI
fMRI_filename = filelist{1};
fMRI_hdr = spm_vol(fMRI_filename);
fMRI_dim = fMRI_hdr.dim;

%% check if there are brain mask in the varargin
flag_mask = 1;
brain_mask_filename = which('brain_mask.hdr');
% TR = 2;
% sampling_frequence  = TR;
% low_cutoff = 0.01;
% high_cutoff = 0.08;
label = 'BP';

for i=1:2:length(varargin)
    switch varargin{i}
        case 'brain_mask'
            brain_mask_filename = varargin{i+1};
            if brain_mask_filename==0
                flag_mask = 0;
            end
            if brain_mask_filename==1
                brain_mask_filename = fullfile(brain_mask_directory, 'brain_mask.hdr');
            end
            if strcmp(brain_mask_filename,'default')
                brain_mask_filename = fullfile(brain_mask_directory, 'brain_mask.hdr');
            end
            break;
        otherwise
    end
end

mask_hdr = spm_vol(brain_mask_filename);
mask_dim = mask_hdr.dim;
dimdim = fMRI_dim == mask_dim;
if isempty(find(dimdim~=1))
    flag_mask = 1;
else
    flag_mask = 0;
end


if(flag_mask)
    
    fprintf('\tUsing the brain mask. \n');
%     mask_hdr = spm_vol(brain_mask_filename);
%     mask_dim = mask_hdr.dim;
    if (mask_dim ~= fMRI_dim)
        error('The dimensions of the brain mask file and fMRI file do NOT match.');
    end
    
    mask_img = spm_read_vols(mask_hdr);
    brain_index  = find(mask_img>0);
    n_vox_brain = length(brain_index);
    
    %% read the fMRI data
    fprintf('\treading fMRI time series. \n');
    %TC_total = zeros(T, n_vox_brain, 'single');
    TC_total = zeros(T, n_vox_brain);
    
    for t = 1:T
        fMRI_filename = filelist{t};
        fMRI_hdr = spm_vol(fMRI_filename);
        fMRI_img = spm_read_vols(fMRI_hdr);
        fMRI_brain = fMRI_img(brain_index);
        TC_total(t,:)=fMRI_brain;
    end
    fMRI_dim = fMRI_hdr.dim;
    
    %% get filter parameter
    for j =1:2:length(varargin)
        
        switch varargin{j}
            case 'brain_mask'
                
            case 'TR'
                sampling_frequence = varargin{j+1};
                TR = sampling_frequence;
                
            case 'low_cutoff'
                low_cutoff = varargin{j+1};
                
            case 'high_cutoff'
                high_cutoff = varargin{j+1};
                
            otherwise
                error('Unknown action.');
        end
    end
    
    %% print the filter parameter
    fprintf('\tfilter parameter:  \n');
    fprintf('\t\tTR=%s sec. \n', num2str(TR));
    fprintf('\t\tLow_cutoff=%s Hz. \n', num2str(low_cutoff));
    fprintf('\t\tHigh_cutoff=%s Hz. \n', num2str(high_cutoff));

    
    %%
    fprintf('\tfilter...\n');
    for n = 1:size(TC_total,2)
        TC = TC_total(:,n);
        if TC == zeros(T,1)
        else
            Y = fft(TC)/T;
            Ny = (1/sampling_frequence )/2;
            F = linspace(0,1,T/2)*Ny;
            low_index = find(F<low_cutoff & F>0);
            f_low_index = (T+2) - low_index;
            high_index = find(F>high_cutoff & F<Ny);
            f_high_index = (T+2) - high_index;
            
            Y_filter = Y;
            Y_filter(low_index) = 0;
            Y_filter(high_index) =0;
            Y_filter(f_low_index) = 0;
            Y_filter(f_high_index)  =0;
            
            TC = ifft(Y_filter);  %
            
            TC_total(:,n) = TC;
        end
    end
    
    %% save the new 3D files
    fprintf('\tsaving the result... \n');
    new_filelist= editfilenames(filelist,'prefix',strcat(label,'_'));
    
    for t = 1:T
        newfile_hdr = fMRI_hdr;
        newfile_hdr.dt = [16 0];
        newfile_hdr.fname = new_filelist{t};
        newfile_img = zeros(fMRI_dim);
        newfile_img(brain_index) = TC_total(t,:);
        spm_write_vol(newfile_hdr, newfile_img);
    end
    
    
else
    fprintf('\tNo brain mask to be used. \n');
    
    
    %% read the fMRI data
    fprintf('\treading fMRI time series. \n');
    %TC_total = zeros(fMRI_dim(1),fMRI_dim(2),fMRI_dim(3),T,'single');
    TC_total = zeros(fMRI_dim(1),fMRI_dim(2),fMRI_dim(3),T);
    for t = 1:T
        fMRI_filename = filelist{t};
        fMRI_hdr = spm_vol(fMRI_filename);
        fMRI_img = spm_read_vols(fMRI_hdr);
        TC_total(:,:,:,t)=fMRI_img;
    end
    fMRI_dim = fMRI_hdr.dim;
    
    
    %% get filter parameter
    for j =1:2:length(varargin)
        
        switch varargin{j}
            case 'brain_mask'
                
            case 'TR'
                sampling_frequence = varargin{j+1};
                TR = sampling_frequence;
                
            case 'low_cutoff'
                low_cutoff = varargin{j+1};
                
            case 'high_cutoff'
                high_cutoff = varargin{j+1};
                
            otherwise
                error('Unknown action.');
        end
    end
    
    %% print the filter parameter
    fprintf('\tfilter parameter:  \n');
    fprintf('\t\tTR=%s sec. \n', num2str(TR));
    fprintf('\t\tLow_cutoff=%s Hz. \n', num2str(low_cutoff));
    fprintf('\t\tHigh_cutoff=%s Hz. \n', num2str(high_cutoff));
       
    
    %%
    fprintf('\tfiltering... \n');
    for i = 1:size(TC_total,1)
        for j = 1:size(TC_total,2)
            for k = 1:size(TC_total,3)
                TC = squeeze(TC_total(i,j,k,:));
                if TC == zeros(T,1)
                else
                    Y = fft(TC)/T;
                    Ny = (1/sampling_frequence )/2;
                    F = linspace(0,1,T/2)*Ny;
                    low_index = find(F<low_cutoff & F>0);
                    f_low_index = (T+2) - low_index;
                    high_index = find(F>high_cutoff & F<Ny);
                    f_high_index = (T+2) - high_index;
                    
                    Y_filter = Y;
                    Y_filter(low_index) = 0;
                    Y_filter(high_index) =0;
                    Y_filter(f_low_index) = 0;
                    Y_filter(f_high_index)  =0;
                    
                    TC = ifft(Y_filter);  %
                    
                     TC_total(i,j,k,:) = TC;
                end
            end
        end
    end
    
    
    
    %% save the new 3D files
    fprintf('\tsaving the new 3D files... \n');
    
    new_filelist= editfilenames(filelist,'prefix',strcat(label,'_'));
    
    for t = 1:T
        newfile_hdr = fMRI_hdr;
        newfile_hdr.dt = [16 0];
        newfile_hdr.fname = new_filelist{t};
        spm_write_vol(newfile_hdr, TC_total(:,:,:,t));
    end
end

prefix = label;
fprintf('\tBandpass filtering finished. \n');
