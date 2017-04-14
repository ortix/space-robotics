addpath('gui/');
addpath('libraries/');
addpath('cad/');
addpath('models/');

% Open UDP Socket
udpr = dsp.UDPReceiver('LocalIPPort',31000,'MessageDataType','double');
setup(udpr);

% Open and run the model
model = 'visualizer';
open_system(model);
set_param('visualizer', 'SimulationCommand', 'start')

% Allocate memory
q = zeros(6,1);
assignin('base','q',q)
set_param([model '/q'],'value', 'q')

while(1)
    packet = udpr();
    
    if(~isempty(packet))
        q = packet(1:6)
        assignin('base','q',q)
        set_param([model '/q'],'value', 'q')
    end
    
    pause(1/100);
end

