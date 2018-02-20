function [coordinate] = find_voxel(volume)
x = size(volume ,1);
y = size(volume ,2);
z = size(volume ,3);

index = find(volume(:)>0);
coordinate = zeros(numel(index),3);
for i = 1 : numel(index)
    coordinate(i,3) = ceil(index(i)/(x*y));
    coordinate(i,2) = ceil( ( index(i) - (x*y)*(coordinate(i,3)-1) )/x);
    coordinate(i,1) = index(i) - (x*y)*(coordinate(i,3)-1) - (coordinate(i,2)-1)*x ; 
end
