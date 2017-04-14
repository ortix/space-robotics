function DH = GetDH

DH(1) = struct('theta',0,'d',0.4,'a',0.025,'alpha',pi/2);
DH(2) = struct('theta',0,'d',0,'a',0.560,'alpha',pi);
DH(3) = struct('theta',0,'d',0,'a',0.035,'alpha',-pi/2);
DH(4) = struct('theta',0,'d',0.515,'a',0,'alpha',pi/2);
DH(5) = struct('theta',0,'d',0,'a',0,'alpha',-pi/2);
DH(6) = struct('theta',0,'d',0,'a',0,'alpha',0);
DH(6).tool = GetPlanarT([0 0 0.240]);

end