function [xyz,EEFforward,EEFup] = getPos(q)
% Takes q input and returns world XYZ. This implements forward
% kinematics.
% On first startup it loads DH parameters.

persistent T06;

% If getPos is called for the first time, load DH parameters and
% calculate T06.
if isempty(T06)
    
    % Load DH params.
    load('DH_parameters.mat');
    
    syms th1 th2 th3 th4 th5 th6;
    th = [th1 th2 th3 th4 th5 th6];
    theta = th + dth;  % The syms + delta theta parameter
    
    % Calculate 6 transformation matrices. These have the th1..6
    % symbolics.
    T1 = Tmatrix(1,alp,theta,d,a);
    T2 = Tmatrix(2,alp,theta,d,a);
    T3 = Tmatrix(3,alp,theta,d,a);
    T4 = Tmatrix(4,alp,theta,d,a);
    T5 = Tmatrix(5,alp,theta,d,a);
    T6 = Tmatrix(6,alp,theta,d,a);
    
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
