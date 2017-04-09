%trajectory test martin kooper
% 8 april. Sun is shining outside. I am looking at a black screen.
% Lets program!
close all 
clc

% Generate random points in a spiral
npts = 10;
t = linspace(0,8*pi,npts);
z = linspace(-1,1,npts);
omz = sqrt(1-z.^2);
xyz = [cos(t).*omz; sin(t).*omz; z];
%xyz = [0 0 0 ; 1 1 1 ; -2 -2 2].';

% Use curve fitting to fit a spline through all points. This is our
% path generator.
traj = cscvn(xyz(:,1:end ));

% Plot points and text
plot3(xyz(1,:),xyz(2,:),xyz(3,:),'ro','LineWidth',2);
text(xyz(1,:),xyz(2,:),xyz(3,:),[repmat('  ',npts,1), num2str((1:npts)')])


% Turn off axes.  Bring forward and fix perspective. Rather 'gebeund'
ax = gca;
ax.XTick = [];
ax.YTick = [];
ax.ZTick = [];
box on

shg
axis equal
camproj('perspective')
cameratoolbar



% Plot path over points
hold on
fnplt(traj,'r',1)



%%%% Now generate positions along our path %%%

n = 200;    % Amount of positions

% Values to interpolate over
endPos = traj.breaks(end);    % End of the spline interpolation
xq = linspace(0,endPos,n);

% 0.1 and 0.9 are inflection points
y = smf2(xq ,[0.1*endPos 0.9*endPos])*endPos;


% This generates a linear result
posLin = fnval(traj,xq);

% This gives an S interpolation result
posSmf2 = fnval(traj,y);


% Plot position over path
 plot3(posLin(1,:),posLin(2,:),posLin(3,:),'ko','LineWidth',1); %
% Linear
plot3(posSmf2(1,:),posSmf2(2,:),posSmf2(3,:),'bo','LineWidth',1); 

%linTraj(xyz,50,4,[0.05 0.95]);