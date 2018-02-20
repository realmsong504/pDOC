function [age, duration, etiology] = f_read_clinical_characteristics(subject_path)
%% load clinical characteristics for DOC
% age: years
% duration: months
% etiology: 1: trauma; 2: stroke; 3: anoxia
% msong@nlpr.ia.ac.cn

if(~exist( subject_path,'file'))
    fprintf('%s \s', subject_path);
    error('clinical characteristics Not exist');
end

fid = fopen(subject_path,'r');
index = 0;

age = 0;
duration = 0;
etiology = 3;

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    index=index+1;
    str = strtrim(tline);
    k = strfind(tline, ':');
    if(k>0)  %':'
        parts = msong_strsplit(':', str);
        item = strtrim(char(parts{1}));
        if(strcmpi(item, 'age'))
            value = str2num(strtrim(parts{2}));
            age = value;
        elseif (strcmpi(item, 'duration'))
            value = str2num(strtrim(parts{2}));
            duration = value;
        elseif (strcmpi(item, 'etiology'))
            value = strtrim(parts{2});
            if (strcmpi(value(1),'t'))
                etiology = 1;
            elseif (strcmpi(value(1),'s'))
                etiology = 2;
            else
                etiology = 3;
            end
        end
    else  % ','
        parts = msong_strsplit(',', str);
        item = strtrim(char(parts{1}));
        if(strcmpi(item, 'age'))
            value = str2num(strtrim(char(parts{2})));
            age = value;
        elseif (strcmpi(item, 'duration'))
            value = str2num(strtrim(char(parts{2})));
            duration = value;
        elseif (strcmpi(item, 'etiology'))
            value = strtrim(char(parts{2}));
            if (strcmpi(value(1),'t'))
                etiology = 1;
            elseif (strcmpi(value(1),'s'))
                etiology = 2;
            else
                etiology = 3;
            end
        end
        
    end
    
end
fclose(fid);



