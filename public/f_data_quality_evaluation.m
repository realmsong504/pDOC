function [] = f_data_quality_evaluation(subject_list_file)

% fMRI quality evaluation for DOC data. It includes two parts:
% (1) head motion
% (2) effective T
% (3) mean fMRI
% (4) tSNR
% msong@nlpr.ia.ac.cn

[directory, subject_name] = fileparts(subject_list_file);
subject_directory = fullfile(directory, subject_name);


%% (1) head motion

[headmotion, T_FD] = f_head_motion_evaluation(subject_list_file);

for j =4:6
    headmotion(:,j) = headmotion(:,j).*50;
end

T = size(headmotion,1);

fig=figure('Name',strcat(subject_name,'_headmotion_curve'));
set(fig,'units','centimeters','position',[3 3 30 20],'color','w');


titles = {...
    'x\_translation';
    'y\_translation';
    'z\_translation';
    'x\_rotation';
    'y\_rotation';
    'z\_rotation';
    };
colors = {...
    'r';...
    'k';...
    'b';...
    'm';...
    'g';...
    'c'};
subplot(4,4,1:4);grid; hold on;
title(strcat( subject_name,' : head motion'));

xlim([1 T+1]);
for i = 1:6
    plot([1:T],headmotion(:,i),char(colors{i}),  'LineWidth', 3);
end
legend(char(titles),'Location','EastOutside'); hold off;

subplot(4,4,5:8); axis off; xlim([0 1]);
ratio_T = T_FD./T*100;
text(0,0.5, sprintf('effective T = %d; %4.2f%% of the raw fMRI volumes', T_FD, ratio_T),'FontSize',18);


%%
program_location = which('pDOC');
[program_dir] = fileparts(program_location);
network_name_total = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));
fMRI_directory= [];
[BOLD_directory] = msong_select_subdirectory('subdir', subject_directory,  '^BOLD.*');
[BOLD_directory2] = msong_select_subdirectory('subdir', subject_directory,  '^fMRI.*');
[BOLD_directory3] = msong_select_subdirectory('subdir', subject_directory,  '^fmri.*');

if(size(BOLD_directory, 1)>0)
    fMRI_directory = BOLD_directory(1,:);
end
if(size(BOLD_directory2, 1)>0)
    fMRI_directory = BOLD_directory2(1,:);
end
if(size(BOLD_directory3, 1)>0)
    fMRI_directory = BOLD_directory3(1,:);
end
if(~exist(fMRI_directory, 'dir'))
    error(fprintf('fMRI directory: %s does not exist. \n', fMRI_directory));
end

result_dir = fullfile(fMRI_directory, 'reports');
if(~exist(result_dir, 'dir'))
    mkdir(fMRI_directory, 'reports');
end

EPI_directory = fullfile(fMRI_directory,'EPI');
ROI_dir = fullfile(EPI_directory, 'brain_ROI_DOC');                       %   the path of the ROI file

%% (3) mean fMRI
network_name = char(network_name_total{1});  % DMN

mean_fMRI_file = spm_select('FPList',[fMRI_directory],[strcat('^mean.*\.nii$')]);
mean_fMRI_hdr = spm_vol(mean_fMRI_file );

dim_mean_fMRI = mean_fMRI_hdr.dim;
z_mean_fMRI = dim_mean_fMRI(3);
show_z = ceil(sqrt(z_mean_fMRI));

max_row = 4;
max_column = 1;
gap = 5;

initial_axial_slice_number= z_mean_fMRI - max_row*gap - 1;
if(initial_axial_slice_number<0)
    initial_axial_slice_number = 1;
    gap = 3;
end


mean_fMRI_map = spm_read_vols(mean_fMRI_hdr);
mean_fMRI_map = rot90_3D( mean_fMRI_map, 3,3 );
mean_fMRI_map(find(mean_fMRI_map<0)) =0;
mean_fMRI_map2 = zeros(size(mean_fMRI_map));

wEPI_dir = fullfile(fMRI_directory, 'EPI');
wBN_dir = fullfile(wEPI_dir, 'brainnetwork_6');
wDMN_file = spm_select('FPList',[wBN_dir],[strcat('^w', network_name, '_T.*\.nii$')]);
wDMN_map_hdr = spm_vol(wDMN_file);
wDMN_map0 = spm_read_vols(wDMN_map_hdr);
wDMN_map = rot90_3D(wDMN_map0, 3, 3);

