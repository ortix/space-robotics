syms th1 th2 th3 th4 th5 th6
format shortG
%IK_data
a = [25 560 35 0 0 0];
alp = [.5*pi 0 .5*pi -.5*pi .5*pi 0];
d = [400 0 0 515 0 87];
theta = [th1 .5*pi+th2 th3 th4 th5 th6];
% th = [0*pi .5*pi-0*pi 0*pi 0*pi 0*pi 0*pi];

%Individual transformation matrices
A1 = Aind(1,a,alp,d,theta);
A2 = Aind(2,a,alp,d,theta);
A3 = Aind(3,a,alp,d,theta);
A4 = Aind(4,a,alp,d,theta);
A5 = Aind(5,a,alp,d,theta);
A6 = Aind(6,a,alp,d,theta);

%Transformation matrix
T02 = A1*A2;
T04 = A1*A2*A3*A4;
T06 = A1*A2*A3*A4*A5*A6;



%% Joint 1

theta1 =  [atan2(T06(2,4)-d(6)*T06(2,3),T06(1,4)-d(6)*T06(1,3));
    atan2(T06(2,4)-d(6)*T06(2,3),T06(1,4)-d(6)*T06(1,3)) + pi];

%% Joint 3
P24K0 = [T04(1,4);T04(2,4);T04(3,4)] - [T02(1,4);T02(2,4);T02(3,4)];
e = atan2(-d(4),a(3));

nP24K0 = norm(P24K0);

l = sqrt((515^2+35^2));

phi = asin( (l^2 - a(2)^2 + nP24K0.^2) / (2*nP24K0*l)) + ...
    (asin(nP24K0 - ((l^2-a(2)^2+nP24K0)/(2*nP24K0)))/a(2));

theta3 = [pi - phi - e;
        pi + phi - e];
    
%% Joint 2

P24K2 = T02(1:3,1:3)*P24K0;
beta1 = atan2(P24K2(1),P24K2(2));

nP24K2 = norm(P24K2);

beta2 = asin((a(2)^2 - nP24K2.^2 + l^2)/(2*l*a(2)))+ ...
    asin(  (l - ((a(2)^3 - nP24K2.^2+l^2 )/(2*l)))   / nP24K2 );

theta2 = [pi/2 - (abs(beta1)+beta2);
          pi/2 + (abs(beta1)-beta2)];
 
%% Joint 5

N04K0 = [T04(1,3);T04(2,3);T04(3,3)]; 
N06K0 = [T06(1,3);T06(2,3);T06(3,3)]; 

theta5 = pi - acos(dot(N04K0,N06K0));

%% Joint 4 and 6
R46 = [-cos(theta(4))*cos(theta(5))*cos(theta(6))-sin(theta(4))*sin(theta(6)) cos(theta(4))*cos(theta(5))*sin(theta(6))-sin(theta(4))*cos(theta(6)) -cos(theta(4))*sin(theta(5));
-sin(theta(4))*cos(theta(5))*cos(theta(6))+cos(theta(4))*sin(theta(5)) sin(theta(4))*cos(theta(5))*sin(theta(6))+cos(theta(4))*cos(theta(6)) -sin(theta(4))*sin(theta(5));
sin(theta(5))*cos(theta(6)) -sin(theta(5))*sin(theta(6)) -cos(theta(5))];


theta4 = atan2(-R46(2,3),-R46(1,3));
theta6 = atan2(-R46(3,2),-R46(3,1));





