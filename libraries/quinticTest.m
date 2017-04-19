close all;
clear all;

% Load points
load('fixed_8.mat');
nPts = size(positions,1);

%%%

% Run IK for all points with a dummy orientation vector.
orientation = [1 0 0];
DH = getDH();
config = 'ru';

% Get all q values for all points
q = zeros(nPts,6);
for i=1:nPts
    q(i,:) = inverseKinematics(positions(i,:),orientation,DH,config);
end

%%%

% Stuff needed for trajectory generation.
% Sample rate and acceleration constraints for each point. Dummy
% values.
sr = 50;
acc = 0;

% A row of dummy velocites for each q in JOINT SPACE. Starts and ends on
% zero
velocities = [zeros(1,nPts) ;
             rand(nPts-2,nPts)
             zeros(1,nPts)];
%velocities = zeros(nPts,1);

% A time vector containing the timestamp of each point.
time = [0 5 10 15 20 25 30 45 50];

% Calculate how many steps the algorithm wil calculate.
amountOfSteps = time(end)-time(1)*sr;

% We only save the angles.
qOut = zeros(amountOfSteps,6);

% For all six angles, interpolate between current and next taking point
% specific constants into account.
for j = 1:nPts-1
    for h = 1:6
        % Run smoothstep over each pair of q.
        [qTemp, ~,~,~] = smoothstep(time(j),time(j+1),...
            q(j,h),q(j+1,h),...
            velocities(j),velocities(j+1),...
            acc,acc,sr,'no');
        
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


% Plot points
plot3(positions(:,1),positions(:,2),positions(:,3),'ro','LineWidth',1);
box on
shg
axis equal
camproj('perspective')

% Plot q
figure
plot(time,q,'b-.')


% Interpolated q
hold on
timeVec = linspace(time(1),time(end),length(qOut));
plot(timeVec,qOut);
legend('q1','q2','q3','q4','q5','q6','q1','q2','q3','q4','q5','q6','Location','best');