for i  =1 : size(mean_fMRI_map,3)
    slice_index = i;
    bg = squeeze(mean_fMRI_map(:,:, slice_index));
    d0 = squeeze(wDMN_map(:,:, slice_index));
    d0 = d0>0;
    canny_threhold = 0.5;
    d=edge(d0,'canny',canny_threhold);
    edge_index = find(d>0);
    bg(edge_index) = min(bg(:));
    mean_fMRI_map2(:,:, slice_index) = bg;
end

anat01 = mean_fMRI_map2 ./ max(mean_fMRI_map2(:));
anat0_63 = round( 63 * anat01 );
anat64 = anat0_63 + 1;

%%%%%%%%% show seedpoint%%%%%%%%%%%%
Seedmap_dir = fullfile(fMRI_directory, 'EPI', 'brain_ROI_DOC', network_name);
Seedmap_filename = spm_select('FPList',[Seedmap_dir], sprintf('^w.*\\.nii$'));
SeedAll_map  = zeros(size(wDMN_map0));
for i = 1: size(Seedmap_filename , 1)
    Seed_hdr = spm_vol(Seedmap_filename(i,: ));
    Seed_map = spm_read_vols(Seed_hdr);
    SeedAll_map = SeedAll_map + Seed_map;
end
SeedAll_map = rot90_3D(SeedAll_map, 3, 3);

Seedmap = SeedAll_map;
thresholded_Seedmap =  double(Seedmap > 0) ;

Seedmap01 = thresholded_Seedmap ./ max(thresholded_Seedmap(:));
Seedmap0_63 = round( 63 * Seedmap01 );
Seedmap64 = 1 + Seedmap0_63;

anat_RGB = zeros(size(anat64,1), size(anat64,2), size(anat64,3),3);
Seedmap_RGB = zeros(size(Seedmap64,1), size(Seedmap64,2), size(Seedmap64,3),3);

gray_cmap = colormap('gray');   %%% This reads in the current colormap matrix
hot_cmap = colormap('Jet');

for RGB_dim = 1:3,  %%% Loop through the three slabs: R, G, and B
    
    gray_cmap_rows_for_anat = anat64;
    hot_cmap_rows_for_Seedmap = Seedmap64;
    
    colour_slab_vals_for_anat = gray_cmap(gray_cmap_rows_for_anat, RGB_dim);
    colour_slab_vals_for_Seedmap = hot_cmap(hot_cmap_rows_for_Seedmap, RGB_dim);
    
    anat_RGB(:,:,:,RGB_dim) = reshape( colour_slab_vals_for_anat, size(anat64));
    Seedmap_RGB(:,:,:,RGB_dim) = reshape( colour_slab_vals_for_Seedmap, size(Seedmap64));
    
end;  % End of loop through the RGB dimension.

Seedmap_opacity = 1;     % 0.4 is a reasonable opacity value to try first

compound_RGB = zeros(size(anat64,1), size(anat64,2), size(anat64,3),3);

for RGB_dim = 1:3,  %%% Loop through the three slabs: R, G, and B
    
    compound_RGB(:,:,:,RGB_dim) = ...
        (thresholded_Seedmap==0) .* ...    % Where T-map is below threshold
        anat_RGB(:,:,:,RGB_dim) + ...
        (thresholded_Seedmap>0).* ...      % Where T-map is above threshold
        ( (1-Seedmap_opacity) * anat_RGB(:,:,:,RGB_dim) + ...
        Seedmap_opacity * Seedmap_RGB(:,:,:,RGB_dim) );
    
end;
compound_RGB = min(compound_RGB,1);

for loop_counter = 1:max_row* max_column ,     %%% Go around 9 times, adding one to the
    %%% value of loop_counter each time.
    axial_slice_number = gap*loop_counter + initial_axial_slice_number;
    axial_slice_vals = compound_RGB(:,:,axial_slice_number,:);
    axial_slice_2D_RGB = squeeze(axial_slice_vals);
    
    %
    if(loop_counter==max_row* max_column)
        %axes(ha(loop_counter));
        subplot(4,4,12);
        image(axial_slice_2D_RGB);hold on;
        set(gca,'YDir','normal');
        axis('image');  %%% Make the proportions of the image correct
        axis('off');    %%% Turn off the numbers on the x- and y-axes
        text(6,10,'L','Color',[1 1 1],'FontWeight','bold');
        text(size(axial_slice_2D_RGB,1)-6*1.5, 10, 'R','Color',[1 1 1],'FontWeight','bold');
        hold off;
    else
        %axes(ha(loop_counter));
        subplot(4,4,8+loop_counter);
        image(axial_slice_2D_RGB);
        set(gca,'YDir','normal');
        axis('image');  %%% Make the proportions of the image correct
        axis('off');    %%% Turn off the numbers on the x- and y-axes
        
    end
    
