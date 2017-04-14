function [EEFOrientationPtsEased]  = orientationTrajectory(currentOri,targetOri,ease,segments,discrete)
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

points = [currentOri ; targetOri].';

EEFOrientationPtsEased = [];




% Continuous spline between points
if ~discrete
curve = cscvn(points(:,1:end));
    
    
    % Numerical arc length calculation
    crvEnd = curve.breaks(end);
    linSteps = linspace(0,crvEnd,crvEnd*3000);
    
    xyz = fnval(curve,linSteps);
    xyzDist = diff(xyz,1,2);
    arcLength = 0;
    for i = 1:crvEnd*3000-1
        arcLength = arcLength + norm(xyzDist(:,i));
    end
    
    
    % Determine #segments based on path length, sr and max velocity.
    % Try to correct for S curve easing that increases max velocity later.
    segs = round(sr*arcLength/vMax/(1-2*ease));
    
    xq = linspace(0,crvEnd,segs);
    y = smf2(xq ,[ease*crvEnd (1-ease)*crvEnd])*crvEnd;
    
    % Evaluate the spline from an S distribution of points.
    posSmf2 = fnval(curve,y);
    
    EEFOrientationPtsEased = posSmf2.';
    
end


% Discrete between points.
for i = 1:nPoints
    
    % Create spline through current and next point of orientation
    % vector.
    curve = cscvn(points(:,i:i+1));

    % Find the other end of the spline description and interpolate
    % over the spline. This eliminates descending vectors and works
    % for all directions.
    crvEnd = curve.breaks(end);
    xq = linspace(0,crvEnd,segments(i));
    y = smf2(xq ,[ease*crvEnd (1-ease)*crvEnd])*crvEnd;
    
    % Evaluate the spline from an S distribution of points.
    ptsSMF = fnval(curve,y);

    EEFOrientationPtsEased = [EEFOrientationPtsEased ptsSMF];

end


EEFOrientationPtsEased = EEFOrientationPtsEased.';

end
