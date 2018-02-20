function [GOS] = f_regulate_GOS(GOS_pro_cell)
%% regulate GOS cell to an array of integer
% msong@nlpr.ia.ac.cn

n = size(GOS_pro_cell,1);
GOS = zeros(n,1);
for i =1 : n
    temp = strtrim(char(GOS_pro_cell{i}));
    GOS(i) = str2num(temp(1));
end