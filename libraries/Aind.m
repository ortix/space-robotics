function A = Aind(i,a,alp,d,th)
    A = [cos(th(i)) -sin(th(i))*cosd(alp(i)) sin(th(i))*sind(alp(i)) cos(th(i))*a(i);
         sin(th(i)) cos(th(i))*cosd(alp(i)) -cos(th(i))*sind(alp(i)) sin(th(i))*a(i);
         0  sind(alp(i)) cosd(alp(i)) d(i);
         0  0   0   1];
end