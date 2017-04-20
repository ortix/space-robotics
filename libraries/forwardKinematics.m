function [pos, T, rot] = forwardKinematics(q)
persistent DH

if(isempty(DH))
   DH = getDH(); 
end

T = getTransformToFrame(1:6,q,DH)*(DH(6).tool);
pos = T(1:3,4).';
rot = round(rotationMatrixToVector(T(1:3,1:3))/pi,3);
end