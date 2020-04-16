function [label_probabiltiy] = f_calculate_label_probability(subject_list_file, testing_score_v, training_score, training_label, label_threshold)

%% calculate the probability of each cluster that are by thresholding the training label)
%
% msong@nlpr.ia.ac.cn

width_section = 3;

testing_score = testing_score_v(1);
yfit_intercept = testing_score_v(2);
yfit_image = testing_score_v(3);
yfit_clinical = testing_score_v(4);


[directory, subject_name] = fileparts(subject_list_file);
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


if(nargin<6)
    fig6 = figure('Name', 'Prognositication with rs-fMRI and clinical characteristics','NumberTitle','off','Tag','fig_results');
    set(fig6,'units','centimeters','position',[3 3 25 10],'color','w');

    %     label_threshold =2;
    %
    %     %%
    %     low_label_index = find(training_label <= label_threshold);  % GOS 1,2 : non_recovery
    %     high_label_index = find(training_label > label_threshold);  % GOS 3,4,5 : recovery
    %
    %     %%  prediction and awaken ratio ( section computation)
    %     section = [2:width_section:25];
    %     n_section = numel(section) +1;
    %     index_awaken_subject = high_label_index ;
    %     label_awaken_subject = zeros(numel(training_score),1);
    %     label_awaken_subject(index_awaken_subject) = 1;
    %     [prediction_sort, ind] = sort(training_score);
    %     %awaken_ratio_array = zeros(n_section, 1);
    %     awaken_count_array = zeros(n_section, 2);
    %     hold on;
    %     start_point = prediction_sort(1);
    %     % smaller than or equal to section(1)
    %     for i = 1: n_section
    %         if(i~=n_section)
    %             end_point = section(i);
    %         else
    %             end_point = prediction_sort(end);
    %         end
    %         i_section_subject = (training_score<end_point) & (training_score >= start_point) ;
    %         i_section_awaken = i_section_subject.* label_awaken_subject;
    %         n_awaken = sum(i_section_awaken(:));
    %         n_nonawaken = numel(find(i_section_subject>0)) - n_awaken;
    %         awaken_count_array(i, 1) = n_nonawaken;
    %         awaken_count_array(i, 2) = n_awaken;
    %         start_point = end_point;
    %     end
    %     awaken_ratio_array = awaken_count_array(:,2)./sum(awaken_count_array,2);
    %
    %     b= isnan(awaken_ratio_array) ;
    %     c=~b;
    %     d =find(c,1,'last');
    %
    %     for i=d: numel(awaken_ratio_array)
    %         awaken_ratio_array(i) = 1;
    %     end
    %
    %     tick_labels = msong_tick_labels(section);
    %
    %     subplot(4,3,[1 4 7 10]);
    %     hold on;
    %     barh(awaken_ratio_array, 'c');
    %     title('Prognositication with rs-fMRI and clinical characteristics');
    %     plot(awaken_ratio_array,[1: numel(awaken_ratio_array)], ':^r','LineWidth',2,'markerfacecolor','r');
    %     set(gca,'YTick',[1: numel(awaken_ratio_array)]); ylabel('Predicted Score');
    %     set(gca,'YTickLabel',tick_labels); xlabel('Consciousness Recovery Probability');
    %     xlim([0, 1.1]);
    %     my_ylim = ylim();
    %     ylim(my_ylim);
    %     dashline(ones(size([0:0.1:4]))*awaken_ratio_array(4),[0:0.1:4], 2,2,2,2, 'color',[.75 .75 .75]);
    %     dashline(ones(size([0:0.1:5]))*awaken_ratio_array(5),[0:0.1:5], 2,2,2,2, 'color',[.75 .75 .75]);
    %     dashline(ones(size([0:0.1:6]))*awaken_ratio_array(6),[0:0.1:6], 2,2,2,2, 'color',[.75 .75 .75]);
    %     dashline(ones(size([0:0.1:7]))*awaken_ratio_array(7),[0:0.1:7], 2,2,2,2, 'color',[.75 .75 .75]);
    %     text(awaken_ratio_array(4)+0.015, 4-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(4)*100),'FontSize',8);
    %     text(awaken_ratio_array(5)+0.015, 5-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(5)*100),'FontSize',8);
    %     text(awaken_ratio_array(6)+0.015, 6-0.55, sprintf('%3.1f%%\n', awaken_ratio_array(6)*100),'FontSize',8);
    %
    %     %title(sprintf('%s\n', 'Recover Rate in PLA Army General Hospital'));
    %
    %     hold off;
    
    alpha_file  = 'alpha_samples.txt';
    alpha = importdata(alpha_file);
    
    beta_file  = 'beta_samples.txt';
    beta = importdata(beta_file);
    %probabiltiy = msong_logistic(testing_score, mean(beta), mean(alpha));
    
    index = 0;
    step = 1;
    for score = -2: step: 25
        
        index = index +1;
        p_all = msong_logistic(score, beta', alpha');
        p_all_mean(index) = mean(p_all);
        y(index, :) = quantile(p_all,[0.05 0.95]);
        
    end
    
    subplot(4,3,[1 4 7 10]);
    title('Posterior probability estimates for consciousness recovery');
    xlabel('Predicted score');
    ylabel('Probability estimate');
    
    hold on;
    x_range = [-2:step:25];
    h1 = plot(x_range, p_all_mean,'r-','LineWidth',2);
    h2 = plot(x_range, y(:,1), 'b--');
    plot(x_range, y(:,2),'b--');
    legend([h1 h2], 'average probability','95% CI','Location','NorthWest');
    
    
    a_score = testing_score;
    p_a = msong_logistic(a_score, beta', alpha');
    p_a_mean = mean(p_a);
    y_a = quantile(p_a,[0.05 0.95]);
    
    x2_lim = ones(100,1)*a_score;
    p_lim = linspace(0, p_a_mean, 100);
    x_min = xlim;
    x3_lim = linspace(x_min(1), a_score, 100);
    
    dashline(x2_lim, p_lim, 2,2,2,2, 'color',[.5 .5 .5]);
    dashline(x3_lim, p_a_mean* ones(100,1), 2,2,2,2, 'color',[.5 .5 .5]);
    
    plot(a_score, p_a_mean, 'rs');
    plot(a_score, y_a(1),'bo');
    plot(a_score, y_a(2),'bo');
    if(p_a_mean>0.8)
        text(18, p_a_mean - 0.1, sprintf('probability = %3.2f\n95%% CI = [%3.2f,%3.2f]', p_a_mean, y_a(1), y_a(2)));
    elseif(p_a_mean>0.5)
        text(a_score + 1, p_a_mean - 0.1, sprintf('probability = %3.2f\n95%% CI = [%3.2f,%3.2f]', p_a_mean, y_a(1), y_a(2)));
    else
        text(a_score - 5, p_a_mean + 0.1, sprintf('probability = %3.2f\n95%% CI = [%3.2f,%3.2f]', p_a_mean, y_a(1), y_a(2)));
    end
    % text(a_score - 2, y_a(2)+0.02, sprintf('%3.2f', y_a(2)));
    % text(a_score + 0.5, y_a(1)-0.02, sprintf('%3.2f', y_a(1)));
    
    
    
    hold off;
    
    
    
    subplot(4,3,[2 3]);  hold on;
    text_descend = 0.15;
    axis off;
    text(0,1-text_descend,  sprintf('Patient name : %s', subject_name),'FontSize',12);
    clinical_characteristics_path = fullfile(subject_directory, 'clinical_characteristics.txt');
    [age, duration, etiology] = f_read_clinical_characteristics(clinical_characteristics_path);
    switch etiology
        case 1
            etiology_str = 'Trauma';
        case 2
            etiology_str = 'Stroke';
        case 3
            etiology_str = 'Anoxia';
    end
    
    text(0.05,0.5-text_descend,  sprintf('\tEtiology = %s', etiology_str),'FontSize',10);
    text(0.05,0.2-text_descend,  sprintf('\tIncidence age = %4.1f years', age),'FontSize',10);
    text(0.05,-0.1-text_descend,  sprintf('\tDuration of unconsciousness = %4.1f months', duration),'FontSize',10);
    
    hold off;
    
    subplot(4,3, [5 6]); axis off; hold on;
    dashline([0:0.1:1],ones(size([0:0.1:1]))*(1-text_descend), 1,1,1,1, 'color',[.75 .75 .75]);
    [headmotion, T_FD] = f_head_motion_evaluation(subject_list_file);
    for j =4:6
        headmotion(:,j) = headmotion(:,j).*50;
    end
    T = size(headmotion,1);
    ratio_T = T_FD./T*100;
    text(0,0.8-text_descend, sprintf('fMRI quality: '),'FontSize',12);
    text(0.05,0.5-text_descend, sprintf('\ttotal T = %d', T),'FontSize',10);
    text(0.05,0.2-text_descend, sprintf('\teffective T = %d; %4.2f%% of the total volumes', T_FD, ratio_T),'FontSize',10);
    
    
    hold off;
    
    subplot(4,3, 8); axis off; hold on;
    %% mean fMRI
    program_location = which('pDOC');
    [program_dir] = fileparts(program_location);
    network_name_total = msong_load_network_name(fullfile(program_dir, 'model', 'network_name.txt'));
    
    
    EPI_directory = fullfile(fMRI_directory,'EPI');
    ROI_dir = fullfile(EPI_directory, 'brain_ROI_DOC');                       %   the path of the ROI file
    network_name = char(network_name_total{1});  % DMN
    
    mean_fMRI_file = spm_select('FPList',[fMRI_directory],[strcat('^mean.*\.nii$')]);
    mean_fMRI_hdr = spm_vol(mean_fMRI_file );
    
    dim_mean_fMRI = mean_fMRI_hdr.dim;
    z_mean_fMRI = dim_mean_fMRI(3);
    show_z = ceil(sqrt(z_mean_fMRI));
    
    max_row = 1;
    max_column = 1;
    gap = 5;
    initial_axial_slice_number= round(z_mean_fMRI/2);
    
    
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
    
    
    %%% value of loop_counter each time.
    axial_slice_number = initial_axial_slice_number;
    axial_slice_vals = compound_RGB(:,:,axial_slice_number,:);
    axial_slice_2D_RGB = squeeze(axial_slice_vals);
    
    %
    
    %axes(ha(loop_counter));
    image(axial_slice_2D_RGB);hold on;
    set(gca,'YDir','normal');
    axis('image');  %%% Make the proportions of the image correct
    axis('off');    %%% Turn off the numbers on the x- and y-axes
    text(6,10,'L','Color',[1 1 1],'FontWeight','bold');
    text(size(axial_slice_2D_RGB,1)-6*1.5, 10, 'R','Color',[1 1 1],'FontWeight','bold');
    hold off;
    
    
    subplot(4,3, 9); axis off; hold on;
    %% compute the overlay ratio for wmaskEPI_V2mm_float32.nii and rmaskEPI_V2mm_float32.nii
    f_mask = spm_select('FPList', EPI_directory,  '^maskEPI_V2mm_float32.*\.nii$') ;
    wmask_file = char(editfilenames(f_mask,'prefix','w'));
    rmask_file = char(editfilenames(f_mask,'prefix','r'));
    [ratio_intersection] = msong_calculate_intersection(wmask_file, rmask_file);
    %fprintf('intersection between mask & brain: %4.3f\n', ratio_intersection);
    if(ratio_intersection<0.5)
        text(-0.5,0.8, '\leftarrowWarning! Too low registration quality for fMRI',...
            'EdgeColor','red','FontSize',12);
        text(-0.2, 0.4, 'maybe because of cranioplasty, incomplete brain, etc.','FontSize',10);
        text(-0.2,0.1,  sprintf('brain intersection ratio = %4.2f', ratio_intersection),'FontSize',10, 'Color', 'red');
    else
        text(0,0.3,  sprintf('brain intersection ratio = %4.2f', ratio_intersection),'FontSize',10);
    end
    hold off;
    
    subplot(4,3,[11 12]); axis off; hold on;
    dashline([0:0.1:1],ones(size([0:0.1:1]))*(1-text_descend), 1,1,1,1, 'color',[.75 .75 .75]);
    
    
    %     index = find(section<=testing_score, 1, 'last');
    %     index = index +1;
    %
    %     probabiltiy = awaken_ratio_array(index);
    
    
    follow_up_result = 'Consciousness recovery probability';
    fprintf('%s: p=%3.2f\n', follow_up_result, p_a_mean);
    text(0,0.85-text_descend,  sprintf('Predicted Result'),'FontSize',12);
    text(0.05,0.6-text_descend,  sprintf('\tPredicted total score = %4.2f', testing_score),'FontSize',10,'color','red');
    text(0.05,0.3-text_descend,  sprintf('\t\t\t interception= %4.2f, imageScore= %4.2f, clinicalScore= %4.2f', yfit_intercept, yfit_image, yfit_clinical),'FontSize',10);
    text(0.05,0-text_descend,  sprintf('\t%s = ', follow_up_result),'FontSize',10);
    text(0.8,0-text_descend,  sprintf('%3.2f',  p_a_mean),'FontSize',10,'color','red');
    hold off;
    
    label_probabiltiy(1) = 1;  % recovery
    label_probabiltiy(2) = p_a_mean;
    
    print(fig6, '-djpeg',fullfile(result_dir,  'prognostication_result'));
    
    if(ratio_intersection<0.5)
        warndlg('Too low registration quality for fMRI that could make prediction incorrect!','!! Warning !!');
    end
    
else
    fprintf('Not support mulitple label\n');
    label_probabiltiy(1) = -1;  % recovery
    label_probabiltiy(2) = 0;
end




