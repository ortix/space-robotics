udpr = dsp.UDPReceiver('LocalIPPort',31000,'MessageDataType','double');

setup(udpr);

while(1)
dataReceived = udpr()
pause(1/100);
end