end;    %%% The end of this for-loop


%% (4) tSNR
tSNR_dir = fullfile(fMRI_directory, 'tSNR');

subplot(4,4,13:16); hold on; grid;
if(~exist(tSNR_dir, 'dir'))  % not exist

    %%  EPI-ROI directory
    brain_mask_directory = fullfile(fMRI_directory, 'EPI');
    brain_mask_file = fullfile(brain_mask_directory, 'wmaskEPI_V2mm_float32.nii');
    if(~exist(brain_mask_file, 'file'))
        error('Brain mask not exist.');
    end
    
    f = spm_select('FPList', fMRI_directory,  '^bb.*\.nii$') ;
    if(size(f,1)==0)
        f = spm_select('FPList', fMRI_directory,  sprintf('^%s.*\\.nii$', upper(subject_name))) ;
    end
    
    [tSNR_image] = msong_tSNR_image(f, brain_mask_file);
    
end


% tSNR have been calculated
tSNR_image_filepath = spm_select('FPList',tSNR_dir,[strcat( '^tSNR.*\.nii$')]);
total_n_ROI_file = 0;
ROI_name_all = {};
for i=1: numel(network_name_total)
    %fprintf('\n%d_%s ...\n', i, char(network_name{i}));
    
    %% ROI
    ROI_file = [];
    temp = spm_select('FPList',[fullfile(ROI_dir, network_name_total{i})],[strcat( '^w.*\.nii$')]);
    ROI_file = strvcat(ROI_file,temp);
    n_ROI_file = size(ROI_file, 1);
    
    %%
    [tSNR_ROI] = f_ExtractMultipleROISingal_4D(ROI_file, tSNR_image_filepath);
    M{i} = tSNR_ROI;
    
    %% sort and write to the result file
    for j = 1: n_ROI_file
        [ROI_dir2, ROI_filename] = fileparts(strtrim(ROI_file(j,:)));
        parts = msong_strsplit('_', ROI_filename);
        ROI_filename2 = char(parts{2});
        ROI_name_all{total_n_ROI_file + j } = ROI_filename2;
    end
    
    N(total_n_ROI_file+1 : total_n_ROI_file+n_ROI_file) = i;
    total_n_ROI_file = total_n_ROI_file + n_ROI_file;
end

G = cell(total_n_ROI_file,1);
M2 = zeros(total_n_ROI_file,1);
index_ROI = 0;
for i=1: numel(M)
    temp = M{i};
    for j =1: numel(temp)
        M2(index_ROI+j) = temp(j);
        G{index_ROI+j} = network_name_total{i};
    end
    index_ROI =index_ROI +j;
    
end

%figure('Name',strcat(subject_name,'_scatter'),'NumberTitle','off');
gscatter(N,M2,N);  hold on;
xlabel('');
ylabel('tSNR');
title(strcat( subject_name,' : tSNR'));
set(gca,'Xtick',1:numel(network_name_total),'XTickLabel', network_name_total);


legend(gca,'off');
hold on;
% print the maximum and minmum ROI
for i=1: numel(M)
    temp = M{i};
    %temp = msong_z2r(temp);
    ROI_index = find(N==i);
    %max
    [ma, ma_index] = max(temp);
    show_ROI_name = char(ROI_name_all(ROI_index(ma_index)));
    show_ROI_name2 = strrep(show_ROI_name, '_','\_');
    text(i+0.05, ma, show_ROI_name2 );
    %min
    [mi, mi_index] = min(temp);
    show_ROI_name = char(ROI_name_all(ROI_index(mi_index)));
    show_ROI_name2 = strrep(show_ROI_name, '_','\_');
    text(i+0.05, mi, show_ROI_name2 );
    
end
hold off;

print(fig,'-djpeg',fullfile(result_dir,  'headMotion_fMRI'));


