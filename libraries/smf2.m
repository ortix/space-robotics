function y = smf2(x,params)
if nargin ~= 2,
    error('Two arguments are required by SMF.');
elseif length(params) < 2,
    error('SMF needs at least two parameters.');
end

x0 = params(1); x1 = params(2);

if(x0 >= x1)
    error('x0 may not be bigger than x1');
end

y = zeros(size(x));

index1 = find(x <= x0);
if ~isempty(index1),
    y(index1) = zeros(size(index1));
end

index2 = find((x0 < x) & (x <= (x0+x1)/2));
if ~isempty(index2),
    y(index2) = 2*((x(index2)-x0)/(x1-x0)).^2;
end

index3 = find(((x0+x1)/2 < x) & (x <= x1));
if ~isempty(index3),
    y(index3) = 1-2*((x1-x(index3))/(x1-x0)).^2;
end

index4 = find(x1 <= x);
if ~isempty(index4),
    y(index4) = ones(size(index4));
end
end
