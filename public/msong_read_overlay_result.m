
function ROI_result_cell = msong_read_overlay_result(result_file_path)

file_result_fid = fopen(result_file_path);

file_result_cell = textscan(file_result_fid, '%s');

% DMN
DMN_name = file_result_cell{1,1}{1};
k = strfind(DMN_name, '_DMN');
if(k>0)
    ROI_result_cell{1,1} =  strcat('DMN_',file_result_cell{1,1}{2}); 
    ROI_result_cell{1,2} =  file_result_cell{1,1}{6}; 
    ROI_result_cell{2,1} =  strcat('DMN_',file_result_cell{1,1}{3}); 
    ROI_result_cell{2,2} =  file_result_cell{1,1}{7};
    ROI_result_cell{3,1} =  strcat('DMN_',file_result_cell{1,1}{4}); 
    ROI_result_cell{3,2} =  file_result_cell{1,1}{8};    
    ROI_result_cell{4,1} =  strcat('DMN_',file_result_cell{1,1}{5}); 
    ROI_result_cell{4,2} =  file_result_cell{1,1}{9};
else
    error('read overlay file: DMN for %s',result_file_path);
end

% ExecuContr
ExecuContr_name = file_result_cell{1,1}{10};
k = strfind(ExecuContr_name, '_ExecuContr');
if(k>0)
    ROI_result_cell{5,1} =  strcat('ExecuContr_',file_result_cell{1,1}{11}); 
    ROI_result_cell{5,2} =  file_result_cell{1,1}{16}; 
    ROI_result_cell{6,1} =  strcat('ExecuContr_',file_result_cell{1,1}{12}); 
    ROI_result_cell{6,2} =  file_result_cell{1,1}{17};
    ROI_result_cell{7,1} =  strcat('ExecuContr_',file_result_cell{1,1}{13}); 
    ROI_result_cell{7,2} =  file_result_cell{1,1}{18};    
    ROI_result_cell{8,1} =  strcat('ExecuContr_',file_result_cell{1,1}{14}); 
    ROI_result_cell{8,2} =  file_result_cell{1,1}{19};
    ROI_result_cell{9,1} =  strcat('ExecuContr_',file_result_cell{1,1}{15}); 
    ROI_result_cell{9,2} =  file_result_cell{1,1}{20};    
else
    error('read overlay file: ExecuContr');
end

% Salience
Salience_name = file_result_cell{1,1}{21};
k = strfind(Salience_name, '_Salience');
if(k>0)
    ROI_result_cell{10,1} =  strcat('Salience_',file_result_cell{1,1}{22}); 
    ROI_result_cell{10,2} =  file_result_cell{1,1}{25}; 
    ROI_result_cell{11,1} =  strcat('Salience_',file_result_cell{1,1}{23}); 
    ROI_result_cell{11,2} =  file_result_cell{1,1}{26};
    ROI_result_cell{12,1} =  strcat('Salience_',file_result_cell{1,1}{24}); 
    ROI_result_cell{12,2} =  file_result_cell{1,1}{27};    
else
    error('read overlay file: Salience');
end

% Sensorimotor
Sensorimotor_name = file_result_cell{1,1}{28};
k = strfind(Sensorimotor_name, '_Sensorimotor');
if(k>0)
    ROI_result_cell{13,1} =  strcat('Sensorimotor_',file_result_cell{1,1}{29}); 
    ROI_result_cell{13,2} =  file_result_cell{1,1}{32}; 
    ROI_result_cell{14,1} =  strcat('Sensorimotor_',file_result_cell{1,1}{30}); 
    ROI_result_cell{14,2} =  file_result_cell{1,1}{33};
    ROI_result_cell{15,1} =  strcat('Sensorimotor_',file_result_cell{1,1}{31}); 
    ROI_result_cell{15,2} =  file_result_cell{1,1}{34};    
else
    error('read overlay file: Sensorimotor');
end

% Auditory
Auditory_name = file_result_cell{1,1}{35};
k = strfind(Auditory_name, '_Auditory');
if(k>0)
    ROI_result_cell{16,1} =  strcat('Auditory_',file_result_cell{1,1}{36}); 
    ROI_result_cell{16,2} =  file_result_cell{1,1}{39}; 
    ROI_result_cell{17,1} =  strcat('Auditory_',file_result_cell{1,1}{37}); 
    ROI_result_cell{17,2} =  file_result_cell{1,1}{40};
    ROI_result_cell{18,1} =  strcat('Auditory_',file_result_cell{1,1}{38}); 
    ROI_result_cell{18,2} =  file_result_cell{1,1}{41};    
else
    error('read overlay file: Auditory');
end

% Visual
Visual_name = file_result_cell{1,1}{42};
k = strfind(Visual_name, '_Visual');
if(k>0)
    ROI_result_cell{19,1} =  strcat('Visual_',file_result_cell{1,1}{43}); 
    ROI_result_cell{19,2} =  file_result_cell{1,1}{47}; 
    ROI_result_cell{20,1} =  strcat('Visual_',file_result_cell{1,1}{44}); 
    ROI_result_cell{20,2} =  file_result_cell{1,1}{48};
    ROI_result_cell{21,1} =  strcat('Visual_',file_result_cell{1,1}{45}); 
    ROI_result_cell{21,2} =  file_result_cell{1,1}{49};    
    ROI_result_cell{22,1} =  strcat('Visual_',file_result_cell{1,1}{46}); 
    ROI_result_cell{22,2} =  file_result_cell{1,1}{50};    
else
    error('read overlay file: Visual');
end


fclose(file_result_fid);

