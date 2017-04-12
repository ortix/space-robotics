function [T1, T2, T3, T4, T5, T6] = Tmatrices
% Returns a DH convention styled transformation matrix from one
% frame to the next. Takes the DH parameters and input and returns a
% transformation matrix from one frame to the next.

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
end

function T = Tmatrix(i,alp,theta,d,a)
T = [cos(theta(i)) -sin(theta(i))*cos(alp(i)) sin(theta(i))*sin(alp(i)) cos(theta(i))*a(i);
         sin(theta(i)) cos(theta(i))*cos(alp(i)) -cos(theta(i))*sin(alp(i)) sin(theta(i))*a(i);
         0  sin(alp(i)) cos(alp(i)) d(i);
         0  0   0   1];
end