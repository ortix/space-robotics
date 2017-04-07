syms th1 th2 th3 th4 th5 th6
format shortG
%IK_data
a = [25 560 35 0 0 0];
alp = [.5*pi 0 .5*pi -.5*pi .5*pi 0];
d = [400 0 0 515 0 87];
% th = [th1 th2+.5*pi th3 th4 th5 th6];
th = [0*pi .5*pi-0*pi 0*pi 0*pi 0*pi 0*pi];

%Individual transformation matrices
A1 = Aind(1,a,alp,d,th);
A2 = Aind(2,a,alp,d,th);
A3 = Aind(3,a,alp,d,th);
A4 = Aind(4,a,alp,d,th);
A5 = Aind(5,a,alp,d,th);
A6 = Aind(6,a,alp,d,th);

%Transformation matrix
T0 = A1*A2*A3*A4*A5*A6;


