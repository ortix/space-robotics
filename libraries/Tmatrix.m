function T = Tmatrix(i,alp,theta,d,a)
% Returns a DH convention styled transformation matrix from one
% frame to the next. Takes the DH parameters and input and returns a
% transformation matrix from one frame to the next.
    T = [cos(theta(i)) -sin(theta(i))*cos(alp(i)) sin(theta(i))*sin(alp(i)) cos(theta(i))*a(i);
         sin(theta(i)) cos(theta(i))*cos(alp(i)) -cos(theta(i))*sin(alp(i)) sin(theta(i))*a(i);
         0  sin(alp(i)) cos(alp(i)) d(i);
         0  0   0   1];
end