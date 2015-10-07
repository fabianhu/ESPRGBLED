-- activate server in fritz box by calling #96*5*
-- configure your wifi
-- wifi.setmode(wifi.STATION)
-- wifi.sta.config("SSID","password")
-- wifi.sta.autoconnect(1)

mode = 0
level_r=0
level_g=0
level_b=0

maxpwm = 50
steppwm = 10
interval = 1000

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function setoff()
    pwm.setduty(6,0) -- r
    pwm.setduty(5,0) -- g
    pwm.setduty(7,0) -- b 
end

function setupfade()
    mode = 3
    level_r = maxpwm / 3 -- r
    level_g = maxpwm / 3*2 -- g
    level_b = 0 -- b  
end


function fritzrcv(sck, c) 
    print(c) 
    sps = split(c,';')
    for i,v in ipairs(sps) do
        print(v)
    end
    
    if sps[2] == "CALL" then
      mode = 0
      level_r = 0 -- r
      level_g = 0 -- g
      level_b = 1023 -- b  
    end
    
    if sps[2] == "RING" then
      mode = 1
      level_r = 1023 -- r
      level_g = 0 -- g
      level_b = 0 -- b  
    end
    
    if sps[2] == "CONNECT" then
      mode = 0
      level_r = 0 -- r
      level_g = 1023 -- g
      level_b = 0 -- b  
    end
    
    if sps[2] == "DISCONNECT" then
      mode = 0
      level_r = 0 -- r
      level_g = 0 -- g
      level_b = 0 -- b  
    end

end


function fritzconn(sck,c)
    print("connected to FB")
      mode = 0
      level_r = 0 -- r
      level_g = maxpwm -- g
      level_b = 0 -- b  
end

function fritzdisconn(sck,c)
    print("disconnection from FB")
    level_r = 1023
end

function pwmsetduty(pin,lvl)
    if lvl < 0 then 
        lvl = 0-lvl 
    end
  
    pwm.setduty(pin,lvl)
end

function setlight()
    pwmsetduty(6,level_r) -- r
    pwmsetduty(5,level_g) -- g
    pwmsetduty(7,level_b) -- b 
    --print (level_r, level_g, level_b )
end


function inc(n) -- with overflow
    if n < (maxpwm-steppwm) then
        return n+steppwm
    else
        return -maxpwm
    end
end

function dec(n)
    if n > steppwm then
        return n-steppwm
    else
        return 0
    end
end

function dolight()
    ip,nm,gw = wifi.sta.getip()
    if ip == nil then 
        if mode ~= 3 then -- inc
            setupfade()
        end
    else 
        mode =0
    end
    
    if mode == 3 then -- cycle
        level_r = inc(level_r)
        level_g = inc(level_g)
        level_b = inc(level_b)
        setlight()
        return
    end
    
    if mode == 0 then -- static
        level_r = dec(level_r)
        level_g = dec(level_g)
        level_b = dec(level_b)
        setlight()
        return
    end

    if mode == 1 then -- blink
        setlight()
        tmr.alarm(3, interval/2 , 0, function() 
            setoff()
        end)
    end
   
end

pwm.setup(5,1000,0)
pwm.setup(6,1000,0)
pwm.setup(7,1000,0)

level_b = 500
setlight()

setoff()

-- wait for connect
tmr.alarm(1, 5000, 0, function() 
    ip,nm,gw = wifi.sta.getip()
    print(ip)
    if ip == nil then
        print "ough"
        tmr.alarm(1, 10000, 0, function() 
            node.restart()
        end)
    else
        pwm.setduty(5,0) -- g
        sk=net.createConnection(net.TCP, 0)
        sk:on("receive", fritzrcv )
        sk:on("connection", fritzconn )
        sk:on("reconnection", fritzconn )
        sk:on("disconnection", fritzdisconn )
        --sk:on("sent", fritzsent )
        
        sk:connect(1012,"192.168.1.1")
    end
end)

tmr.alarm(2, interval, 1, dolight)



