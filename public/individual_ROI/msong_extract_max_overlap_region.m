function selectedRegion = msong_extract_max_overlap_region(A, B)
    % 输入：
    % A: 3D 二值矩阵，只含一个小连通区域为 1
    % B: 3D 二值矩阵，含多个连通区域为 1
    % 输出：
    % selectedRegion: 与 A 中连通区域重合最多的 B 中连通区域（二值矩阵）

    % 对 B 中的所有连通区域进行标记
    CC = bwconncomp(B, 26);  % 26 连通性用于 3D
    labeledB = labelmatrix(CC);

    % 获取 A 中的连通区域索引（A中值为1的位置）
    idxA = find(A == 1);

    % 对每一个 B 中的连通区域计算与 A 重叠的体素数量
    numRegions = CC.NumObjects;
    overlapCounts = zeros(numRegions, 1);

    for i = 1:numRegions
        regionIdx = CC.PixelIdxList{i};
        overlapCounts(i) = numel(intersect(regionIdx, idxA));
    end

    % 找到与 A 重叠最多的那个区域
    [~, maxIdx] = max(overlapCounts);

    % 构造输出矩阵
    selectedRegion = zeros(size(B));
    selectedRegion(CC.PixelIdxList{maxIdx}) = 1;
end
