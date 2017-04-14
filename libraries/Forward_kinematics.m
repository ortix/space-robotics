function [pos, T] = forward_kinematics(q)
DH = GetDH();
T = GetTransformToFrame(1:6,q,DH)*(DH(6).tool);
pos = T(1:3,4);
end