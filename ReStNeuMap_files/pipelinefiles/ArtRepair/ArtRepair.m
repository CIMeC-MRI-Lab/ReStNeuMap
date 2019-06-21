function varargout = spm_artifactrepair(varargin)
% SPM_ARTIFACTREPAIR M-file for spm_artifactrepair.fig
%      SPM_ARTIFACTREPAIR, by itself, creates a new SPM_ARTIFACTREPAIR or raises the existing
%      singleton*.
%
%      H = SPM_ARTIFACTREPAIR returns the handle to a new SPM_ARTIFACTREPAIR or the handle to
%      the existing singleton*.
%
%      SPM_ARTIFACTREPAIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPM_ARTIFACTREPAIR.M with the given input arguments.
%
%      SPM_ARTIFACTREPAIR('Property','Value',...) creates a new SPM_ARTIFACTREPAIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spm_artifactrepair_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spm_artifactrepair_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help spm_artifactrepair

% Last Modified by GUIDE v2.5 26-Mar-2009 10:52:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spm_artifactrepair_OpeningFcn, ...
                   'gui_OutputFcn',  @spm_artifactrepair_OutputFcn, ...
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


% --- Executes just before spm_artifactrepair is made visible.
function spm_artifactrepair_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spm_artifactrepair (see VARARGIN)

% Choose default command line output for spm_artifactrepair
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spm_artifactrepair wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spm_artifactrepair_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


