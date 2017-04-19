function q_out = positionTrajectory2(positions,sr,vMax,cfg,orientation)

nPts = size(positions,1);

% Run IK for all points with a dummy orientation vector.
DH = getDH();

% Get all q values for all points and run FK to verify.
q = zeros(nPts,6);
FKpoints = zeros(nPts,3);
for i=1:nPts
    q(i,:) = inverseKinematics(positions(i,:),orientation,DH,cfg);
    FKpoints(i,:) = forwardKinematics(q(i,:));
end

% Acceleration at endpoint is set to 0
acc = 0;

% A row of dummy velocites for each q in JOINT SPACE. Starts and ends on
% zero
% velocities = [zeros(1,nPts) ;
%              rand(nPts-2,nPts)
%              zeros(1,nPts)];
velocities = zeros(nPts,1);

% Calculate distances between points
distances = abs(diff(positions));
distances = diag(sqrt(distances*distances.'));

% A time vector containing the timestamp of each point. This is based the
% the maximum velocity of the END EFFECTOR!
time = zeros(1,size(distances,1)+1);
time(2:end) = distances/vMax;

% Calculate how many steps the algorithm wil calculate and declare
% memory.
amountOfSteps = sum(round(sr*time(2:end)));
qOut = zeros(amountOfSteps,6); % We only save the angles.

% For all six angles, interpolate between current and next taking point
% specific constants into account. '1' turns on plot function, but
% for each interpolation call...
for j = 1:nPts-1
    for h = 1:6
        % Run smoothstep over each pair of q.
        [qTemp, ~,~,~] = smoothstep(time(j),time(j+1),...
            q(j,h),q(j+1,h),...
            velocities(j),velocities(j+1),...
            acc,acc,sr,0);
        
        % Create index to paste output in
        if j == 1
            range = 1:time(j+1)*sr;
        else
            range = (time(j)*sr)+1:time(j+1)*sr;
        end
        
        % append to output vector
        qOut(range,h) = qTemp;
    end
    
end

% Plot q
figure
plot(time,q,'b-.')

% Interpolated q
hold on
timeVec = linspace(time(1),time(end),length(qOut));
plot(timeVec,qOut);
legend('q1','q2','q3','q4','q5','q6','q1','q2','q3','q4','q5','q6','Location','best');


% Plot points and also plot the FK points
figure
plot3(positions(:,1),positions(:,2),positions(:,3),'r-o','LineWidth',1);
hold on
plot3(FKpoints(:,1),FKpoints(:,2),FKpoints(:,3),'b-.o','LineWidth',1);


% Run FK for each set of q found.
FKpointsEase = zeros(amountOfSteps,3);
for g = 1:amountOfSteps
    FKpointsEase(g,:) = forwardKinematics(qOut(g,:));
end

% Now plot the path generated by interpolating q.
plot3(FKpointsEase(:,1),FKpointsEase(:,2),FKpointsEase(:,3),'b','LineWidth',2);
box on
shg
axis equal
camproj('perspective')
legend('Points entered into trajectory','FK points trajectory','Interpolated q','Location','Best');

end