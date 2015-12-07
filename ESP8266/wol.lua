-- send a WOL magic packet

cu=net.createConnection(net.UDP)
-- cu:on("receive",function(cu,c) print(c) end)
cu:connect(0,"192.168.1.255") -- to broadcast of this subnet
arrhdr = "\255\255\255\255\255\255" -- WOL header

addr_hex_str="00-11-32-31-08-ad" -- the address to be woken

local function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

local lines = split(addr_hex_str, "-")

arrmac="" -- the MAC in binary representation
for r,line in ipairs(lines) do
   local r = tonumber(line, 16)
   arrmac = arrmac..string.char(r)
end

-- test print out the MAC
--for i = 1, #arrmac do
--    local c = arrmac:sub(i,i)
--    print(string.byte(c))
--end

wolpacket = arrhdr -- build the magic packet header + 16x MAC
for i=1,16 do
    wolpacket = wolpacket..arrmac
end

cu:send(wolpacket)
cu:close()



