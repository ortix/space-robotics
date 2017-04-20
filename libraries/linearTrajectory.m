function traj = linearTrajectory(positions,Fs,vMax)

% Fun experiment to see if we can optimize the trajector generator.
% Conclusion: yes we can by pre-allocating memory.

path = positions;
nPoints = size(path,1);

% Calculate distances
distances = abs(diff(path));
distances = diag(sqrt(distances*distances.'));

% Time necessary for each step
t = distances/vMax;
samples = round(Fs*t);
traj = zeros(sum(samples),size(path,2));

idx = 0;
for i = 1:nPoints-1
   
    % Select the location where we are filling the array
    idx2 = idx+samples(i);
    
    for j = 1:size(path,2)
        
       ptp = linspace(path(i,j),path(i+1,j),samples(i)).'; 
       traj((idx+1):idx2,j) = ptp;
       
    end
    
    % We now reset the location to where we just ended
    idx = idx2;
end

end
