% This function binds a callback to any block specified as soon as
% it outputs a value. We will use it to bind to a trivial block and
% then update the gui in the event handler.
function h = bindCallback(model)
%% Initial block with documentation
% The GUI handles are by default hidden, turn them on
% I'm not sure if this should be enabled at all. Will test later
set(0,'ShowHiddenHandles','on');

% Determine which block should be logged. Doesn't really matter
% which block it is as long as it outputs a value and updates every
% tick.
blk = [model '/Visualize/q-log'];

% Define event listener. This event is fired AFTER the block has
% output its values.
event = 'PostOutputs';

% Get the app object from the workspace. This could probably be
% moved to the gui interface where the gui places itself in the
% model workspace. Not sure if that will work.  bdroot is the name
% of the current open model. This should be variable and be given by
% the function argument. This also assumes that the app obj is in
% the model workspace. Move it there manually for now.
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