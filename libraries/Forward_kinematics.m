%% Forward Kinematics
syms th1 th2 th3 th4 th5 th6 real

%DH convention
a = [25 560 35 0 0 0];
alp = [90 0 90 -90 90 0];
d = [400 0 0 515 0 87];
th = [th1 .5*pi+th2 th3 th4 th5 th6];
% th = [0*pi .5*pi-0*pi 0*pi 0*pi 0*pi 0*pi];

%Individual transformation matrices
A1 = Aind(1,a,alp,d,th);
A2 = Aind(2,a,alp,d,th);
A3 = Aind(3,a,alp,d,th);
A4 = Aind(4,a,alp,d,th);
A5 = Aind(5,a,alp,d,th);
A6 = Aind(6,a,alp,d,th);

%Transformation matrix
T06 = A1*A2*A3*A4*A5*A6;

%position output
fkpos = [T06(1,4);T06(2,4);T06(3,4)];

%% Inverse Kinematics
syms x06 y06 z06 real
dist06 = [x06;y06;z06];

%joint 1
ori06 = [T06(1,3);T06(2,3);T06(3,3)];
dist46 = d(6)*ori06;
dist04 = dist06-dist46;

IK_th1(1) = atan2(dist04(2),dist04(1));
IK_th1(2) = atan2(dist04(2),dist04(1))+pi;

%joint 3
T02 = A1*A2;
dist02 = subs(T02(1:3,4),th2,0);
dist24 = dist04-dist02;
l1 = sqrt(35^2+515^2);
l2 = 560;
% phi = acos((l1^2+l2^2-norm(dist24)^2)/(2*l1*l2));
phi2 = atan2(d(4),a(3));

phi = asin((l1^2-l2^2+norm(dist24)^2)/(2*norm(dist24)*l1))+asin((norm(dist24)-(l1^2-l2^2+norm(dist24)^2)/(2*norm(dist24)))/l2);

IK_th3(1) = pi-phi-phi2;
IK_th3(2) = pi+phi-phi2;

%joint 2
R02 = T02(1:3,1:3);
dist24_2 = R02\dist24;
beta1 = atan2(dist24_2(1),dist24_2(2));
beta2 = acos((norm(dist24_2)^2+l2^2-l1^2)/(2*norm(dist24_2)*l2));

IK_th2(1) = .5*pi-(abs(beta1)+beta2);
IK_th2(2) = .5*pi+(abs(beta1)-beta2);

%joint 5
T04 = A1*A2*A3*A4;
N04 = T04(1:3,3);
ori04 = subs(N04,th4,0);

IK_th5 = pi-acos(dot(ori04,ori06));

%joint 4 and 6

% R46 = T04(1:3,1:3)\T06(1:3,1:3)
R46 = A4(1:3,1:3)*A5(1:3,1:3)*A6(1:3,1:3);

%deze zijn wellicht fout
IK_th4 = atan2(R46(2,3),R46(1,3));
IK_th6 = atan2(R46(3,2),-R46(3,1));

%% Hoeken samenvoegen

Angles = [IK_th1;IK_th2;IK_th3;IK_th4 IK_th4;IK_th5 IK_th5;IK_th6 IK_th6];
Theta = [th1;th2;th3;th4;th5;th6];







