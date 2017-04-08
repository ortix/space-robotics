function varargout = simpleGUI
% This function creates a simple user interface for running a Simulink
% model and displaying signals in the model on a MATLAB user interface.
%
% Specifically the UI works with a model called 'simpleModel.mdl', that
% contains the three blocks
%
%                    Sine Wave --> Gain --> Scope
%
% The UI allows the model to be started and stopped, and allows the value
% of the gain to be tuned.  The model does not have to be open to use the
% UI (and it's recommended for it to be closed).
%
% The UI allows the model to be run in either simulation mode (requiring a
% Simulink license) or as a generic real-time (GRT) executable (since the
% model must be "built" this requires an RTW license).
%
% In Simulation Mode: The value of both the signal being fed into the
% Gain block and the signal being fed into the Scope block are displayed on
% an axis on the UI. 
% In GRT/External Mode: Only the signal being fed into the scope is
% displayed.  This is because External Mode only allows data from
% certain types of blocks to be uploaded.  In this model the only
% block that is the Scope block.
%
% It is intended as a demonstration program to show various aspects of 
% using MATLAB, Simulink and RTW:
% 
%   - how to create a MATLAB UI using command line functionality
%   - how to start/stop a Simulink model using command line functionality
%   - how to add a listener to a Simulink block so that signals can be
%   viewed from a MATLAB UI.
%   - how to build a GRT executable using command line functionality
%   - how to interface with code running in "real-time" (For the purposes
%   of this UI the grt code is running on the host machine, so it is not
%   running in hard real-time, however it is using External Mode to
%   communicate with the code and hence shows how communication would be
%   performed if the code was truly running on an RTOS.
%
% NOTE: there are many different ways of creating a UI that talks
% to real-time code, and the appropriate way will depend on the exact
% functionality required, the RTOS, the hardware, the type of communication
% mechanism being used, and any API (application program interface) that is
% available.
%
% This code is not intended to be "bullet-proof", nor comprehensive.  It is
% by its nature a very simple application.

% Author: Phil Goddard (phil@goddardconsulting.ca)
% Date: Q4, 2009
% Version: 3.0  (If updated/changed, then also change the "About Box" info
%                in the localAboutPulldown function.)
% MATLAB version: R2008b
% Revision notes: Versions prior to 3.0 only displayed the Scope's input
%                 signal, not the Gain's input signal too.

% This UI hard codes the name of the model that is being controlled
modelName = 'simpleModel';
% Do some simple error checking on the input
if ~localValidateInputs(modelName)
    estr = sprintf('The model %s.mdl cannot be found.',modelName);
    errordlg(estr,'Model not found error','modal');
    return
end
% Do some simple error checking on varargout
error(nargoutchk(0,1,nargout));

% Create the UI if one does not already exist.
% Bring the UI to the front if one does already exist.
hf = findall(0,'Tag',mfilename);
if isempty(hf)
    % Create a UI
    hf = localCreateUI(modelName);
else
    % Bring it to the front
    figure(hf);
end

% populate the output if required
if nargout > 0
    varargout{1} = hf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to create the user interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hf = localCreateUI(modelName)

try
    % Create the figure, setting appropriate properties
    hf = figure('Tag',mfilename,...
        'Toolbar','none',...
        'MenuBar','none',...
        'IntegerHandle','off',...
        'Units','normalized',...
        'Resize','off',...
        'NumberTitle','off',...
        'HandleVisibility','callback',...
        'Name',sprintf('Custom UI for controlling %s.mdl',modelName),...
        'CloseRequestFcn',@localCloseRequestFcn,...
        'Visible','off');
    
    % Create an axes on the figure
    ha = axes('Parent',hf,...
        'HandleVisibility','callback',...
        'Unit','normalized',...
        'OuterPosition',[0.25 0.1 0.75 0.8],...
        'Xlim',[0 10],...
        'YLim',[-1 1],...
        'Tag','plotAxes');
    xlabel(ha,'Time');
    ylabel(ha,'Signal Value');
    title(ha,'Signal Value v''s Time');
    grid(ha,'on');
    box(ha,'on');
    
    % Create an edit box containing the model name
    hnl = uicontrol('Parent',hf,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.9 0.15 0.03],...
        'BackgroundColor',get(hf,'Color'),...
        'String','Model Name',...
        'HandleVisibility','callback',...
        'Tag','modelNameLabel'); %#ok
    hnl = uicontrol('Parent',hf,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.02 0.82 0.21 0.06],...
        'String',sprintf('%s.mdl',modelName),...
        'Enable','inactive',...
        'Backgroundcolor',[1 1 1],...
        'HandleVisibility','callback',...
        'Tag','modelNameLabel'); %#ok
    
    % Create a Mode (Simulation or GRT) panel
    hbg = uibuttongroup('Parent',hf,...
        'Units','normalized',...
        'Position',[0.02 0.6 0.21 0.2],...
        'Title','Mode',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'SelectionChangeFcn',@localModeChanged,...
        'Tag','modeGroup');
    strings = {'Simulation','GRT'};
    positions = [0.6 0.3];
    tags = {'modeRBSim','modeRBGRT'};
    % The enable property is a function of whether an RTW license is
    % available
    if license('test','Real-Time_Workshop')
        enable = {'on','on'};
    else
        enable = {'on','off'};
        % Also pop-up a dialog telling the user what's happening
        str = sprintf('%s\n%s\n%s',...
            'A real-Time Workshop license isn''t available, or cannot be',...
            'checked out.  The UI is being rendered however only ',...
            'simulation functionality is being enabled.');
        hedlg = errordlg(str,'RTW License Error','modal');
        uiwait(hedlg);
    end
    for idx = 1:length(strings)
        uicontrol('Parent',hbg,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',[0.15 positions(idx) 0.75 0.2],...
            'String',strings{idx},...
            'Enable',enable{idx},...
            'Backgroundcolor',get(hf,'Color'),...
            'HandleVisibility','callback',...
            'Tag',tags{idx});
    end
    
    % Create a parameter tuning panel
    htp = uipanel('Parent',hf,...
        'Units','normalized',...
        'Position',[0.02 0.38 0.21 0.2],...
        'Title','Parameter Tuning',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'Tag','tunePanel');
    htt = uicontrol('Parent',htp,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.15 0.65 0.7 0.2],...
        'BackgroundColor',get(hf,'Color'),...
        'String','Gain:',...
        'HorizontalAlignment','left',...
        'HandleVisibility','callback',...
        'Tag','modelNameLabel'); %#ok
    hte = uicontrol('Parent',htp,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.15 0.28 0.7 0.3],...
        'String','',...
        'Backgroundcolor',[1 1 1],...
        'Enable','on',...
        'Callback',@localGainTuned,...
        'HandleVisibility','callback',...
        'Tag','tuneGain');
    
    
    % Create a panel for operations that can be performed
    hop = uipanel('Parent',hf,...
        'Units','normalized',...
        'Position',[0.02 0.1 0.21 0.27],...
        'Title','Operations',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'Tag','tunePanel');
    strings = {'Build','Start','Stop'};
    positions = [0.7 0.45 0.2];
    tags = {'buildpb','startpb','stoppb'};
    callbacks = {@localBuildPressed, @localStartPressed, @localStopPressed};
    enabled ={'off','on','off'};
    for idx = 1:length(strings)
        uicontrol('Parent',hop,...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[0.15 positions(idx) 0.7 0.2],...
            'BackgroundColor',get(hf,'Color'),...
            'String',strings{idx},...
            'Enable',enabled{idx},...
            'Callback',callbacks{idx},...
            'HandleVisibility','callback',...
            'Tag',tags{idx});
    end
    
    % Create some application data storing the UI handles and various
    % pieces of information about the model's original state.
    
    % Can only do the following if a Simulink License is available
    simulinkLicenceAvailable = license('test','Simulink');
    if simulinkLicenceAvailable
        try
            % Load the simulink model
            ad = localLoadModel(modelName);
            
            % The gain value needs to be poked into the UI
            set(hte,'String',ad.gainValue);
            
            % Put an empty line on the axes for each signal that will be
            % monitored
            % Save the line handles, which will be useful to have in an
            % array during the graphics updating routine.
            nlines = length(ad.viewing);
            hl = nan(1,nlines);
            colourOrder = get(ha,'ColorOrder');
            for idx = 1:nlines
                hl(idx) = line('Parent',ha,...
                    'XData',[],...
                    'YData',[],...
                    'Color',colourOrder(mod(idx-1,size(colourOrder,1))+1,:),...
                    'EraseMode','xor',...
                    'Tag',sprintf('signalLine%d',idx));
            end
            ad.lineHandles = hl;

        catch ME %#ok
            simulinkLicenceAvailable = false;
        end
    end
    if ~simulinkLicenceAvailable
        % If no Simulink license available then disable all UI controls
        % Not all uicomponents (e.g. figure, axes,...) have an Enable
        % property so do this in a loop.  The loop catches those widgets
        % without an Enable property and does nothing for them.
        allHandles = findall(hf);
        arrayfun(@(h)set(h,'Enable','off'),allHandles,...
            'ErrorHandler',@(obj,evt)disp(''));
        
        % For the UI to be closed there needs to be a modelName field in
        % appdata so just create a dummy one
        ad.modelName = modelName;
        
        % Also pop-up a dialog telling the user what's happening
        str = sprintf('%s\n%s\n%s\n%s',...
            'A Simulink license isn''t available, or cannot be',...
            'checked out.  The UI is being rendered however all ',...
            'functionality is being disabled.  Check for an available',...
            'license then try again.');
        hedlg = errordlg(str,'Simulink License Error','modal');
        uiwait(hedlg);
    end
    
    % Create a Help pull-down menu
    % (Do this here these should be enabled even if there is no Simulink
    % license.)
    hhpd = uimenu('Parent',hf,...
        'Label','Help',...
        'Tag','helpmenu');
    labels = {'Application Help','About'};
    tags = {'apphelppd','aboutpd'};
    callbacks = {@localAppHelpPulldown,@localAboutPulldown};
    for idx = 1:length(labels)
        uimenu('Parent',hhpd,...
            'Label',labels{idx},...
            'Callback',callbacks{idx},...
            'Tag',tags{idx});
    end

    % Create the handles structure
    ad.handles = guihandles(hf);
    % Save the application data
    guidata(hf,ad);
    
    % Position the UI in the centre of the screen
    movegui(hf,'center')
    % Make the UI visible
    set(hf,'Visible','on');
