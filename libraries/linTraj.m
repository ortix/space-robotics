function ptsOut = linTraj(pointsIn,sr,vMax)
% Takes points in a 3xn vector containing all points [x y z]' the
% robot's EEF should pass through and generates linearly
% interpolated paths through them, based on steps/s (sr) and max
% velocity, S shaped easing curve.


% Check input. If only 1 point is given assume current pos as start.
% if nargin < 3
%     error('Needs 3 inputs: points, sample rate and easing');   
% end

% if length(ease) < 2
%     error('Please enter two inflection points');
% end

% if length(pointsIn) < 1
%     disp('Take current position');
%     pointsIn = [getPos pointsIn];
% end




nPts = length(pointsIn);

% Declare memory. I do this dynamically since we dont know how many
% steps will be generated.
x_s = [];
y_s = [];
z_s = [];
ptsLin = [];
travelTime = zeros(1,nPts);

% Find euclidian distances between points.
xyzDist = diff(pointsIn,1,2)
travDist = sqrt(  sum(  xyzDist(:,:).^2));

% S curve interpolate for each set of two points.
for i = 1:nPts-1
    
    % Determine #segments based on path length, sr and max velocity.
    % Try to correct for S curve easing that increases max velocity later.
    segs = round(sr*travDist(i)/vMax); % /diff(ease));
    
    % Linearly interpolate between current and next point.
    steps = [linspace(pointsIn(1,i),pointsIn(1,i+1),segs)
             linspace(pointsIn(2,i),pointsIn(2,i+1),segs)
             linspace(pointsIn(3,i),pointsIn(3,i+1),segs)]
    
    % Sort ascending
    steps2 =  sort(steps,2);
    
    
    
%     % Get inflection points for S curve for x y and z. This is
%     broken since it sometimes yields a 0 index.
%     inflPts(1,:) = [steps2(1,(round(ease(1)*segs))) steps2(1,(round(ease(2)*segs)))];
%     inflPts(2,:) = [steps2(2,(round(ease(1)*segs))) steps2(2,(round(ease(2)*segs)))];
%     inflPts(3,:) = [steps2(3,(round(ease(1)*segs))) steps2(3,(round(ease(2)*segs)))];
    
steps2
[steps2(3,1) steps2(3,end)]
    % S curve distribution
    x =  smf2(steps2(1,:),[steps2(1,1) steps2(1,end)]).*xyzDist(1,i);
    
    y =  smf2(steps2(2,:),[steps2(2,1) steps2(2,end)]).*xyzDist(2,i);
    
    z =  smf2(steps2(3,:),[steps2(3,1) steps2(3,end)]).*xyzDist(3,i);
    
    smfPts = [x ; y ; z]
    
    
    % Check if flipped and flip back rows
    for j = 1:3
        if steps2(j,1) ~= steps(j,1)
          
            
            smfPts(j,:) =  fliplr(smfPts(j,:))
             disp([i j])
        end
    end
    
    smfPts
    
    % Calculate and append to output
    x_s  = [x_s  smfPts(1,:) ] ;
    y_s  = [y_s  smfPts(2,:) ] ;
    z_s  = [z_s  smfPts(3,:) ] ;
   
    % Calculate travel time based on #segments and sr
    travelTime = [travelTime segs*sr];
    
    ptsLin = horzcat(ptsLin,[steps(1,:) ;steps(2,:) ;steps(3,:)]);
end

% Output
ptsOut = [x_s ; y_s ; z_s];


totTravelTime = sum(travelTime);

plotPaths(pointsIn,ptsOut,ptsLin);

    

end

function plotPaths(pointsIn,ptsOut,ptsLin)
hold on
plot3(pointsIn(1,:),pointsIn(2,:),pointsIn(3,:),'-o','LineWidth',2);
plot3(ptsOut(1,:),ptsOut(2,:),ptsOut(3,:),'ko','LineWidth',2);
plot3(ptsLin(1,:),ptsLin(2,:),ptsLin(3,:),'bo','LineWidth',2);
cameratoolbar
end