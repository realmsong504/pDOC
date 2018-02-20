function [G_show, G_index] = msong_cell_sort(G, order)
% sort string cell according to the specific order
n_cell = size(G, 1);
if(n_cell==1)
    n_cell = size(G,2);
end
n_item = size(order, 1);
if(n_item ==1)
    n_item = size(order, 2);
end

index = zeros(n_cell, 1);
G_show = cell(size(G));
for i =1: n_item
    item = char(order{i});
    for j = 1: n_cell
        temp = char(G{j});
        if(strcmp(item, temp))
            index(j) = i;
            %G_show{j} = item;
        end
    end
end

G_index = index;
G_show =  order(sort(G_index));