catch ME
    % Get rid of the figure if it was created
    if exist('hf','var') && ~isempty(hf) && ishandle(hf)
        delete(hf);
    end
    % Get rid of the model if it was loaded
    close_system('simpleModel',0)   
    % throw up an error dialog
    estr = sprintf('%s\n%s\n\n',...
        'The UI could not be created.',...
        'The specific error was:',...
        ME.message);
    errordlg(estr,'UI creation error','modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to ensure that the model actually exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelExists = localValidateInputs(modelName)

num = exist(modelName,'file');
if num == 4
    modelExists = true;
else
    modelExists = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Mode radio buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localModeChanged(hObject,eventdata)

% get the application data
ad = guidata(hObject);
% Make changes to the UI depending on whether Simulation or GRT is required
switch get(eventdata.NewValue,'String')
    case 'Simulation'
        % Turn off the Build button
        set(ad.handles.buildpb,'Enable','off');
        % Turn on the Start button
        set(ad.handles.startpb,'Enable','on');
    case 'GRT'
        if ad.modelAlreadyBuilt
            % Turn off the Build button
            set(ad.handles.buildpb,'Enable','off');
            % Turn off the Start button
            set(ad.handles.startpb,'Enable','on');
        else
            % Turn on the Build button
            set(ad.handles.buildpb,'Enable','on');
            % Turn off the Start button
            set(ad.handles.startpb,'Enable','off');
        end
    otherwise
        % shouldn't be able to get in here
        errordlg('Selection Error',...
            'An illegal selection was made.', 'modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Build button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localBuildPressed(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

try
    % throw up a wait bar as this'll take a while
    wStr = sprintf('%s\n%s',...
        'Please wait while the model builds.',...
        'Be patient as this may take several minutes.');
    hw = waitbar(0.5,wStr);
    % set the simulation mode to external
    set_param('simpleModel','SimulationMode','external');
    % Build the model
    rtwbuild(ad.modelName);
    % reset the simulation mode to its original value
    set_param('simpleModel','SimulationMode',ad.originalMode);
    % destroy the waitbar
    delete(hw);
    % Toggle the state of the buttons
    % Turn off the Build button
    set(ad.handles.buildpb,'Enable','off');
    % Turn on the Start button
    set(ad.handles.startpb,'Enable','on');
    % Set the already built flag so we don't build again
    ad.modelAlreadyBuilt = true;
    % Flush the graphics buffer
    drawnow
catch ME
    % Get rid of the waitbar
    if exist('hw','var') && ~isempty(hw) && ishandle(hw)
        delete(hw);
        drawnow;
    end
    % throw up an error dialog
    estr = sprintf('%s\n%s\n\n',...
        'The model could not be built.',...
        'The specific error was:',...
        ME.message);
    errordlg(estr,'Build error','modal');
    % Set the already built flag to false so another build attempt is
    % reqired
    ad.modelAlreadyBuilt = false;
end

% store the changed app data
guidata(gcbo,ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Start button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localStartPressed(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Load the model if required (it may have been closed manually).
if ~modelIsLoaded(ad.modelName)
    load_system(ad.modelName);
end

% toggle the buttons
% Turn off the Start button
set(ad.handles.startpb,'Enable','off');
% Turn on the Stop button
set(ad.handles.stoppb,'Enable','on');

% disable Mode changes
set(get(ad.handles.modeGroup,'Children'),'Enable','off');

% Push the current gain value in the UI into the model
localGainTuned(ad.handles.tuneGain);

% reset the line(s)
for idx = 1:length(ad.lineHandles)
    set(ad.lineHandles(idx),...
        'XData',[],...
        'YData',[]);
end

% Perform a different operation depending on whether Simulation or GRT is
% required
switch get(get(ad.handles.modeGroup,'SelectedObject'),'Tag')
    case 'modeRBSim'
        % set the stop time to inf
        set_param(ad.modelName,'StopTime','inf');
        % set the simulation mode to normal
        set_param(ad.modelName,'SimulationMode','normal');
        % Set a listener on the Gain block in the model's StartFcn
        set_param(ad.modelName,'StartFcn','localAddEventListener');
        % start the model
        set_param(ad.modelName,'SimulationCommand','start');
        
    case 'modeRBGRT'
        % set the stop time to inf
        set_param(ad.modelName,'StopTime','inf');
        % set the simulation mode to external
        set_param(ad.modelName,'SimulationMode','external');
        % Start the grt code
        % NOTE: This brings up a dos box which will need to be closed 
        %       manually
        system(sprintf('%s -tf inf -w &',ad.modelName));
        % Connect to the code
        set_param(ad.modelName,'SimulationCommand','connect');
        % start the model
        set_param(ad.modelName,'SimulationCommand','start');
        % Attach the listener
        localAddEventListener;
    otherwise
        % shouldn't be able to get in here
        errordlg('Selection Error',...
            'Neither simulation nor GRT was attempted.', 'modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Stop button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localStopPressed(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Perform a different operation depending on whether Simulation or GRT was
% being performed
switch get(get(ad.handles.modeGroup,'SelectedObject'),'Tag')
    case 'modeRBSim'
        % stop the model
        set_param(ad.modelName,'SimulationCommand','stop');
        
    case 'modeRBGRT'
        % stop the model
        set_param(ad.modelName,'SimulationCommand','stop');
        % disconnect from the code
        set_param(ad.modelName,'SimulationCommand','disconnect');
    otherwise
        % shouldn't be able to get in here
        errordlg('Selection Error',...
            'Neither simulation nor GRT was attempted.', 'modal');
end

% set model properties back to their original values
set_param(ad.modelName,'Stoptime',ad.originalStopTime);
set_param(ad.modelName,'SimulationMode',ad.originalMode);

% toggle the buttons
% Turn on the Start button
set(ad.handles.startpb,'Enable','on');
% Turn off the Stop button
set(ad.handles.stoppb,'Enable','off');

% enable Mode changes
set(get(ad.handles.modeGroup,'Children'),'Enable','on');

% Remove the listener on the Gain block in the model's StartFcn
localRemoveEventListener;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for gain tuning edit box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localGainTuned(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Check that a valid value has been entered
str = get(hObject,'String');
newValue = str2double(str);

% Do the change if it's valid
if ~isnan(newValue)
    % poke the new value into the model
    set_param(ad.tuning.blockName,ad.tuning.blockProp,str);
    % change the axes scale
    set(ad.handles.plotAxes,'Ylim',max(abs(newValue),1)*[-1 1]);
    % store the new value
    ad.gainValue = str;
    guidata(hObject,ad);
else
    % throw up an error dialog
    estr = sprintf('%s is an invalid Gain value.',str);
    errordlg(estr,'Gain Tuning Error','modal');
    % reset the edit box to the old value
    set(hObject,'String',ad.gainValue);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for deleting the UI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localCloseRequestFcn(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Can only close the UI if the model has been stopped
% Can only stop the model is it hasn't already been unloaded (perhaps
% manually).
if modelIsLoaded(ad.modelName)
    switch get_param(ad.modelName,'SimulationStatus');
        case 'stopped'
            % Reset the gain to its original value
            set_param(ad.tuning.blockName,ad.tuning.blockProp,ad.originalGainValue);
            % close the Simulink model
            close_system(ad.modelName,0);
            % destroy the window
            delete(gcbo);
        otherwise
            errordlg('The model must be stopped before the UI is closed',...
                'UI Close error','modal');
    end
else
    % destroy the window
    delete(gcbo);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for adding an event listener to the gain block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localAddEventListener

% get the application data
ad = guidata(gcbo);

% execute any original startFcn that the model may have had
if ~isempty(ad.originalStartFcn)
    evalin('Base',ad.originalStartFcn);
end

% Add the listener(s)
% For this example all events call into the same function
ad.eventHandle = cell(1,length(ad.viewing));
for idx = 1:length(ad.viewing)
    ad.eventHandle{idx} = ...
        add_exec_event_listener(ad.viewing(idx).blockName,...
        ad.viewing(idx).blockEvent, ad.viewing(idx).blockFcn);
end

% store the changed app data
guidata(gcbo,ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for executing the event listener on the gain block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localEventListener(block, eventdata) %#ok

% Note: this callback is called by all the block listeners.  No effort has
% been made to time synchronise the data from each signal.  Rather it is
% assumed that since each block calls this function at every time step and
% hence the time synchronisation will come "for free".  This may not be the
% case for other models and additional code may be required for them to
% work/display data correctly.

% get the application data
hf = findall(0,'tag',mfilename);
ad = guidata(hf);

% Get the handle to the line that currently needs updating
thisLineHandle = ...
    ad.lineHandles([ad.viewing.blockHandle]==block.BlockHandle);

% Get the data currently being displayed on the axis
xdata = get(thisLineHandle,'XData');
ydata = get(thisLineHandle,'YData');
% Get the simulation time and the block data
sTime = block.CurrentTime;
data = block.InputPort(1).Data;

% Only the last 1001 points worth of data
% The model sample time is 0.001 so this represents 1000 seconds of data
if length(xdata) < 1001
    newXData = [xdata sTime];
    newYData = [ydata data];
else
    newXData = [xdata(2:end) sTime];
    newYData = [ydata(2:end) data];
end

% Display the new data set
set(thisLineHandle,...
    'XData',newXData,...
    'YData',newYData);

% The axes limits may also need changing
newXLim = [max(0,sTime-10) max(10,sTime)];
set(ad.handles.plotAxes,'Xlim',newXLim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for removing the event listener from the gain block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localRemoveEventListener

% get the application data
ad = guidata(gcbo);

% return the startFcn to its original value
set_param(ad.modelName,'StartFcn',ad.originalStartFcn);

% delete the listener(s)
for idx = 1:length(ad.eventHandle)
    if ishandle(ad.eventHandle{idx})
        delete(ad.eventHandle{idx});
    end
end
% remove this field from the app data structure
ad = rmfield(ad,'eventHandle');
%save the changes
guidata(gcbo,ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check that model is still loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelLoaded = modelIsLoaded(modelName)

try
    modelLoaded = ...
        ~isempty(find_system('Type','block_diagram','Name',modelName));
catch ME %#ok
    % Return false if the model can't be found
    modelLoaded = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to load model and get certain of its parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = localLoadModel(modelName)

% Load the simulink model
if ~modelIsLoaded(modelName)
    load_system(modelName);
end
% Create some application data storing various
% pieces of information about the model's original state.
% These will be used to "reset" the model to its original state when
% the UI is closed.
ad.modelName = modelName;
ad.tuning.blockName = sprintf('%s/Gain',ad.modelName);
ad.tuning.blockProp = 'Gain';
ad.originalGainValue = get_param(ad.tuning.blockName,ad.tuning.blockProp);
ad.gainValue = ad.originalGainValue;

% List the blocks that are to have listeners applied
ad.viewing = struct(...
    'blockName','',...
    'blockHandle',[],...
    'blockEvent','',...
    'blockFcn',[]);
% Every block has a name
ad.viewing(1).blockName = sprintf('%s/Scope',ad.modelName);
ad.viewing(2).blockName = sprintf('%s/Gain',ad.modelName);
% That block has a handle
% (This will be used in the graphics drawing callback, and is done here
% as it should speed things up rather than searching for the handle
% during every event callback.)
ad.viewing(1).blockHandle = get_param(ad.viewing(1).blockName,'Handle');
ad.viewing(2).blockHandle = get_param(ad.viewing(2).blockName,'Handle');
% List the block event to be listened for
ad.viewing(1).blockEvent = 'PostOutputs';
ad.viewing(2).blockEvent = 'PostOutputs';
% List the function to be called
% (These must be subfunctions within this mfile).
ad.viewing(1).blockFcn = @localEventListener;
ad.viewing(2).blockFcn = @localEventListener;

% Save some of the models original info that this UI may change
% (and needs to change back again when the simulation stops)
ad.originalStopTime = get_param(ad.modelName,'Stoptime');
ad.originalMode =  get_param(ad.modelName,'SimulationMode');
ad.originalStartFcn = get_param(ad.modelName,'StartFcn');

% We'll also have a flag saying if the model has been previously built
ad.modelAlreadyBuilt = false;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for viewing the documentation/help
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localAppHelpPulldown(hObject,eventdata) %#ok

% Just view the help for the primary function in this file
doc(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for viewing an about box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localAboutPulldown(hObject,eventdata) %#ok

% Create an about box
str = {[mfilename,' was written by Phil Goddard, the Principal of Goddard Consulting.'];...
    'Feel free to send comments to phil@goddardconsulting.ca';...
    ' ';...
    'Version 3.0';...
    'Q4 2009'};
msgbox(str,'About Box','Help','modal')






