function R = roty(t, deg)
    if nargin > 1 && strcmp(deg, 'deg')
        t = t *pi/180;
    end
    ct = cos(t);
    st = sin(t);
    R = [
        ct  0   st
        0   1   0
       -st  0   ct
       ];
