function postProcess(q,Ts)

figure
t = linspace(1,size(q,2)/Ts,size(q,2));

for i = 1:6

       subplot(2,3,i)
       plot(t,q(i,:))
       title(sprintf('q%i',i));
       xlabel('t [s]')
       ylabel('theta [rad]');
end




end