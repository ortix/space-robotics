function traj = lin_trajectory(point_i,point_f,n)

traj = zeros(n,3);

for j = 1:3
   traj(:,j) = linspace(point_i(j),point_f(j),n);
end

end