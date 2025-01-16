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

% Add logos to GUI
axes(handles.axes1)
imshow('logocimecg.png') 
axes(handles.axes2)
imshow('logounitng.png') 
guidata(hObject, handles);

% UIWAIT makes GUI_LN wait for user response (see UIRESUME)
uiwait(handles.figure1);

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

% Show 'no anatomical images folder selected!' message if folder is not
% selected
if c.anatdatadir == 0
    nullMessageAnat = 'no anatomical images folder selected!';
    set(handles.text6, 'String', nullMessageAnat);
end

% If there is not any missing folder, then Start button changes color
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

% Show 'no resting-state images folder selected!' message if folder is not
% selected
if c.datadir == 0
    nullMessageRS = 'no resting-state images folder selected!';
    set(handles.text12, 'String', nullMessageRS);
end

% If there is not any missing folder, then Start button changes color
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
% --- Set FSL environment -- LN 

% Read configuration_file and store spm folder name as spm
rsnmPath = what('ReStNeuMap_v2');
rsnmDir = rsnmPath.path;
configFile = fullfile(rsnmDir, filesep, 'config_file.txt');
fid = fopen(configFile,'rt');
while ~feof(fid) % Check every line in the file
    templinFSL = fgetl(fid); % Read one line
    if contains(templinFSL,'fslPath:') % If it starts with 'spmVersion:' 
        valueFSL = erase(templinFSL,"fslPath: ");
    else 
        continue
    end
end

setenv('FSLDIR',valueFSL);
setenv('FSLOUTPUTTYPE','NIFTI_GZ');

