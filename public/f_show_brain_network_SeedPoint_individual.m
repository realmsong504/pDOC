function [] = f_show_brain_network_SeedPoint_individual(subject_list_file, show_network_index, T_threshold)

%% show whole brain connectivity for each ROI
% show_network_index
% 1: DMN
% 2: ExecuContr
% 3: Salience
% 4: Sensorimotor
% 5: Auditory
% 6: Visual

% msong@nlpr.ia.ac.cn

initial_axial_slice_number = 5;
gap =1;

if(nargin<3)
    show_network_index = 1;
    T_threshold = 0.5;
end

[directory, subject_name] = fileparts(subject_list_file);

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
addpath(fullfile(program_dir, 'public','export_fig'));
network_name_total = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));

network_name = char(network_name_total{show_network_index});

subject_directory = fullfile(directory, subject_name);

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
mkdir(result_dir, network_name);
result_dir = fullfile(fMRI_directory, 'reports', network_name);
mkdir(result_dir);

work_dir = deblank(fMRI_directory);

mean_fMRI_file = spm_select('FPList',[work_dir],[strcat('^mean.*\.nii$')]);
mean_fMRI_hdr = spm_vol(mean_fMRI_file );

dim_mean_fMRI = mean_fMRI_hdr.dim;
z_mean_fMRI = dim_mean_fMRI(3);
show_z = ceil(sqrt(z_mean_fMRI));

max_row = 6;
if(z_mean_fMRI>=max_row)
    max_column = floor(z_mean_fMRI/max_row)-1;
else
    error('the number of slices of fMRI is too small');
end

if(max_column*max_row+1>z_mean_fMRI)
    error('too many number of presentation subplot\n');
end

mean_fMRI_map = spm_read_vols(mean_fMRI_hdr);
mean_fMRI_map = rot90_3D( mean_fMRI_map, 3,3 );
mean_fMRI_map(find(mean_fMRI_map<0)) =0;
mean_fMRI_map2 = zeros(size(mean_fMRI_map));

wEPI_dir = fullfile(work_dir, 'EPI');
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
Seedmap_dir = fullfile(work_dir, 'EPI', 'brain_ROI_DOC', network_name);
Seedmap_filename = spm_select('FPList',[Seedmap_dir], sprintf('^w.*\\.nii$'));
SeedAll_map  = zeros(size(wDMN_map0));
for i = 1: size(Seedmap_filename , 1)
    Seed_hdr = spm_vol(Seedmap_filename(i,: ));
    Seed_map = spm_read_vols(Seed_hdr);
    SeedAll_map = SeedAll_map + Seed_map;
end
SeedAll_map = rot90_3D(SeedAll_map, 3, 3);
fig_seed = figure('Name', strcat(subject_name, '_', network_name), 'NumberTitle','off');
axis off;
hold on;
ha = tight_subplot(max_column,max_row,[.01 .01],[.01 .01],[.01 .01]);

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
        axes(ha(loop_counter));
        image(axial_slice_2D_RGB);hold on;
        set(gca,'YDir','normal');
        axis('image');  %%% Make the proportions of the image correct
        axis('off');    %%% Turn off the numbers on the x- and y-axes
        text(gca,6,10,'L','Color',[1 1 1],'FontWeight','bold');
        text(gca, size(axial_slice_2D_RGB,1)-6*1.5, 10, 'R','Color',[1 1 1],'FontWeight','bold');
        hold off;
    else
        axes(ha(loop_counter));
        image(axial_slice_2D_RGB);
        set(gca,'YDir','normal');
        axis('image');  %%% Make the proportions of the image correct
        axis('off');    %%% Turn off the numbers on the x- and y-axes
        
    end
    
end;    %%% The end of this for-loop
export_fig(fullfile(result_dir,strcat(network_name, '_all_ROI.jpg'))) ;


%%%%%%%%%%%% Z map **************************************************
Tmap_dir = fullfile(work_dir, 'result_6BN', network_name);
n_Tmap = size(dir(Tmap_dir),1) -2 ;

