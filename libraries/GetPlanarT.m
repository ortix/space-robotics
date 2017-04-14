function T = getPlanarT(xyz)

T = eye(4);
T(1:3,4) = xyz;

end
