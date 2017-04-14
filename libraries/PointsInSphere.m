function [x,y,z] = PointsInSphere(r,n)

rvals = 2*rand(n,1)-1;
elevation = asin(rvals);
azimuth = 2*pi*rand(n,1);
radii = r*(rand(n,1).^(1/r));
[x,y,z] = sph2cart(azimuth,elevation,radii);
end
% figure
% plot3(x,y,z,'.')
% axis equal