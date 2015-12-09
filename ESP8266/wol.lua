-- send a WOL magic packet
-- required: set up your wlan and adjust the MAC address and broadcast IP

broadcast_address = "192.168.1.255" -- of this subnet
addr_MAC_str="00-11-32-31-08-ad" -- the address to be woken

arrhdr = "\255\255\255\255\255\255" -- magic packet header

cu = net.createConnection(net.UDP) -- setup connection

cu:connect(0,broadcast_address) -- connect to broadcast 

-- helper stuff to dissect the MAC string
local function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

arrmac="" -- the MAC in binary representation
local single_bytes = split(addr_MAC_str, "-")
-- create binary string of MAC address
for r,line in ipairs(single_bytes) do
   local r = tonumber(line, 16)
   arrmac = arrmac..string.char(r)
end

-- test print out the MAC
--for i = 1, #arrmac do
--    local c = arrmac:sub(i,i)
--    print(string.byte(c))
--end

wolpacket = arrhdr -- build the magic packet = header + 16x MAC
for i=1,16 do
    wolpacket = wolpacket..arrmac
end

cu:send(wolpacket) -- finally send the packet
cu:close()



