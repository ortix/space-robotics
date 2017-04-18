function theta = inverseKinematics(pos,orientation,DH,config)
%% Build DH Transform struct
% If someone forgets to pass in the DH parameters, just lazy load
% them anyway
if(isempty(DH))
   DH = getDH(); 
end

%% Configuration
% If there is no configuration set for the shoulder and elbow
% default to the config below
if(isempty(config))
    config = 'ru';
end

%% Calculate Transformation Matrix

% XYZ coordinates of end effector (target)
T = getPlanarT(pos);

% Rotate tool head based on the orientation vector. The orientation
% vector is a 1x3 vector which units pi*rad. Each element of the
% rotation vector is passed into a rotation function which
% ultimately is appended to the initial transformation matrix from
% the previous step.
ori = orientation;
Trot = eye(4);
Trot(1:3,1:3) = rotx(ori(1)*pi)*roty(ori(2)*pi)*rotz(ori(3)*pi);


% Rotate the transformation matrix and move with the length of the
% end effector.
T = T*Trot*inv(DH(6).tool);


%% Extract Parameters
% Store the link lengths 
a1 = DH(1).a;
a2 = DH(2).a;
a3 = DH(3).a;


% Store the link offsets
d1 = DH(1).d;
d2 = DH(2).d;
d3 = DH(3).d;
d4 = DH(4).d;

% get rotation vectors from the transformation matrix
Ox = T(1,2);
Oy = T(2,2);
Oz = T(3,2);

Ax = T(1,3);
Ay = T(2,3);
Az = T(3,3);

Px = T(1,4);
Py = T(2,4);
Pz = T(3,4);


%% Calculate the joint angles

% Set default parameters n1, n2 and n3 configure robot arm shoulder,
% elbow and wrist. These are the defautl settings
n1 = -1;    % 'r'
n2 = -1;   % 'u'
n4 = -1;   % 'n'

% Switch over the configuration to determine configuration as passed
% into the function
if contains(config, 'l')
    n1 = -1;
end
if contains(config, 'r')
    n1 = 1;
end
if contains(config, 'u')
    if n1 == 1
        n2 = 1;
    else
        n2 = -1;
    end
end
if contains(config, 'd')
    if n1 == 1
        n2 = -1;
    else
        n2 = 1;
    end
end
if contains(config, 'n')
    n4 = 1;
end
if contains(config, 'f')
    n4 = -1;
end

%% Joint 1
r=sqrt(Px^2+Py^2);

if (n1 == 1)
    theta(1)= atan2(Py,Px) + asin((d2-d3)/r);
else
    theta(1)= atan2(Py,Px)+ pi - asin((d2-d3)/r);
end

%% Joint 2
X= Px*cos(theta(1)) + Py*sin(theta(1)) - a1;
r=sqrt(X^2 + (Pz-d1)^2);
Psi = acos((a2^2-d4^2-a3^2+X^2+(Pz-d1)^2)/(2.0*a2*r));

if ~isreal(Psi)
    warning('point not reachable');
    theta = [NaN NaN NaN NaN NaN NaN];
    return
end

theta(2) = atan2((Pz-d1),X) + n2*Psi;

%% Joint 3
Nu = cos(theta(2))*X + sin(theta(2))*(Pz-d1) - a2;
Du = sin(theta(2))*X - cos(theta(2))*(Pz-d1);
theta(3) = atan2(a3,d4) - atan2(Nu, Du);

%% Joint 4
Y = cos(theta(1))*Ax + sin(theta(1))*Ay;
M2 = sin(theta(1))*Ax - cos(theta(1))*Ay ;
M1 =  ( cos(theta(2)-theta(3)) )*Y + ( sin(theta(2)-theta(3)) )*Az;
theta(4) = atan2(n4*M2,n4*M1);

%% Joint 5
Nu =  -cos(theta(4))*M1 - M2*sin(theta(4));
M3 =  -Az*( cos(theta(2)-theta(3)) ) + Y*( sin(theta(2)-theta(3)) );
theta(5) = atan2(Nu,M3);

%% Joint 6
Z = cos(theta(1))*Ox + sin(theta(1))*Oy;
L2 = sin(theta(1))*Ox - cos(theta(1))*Oy;
L1 = Z*( cos(theta(2)-theta(3) )) + Oz*( sin(theta(2)-theta(3)));
L3 = Z*( sin(theta(2)-theta(3) )) - Oz*( cos(theta(2)-theta(3)));
A1 = L1*cos(theta(4)) + L2*sin(theta(4));
A3 = L1*sin(theta(4)) - L2*cos(theta(4));
Nu =  -A1*cos(theta(5)) - L3*sin(theta(5));
Du =  -A3;
theta(6) = atan2(Nu,Du);

q = theta;

