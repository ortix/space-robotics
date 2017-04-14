function R = rotx(t, deg)

if nargin > 1 && strcmp(deg, 'deg')
    t = t *pi/180;
end

ct = cos(t);
st = sin(t);
R = [
    1   0    0
    0   ct  -st
    0   st   ct
    ];
