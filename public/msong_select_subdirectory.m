function [sub_directory] = msong_select_subdirectory(type, directory, filter)
% type = 'subdir';
% directory = 'I:\beizong\20160608_milestone1\MCS\0\LiuChunguan';
% filter =  '^BOLD.*';

index = 1;
sub_directory = cell(index,1);
switch type
    case 'subdir'
        all_directory = dir(directory);
        for i = 1:size(all_directory, 1)
                s = regexp(all_directory(i,:).name, filter);
            if(numel(s)>0)
                sub_directory{index} = fullfile(directory, all_directory(i,:).name);
                index = index +1;
            end
        end
end
if(index>1)
    sub_directory = char(sub_directory);
else
    sub_directory = '';
end
%sub_directory