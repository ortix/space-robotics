function [ptsEased, ptsLin] = trajectory_generator(currentPos,targets,sr,vMax,ease)
% Takes points in a 3xn vector containing all points [x y z]' the
% robot's EEF should pass through and generates linearly
% interpolated paths through them, based on steps/s (sr) and max
% velocity, S shaped easing curve.


% Sanitize easing input
if ease > 0.3
    disp('Ease too big. Set to 0.3');
    ease = 0.3;
elseif ease <0
    ease = 0;
    disp('Ease too small. Set to 0');
end


% Minimum radius sphere through which the EEF cannot move.
Rmin = 0.5;


nPoints = size(targets,2);
points = [currentPos targets];

% Declare memory. I do this dynamically since we dont know how many
% steps will be generated.
ptsLin = [];
ptsEased = [];
travelTime = zeros(1,nPoints);

% Find euclidian distances between points.
xyzDist = diff(points,1,2);
travDist = sqrt(  sum(  xyzDist(:,:).^2));

% Interpolation for each set of two points.
for i = 1:nPoints
    
    % Create spline through current and next point
    curve = cscvn(points(:,i:i+1));
%     fnplt(curve,'r',1)
    
    % Determine #segments based on path length, sr and max velocity.
    % Try to correct for S curve easing that increases max velocity later.
    segs = round(sr*travDist(i)/vMax/(1-2*ease)); 
    
    % Linearly interpolate between current and next point.
    steps = zeros(3,segs);
    for j = 1:3
        steps(j,:) = linspace(points(j,i),points(j,i+1),segs);
    end
   
        
    %%%%%%%%% The following can maybe be replaced by our own polynomial
    %%%%%%%%% smoothstepping 
    
    % Find the other end of the spline description and interpolate
    % over the spline. This eliminates descending vectors and works
    % for all directions.
    crvEnd = curve.breaks(end);
    xq = linspace(0,crvEnd,segs);
    y = smf2(xq ,[ease*crvEnd (1-ease)*crvEnd])*crvEnd;
    
    % Evaluate the spline from an S distribution of points.
    posSmf2 = fnval(curve,y);
    %%%%%%%%%
    
    % Now check whether any of the points lie inside a minimum
    % radius.
    for h = 1:segs
        
        % Get vector norm from 0..point.
        ptLin = norm(steps(:,h));
        ptSMF = norm(posSmf2(:,h));
        
        % If the vector is smaller than Rmin, scale it to outside
        % the minimum radius, for both linear and smf points.
        if ptLin < Rmin
            steps(:,h) = steps(:,h)./ptLin .* Rmin;
        end
        
        if ptSMF < Rmin
            posSmf2(:,h) = posSmf2(:,h)./ptSMF .* Rmin;
        end
        
    end
    
    % Calculate travel time based on #segments and sr.
    travelTime = [travelTime segs/sr];
    
    % Output eased and linear points.
    ptsLin = horzcat(ptsLin, [steps(1,:) ;steps(2,:) ;steps(3,:)] );
        
    ptsEased = [ptsEased posSmf2];
        
end

% Total travel time, plot and output
totTravelTime = sum(travelTime);

% plotPaths(pointsIn,ptsEased,ptsLin);

end

% Plot function. Can be turned off
% function plotPaths(pointsIn,ptsEased,ptsLin)
% hold on
% plot3(pointsIn(1,:),pointsIn(2,:),pointsIn(3,:),'-o','LineWidth',1);
% plot3(ptsEased(1,:),ptsEased(2,:),ptsEased(3,:),'go','LineWidth',2);
% plot3(ptsLin(1,:),ptsLin(2,:),ptsLin(3,:),'bo','LineWidth',1);
% cameratoolbar
% shg
% end