function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If there is a missing folder, print warning.
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

        NetworkTemplatesWhPath = what('ReStNeuMapNetworkTemplates');
        atldir = NetworkTemplatesWhPath.path;
        assignin('base','atldir',atldir);
        checkvalue = handles.tempfiles_checkbox.Value;
        msgend = handles.text13runningstat;
    
        % Once everything is set, create logfile and run ReStNeuMap core scripts!
        statusLog0 = system(['echo "ReStNeuMap_v2 processing started on:" >> ', atldir,'/ReStNeuMapv2_log.txt']);
        statusLog0date = system(['date >> ', atldir,'/ReStNeuMapv2_log.txt']);
        statusLog0space =  system(['echo " " >> ', atldir,'/ReStNeuMapv2_log.txt']);
        statusLogs0 = [statusLog0 statusLog0date statusLog0space];
        if any(statusLogs0)
            disp(' ');
            disp('an error occurred writing ReStNeuMap''s logfile');
        end
        
        % Run Preprocessing, melodic, cross correlation and network
        % visualization
        exitstatus = ReStNeuMap_PreProc_main(handles.text6.String, handles.text12.String);
        melodic();
        crosscorrelation();
        networkvisualization();
        results2folders();
        
        % Set up folder structure with output files
        cd ..
        % Create QualityAssuranceMetrics folder and move files to it
        statusMkdir = system('mkdir QualityAssuranceMetrics');
        statusMv1 = system('mv ./ProcessDir/checkreg_output.png ./QualityAssuranceMetrics');
        statusMv2 = system('mv ./ProcessDir/DMN/top*.nii.gz ./ProcessDir/DMN/rDMN.nii.gz ./ProcessDir/DMN/DMN_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusMv3 = system('mv ./ProcessDir/FPN/top*.nii.gz ./ProcessDir/FPN/rFPN.nii.gz ./ProcessDir/FPN/FPN_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusMv4 = system('mv ./ProcessDir/Language/top*.nii.gz ./ProcessDir/Language/rLanguage.nii.gz ./ProcessDir/Language/Language_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusMv5 = system('mv ./ProcessDir/Prim_Visual/top*.nii.gz ./ProcessDir/Prim_Visual/rPrim_Visual.nii.gz ./ProcessDir/Prim_Visual/Prim_Visual_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusMv6 = system('mv ./ProcessDir/Speech_Arrest/top*.nii.gz ./ProcessDir/Speech_Arrest/rSpeech_Arrest.nii.gz ./ProcessDir/Speech_Arrest/Speech_Arrest_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusMv7 = system('mv ./ProcessDir/Sensorimotor/top*.nii.gz ./ProcessDir/Sensorimotor/rSensorimotor.nii.gz ./ProcessDir/Sensorimotor/Sensorimotor_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusMv8 = system('mv ./ProcessDir/Visuospatial/top*.nii.gz ./ProcessDir/Visuospatial/rVisuospatial.nii.gz ./ProcessDir/Visuospatial/Visuospatial_2_T1.nii.gz ./QualityAssuranceMetrics');
        statusesQAM = [statusMkdir, statusMv1, statusMv2, statusMv3, statusMv4, statusMv5, statusMv6, statusMv7, statusMv8];
        if any(statusesQAM)
            close all
            msgstatusQAM = 'an error occurred creating the QualityAssuranceMetrics folder or moving output files into it.';
            error(msgstatusQAM)
        end
        
        QC_path=what('QualityAssuranceMetrics');
        QC_path=QC_path.path;
        zip(QC_path,QC_path);
        rmdir(QC_path,'s');
        
        delete('./ProcessDir/*.sh','./ProcessDir/*.lut','./ProcessDir/path.txt');
        AROMA_path=what('ICA_AROMA');
        AROMA_path=AROMA_path.path;
        zip(AROMA_path,AROMA_path);
        rmdir(AROMA_path,'s');

        
        % If the user checked the Optional Files box, then do not delete
        % temporary files and move it to the TemporaryFiles folder
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
                zip('TemporaryFiles','TemporaryFiles');
                %system('tar -zcvf ./TemporaryFiles.tar.gz ./TemporaryFiles');
                rmdir('TemporaryFiles','s');
            end
        
        else
         
            % If the user did not check the Optional Files box, then delete
            % temporary files.
            disp(' ');
            disp('Temporary files are being removed (default)');
            curdir = pwd;
            curdir = dir(curdir);
            curdir = curdir(~ismember({curdir.name},{'.','..','.DS_Store','ICA_AROMA.tar.gz','QualityAssuranceMetrics.tar.gz','ProcessDir','rawdata.tar.gz'}));
            for fileTemp = 1:length(curdir)
                    baseFileName = curdir(fileTemp).name;
                    fullFileName = fullfile(pwd, baseFileName);
                    %fprintf(1, 'Now deleting %s\n', fullFileName);
                    delete(fullFileName);
            end
        end
     
        % Go to the ProcessDir folder and put there the expected output files
        % list
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
        
        cd ..
   
        % Fill in log containing info about hardware, OS, and running time
        logpath = which('ReStNeuMapv2_log.txt');
        statusMvLog = system(['mv ',logpath,' .']);
        if statusMvLog
            disp(' ');
            disp('an error occurred moving ReStNeuMap''s logfile');
        end
        if ~ismac
            statusLog1 = system('echo "ReStNeuMap v2 log:" >> ReStNeuMapv2_log.txt');
            statusLog2 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog3 = system('echo "CPU INFO:" >> ReStNeuMapv2_log.txt');
            statusLog4 = system('lscpu >> ReStNeuMapv2_log.txt');
            statusLog5 = system('echo " ">>  ReStNeuMapv2_log.txt');
            statusLog6 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog7 = system('echo "RAM INFO:" >> ReStNeuMapv2_log.txt');
            statusLog8 = system('cat /proc/meminfo >> ReStNeuMapv2_log.txt');
            statusLog9 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog10 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog11 = system('echo "OS INFO:" >> ReStNeuMapv2_log.txt');
            statusLog12 = system('lsb_release -a >> ReStNeuMapv2_log.txt');
            statusLog13 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog14 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog15 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog16 = system('echo "processing ended on:" >> ReStNeuMapv2_log.txt');
            statusLog17 = system('date >> ReStNeuMapv2_log.txt');
     
            statusLogs = [statusLog1 statusLog2 statusLog3 statusLog4 statusLog5 statusLog6 statusLog7 ...
                statusLog8 statusLog9 statusLog10 statusLog11 statusLog12 statusLog13 statusLog14 statusLog15 ...
                statusLog16 statusLog17];
            if any(statusLogs)
                disp(' ');
                disp('an error occurred writing ReStNeuMap''s logfile');
            end
        end
    
        if ismac 
            statusLog1 = system('echo "ReStNeuMap v2 log:" >> ReStNeuMapv2_log.txt');
            statusLog2 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog3 = system('echo "CPU INFO:" >> ReStNeuMapv2_log.txt');
            statusLog4 = system('sysctl -n machdep.cpu.brand_string >> ReStNeuMapv2_log.txt');
            statusLog5 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog6 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog7 = system('echo "RAM INFO:" >> ReStNeuMapv2_log.txt');
            statusLog8 = system('sysctl hw.memsize >> ReStNeuMapv2_log.txt');
            statusLog9 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog10 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog11 = system('echo "OS INFO:" >> ReStNeuMapv2_log.txt');
            statusLog12 = system('sw_vers >>  ReStNeuMapv2_log.txt');
            statusLog13 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog14 = system('echo "---------------------" >> ReStNeuMapv2_log.txt');
            statusLog15 = system('echo " " >> ReStNeuMapv2_log.txt');
            statusLog16 = system('echo "processing ended on:" >> ReStNeuMapv2_log.txt');
            statusLog17 = system('date >> ReStNeuMapv2_log.txt');
        
            statusLogs = [statusLog1 statusLog2 statusLog3 statusLog4 statusLog5 statusLog6 statusLog7 ...
                statusLog8 statusLog9 statusLog10 statusLog11 statusLog12 statusLog13 statusLog14 statusLog15 ...
                statusLog16 statusLog17];
            if any(statusLogs)
                disp(' ');
                disp('an error occurred writing ReStNeuMap''s logfile');
            end
        end
    
        % If everything went well, show a final message
        disp(' ');
        disp('=================================================');
        disp(' ');
        disp(['ReStNeuMap v2 has ended on ', datestr(now)]);
        disp(' ');
        disp('=================================================');
        mycurrdir = pwd;
       
        
        exitstatusmessage = '';
        if exitstatus.compinf == false
            msgcompinf = [' with possible non-convergence of melodic for FSL-determined number of components'];
            exitstatusmessage = [exitstatusmessage, msgcompinf];
        end
            
        msgpopup = msgbox(['ReStNeuMap processing ended',exitstatusmessage,'. You can find ReStNeuMap output files and folders within the ',mycurrdir,' folder'], 'Operation completed');
        if isgraphics(msgpopup)
            close(msgpopup);
            user_agreement;
        end
                
    catch ME
        disp(ME.message);
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
line1 = '\bfReStNeuMap v2\rm';
line2 = 'A tool for automatic extraction of resting state fMRI networks in neurosurgical practice.';
line3 = '';
line3a = 'Please cite this tool as: ';
line3b = 'Moretto M., Luciani B.F., Zigiotto L., Saviola F., Tambalo S., Cabalo D.G., Annicchiarico L., Venturini M., Jovicich J., and Sarubbo S. Neurosurgery 2024.';
line3e = '\bfReStNeuMap''s INPUT\rm';
line4 = 'In order to run ReStNeuMap, select the following folders:';
line11 = '\bfDICOM ANATOMICAL IMAGES FOLDER\rm: the folder where anatomical image dicom files are stored (the folder must contain only the patient''s anatomical dicom files and nothing else)';
line13 = '\bfDICOM RESTING-STATE IMAGES FOLDER\rm: the folder where resting-state dicom files are stored (the folder must contain only the patient''s resting-state dicom files and nothing else)';
line16 = '\bfOPTIONAL OUTPUT\rm: Check the Optional Output box if you want to keep ReStNeuMap''s temporary files';
line3f = '\bfReStNeuMap''s OUTPUT\rm';
line17 = 'For a list and a description of the expected output files, please check ReStNeuMap''s tutorial or the output\_files\_list.txt file generated by ReStNeuMap within the ProcessDir folder once ReStNeuMap processing has ended, or ReStNeuMap''s tutorial';

f = msgbox({line1, line2, line3,line3a, line3b, line3, line3, line3e, line3, line4, line3,...
   line11, line3, line13, line3, line16, line3, line3, line3f, line3, line17}, 'Info', 'none', Opt);
