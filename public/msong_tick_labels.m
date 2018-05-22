function tick_labels = msong_tick_labels(section)
% section : a number array

n_section = numel(section) + 1;
tick_labels = cell(n_section, 1);
% tick_labels{1} = sprintf('Tp<%d', section(1));
% for i = 2: n_section-1
%     tick_labels{i} = sprintf('%d<=Tp<%d', section(i-1), section(i));
% end
% tick_labels{i+1} = sprintf('Tp>=%d', section(i));

tick_labels{1} = sprintf('¡Ü%d', section(1));
for i = 2: n_section-1
    tick_labels{i} = sprintf('[%d, %d)', section(i-1), section(i));
end
tick_labels{i+1} = sprintf('¡Ý%d', section(i));
 
