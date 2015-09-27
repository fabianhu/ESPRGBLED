-- activate server in fritz box by calling #96*5*
-- configure your wifi
-- wifi.setmode(wifi.STATION)
-- wifi.sta.config("SSID","password")
-- wifi.sta.autoconnect(1)

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function fritzrcv(sck, c) 
    print(c) 
    sps = split(c,';')
    for i,v in ipairs(sps) do
        print(v)
    end
    
    if sps[2] == "CALL" then
      pwm.setduty(5,0) -- g
      pwm.setduty(6,0) -- r
      pwm.setduty(7,1023) -- b  
    end
    
    if sps[2] == "RING" then
      pwm.setduty(5,0) -- g
      pwm.setduty(6,1023) -- r
      pwm.setduty(7,0) -- b  
    end
    
    if sps[2] == "CONNECT" then
      pwm.setduty(5,1023) -- g
      pwm.setduty(6,0) -- r
      pwm.setduty(7,0) -- b 
    end
    
    if sps[2] == "DISCONNECT" then
      pwm.setduty(5,0) -- g
      pwm.setduty(6,0) -- r
      pwm.setduty(7,0) -- b 
    end

end

pwm.setup(5,1000,0)
pwm.setup(6,1000,0)
pwm.setup(7,1000,0)

pwm.setduty(5,100) -- g
pwm.setduty(6,0) -- r
pwm.setduty(7,0) -- b 

-- wait for connect
tmr.alarm(1, 5000, 0, function() 
    ip,nm,gw = wifi.sta.getip()
    print(ip)
    if ip == nil then
        print "ough"
        tmr.alarm(1, 1000, 0, function() 
            node.restart()
        end)
    else
        pwm.setduty(5,0) -- g
        sk=net.createConnection(net.TCP, 0)
        sk:on("receive", fritzrcv )
        sk:connect(1012,"192.168.1.1")
    end
end)










