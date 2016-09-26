%
% Release date: 2016/09/26
% Author: M. Bawaj
%

function varargout = XMLspectrumGUI(varargin)
% XMLSPECTRUMGUI MATLAB code for XMLspectrumGUI.fig
%      XMLSPECTRUMGUI, by itself, creates a new XMLSPECTRUMGUI or raises the existing
%      singleton*.
%
%      H = XMLSPECTRUMGUI returns the handle to a new XMLSPECTRUMGUI or the handle to
%      the existing singleton*.
%
%      XMLSPECTRUMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XMLSPECTRUMGUI.M with the given input arguments.
%
%      XMLSPECTRUMGUI('Property','Value',...) creates a new XMLSPECTRUMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before XMLspectrumGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to XMLspectrumGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help XMLspectrumGUI

% Last Modified by GUIDE v2.5 26-Sep-2016 16:21:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @XMLspectrumGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @XMLspectrumGUI_OutputFcn, ...
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

% --- Executes just before XMLspectrumGUI is made visible.
function XMLspectrumGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to XMLspectrumGUI (see VARARGIN)

% Choose default command line output for XMLspectrumGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes XMLspectrumGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Reset C matrix and set the default uniChoosen at the begining.
global C;
C = 0;
global unitChoosen;
unitChoosen = 1;



% --- Outputs from this function are returned to the command line.
function varargout = XMLspectrumGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_file_Callback(hObject, eventdata, handles)
% hObject    handle to Open_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,path] = uigetfile({'*.TRC'},'Spectrum file selector.'); % returns filename
disp([path, filename]); % debug line

global Start_freq;
global Stop_freq;
global C;
global unitChoosen;

% parse spectrum parameters
spectParam = XMLspectrumGetParam([path, filename]);
% show parameters on the canvas
tempHandle = findobj(gcf,'Tag','Start_freq_val');
set(tempHandle,'String',num2str(spectParam(2)));
tempHandle = findobj(gcf,'Tag','Stop_freq_val');
set(tempHandle,'String',num2str(spectParam(3)));
tempHandle = findobj(gcf,'Tag','Span_freq_val');
set(tempHandle,'String',num2str(spectParam(1)));
tempHandle = findobj(gcf,'Tag','RBW_val');
set(tempHandle,'String',num2str(spectParam(8)));
tempHandle = findobj(gcf,'Tag','Tr1_avg_val');
set(tempHandle,'String',num2str(spectParam(10)));
tempHandle = findobj(gcf,'Tag','Tr2_avg_val');
set(tempHandle,'String',num2str(spectParam(11)));
tempHandle = findobj(gcf,'Tag','Tr3_avg_val');
set(tempHandle,'String',num2str(spectParam(12)));
tempHandle = findobj(gcf,'Tag','Tr4_avg_val');
set(tempHandle,'String',num2str(spectParam(13)));
% plot the data
C = XMLspectrumGetData([path, filename]);
Start_freq = spectParam(2);
Stop_freq = spectParam(3);
RBW = spectParam(8);

C = normalizePSD(C, RBW);

if unitChoosen == 0
    unitChoosen = 1; % 1 = dBm/Hz, 2 = V^2/Hz, 3 = V/sqrt(Hz)
end;
plotSpectrum(C);

% If there is no error update windows name with the analyzed filename.
tempHandle = findobj(gcf,'Tag','figure1');
set(tempHandle,'Name',['XMLspectrumGUI - ',filename]);

fclose all;


% --- Executes when selected object is changed in uipanel_unit.
function uipanel_unit_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_unit 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global unitChoosen; % 1 = dBm/Hz, 2 = V^2/Hz, 3 = V/sqrt(Hz)
global C;

rbut = get(eventdata.NewValue,'Tag');

switch rbut
    case 'radiobutton_dBmHz'
        unitChoosen = 1;
        plotSpectrum(C);
    case 'radiobutton_V2Hz'
        unitChoosen = 2;
        plotSpectrum(C);
    case 'radiobutton_VSqrtHz'
        unitChoosen = 3;
        plotSpectrum(C);
end;


function plotSpectrum(C)
global Start_freq;
global Stop_freq;
global unitChoosen;

if ~C
    return;
end;

%%Iloœæ punktów pomiarowych
points_num = length(C);
freq_points = logspace(log10(Start_freq),log10(Stop_freq),points_num);
CtoPrint = C;
switch unitChoosen
    case 2
        if C
            RloadHandle = findobj(gcf,'Tag','edit_Rload');
            Rload = str2double(get(RloadHandle,'String'));
            CtoPrint = PSD2ESD(C, Rload);
        end;
    case 3
        if C
            RloadHandle = findobj(gcf,'Tag','edit_Rload');
            Rload = str2double(get(RloadHandle,'String'));
            CtoPrint = sqrt(PSD2ESD(C, Rload));
        end;
end;

plotHandle = findobj(gcf,'Tag','spectrumPlot');

ymax_auto_get = get(findobj(gcf,'Tag','checkbox_ymax_auto'),'Value');
if ~ymax_auto_get
    ymax = str2double(get(findobj(gcf,'Tag','edit_ymax'),'String'));
end;

switch unitChoosen
    case 1
        semilogx(plotHandle, freq_points', CtoPrint);
        set(plotHandle,'Tag','spectrumPlot');
        ylabel(plotHandle,'PSD [dBm/Hz]');
    case 2
        loglog(plotHandle, freq_points', CtoPrint);
        set(plotHandle,'Tag','spectrumPlot');
        ylabel(plotHandle,'PSD [V^2/Hz]');
        if ~ymax_auto_get
            ylim(plotHandle,[0 ymax]);
        end;
    case 3
        loglog(plotHandle, freq_points', CtoPrint);
        set(plotHandle,'Tag','spectrumPlot');
        ylabel(plotHandle,'PSD [V/sqrt(Hz)]');
        if ~ymax_auto_get
            ylim(plotHandle,[0 ymax]);
        end;
end;

title(plotHandle,'Spectrum')
legend(plotHandle,'Trace A', 'Trace B', 'Trace C', 'Trace D');
xlabel(plotHandle,'Freq [Hz]');
xlim(plotHandle,[Start_freq Stop_freq]);
grid on;


function edit_Rload_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Rload as text
%        str2double(get(hObject,'String')) returns contents of edit_Rload as a double


% --- Executes during object creation, after setting all properties.
function edit_Rload_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Rload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ymax as text
%        str2double(get(hObject,'String')) returns contents of edit_ymax as a double
global C;
plotSpectrum(C);

% --- Executes during object creation, after setting all properties.
function edit_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_ymax_auto.
function checkbox_ymax_auto_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ymax_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ymax_auto
global C;
plotSpectrum(C);
