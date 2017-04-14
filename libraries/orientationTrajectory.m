function [EEFOrientationPtsEased]  = orientationTrajectory(currentOri,targetOri,ease,segments)
% Generates interpolated curve for the orientation of the EEF


% Sanitize easing input
if ease > 0.3
    disp('Ease too big. Set to 0.3');
    ease = 0.3;
elseif ease <0
    ease = 0;
    disp('Ease too small. Set to 0');
end

nPoints = size(targetOri,1);

points = [currentOri targetOri];

EEFOrientationPtsEased = [];


for i = 1:nPoints
    
    % Create spline through current and next point of orientation
    % vector.
    curve = cscvn(points(:,i:i+1));

    % Find the other end of the spline description and interpolate
    % over the spline. This eliminates descending vectors and works
    % for all directions.
    crvEnd = curve.breaks(end);
    xq = linspace(0,crvEnd,segments);
    y = smf2(xq ,[ease*crvEnd (1-ease)*crvEnd])*crvEnd;
    
    % Evaluate the spline from an S distribution of points.
    ptsSMF = fnval(curve,y);

    EEFOrientationPtsEased = [EEFOrientationPtsEased ptsSMF];

end
