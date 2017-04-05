% Prepares your to correctly use and display the visualizer. First
% copy the contents of visualizer.slx into your model/subsystem and
% then run this script. Don't forget to the the model variable!

% Enter the name of your model here
model = 'my_model';

load_system(model);
set_param(model,'PostLoadFcn','cd(fileparts(which(bdroot)))')
set_param(model,'InitFcn','addpath(genpath(''../''));arm_datafile');
save_system(model);
