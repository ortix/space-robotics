%% Parameters
% clear DH
% %        theta    d           a       alpha
% DH(1,:) = ([0        0.4         0.025    pi/2]);
% DH(2,:) = ([0        0           0.560    pi]);
% DH(3,:) = ([0        0           0.035   -pi/2]);
% DH(4,:) = ([0        0.62        0        pi/2]);
% DH(5,:) = ([0        0           0       -pi/2]);
% DH(6,:) = ([0        0           0        0]);

%% Build DH Transform struct
clear DH
DH(1) = struct('theta',0,'d',0.4,'a',0.025,'alpha',pi/2);
DH(2) = struct('theta',0,'d',0,'a',0.560,'alpha',pi);
DH(3) = struct('theta',0,'d',0,'a',0.035,'alpha',-pi/2);
DH(4) = struct('theta',0,'d',0.515,'a',0,'alpha',pi/2);
DH(5) = struct('theta',0,'d',0,'a',0,'alpha',-pi/2);
DH(6) = struct('theta',0,'d',0,'a',0,'alpha',0);

tool=GetPlanarT([0 0 0.087]);

%% Configuration
configuration = 'ru';

cfg = [1 1 1];  % left, up, noflip

for c=configuration
    switch c
        case 'l'
            cfg(1) = 1;
        case 'r'
            cfg(1) = 2;
        case 'u'
            cfg(2) = 1;
        case 'd'
            cfg(2) = 2;
        case 'n'
            cfg(3) = 1;
        case 'f'
            cfg(3) = 2;
    end
end
%% Calculate Transformation Matrix

% XYZ coordinates of end effector (target)
T = GetPlanarT([0.5 0 0.5]);

% Set robot in the origin and add offset of tool to the transform
% Also rotate tool head
Trot = eye(4);
Trot(1:3,1:3) = roty(pi/2);
T = T*inv(tool)*Trot;


%% Extract Parameters
% get the a1, a2 and a3-- link lenghts for link no 1,2,3
a1 = DH(1).a;
a2 = DH(2).a;
a3 = DH(3).a;


% get d1,d2,d3,d4---- Link offsets for link no 1,2,3,4
d1 = DH(1).d;
d2 = DH(2).d;
d3 = DH(3).d;
d4 = DH(4).d;

% Get the parameters from transformation matrix

Ox = T(1,2);
Oy = T(2,2);
Oz = T(3,2);

Ax = T(1,3);
Ay = T(2,3);
Az = T(3,3);

Px = T(1,4);
Py = T(2,4);
Pz = T(3,4);


%% Calculations first 3 joints

% Set the parameters n1, n2 and n3 to get required configuration from
% solution
n1 = -1;   % 'l'
n2 = -1;   % 'u'
n4 = -1;   % 'n'

if ~isempty(strfind(configuration, 'l'))
    n1 = -1;
end
if ~isempty(strfind(configuration, 'r'))
    n1 = 1;
end
if ~isempty(strfind(configuration, 'u'))
    if n1 == 1
        n2 = 1;
    else
        n2 = -1;
    end
end
if ~isempty(strfind(configuration, 'd'))
    if n1 == 1
        n2 = -1;
    else
        n2 = 1;
    end
end
if ~isempty(strfind(configuration, 'n'))
    n4 = 1;
end
if ~isempty(strfind(configuration, 'f'))
    n4 = -1;
end

% Calculation for theta(1)
r=sqrt(Px^2+Py^2);

if (n1 == 1)
    theta(1)= atan2(Py,Px) + asin((d2-d3)/r);
else
    theta(1)= atan2(Py,Px)+ pi - asin((d2-d3)/r);
end

% Calculation for theta(2)
X= Px*cos(theta(1)) + Py*sin(theta(1)) - a1;
r=sqrt(X^2 + (Pz-d1)^2);
Psi = acos((a2^2-d4^2-a3^2+X^2+(Pz-d1)^2)/(2.0*a2*r));

if ~isreal(Psi)
    warning('point not reachable');
    theta = [NaN NaN NaN NaN NaN NaN];
    return
end

theta(2) = atan2((Pz-d1),X) + n2*Psi;

% Calculation for theta(3)
Nu = cos(theta(2))*X + sin(theta(2))*(Pz-d1) - a2;
Du = sin(theta(2))*X - cos(theta(2))*(Pz-d1);
theta(3) = atan2(a3,d4) - atan2(Nu, Du);

% Calculation for theta(4)
Y = cos(theta(1))*Ax + sin(theta(1))*Ay;
M2 = sin(theta(1))*Ax - cos(theta(1))*Ay ;
M1 =  ( cos(theta(2)-theta(3)) )*Y + ( sin(theta(2)-theta(3)) )*Az;
theta(4) = atan2(n4*M2,n4*M1);

% Calculation for theta(5)
Nu =  -cos(theta(4))*M1 - M2*sin(theta(4));
M3 =  -Az*( cos(theta(2)-theta(3)) ) + Y*( sin(theta(2)-theta(3)) );
theta(5) = atan2(Nu,M3);

% Calculation for theta(6)
Z = cos(theta(1))*Ox + sin(theta(1))*Oy;
L2 = sin(theta(1))*Ox - cos(theta(1))*Oy;
L1 = Z*( cos(theta(2)-theta(3) )) + Oz*( sin(theta(2)-theta(3)));
L3 = Z*( sin(theta(2)-theta(3) )) - Oz*( cos(theta(2)-theta(3)));
A1 = L1*cos(theta(4)) + L2*sin(theta(4));
A3 = L1*sin(theta(4)) - L2*cos(theta(4));
Nu =  -A1*cos(theta(5)) - L3*sin(theta(5));
Du =  -A3;
theta(6) = atan2(Nu,Du);

%% Correct last 3 joints angles (wrist)

% Get transform matrix from base to joint 3
T13 = GetTransformToFrame(1:3, theta(1:3),DH);

% Get rotation matrix by transforming into joint 4
Td4 = GetPlanarT([0 0 DH(4).d]);
R = inv(Td4) * inv(T13) * T;

% the spherical wrist implements Euler angles
% if cfg(3) == 1
%     theta(4:6) = tr2eul(R,'flip');
% else
%     theta(4:6) = tr2eul(R);
% end

% Flip the wrist
% if DH(4).alpha < 0
%     theta(5) = -theta(5);
% end

q = theta

