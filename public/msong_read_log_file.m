function patient_info = msong_read_log_file(log_file_path)

log_file_fid = fopen(log_file_path);

patient_info_cell = textscan(log_file_fid, '%s');

input_name = patient_info_cell{1,1}{2};
k = strfind(input_name, 'Input');
if(k>0)
    % line 4:
    patient_result_cell_temp =  strtrim(patient_info_cell{1,1}{4}); 
    parts = msong_strsplit(':', patient_result_cell_temp);
    patient_info{1,1} =  parts{1}; 
    patient_info{1,2} =  parts{2}; 
    % line 5:
    patient_result_cell_temp =  strtrim(patient_info_cell{1,1}{5}); 
    parts = msong_strsplit(':', patient_result_cell_temp);
    patient_info{2,1} =  parts{1}; 
    patient_info{2,2} =  parts{2}; 
    % line 6:
    patient_result_cell_temp =  strtrim(patient_info_cell{1,1}{6}); 
    parts = msong_strsplit(':', patient_result_cell_temp);
    patient_info{3,1} =  parts{1}; 
    patient_info{3,2} =  parts{2};     

    % line 11:
    patient_result_cell_temp =  strtrim(patient_info_cell{1,1}{11}); 
    parts = msong_strsplit(':', patient_result_cell_temp);
    patient_info{4,1} =  parts{1}; 
    patient_info{4,2} =  parts{2}; 
    
else
    error('read log file: %s',log_file_path);
end

% simplify 
if(strfind(patient_info{2,1}, 'age'))
    patient_info{2,1} = 'Age';
end
if(strfind(patient_info{3,1}, 'Duration'))
    patient_info{3,1} = 'Duration';
end
if(strfind(patient_info{4,1}, 'probability'))
    patient_info{4,1} = 'PLS_prediction';
end

fclose(log_file_fid);



