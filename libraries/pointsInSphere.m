function [x,y,z] = pointsInSphere(r1,r2,n)

% Generate a hollow sphere with n random points between r1 and r2

rvals = 2*rand(n,1)-1;
elevation = asin(rvals);
azimuth = 2*pi*rand(n,1);
x = (r1/r2)^r2;
radii = r2*(x+(1-x)*rand(n,1)).^(1/r2);
[x,y,z] = sph2cart(azimuth,elevation,radii);

% figure
% plot3(x,y,z,'.')
% axis equal

end
