% This function should be called on startFnc callback in the
% simulink model. Best to add this to the callback through the GUI.
function h = bindCallback
% The GUI handles are by default hidden, turn them on
% I'm not sure if this should be enabled at all. Will test later
set(0,'ShowHiddenHandles','on');

% Determine which block should be logged. Make model name variable
% somehow. Probably best to take it as an argument in this function.
blk = 'realtime_test/Sine Wave';

% Define event listener. This event is fired AFTER the block has
% output its values.
event = 'PostOutputs';

% Get the app object from the workspace. This could probably be
% moved to the gui interface where the gui places itself in the
% model workspace. Not sure if that will work.  bdroot is the name
% of the current open model. This should be variable and be given by
% the function argument.
app = getVariable(get_param(bdroot,'ModelWorkspace'),'app');

% The listener is, for now, an arbitrary function (updategui) which
% takes 3 arguments. The first 2 are passed in by the event itself.
% The last argument is the app object which needs updating. This
% might be slow so look into passing handles instead of entire
% objects.
listener = @(obj,event) updategui(obj,event,app);

%Create the listener
h = add_exec_event_listener(blk, event, listener);
end