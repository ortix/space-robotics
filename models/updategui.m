function varargout = updategui(obj,event,app)
%create a run time object that can return the value of the gain block's
%output and then put the value in a string.  
rto = get_param('realtime_test/Sine Wave','RuntimeObject');
app.q1EditField.Value = rto.OutputPort(1).Data