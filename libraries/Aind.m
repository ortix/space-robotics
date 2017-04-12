function T = Aind(i,alpha,th,d,a)
% Returns a DH convention styled transformation matrix from one
% frame to the next. Takes the DH parameters and input and returns a
% transformation matrix from one frame to the next.
    T = [cos(th(i)) -sin(th(i))*cos(alpha(i)) sin(th(i))*sin(alpha(i)) cos(th(i))*a(i);
         sin(th(i)) cos(th(i))*cos(alpha(i)) -cos(th(i))*sin(alpha(i)) sin(th(i))*a(i);
         0  sin(alpha(i)) cos(alpha(i)) d(i);
         0  0   0   1];
end