for i = 1: n_Tmap;
    Tmap_file = spm_select('FPList',[Tmap_dir],[sprintf('^%02d.*\\.nii$', i)]);
    
    [Tmap_file_dir , T_map_filename ] = fileparts(Tmap_file);
    parts = msong_strsplit('_', T_map_filename);
    ROI_name = char(parts{3});
    
    fig_Tmap = figure('Name', sprintf('%s', ROI_name),'NumberTitle','off');
    ha = tight_subplot(max_column,max_row,[.01 .01],[.01 .01],[.01 .01]);
    
    %Tmap_file = Tmap_path;
    Tmap_hdr = spm_vol(Tmap_file);
    Tmap = spm_read_vols(Tmap_hdr);
    Tmap = rot90_3D( Tmap, 3,3 );
    Tmap(isinf(Tmap)) = 0;  % 2020/11/8, msong
    thresholded_Tmap = ( Tmap > T_threshold ) .* Tmap;
    Tmap01 = thresholded_Tmap ./ max(thresholded_Tmap(:));
    Tmap0_63 = round( 63 * Tmap01 );
    Tmap64 = 1 + Tmap0_63;
    
    anat_RGB = zeros(size(anat64,1), size(anat64,2), size(anat64,3),3);
    Tmap_RGB = zeros(size(Tmap64,1), size(Tmap64,2), size(Tmap64,3),3);
    
    gray_cmap = colormap('gray');   %%% This reads in the current colormap matrix
    hot_cmap = colormap('hot');
    
    for RGB_dim = 1:3,  %%% Loop through the three slabs: R, G, and B
        
        gray_cmap_rows_for_anat = anat64;
        hot_cmap_rows_for_Tmap = Tmap64;
        
        colour_slab_vals_for_anat = gray_cmap(gray_cmap_rows_for_anat, RGB_dim);
        colour_slab_vals_for_Tmap = hot_cmap(hot_cmap_rows_for_Tmap, RGB_dim);
        
        anat_RGB(:,:,:,RGB_dim) = reshape( colour_slab_vals_for_anat, size(anat64));
        Tmap_RGB(:,:,:,RGB_dim) = reshape( colour_slab_vals_for_Tmap, size(Tmap64));
        
    end;  % End of loop through the RGB dimension.
    
    Tmap_opacity = 1;     % 0.4 is a reasonable opacity value to try first
    
    compound_RGB = zeros(size(anat64,1), size(anat64,2), size(anat64,3),3);
    
    for RGB_dim = 1:3,  %%% Loop through the three slabs: R, G, and B
        compound_RGB(:,:,:,RGB_dim) = ...
            (thresholded_Tmap==0) .* ...    % Where T-map is below threshold
            anat_RGB(:,:,:,RGB_dim) + ...
            (thresholded_Tmap>0).* ...      % Where T-map is above threshold
            ( (1-Tmap_opacity) * anat_RGB(:,:,:,RGB_dim) + ...
            Tmap_opacity * Tmap_RGB(:,:,:,RGB_dim) );
        % Opacity-weighted sum of anatomical and T-map
    end;
    compound_RGB = min(compound_RGB,1);
    
    for loop_counter = 1:max_row* max_column -1,     %%% Go around 9 times, adding one to the
        %%% value of loop_counter each time.
        axial_slice_number = gap*loop_counter + initial_axial_slice_number;
        axial_slice_vals = compound_RGB(:,:,axial_slice_number,:);
        axial_slice_2D_RGB = squeeze(axial_slice_vals);
        axes(ha(loop_counter));
        image(axial_slice_2D_RGB);
        set(gca,'YDir','normal');
        axis('image');  %%% Make the proportions of the image correct
        axis('off');    %%% Turn off the numbers on the x- and y-axes
        
    end;    %%% The end of this for-loop
    
    %subplot(3,3,loop_counter+1);
%     axes(ha(loop_counter+1));
%     axis('image');  %%% Make the proportions of the image correct
%     axis('off');    %%% Turn off the numbers on the x- and y-axes
%     colormap hot;
%     
%     max_Tmap_value = max(Tmap(:));
%     
%     desired_colorbar_labels =floor(10*linspace(0, max_Tmap_value,5))/10;
%     corresponding_values_on_0_to_1_scale = ...
%         0 +  ( 1 * desired_colorbar_labels / max_Tmap_value );
%     
%     h = colorbar('location','west');   %%% h is the handle of the colorbar
%     set(h, 'YLim', [0 1]);
%     set(h,'YTick',corresponding_values_on_0_to_1_scale);
%     set(h,'YTickLabel',desired_colorbar_labels);
    axes(ha(loop_counter+1));
    colormap hot;
    h = colorbar('location','west');   %%% h is the handle of the colorbar
    
    max_Tmap_value = max(Tmap(:));
    
    desired_colorbar_labels =linspace(0, max_Tmap_value,5);
    corresponding_values_on_1_to_64_scale = ...
        1 +  ( 63 * desired_colorbar_labels / max_Tmap_value );
    desired_colorbar_labels = roundn(desired_colorbar_labels,-2);
    set(h,'YTick',corresponding_values_on_1_to_64_scale/64);
    %yticklabels(cellstr(string(desired_colorbar_labels)));
    set(h,'YTickLabel',cellstr(string(desired_colorbar_labels)));
    %set(h,'YTickLabel',desired_colorbar_labels);
    axis('image');  %%% Make the proportions of the image correct
    axis('off');    %%% Turn off the numbers on the x- and y-axes
    
    ROI_name2 = strcat(ROI_name, '.jpg');
    %print(fig_Tmap,'-djpeg',fullfile(result_dir,ROI_name2));
    export_fig(fullfile(result_dir,ROI_name2));
    
end
