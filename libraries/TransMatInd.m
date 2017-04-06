function Tind = TransMatInd(a, alpha, theta, d)
% Calculates transformation matrix T,1-i,i
%Requires inputs 
% alpha,i-1
% a,i-1
% theta,i
% d,i

% Rx = [1 0 0 0;
%     0 cos(alpha) -sin(alpha) 0;
%     0 sin(alpha) cos(alpha) 0;
%     0 0 0 1];
% 
% Dx = [1 0 0 a;
%     0 1 0 0;
%     0 0 1 0;
%     0 0 0 1];
% 
% Rz = [cos(theta) -sin(theta) 0 0;
%     sin(theta) cos(theta) 0 0;
%     0 0 1 0;
%     0 0 0 1];
% 
% Dz = [1 0 0 0;
%     0 1 1 0;
%     0 1 1 d;
%     0 0 0 1];
% 
% Tind = Rx .* Dx .* Rz .* Dz;

Tind = [cos(theta) -sin(theta) 0 a;
    cos(alpha)*sin(theta) cos(alpha)*cos(theta) -sin(alpha) -d*sin(alpha);
    sin(alpha)*sin(theta) sin(alpha)*cos(theta) cos(alpha) d*cos(alpha);
    0 0 0 1];



end