function ptsOut = linTraj(pointsIn,sr,vMax,ease)
% Takes points in a 3xn vector containing all points [x y z]' the
% robot's EEF should pass through and generates linearly
% interpolated paths through them, based on steps/s (sr) and max
% velocity, S shaped easing curve.


% Sanitize easing input
if ease > 0.3
    disp('Ease too big. Set to 0.3');
    ease = 0.3;
elseif ease <0
    ease = 0
    disp('Ease too small. Set to 0');
end

% if length(pointsIn) < 2
%     disp('Take current position');
%     pointsIn = [getPos pointsIn];
% end




nPts = length(pointsIn);

% Declare memory. I do this dynamically since we dont know how many
% steps will be generated.

ptsLin = [];
ptsEased = [];
travelTime = zeros(1,nPts);

% Find euclidian distances between points.
xyzDist = diff(pointsIn,1,2);
travDist = sqrt(  sum(  xyzDist(:,:).^2));

% S curve interpolate for each set of two points.
for i = 1:nPts-1
    
    % Create spline through current and next point
    curve = cscvn(pointsIn(:,i:i+1));
    fnplt(curve,'r',1)
    
    % Determine #segments based on path length, sr and max velocity.
    % Try to correct for S curve easing that increases max velocity later.
    segs = round(sr*travDist(i)/vMax); % /diff(ease));
    
    % Linearly interpolate between current and next point.
    steps = [linspace(pointsIn(1,i),pointsIn(1,i+1),segs)
            linspace(pointsIn(2,i),pointsIn(2,i+1),segs)
            linspace(pointsIn(3,i),pointsIn(3,i+1),segs)];
   
    crvEnd = curve.breaks(end);
    xq = linspace(0,crvEnd,segs);
    y = smf2(xq ,[ease*crvEnd (1-ease)*crvEnd])*crvEnd;
    
    % This gives an S interpolation result
    posSmf2 = fnval(curve,y);
    
    % Calculate travel time based on #segments and sr
    travelTime = [travelTime segs/sr];
    
    % Output eased and linear points.
    ptsLin = horzcat(ptsLin, [steps(1,:) ;steps(2,:) ;steps(3,:)] );
        
    ptsEased = [ptsEased posSmf2];
        
end

% Total travel time, plot and output
totTravelTime = sum(travelTime);

plotPaths(pointsIn,ptsEased,ptsLin);

ptsOut = ptsEased;    

end

% Plot function. Can be turned off
function plotPaths(pointsIn,ptsEased,ptsLin)
hold on
plot3(pointsIn(1,:),pointsIn(2,:),pointsIn(3,:),'-o','LineWidth',1);
plot3(ptsEased(1,:),ptsEased(2,:),ptsEased(3,:),'go','LineWidth',2);
plot3(ptsLin(1,:),ptsLin(2,:),ptsLin(3,:),'bo','LineWidth',1);
cameratoolbar
end