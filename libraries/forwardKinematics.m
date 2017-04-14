function [pos, T] = forwardKinematics(q)
DH = getDH();
T = getTransformToFrame(1:6,q,DH)*(DH(6).tool);
pos = T(1:3,4).';
end