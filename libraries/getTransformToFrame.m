function T = getTransformToFrame(joints,angles,DH)
T = eye(4);
for joint = joints
    % Shorthand trig
    sa = sin(DH(joint).alpha); ca = cos(DH(joint).alpha);
    sq = sin(angles(joint)); cq = cos(angles(joint));
    
    % Distance between links
    d = DH(joint).d;
    
    % Multiply transformation matrices  
    T =   T * [
        cq  -sq*ca  sq*sa   DH(joint).a*cq
        sq   cq*ca  -cq*sa  DH(joint).a*sq
        0    sa      ca      d
        0    0       0       1];
    
end
end