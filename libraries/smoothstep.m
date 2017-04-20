function [q, qd, qdd, qddd] = smoothstep(t0, tf, q0, qf, v0, vf, ac0, acf, sr,plt)
% Smoothstepping between two values using quintic polynomials.
% Time and #steps taken based on sample rate in steps/s.

% Example 
% [qTemp, ~,~,~] = smoothstep(time(j),time(j+1),...
%           q(j,h),q(j+1,h),...
%           velocities(j),velocities(j+1),...
%           acc,acc,sr,1);
% example : smoothstep(5, 15, 1, 4, 6, 0, 0, 0, 50,1)

% Create time vector based on the time and sample rate.
segments = ceil((tf-t0)*sr);
t = linspace(t0,tf,segments);


% Create system for generating a quintic spline that adheres to start
% and end constraints for pos,vel,acc.
% q(t) = a0 + a1*t +a2*t^2 +a3*t^3 +a4*t^4 +a5*t^5
% solve for a0...a5

A = [1 t0 t0^2    t0^3      t0^4        t0^5
    0  1 2*t0    3*t0^2    4*t0^3      5*t0^4
    0  0 2       6*t0      12*t0^2     20*t0^3
    1 tf tf^2    tf^3      tf^4        tf^5
    0  1 2*tf    3*tf^2    4*tf^3      5*tf^4
    0  0 2       6*tf      12*tf^2     20*tf^3 ];

B = [q0 v0 ac0 qf vf acf].';
a = A\B;

%Numeric evaluation of polynomial for real time execution
q = zeros(1,segments);    % position
qd = zeros(1,segments);   % velocity
qdd = zeros(1,segments);  % acceleration
qddd = zeros(1,segments); %jerk

for i = 1:segments
    tCur = t(i);  % Only do array lookup once.
    q(i) = a(1) + a(2)*tCur + a(3)*tCur^2 + a(4)*tCur^3 + a(5)*tCur^4 + a(6)*tCur^5;
    qd(i) = a(2) + 2*a(3)*tCur +3*a(4)*tCur^2 + 4*a(5)*tCur^3 + 5*a(6)*tCur^4;
    qdd(i) = 2*a(3) + 6*a(4)*tCur + 12*a(5)*tCur^2 + 20*a(6)*tCur^3;
    qddd(i) = 6*a(4) + 24*a(5)*tCur + 60*a(6)*tCur^2;
end

    if (plt == 1)
        plotQ(t,q,qd,qdd,qddd);
    end
    
    % Make sure output is a column
    q = q.';
    qd = qd.';
    qdd = qdd.';
    qddd = qddd.';
end

function plotQ(t,q,qd,qdd,qddd)
close all;
shg
plot(t,q,t,qd,t,qdd,t,qddd);
legend('Position','Velocity','Acceleration','jerk','Location','Best');
end

%  Symbolically.
%  Create polynomial using found constants.
%  syms t;
%  location = a(1) + a(2)*t + a(3)*t^2 + a(4)*t^3 + a(5)*t^4 + a(6)*t^5;
%  velocity = a(2) + 2*a(3)*t +3*a(4)*t^2 + 4*a(5)*t^3 + 5*a(6)*t^4;
%  acceleration = 2*a(3) + 6*a(4)*t + 12*a(5)*t^2 + 20*a(6)*t^3;
%
%  clf;
%  shg
%  hold on;
%
%  fplot(location,[t0 tf]);
%  fplot(velocity,[t0 tf]);
%  fplot(acceleration,[t0 tf]);
%
%  legend('Position','Velocity','Acceleration','Location','Best');