function [xyz,EEFforward,EEFup] = getPos(q)
% Takes q input and returns world XYZ. This implements forward
% kinematics.
% On first startup it loads DH parameters.

persistent T06;

% If getPos is called for the first time, load DH parameters and
% calculate T06.
if isempty(T06)
    
    [T1 T2 T3 T4 T5 T6] = Tmatrices;
    T06 = T1*T2*T3*T4*T5*T6;
    
end

% Assign q to symbolic angles.
th1 = q(1);
th2 = q(2);
th3 = q(3);
th4 = q(4);
th5 = q(5);
th6 = q(6);


% Give outputs.
xyz = eval(T06(1:3,4));
EEFforward = eval(T06(1:3,3));
EEFup = eval(T06(1:3,1));
end
