function A = Aind(i,a,alp,d,th)
    A = [cos(th(i)) -sin(th(i))*cos(alp(i)) sin(th(i))*sin(alp(i)) cos(th(i))*a(i);
         sin(th(i)) cos(th(i))*cos(alp(i)) -cos(th(i))*sin(alp(i)) sin(th(i))*a(i);
         0  sin(alp(i)) cos(alp(i)) d(i);
         0  0   0   1];
end