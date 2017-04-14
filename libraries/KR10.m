clear L
%            theta    d           a       alpha
L(1) = Link([0        0.4         0.025    pi/2      0]);
L(2) = Link([0        0.000       0.560    pi        0]);
L(3) = Link([0        0.000       0.035   -pi/2      0]);
L(4) = Link([0        0.515       0        pi/2      0]);
L(5) = Link([0        0           0       -pi/2      0]);
L(6) = Link([0        0.000       0        0         0]);

KUKA10=SerialLink(L, 'name', 'Kuka KR10');
KUKA10.tool=transl(0,0,0.087);
KUKA10.ikineType = 'kr5';


T = transl(0.5, 0, 0.5);
q = KUKA10.ikine6s(T,'ruf');
q0 = [0 0 0 0 0 0];
KUKA10.plot(q)
