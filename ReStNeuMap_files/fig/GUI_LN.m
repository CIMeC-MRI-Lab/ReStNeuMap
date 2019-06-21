function varargout = GUI_LN(varargin)
% GUI_LN MATLAB code for GUI_LN.fig
%      GUI_LN, by itself, creates a new GUI_LN or raises the existing
%      singleton*.
%
%      H = GUI_LN returns the handle to a new GUI_LN or the handle to
%      the existing singleton*.
%
%      GUI_LN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LN.M with the given input arguments.
%
%      GUI_LN('Property','Value',...) creates a new GUI_LN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_LN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_LN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_LN

% Last Modified by GUIDE v2.5 02-Jul-2018 18:40:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_LN_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_LN_OutputFcn, ...
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


% --- Executes just before GUI_LN is made visible.
function GUI_LN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_LN (see VARARGIN)

% Choose default command line output for GUI_LN
handles.output = hObject;

%add logos to GUI
axes(handles.axes1)
imshow('logocimecg.png') 
axes(handles.axes2)
imshow('logounitng.png') 
guidata(hObject, handles);

% UIWAIT makes GUI_LN wait for user response (see UIRESUME)
uiwait(handles.figure1);


%[x,map] = imread('info.jpg');
%x=imresize(x, 0.5);
%set(handles.pushbutton6,'CData',x);
%set(handles.pushbutton7,'CData',x);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_LN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figureLorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce efficitur quam lacinia, congue orci a, finibus massa. Mauris ac ipsum ut mi ultricies feugiat nec quis justo. Cras consectetur nisi in libero pulvinar blandit. Proin purus sem, porta in leo sed, vulputate pellentesque justo. Morbi a elit ut nulla interdum iaculis. Duis magna libero, cursus a ante sit amet, laoreet rhoncus sem. Duis elit quam, porttitor nec placerat quis, porta a urna.
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%OutputFCN
%The figure can be deleted now
%delete(handles.figure1);
% Get default command line output from handles structure
%varargout{1} = handles.output;

