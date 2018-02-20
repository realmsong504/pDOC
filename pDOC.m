function varargout = pDOC(varargin)
% MAIN_PROGNOSTICATION_DOC MATLAB code for pDOC.fig
%      MAIN_PROGNOSTICATION_DOC, by itself, creates a new MAIN_PROGNOSTICATION_DOC or raises the existing
%      singleton*.
%
%      H = MAIN_PROGNOSTICATION_DOC returns the handle to a new MAIN_PROGNOSTICATION_DOC or the handle to
%      the existing singleton*.
%
%      MAIN_PROGNOSTICATION_DOC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_PROGNOSTICATION_DOC.M with the given input arguments.
%
%      MAIN_PROGNOSTICATION_DOC('Property','Value',...) creates a new MAIN_PROGNOSTICATION_DOC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pDOC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pDOC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pDOC

% Last Modified by GUIDE v2.5 03-Feb-2018 16:43:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pDOC_OpeningFcn, ...
                   'gui_OutputFcn',  @pDOC_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pDOC is made visible.
function pDOC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pDOC (see VARARGIN)

% Choose default command line output for pDOC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pDOC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pDOC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pm_etiology.
function pm_etiology_Callback(hObject, eventdata, handles)
% hObject    handle to pm_etiology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_etiology contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_etiology


% --- Executes during object creation, after setting all properties.
function pm_etiology_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_etiology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_incidence_age_Callback(hObject, eventdata, handles)
% hObject    handle to e_incidence_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_incidence_age as text
%        str2double(get(hObject,'String')) returns contents of e_incidence_age as a double


% --- Executes during object creation, after setting all properties.
function e_incidence_age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_incidence_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_duration_Callback(hObject, eventdata, handles)
% hObject    handle to e_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_duration as text
%        str2double(get(hObject,'String')) returns contents of e_duration as a double


% --- Executes during object creation, after setting all properties.
function e_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_rsfMRI.
function cb_rsfMRI_Callback(hObject, eventdata, handles)
% hObject    handle to cb_rsfMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_rsfMRI
if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take approriate action
    set(handles.pb_choose_fMRI_directory,'Enable','on');
    set(handles.e_rsfMRI_directory,'Enable','on');
    set(handles.e_rsfMRI_directory,'String','Please choose or input ...');
else
    % Checkbox is not checked-take approriate action
    set(handles.pb_choose_fMRI_directory,'Enable','inactive');
    set(handles.e_rsfMRI_directory,'String','NULL');
    set(handles.e_rsfMRI_directory,'Enable','inactive');
end


% --- Executes on button press in pb_calculation.
function pb_calculation_Callback(hObject, eventdata, handles)
% hObject    handle to pb_calculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(handles.cb_rsfMRI, 'Value') == get(handles.cb_rsfMRI, 'Max'))
    % Checkbox is checked: using clinical + fMRI
    flag_using_fMRI = 1;
else
    % only using clinical
    flag_using_fMRI = 0;
end

patient_etiology_all = get(handles.pm_etiology,'String');
patient_etiology_value = get(handles.pm_etiology,'Value');
patient_etiology = char(patient_etiology_all{patient_etiology_value});
patient_incidence_age = str2double(get(handles.e_incidence_age,'String'));
patient_duration_of_DOC = str2double(get(handles.e_duration,'String'));

program_location = which('pDOC');
[program_dir] = fileparts(program_location);
public_function_dir = fullfile(program_dir, 'public');
if(exist(public_function_dir, 'dir'))
    addpath(public_function_dir);
else
    error('public function does not exist.');
end

if (flag_using_fMRI == 1)
    patient_directory = get(handles.e_rsfMRI_directory,'String');
    if(exist(patient_directory,'dir'))
    f_DOC_prognosication_rsfMRI_clinical(patient_directory,...
        patient_etiology, patient_incidence_age, patient_duration_of_DOC);
    else
        pDOC_warning();
    end
else
    % only using clinical characteristics
    %fprintf('only using clinical characteristics');
    % save etiology, age, duration into global
    setappdata(0,'patient_etiology',patient_etiology);  
    setappdata(0,'patient_incidence_age',patient_incidence_age);  
    setappdata(0,'patient_duration_of_DOC',patient_duration_of_DOC);  
    
    f_DOC_prognosication_clinical(patient_etiology, patient_incidence_age, patient_duration_of_DOC);



end

% --- Executes on button press in pb_exit.
function pb_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%a = findall(0, 'Type', 'figure', 'Tag', 'figure_using_clinical_characteristics_only');
a = findobj('Type', 'figure', 'Tag', 'fig_results');
if(~isempty(a))
    close(a);
end
fprintf('Bye.\n');
close(gcf);


function e_rsfMRI_directory_Callback(hObject, eventdata, handles)
% hObject    handle to e_rsfMRI_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_rsfMRI_directory as text
%        str2double(get(hObject,'String')) returns contents of e_rsfMRI_directory as a double


% --- Executes during object creation, after setting all properties.
function e_rsfMRI_directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_rsfMRI_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_choose_fMRI_directory.
function pb_choose_fMRI_directory_Callback(hObject, eventdata, handles)
% hObject    handle to pb_choose_fMRI_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mesg = 'Select one patient''s directory which contains a resting state fMRI';
wd = pwd;
sel='';
[fMRI_directory,sts] = spm_select(1,'dir',mesg,sel,wd);
set(handles.e_rsfMRI_directory,'String',fMRI_directory);


% --- Executes during object creation, after setting all properties.
function cb_rsfMRI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cb_rsfMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
