clear;
close all;

subject_directory = 'Z:\DOC_MRI_BJ\analysis\20250117_NC_test';
% [BOLD_directory] = msong_select_subdirectory('subdir', subject_directory,  '^0.*');
BOLD_directory = subject_directory;

n_BOLD_directory = size(BOLD_directory, 1);
if(n_BOLD_directory <1)
    error('No BOLD directory');
end

[~,subject_name] = fileparts(subject_directory);

for i = 1: n_BOLD_directory
    
    %%
    fMRI_4D_file_directory = strtrim(BOLD_directory(i,:));
    fprintf('%s\n', fMRI_4D_file_directory);
    
    % 初始化一个空的单页PDF
    import mlreportgen.dom.*;
    
    % 检索结果目录
    imageDir = fullfile(fMRI_4D_file_directory, 'fMRI','reports');
    out_dir = imageDir;
    [~,output_filename] = fileparts(fMRI_4D_file_directory);
    outputPDF = sprintf('%s_意识检测报告.pdf',output_filename); % 输出 PDF 文件名
    % 创建 PDF 文件
    doc = Document(fullfile(out_dir,outputPDF), 'pdf');
    
    % 插入图片标题
    para = Paragraph(sprintf('%s 意识检测报告',subject_name));
    para.Bold = true;
    para.FontSize = '18pt'; % 设置字体大小为 18pt
    para.BackgroundColor = 'yellow';
    para.HAlign = 'center'; % 设置居中对齐
    append(doc, para);
    
    % 插入空行
    append(doc, Paragraph(' '));
    
    % 获取结果目录中的图片结果文件
    imageFiles = dir(fullfile(imageDir, '*.jpg')); % 根据你的图片格式修改扩展名
    %[~, idx] = sort([imageFiles.datenum]); % 根据 datenum 字段进行排序
    idx = [4 2 1 5 3];
    tips{2} = '头动分析';
    tips{1} = '不同ROI的功能网络重合度';
    tips{5} = '脑功能网络活动强度与正常人常模Normal controls的对比';
    tips{3} = '意识状态相关的重要特征值及影像评分';
    tips{4} = '意识状态清醒概率估计';
    
    % 遍历所有图片
    for k = 1:length(idx)
        % 获取图片路径和名称
        imgPath = fullfile(imageDir, imageFiles(idx(k)).name);
        
        % 添加一些文字说明（示例文字）
        ROI_name = imageFiles(idx(k)).name;
        
        % 插入图片标题
        para = Paragraph(sprintf('(%d) %s:%s',k,tips{idx(k)},ROI_name));
        append(doc, para);
        % 插入空行
        append(doc, Paragraph(' '));
        
        % 插入图片
        if(k<length(idx))
            img = Image(imgPath);
            img.Width = '7in'; % 调整宽度
            img.Height = []; % 调整高度
            append(doc, img);
        else
            % 读取图片并裁剪中间部分
            originalImg = imread(imgPath);
            [height, width, ~] = size(originalImg);
            
            % 计算裁剪区域（保留中间部分，去除上下左右各 10%）
            cropRect = [width * 0.05, height * 0.1, width * 0.35, height * 0.8];
            croppedImg = imcrop(originalImg, cropRect);
            
            % 将裁剪后的图片保存到临时文件中
            croppedImgPath_1 = fullfile(fMRI_4D_file_directory, ['cropped_1_' imageFiles(idx(k)).name]);
            imwrite(croppedImg, croppedImgPath_1);
            
            % 插入裁剪后的图片
            img = Image(croppedImgPath_1);
            img.Width = '4.5in';  % 设置宽度为 7 英寸
            img.Height = [];    % 让高度自动按比例缩放
            append(doc, img);
            
           %%
            % 计算裁剪区域（保留中间部分，去除上下左右各 10%）
            cropRect = [width * 0.45, height * 0.1, width * 0.55, height * 0.8];
            croppedImg = imcrop(originalImg, cropRect);
            
            % 将裁剪后的图片保存到临时文件中
            croppedImgPath_2 = fullfile(fMRI_4D_file_directory, ['cropped_2_' imageFiles(idx(k)).name]);
            imwrite(croppedImg, croppedImgPath_2);
            
            % 插入裁剪后的图片
            img = Image(croppedImgPath_2);
            img.Width = '6.8in';  % 设置宽度为 7 英寸
            img.Height = [];    % 让高度自动按比例缩放
            append(doc, img);            
            
        end
        
        % 插入空行
        append(doc, Paragraph(' '));
        
        % 插入空行
        append(doc, Paragraph('免责声明：本报告只提供科研参考，不能作为临床诊断和治疗的依据！ '));
        
        % 插入分页符
        append(doc, PageBreak);
    end
    
    % 设置DMN的目录
    imageDir = fullfile(fMRI_4D_file_directory, 'fMRI','reports','DMN');
    out_dir = imageDir;
    
    % 获取DMN目录中的所有图片文件
    imageFiles = dir(fullfile(imageDir, '*.jpg')); % 根据你的图片格式修改扩展名
    [~, idx] = sort([imageFiles.datenum]); % 根据 datenum 字段进行排序
    imageFiles = imageFiles(idx);
    
    % 遍历所有图片
    for k = 1:length(imageFiles)
        % 获取图片路径和名称
        imgPath = fullfile(imageDir, imageFiles(k).name);
        
        % 添加一些文字说明（示例文字）
        ROI_name = imageFiles(k).name;
        
        if(k==1)
            textPara = Paragraph('附：默认网络（DMN）4个ROI的解剖位置(如下图蓝色标识)及功能连接图');
            append(doc, textPara);
            for j = 2:length(imageFiles)
                ROI_name2 = imageFiles(j).name;
                textPara = Paragraph(sprintf('(%d) %s', j-1, ROI_name2(1:end-4)));
                append(doc, textPara);
            end
        else
            textPara = Paragraph(sprintf('(%d) %s的功能连接图', k-1, ROI_name(1:end-4)));
            append(doc, textPara);
        end
        
        % 插入空行
        append(doc, Paragraph(' '));
        
        %     % 插入图片标题
        %     para = Paragraph(imageFiles(k).name);
        %     append(doc, para);
        
        % 插入图片
        img = Image(imgPath);
        img.Width = '7in'; % 调整宽度
        img.Height = '5.6in'; % 调整高度
        append(doc, img);
        
        % 插入空行
        append(doc, Paragraph(' '));
        if(k~=1)
            textPara = Paragraph(sprintf('图片描述: 图中的像素和ROI之间的功能连接强度越大，颜色越亮；落在黑色轮廓线内的区域越多，表示连接的DMN脑区范围越广。'));
            append(doc, textPara);
        else
            % 插入空行
            append(doc, Paragraph(' '));
            append(doc, Paragraph(' '));
        end
        
        if(k <length(imageFiles))
            % 插入分页符
            append(doc, PageBreak);
        end
        
    end
    
    % 关闭并保存PDF
    close(doc);
    
end
fprintf('finish.\n');
