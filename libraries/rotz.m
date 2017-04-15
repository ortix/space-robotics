function R = rotz(t, deg)
if nargin > 1 && strcmp(deg, 'deg')
    t = t *pi/180;
end

ct = cos(t);
st = sin(t);
R = [
    ct  -st  0
    st   ct  0
    0    0   1
    ];