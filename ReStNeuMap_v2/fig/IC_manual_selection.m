function varargout = IC_manual_selection(varargin)
% IC_manual_selection MATLAB code for IC_manual_selection.fig
%      IC_manual_selection, by itself, creates a new IC_manual_selection or raises the existing
%      singleton*.
%
%      H = IC_manual_selection returns the handle to a new IC_manual_selection or the handle to
%      the existing singleton*.
%
%      IC_manual_selection('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IC_manual_selection.M with the given input arguments.
%
%      IC_manual_selection('Property','Value',...) creates a new IC_manual_selection or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IC_manual_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IC_manual_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IC_manual_selection

% Last Modified by GUIDE v2.5 01-Jul-2022 09:08:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IC_manual_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @IC_manual_selection_OutputFcn, ...
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


% --- Executes just before IC_manual_selection is made visible.
function IC_manual_selection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IC_manual_selection (see VARARGIN)

% Choose default command line output for IC_manual_selection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IC_manual_selection wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IC_manual_selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
% checkboxStatus = get(handles.checkbox1_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit1_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit1_Callback, 'enable', 'off')
% end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
% checkboxStatus = get(handles.checkbox2_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit2_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit2_Callback, 'enable', 'off')
% end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
% checkboxStatus = get(handles.checkbox3_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit3_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit3_Callback, 'enable', 'off')
% end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
% checkboxStatus = get(handles.checkbox4_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit4_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit4_Callback, 'enable', 'off')
% end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
% checkboxStatus = get(handles.checkbox5_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit5_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit5_Callback, 'enable', 'off')
% end

% --- Executes on button press in checkbox5.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
% checkboxStatus = get(handles.checkbox6_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit6_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit6_Callback, 'enable', 'off')
% end

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
% checkboxStatus = get(handles.checkbox7_Callback,'Value');
% if checkboxStatus == 1
%     %Allow input
%     set(handles.edit7_Callback, 'enable', 'on')
% else
%     %Block input
%     set(handles.edit7_Callback, 'enable', 'off')
% end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%  str2double(get(hObject,'String')); % returns contents of edit1 as a double
str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if DMN component needs to be changed
if get(handles.edit1,'String')
    if isempty(get(handles.edit1,'Value'))
        return
    elseif ~isnumeric(get(handles.edit1,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit1,'String','');
        return
    elseif ~isempty(get(handles.edit1,'Value'))
        filename = get(handles.checkbox1,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = strsplit(get(handles.edit1,'String'),',');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end


% Check if FPN component needs to be changed
if get(handles.edit2,'String')
    if isempty(get(handles.edit2,'Value'))
        return
    elseif ~isnumeric(get(handles.edit2,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit2,'String','');
        return
    elseif ~isempty(get(handles.edit2,'Value'))
        filename = get(handles.checkbox2,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = get(handles.edit2,'String');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end
 
% Check if Language component needs to be changed
if get(handles.edit3,'String')
    if isempty(get(handles.edit3,'Value'))
        return
    elseif ~isnumeric(get(handles.edit3,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit3,'String','');
        return
    elseif ~isempty(get(handles.edit3,'Value'))
        filename = get(handles.checkbox3,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = get(handles.edit3,'String');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end

% Check if Prim_Visual component needs to be changed 
if get(handles.edit4,'String')
    if isempty(get(handles.edit4,'Value'))
        return
    elseif ~isnumeric(get(handles.edit4,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit4,'String','');
        return
    elseif ~isempty(get(handles.edit4,'Value'))
        filename = get(handles.checkbox4,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = get(handles.edit4,'String');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end

% Check if SAN component needs to be changed
if get(handles.edit5,'String')
    if isempty(get(handles.edit5,'Value'))
        return
    elseif ~isnumeric(get(handles.edit5,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit5,'String','');
        return
    elseif ~isempty(get(handles.edit5,'Value'))
        filename = get(handles.checkbox5,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = get(handles.edit5,'String');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end

% Check if Sensorimotor component needs to be changed
if get(handles.edit6,'String')
    if isempty(get(handles.edit6,'Value'))
        return
    elseif ~isnumeric(get(handles.edit6,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit6,'String','');
        return
    elseif ~isempty(get(handles.edit6,'Value'))
        filename = get(handles.checkbox6,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = get(handles.edit6,'String');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end

% Check if Visuospatial component needs to be changed
if get(handles.edit7,'String')
    if isempty(get(handles.edit7,'Value'))
        return
    elseif ~isnumeric(get(handles.edit7,'Value'))
        errordlg('Please enter a valid number. Thank you.','Error Code III');
        set(handles.edit7,'String','');
        return
    elseif ~isempty(get(handles.edit7,'Value'))
        filename = get(handles.checkbox7,'String');
        filename = strsplit(filename,' (');
        assignin('base', 'filename', string(filename{1}));
        manual_ICs = get(handles.edit7,'String');
        assignin('base', 'manual_ICs', manual_ICs);
        visualize_manual_selection;
    end
end


fprintf('\n ------------------------------------------------------------------------ \n ReStNeuMap has ended. Thank you for using it. \n \n New outputs have been saved in the relevant network folder. \n \n You can close. \n ------------------------------------------------------------------------ \n');

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'status'),'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
%else
    %The GUI is no longer waiting, just closes it
    delete(hObject);
end
% Hint: delete(hObject) closes the figure
%delete(hObject);
