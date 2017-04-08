function varargout = updategui(obj,event,app)

%% Update joint angles
rto = get_param([app.model '/q-log'],'RuntimeObject');
app.q1EditField.Value = rto.OutputPort(1).Data(1);
app.q2EditField.Value = rto.OutputPort(1).Data(2);
app.q3EditField.Value = rto.OutputPort(1).Data(3);
app.q4EditField.Value = rto.OutputPort(1).Data(4);
app.q5EditField.Value = rto.OutputPort(1).Data(5);
app.q6EditField.Value = rto.OutputPort(1).Data(6);

%% Update joint velocities
% rto = get_param([app.model '/qd-log'],'RuntimeObject');
% app.q1EditField.Value = rto.OutputPort(1).Data(1);
% app.q2EditField.Value = rto.OutputPort(1).Data(2);
% app.q3EditField.Value = rto.OutputPort(1).Data(3);
% app.q4EditField.Value = rto.OutputPort(1).Data(4);
% app.q5EditField.Value = rto.OutputPort(1).Data(5);
% app.q6EditField.Value = rto.OutputPort(1).Data(6);