% % --- Executes on button press in browse_anat.
%%function browse_spm12_Callback(hObject, eventdata, handles)
% % hObject    handle to browse_anat (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%%spmdir = uigetdir;
%%set(handles.text15, 'String', spmdir);

% % --- Executes on button press in browse_anat.
%%function browse_atlas_Callback(hObject, eventdata, handles)
% % hObject    handle to browse_anat (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%%atlasdir = uigetdir;
%%set(handles.text16, 'String', atlasdir);





% --- Executes on button press in browse_anat.
function browse_anat_Callback(hObject, eventdata, handles)
% hObject    handle to browse_anat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c.anatdatadir = uigetdir;
set(handles.text6, 'String', c.anatdatadir);

%show 'no anatomical images folder selected!' message if folder is not
%selected
if c.anatdatadir == 0
    nullMessageAnat = 'no anatomical images folder selected!';
    set(handles.text6, 'String', nullMessageAnat);
end

%if there is not any missing folder, then Start button changes color
null1 = '(no folder selected)';
null_ai = 'no anatomical images folder selected!';
null_rs = 'no resting-state images folder selected!';
if ~ isequal(handles.text6.String, null1)  & ~ isequal(handles.text12.String, null1) & ~isequal(handles.text6.String, null_ai) & ~isequal(handles.text12.String, null_rs)
    set(handles.start, 'ForegroundColor', [0 0 0]);
    set(handles.start, 'BackgroundColor', [1 0 0]);
    set(handles.start, 'FontWeight', 'bold');
end


% --- Executes on button press in browse_rs.
function browse_rs_Callback(hObject, eventdata, handles)
% hObject    handle to browse_rs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c.datadir = uigetdir;
set(handles.text12, 'String', c.datadir);

%show 'no resting-state images folder selected!' message if folder is not
%selected
if c.datadir == 0
    nullMessageRS = 'no resting-state images folder selected!';
    set(handles.text12, 'String', nullMessageRS);
end

%if there is not any missing folder, then Start button changes color
null1 = '(no folder selected)';
null_ai = 'no anatomical images folder selected!';
null_rs = 'no resting-state images folder selected!';
if ~ isequal(handles.text6.String, null1)  & ~ isequal(handles.text12.String, null1) & ~isequal(handles.text6.String, null_ai) & ~isequal(handles.text12.String, null_rs)
    set(handles.start, 'ForegroundColor', [0 0 0]);
    set(handles.start, 'BackgroundColor', [0.85 0 0]);
    set(handles.start, 'FontWeight', 'bold');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'),'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
%else
    %The GUI is no longer waiting, just closes it
    delete(hObject);
end
% Hint: delete(hObject) closes the figure
%delete(hObject);

% --- Executes on button press in tempfiles_checkbox.
function tempfiles_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to tempfiles_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checkvalue = handles.tempfiles_checkbox.Value;

% Hint: get(hObject,'Value') returns toggle state of tempfiles_checkbox

function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if there is a missing folder, print warning.
null1 = '(no folder selected)';
null_ai = 'no anatomical images folder selected!';
null_rs = 'no resting-state images folder selected!';
warn_message = 'no folders selected!';
if isequal(handles.text6.String, null1) && isequal(handles.text12.String, null1)
    set(handles.text13runningstat, 'String', warn_message);
    set(handles.start, 'FontWeight', 'bold');
end

if isequal(handles.text6.String, null1) || isequal(handles.text6.String, null_ai)
   warn_message = null_ai;
   set(handles.text13runningstat, 'String', warn_message);
end

if isequal(handles.text12.String, null1) || isequal(handles.text12.String, null_rs)
   warn_message = null_rs;
   set(handles.text13runningstat, 'String', warn_message);
end

%if isequal(handles.text15.String, null1) || isequal(handles.text16.String, null1)
%   warn_message = null_ai;
%   set(handles.text13runningstat, 'String', warn_message);
%end

if isequal(handles.text6.String, null1) || isequal(handles.text6.String, null_ai) || isequal(handles.text12.String, null1) || isequal(handles.text12.String, null_rs) || ...
   isequal(handles.text6.String, 0) || isequal(handles.text12.String, 0)
    
   msgMissingFolders = 'not all folders selected';
   close all
   error(msgMissingFolders)
        
else
         
    try
        set(handles.text13runningstat, 'String', 'Processing running...please wait.');
        set(handles.start, 'ForegroundColor', [0.5 0.5 0.5]);
        set(handles.start, 'BackgroundColor', [0.85 0.85 0.85]);
        set(handles.start, 'FontWeight', 'normal');
        assignin('base','anatdatadir',handles.text6.String);
        assignin('base','datadir',handles.text12.String);
        spmWhPath = what('spm12');
        spmdir = spmWhPath.path;
        assignin('base','spmdir',spmdir);
        NetworkTemplatesWhPath = what('ReStNeuMapNetworkTemplates');
        atldir = NetworkTemplatesWhPath.path;
        assignin('base','atlasdir',atldir);
        checkvalue = handles.tempfiles_checkbox.Value;
        msgend = handles.text13runningstat;
    
        %once everything is set, create logfile and run ReStNeuMap core scripts!
        statusLog0 = system(['echo "ReStNeuMap_v0.2 processing started on:" >> ', atldir,'/ReStNeuMapv0.2_log.txt']);
        statusLog0date = system(['date >> ', atldir,'/ReStNeuMapv0.2_log.txt']);
        statusLog0space =  system(['echo " " >> ', atldir,'/ReStNeuMapv0.2_log.txt']);
        statusLogs0 = [statusLog0 statusLog0date statusLog0space];
        if any(statusLogs0)
            disp(' ');
            disp('an error occurred writing ReStNeuMap''s logfile');
        end
        
        exitstatus = ReStNeuMap_PreProc_main(handles.text6.String, handles.text12.String)
        fwaitb = waitbar(0.6,'ReStNeuMap is processing your data. Please wait...');
        waitbar(0.7,fwaitb);
        fromAtlastoSubj_aut_job(atldir)
        waitbar(0.8,fwaitb);
        extractcomponent_auto_0_1_4(exitstatus)
        % fix 2019-03-05
%         statusMkdir0 = system('mkdir 2T1w');
%         if statusMkdir0
%             close all
%             msgstatusMkdir0 = 'an error occurred while creating the 2T1w folder.';
%             error(msgstatusMkdir0)
%         end
%         reorient_reslice_ReStNeuMapnetworks(pwd)
        waitbar(0.9,fwaitb);
    
        %set up folder structure with output files
        cd ..
        %create QualityAssuranceMetrics folder and move files to it
        statusMkdir = system('mkdir QualityAssuranceMetrics');
        statusMv1 = system('mv artglobal*.jpg ./QualityAssuranceMetrics');
        statusMv2 = system('mv art_repaired.txt ./QualityAssuranceMetrics');
        statusMv3 = system('mv art_deweighted.txt ./QualityAssuranceMetrics');
        statusMv4 = system('mv checkreg_output.png ./QualityAssuranceMetrics');
        statusesQAM = [statusMkdir, statusMv1, statusMv2, statusMv3];
        if any(statusesQAM)
            close all
            msgstatusQAM = 'an error occurred creating the QualityAssuranceMetrics folder or moving ArtRepair output files into it.';
            error(msgstatusQAM)
        end
        
        
        %if the user checked the Optional Files box, then do not delete
        %temporary files and move it to the TemporaryFiles folder
        if checkvalue
            statusMkdirTempFiles = system('mkdir TemporaryFiles');
            statusFind = system('find . -maxdepth 1 -type f -exec mv {} ./TemporaryFiles \;');
            statusTempFil = [statusMkdirTempFiles, statusFind];
            if any(statusTempFil)
                close all
                msgstatusTempFil = 'an error occurred moving ReStNeuMap temporary output files to the TemporaryFiles';
                error(msgstatusTempFil)
            else
                disp('temporary files not removed and saved in TemporaryFiles folder');
            end
        
        else
         
            %if the user did not check the Optional Files box, then delete
            %temporary files.
            if ismac()
                disp(' ');
                disp('temporary files are being removed (default)');
                statusRmFiles = system('find . -type f -maxdepth 1 -delete');
            else
                disp(' ');
                disp('temporary files are being removed (default)');
                statusRmFiles = system('find -maxdepth 1 -type f -delete');
            end
            
            if statusRmFiles
                close all
                msgstatusRmFiles = 'an error occurred while removing temporary files. Please check that all your paths were correctly set.';
                error(msgstatusRmFiles);
            end
        end
     
        %go to the ProcessDir folder and put there the expected output files
        %list
        cd ./ProcessDir
        pathoutfile = which('output_files_list.txt');
        statusCpOutFilesList = system(['cp ', pathoutfile, ' .']); 
        
        if statusCpOutFilesList
            close all
            msgstatusCpOutFilesList = 'an error occurred while copying expected output file list. Please check all your paths.';
            error(msgstatusCpOutFilesList);
        else    
            disp(' ');
            disp('You can find a list of the output files in the ProcessDir folder');
        end
        
        %extract mean connectivity value
        fslstatsStatus = system('pathvarFslstats=$(cat path2fslstats.txt); cp $pathvarFslstats .; bash ReStNeuMap_fslstatsrun.sh');
        
        if any(fslstatsStatus)
           close all
           msgstatusFslstatus = 'an error occurred while extracting mean connectivity values.';
           error(msgstatusFslstatus);
        end
        
        system('rm path.txt');
        system('rm path2fslstats.txt');
        
        cd ..
   
        %fill in log containing info about hardware, OS, and running time
        logpath = which('ReStNeuMapv0.2_log.txt');
        statusMvLog = system(['mv ',logpath,' .']);
        if statusMvLog
            disp(' ');
            disp('an error occurred moving ReStNeuMap''s logfile');
        end
        if ~ismac
            statusLog1 = system('echo "ReStNeuMap v0.2 log:" >> ReStNeuMapv0.2_log.txt');
            statusLog2 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog3 = system('echo "CPU INFO:" >> ReStNeuMapv0.2_log.txt');
            statusLog4 = system('lscpu >> ReStNeuMapv0.2_log.txt');
            statusLog5 = system('echo " ">>  ReStNeuMapv0.2_log.txt');
            statusLog6 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog7 = system('echo "RAM INFO:" >> ReStNeuMapv0.2_log.txt');
            statusLog8 = system('cat /proc/meminfo >> ReStNeuMapv0.2_log.txt');
            statusLog9 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog10 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog11 = system('echo "OS INFO:" >> ReStNeuMapv0.2_log.txt');
            statusLog12 = system('lsb_release -a >> ReStNeuMapv0.2_log.txt');
            statusLog13 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog14 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog15 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog16 = system('echo "processing ended on:" >> ReStNeuMapv0.2_log.txt');
            statusLog17 = system('date >> ReStNeuMapv0.2_log.txt');
     
            statusLogs = [statusLog1 statusLog2 statusLog3 statusLog4 statusLog5 statusLog6 statusLog7 ...
                statusLog8 statusLog9 statusLog10 statusLog11 statusLog12 statusLog13 statusLog14 statusLog15 ...
                statusLog16 statusLog17];
            if any(statusLogs)
                disp(' ');
                disp('an error occurred writing ReStNeuMap''s logfile');
            end
        end
    
        if ismac 
            statusLog1 = system('echo "ReStNeuMap v0.2 log:" >> ReStNeuMapv0.2_log.txt');
            statusLog2 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog3 = system('echo "CPU INFO:" >> ReStNeuMapv0.2_log.txt');
            statusLog4 = system('sysctl -n machdep.cpu.brand_string >> ReStNeuMapv0.2_log.txt');
            statusLog5 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog6 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog7 = system('echo "RAM INFO:" >> ReStNeuMapv0.2_log.txt');
            statusLog8 = system('sysctl hw.memsize >> ReStNeuMapv0.2_log.txt');
            statusLog9 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog10 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog11 = system('echo "OS INFO:" >> ReStNeuMapv0.2_log.txt');
            statusLog12 = system('sw_vers >>  ReStNeuMapv0.2_log.txt');
            statusLog13 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog14 = system('echo "---------------------" >> ReStNeuMapv0.2_log.txt');
            statusLog15 = system('echo " " >> ReStNeuMapv0.2_log.txt');
            statusLog16 = system('echo "processing ended on:" >> ReStNeuMapv0.2_log.txt');
            statusLog17 = system('date >> ReStNeuMapv0.2_log.txt');
        
            statusLogs = [statusLog1 statusLog2 statusLog3 statusLog4 statusLog5 statusLog6 statusLog7 ...
                statusLog8 statusLog9 statusLog10 statusLog11 statusLog12 statusLog13 statusLog14 statusLog15 ...
                statusLog16 statusLog17];
            if any(statusLogs)
                disp(' ');
                disp('an error occurred writing ReStNeuMap''s logfile');
            end
        end
    
        %if everything went well, show a final message
        disp(' ');
        disp('=================================================');
        disp(' ');
        disp(['ReStNeuMap v0.2 has ended on ', datestr(now)]);
        disp(' ');
        disp('=================================================');
        mycurrdir = pwd;
        close(fwaitb)
        
        exitstatusmessage = '';
        if exitstatus.comp10 == false
            msgcomp10 = [' with possible non-convergence of melodic for 10 components'];
            exitstatusmessage = [exitstatusmessage, msgcomp10];
        end
        if exitstatus.comp20 == false
            msgcomp20 = [' with possible non-convergence of melodic for 20 components'];
            exitstatusmessage = [exitstatusmessage, msgcomp20];
        end
        if exitstatus.comp30 == false
            msgcomp30 = [' with possible non-convergence of melodic for 30 components'];
            exitstatusmessage = [exitstatusmessage, msgcomp30];
        end
        if exitstatus.compinf == false
            msgcompinf = [' with possible non-convergence of melodic for FSL-determined number of components'];
            exitstatusmessage = [exitstatusmessage, msgcompinf];
        end
            
   
        msgpopup = msgbox(['ReStNeuMap processing ended',exitstatusmessage,'. You can find ReStNeuMap output files and folders within the ',mycurrdir,' folder'], 'Operation completed');
        
        
        
                
                
    catch ME
        msgcatch = 'an error occurred in ReStNeuMap processing. \n Please verify that your matlab path and input folders are correctly set.';
        close all
        error(msgcatch, 's')
    end

end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Opt.Interpreter = 'tex';
Opt.WindowStyle = 'normal';
line1 = '\bfReStNeuMap v0.1\rm';
line2 = 'A tool for automatic extraction of resting state fMRI networks in neurosurgical practice.';
line3 = '';
line3a = 'Please cite this tool as: ';
line3b = 'Zacà D., Jovicich J., Corsini F., Rozzanigo U., Chioffi F., and Sarubbo S., ReStNeuMap: a tool for automatic extraction of resting state fMRI networks in neurosurgical practice. Journal of Neurosurgery, 2018.';
line3e = '\bfReStNeuMap''s INPUT\rm';
line4 = 'In order to run ReStNeuMap, select the following folders:';
line11 = '\bfDICOM ANATOMICAL IMAGES FOLDER\rm: the folder where anatomical image dicom files are stored (the folder must contain only the patient''s anatomical dicom files and nothing else)';
line13 = '\bfDICOM RESTING-STATE IMAGES FOLDER\rm: the folder where resting-state dicom files are stored (the folder must contain only the patient''s resting-state dicom files and nothing else)';
line16 = '\bfOPTIONAL OUTPUT\rm: Check the Optional Output box if you want to keep ReStNeuMap''s temporary files';
line3f = '\bfReStNeuMap''s OUTPUT\rm';
line17 = 'For a list and a description of the expected output files, please check ReStNeuMap''s tutorial or the output\_files\_list.txt file generated by ReStNeuMap within the ProcessDir folder once ReStNeuMap processing has ended, or ReStNeuMap''s tutorial (you can find it in ReStNeuMap\_v0.1\\ReStNeuMap\_tutorial.pdf).';

f = msgbox({line1, line2, line3,line3a, line3b, line3, line3, line3e, line3, line4, line3,...
   line11, line3, line13, line3, line16, line3, line3, line3f, line3, line17}, 'Info', 'none', Opt);
