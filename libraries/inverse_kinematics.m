% function q = inverse_kinematics(p,orientation)

%% Voorlopig, klopt niet

% Inputs
% p: describingWorld XYZ, 
% orientation: normal vector pointing to toolhead  + angle vector describing tool angle (EEF angle)
% % % 	Determines: All uknown singularity positions. Picks a random orientation.
% 	Output 
% current joint angles (q)

% willekeurige testwaarden
 th1 = .33*pi; th2 = .22*pi; th3= .66*pi; th4 = .99*pi; th5= .88*pi; th6= .55*pi;

% %DH parameters
% a = [25 0 560 35 0 0 0];
% alpha = [0 90 0 90 -90 90 0];
% d = [0 -400 0 0 -515 0 87];
% theta = [0 th1 -90+th2 th3 180+th4 180+th5 th6];

%DH parameters random testwaardes
a = [90 0 560 35 30 30 30];
alpha = [90 90 90 90 -90 90 90];
d = [90 -400 90 90 -515 90 87];
theta = [0 th1 -90+th2 th3 180+th4 180+th5 th6];

% Calculate transformation matrix T,1-i,i
%Requires inputs 
% alpha,i-1
% a,i-1
% theta,i
% d,i

% slordig, loopje komt nog
Tind1 = TransMatInd(a(1), alpha(1), theta(2), d(2));
Tind2 = TransMatInd(a(2), alpha(2), theta(3), d(3));
Tind3 = TransMatInd(a(3), alpha(3), theta(4), d(4));
Tind4 = TransMatInd(a(4), alpha(4), theta(5), d(5));
Tind5= TransMatInd(a(5), alpha(5), theta(6), d(6));
Tind6 = TransMatInd(a(6), alpha(6), theta(7), d(7));

% Big Transformation
T02 = Tind1 .* Tind2;
T04 = Tind1 .* Tind2 .* Tind3 .* Tind4;
T06 = Tind1 .* Tind2 .* Tind3 .* Tind4 .* Tind5 .* Tind6;


%% Joint 1

theta1 =  [atan2(T06(2,4)-d(7)*T06(2,3),T06(1,4)-d(7)*T06(1,3));
    atan2(T06(2,4)-d(7)*T06(2,3),T06(1,4)-d(7)*T06(1,3)) + pi];

%% Joint 3
P24K0 = [T04(1,4);T04(2,4);T04(3,4)] - [T02(1,4);T02(2,4);T02(3,4)];
e = atan2(-d(5),a(4));

nP24K0 = P24K0/norm(P24K0,2);

l = sqrt((515^2+35^2));
phi = asin( (l^2 - a(3)^2 + nP24K0.^2) / (2*nP24K0*l)) + ...
    (asin(nP24K0 - ((l^2-a(3)^2+nP24K0)/(2*nP24K0)))/a(3));

theta3 = [pi - phi - e;
        pi + phi - e];
    
%% Joint 2

P24K2 = T02(1:3,1:3)*P24K0;
beta1 = atan2(P24K2(1),P24K2(2));

nP24K2 = P24K2/norm(P24K2,2);

beta2 = asin((a(3)^2 - nP24K2.^2 + l^2)/(2*l*a(3)))+ ...
    asin(  (l - ((a(3)^3 - nP24K2.^2+l^2 )/(2*l)))   / nP24K2 );

theta2 = [pi/2 - (abs(beta1)+beta2);
          pi/2 + (abs(beta1)-beta2)];
 
%% Joint 5

N04K0 = [T04(1,3);T04(2,3);T04(3,3)]; 
N06K0 = [T06(1,3);T06(2,3);T06(3,3)]; 

theta5 = pi - acos(dot(N04K0,N06K0));

%% Joint 4 and 6
R46 = [-cos(theta(5))*cos(theta(6))*cos(theta(7))-sin(theta(5))*sin(theta(7)) cos(theta(5))*cos(theta(6))*sin(theta(7))-sin(theta(5))*cos(theta(7)) -cos(theta(5))*sin(theta(6));
-sin(theta(5))*cos(theta(6))*cos(theta(7))+cos(theta(5))*sin(theta(6)) sin(theta(5))*cos(theta(6))*sin(theta(7))+cos(theta(5))*cos(theta(7)) -sin(theta(5))*sin(theta(6));
sin(theta(6))*cos(theta(7)) -sin(theta(6))*sin(theta(7)) -cos(theta(6))];


theta4 = atan2(-R46(2,3),-R46(1,3));
theta6 = atan2(-R46(3,2),-R46(3,1));







