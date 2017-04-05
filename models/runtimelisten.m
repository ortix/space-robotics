function SampleFunction
 
ModelName = 'main';
 
% Opens the Simulink model
open_system(ModelName);
 
% Simulink may optimise your model by integrating all your blocks. To
% prevent this, you need to disable the Block Reduction in the Optimisation
% settings.
% set_param(ModelName,'BlockReduction','off');
 
% When the model starts, call the localAddEventListener function
set_param(ModelName,'StartFcn','localAddEventListener');
 
% Start the model
set_param(ModelName, 'SimulationCommand', 'start');
 
% Create a line handle
global ph;
ph = line([0],[0]);
 
% When simulation starts, Simulink will call this function in order to
% register the event listener to the block 'SineWave'. The function
% localEventListener will execute everytime after the block 'SineWave' has
% returned its output.
function eventhandle = localAddEventListener
 
eventhandle = add_exec_event_listener('main/Visualizer/Sine Wave', ...
                                        'PostOutputs', @localEventListener);
 
% The function to be called when event is registered.
function localEventListener(block, eventdata)
 
disp('Event has occured!')
global ph;
 
% Gets the time and output value
simTime = block.CurrentTime;
simData = block.OutputPort(1).Data;
 
% Gets handles to the point coordinates
xData = get(ph,'XData');
yData = get(ph,'YData');
 
% Displaying only the latest n-points
n = 200;
 
if length(xData) <= n
    xData = [xData simTime];
    yData = [yData simData];
else
    xData = [xData(2:end) simTime];
    yData = [yData(2:end) simData];
end
 
% Update point coordinates
 
set(ph,...
    'XData',xData,...
    'YData',yData);
 
% The axes limits need to change as you scroll
samplingtime = .01;
 
%Sampling time of block 'SineWave'
offset = samplingtime*n;
xLim = [max(0,simTime-offset) max(offset,simTime)];
set(gca,'Xlim',xLim);
drawnow;