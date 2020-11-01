<%
-- filename:       util.lp
-- description:    supply useful api for operation data and create HTML
-- project:        BT2.0 GUI

-- name:           printvar
-- description:    print vairaible including table in html codes
-- parameter:      t: vairaible need to print
--                 msg: the message need to print
-- return value:   null
-- author:

cgilua.lp.include("lp/bit.lp")
print = cgilua.print
local mbus = mbus

-- debug function
function printvar(t, msg)        -- quick and dirty generic print function
  local function printit(t, space)
    if type(t) == "number" or type(t) == "string" then
       print(t, "\n")
    elseif type(t) == "table" then
       print("\n", space, "{\n")
       for k,v in pairs(t) do
         print(space.."  ", k, " = ")
         printit(v, space.."  ")
       end
       print(space, "}\n")
    elseif type(t) == "nil" then
       print("nil\n")
    elseif type(t) == "userdata" then
       if tostring(t) then print(tostring(t), "\n")
       elseif tonumber(t) then print(tonumber(t), "\n")
       else print("unknow userdata\n")
       end
    else
       print("hmmm, don't know how to print this\n")
    end
  end
  print("<pre>\n")
  if msg then
     print(msg)
  end
  printit(t, "")
  print("</pre>")
end

-- name:           secondsToClock
-- description:    time convertion
-- parameter:      sSeconds: the number of seconds
-- return value:   directly return the string
-- author:

-- time&size convertion
function SecondsToClock(sSeconds)
  local nSeconds = tonumber(sSeconds)
  if nSeconds == 0 then
     return "00:00:00";
  else  
     local days = nSeconds/86400
     local daystr = "days"
     if days==1 then
       daystr = "day"
     end     
     local showtime = string.format("%d %s, %u:%02u:%02u", days, daystr, (nSeconds%86400)/3600, (nSeconds%3600)/60, nSeconds%60)    
     return showtime
  end
end

-- name:           formatN
-- description:    format number to xxxx,xxx,xxx
-- parameter:      num: the number
-- return value:   directly return the string
-- arithmetic:     123456789,
--                 reverse   987654321,  must from back to front.
--                 add "," in every 3 digits
--                 but last one, don't add ","
--                 987,654,321
--                 reverse back
--                 123,456,789

function formatN(num)
 local times=#num/3
 if times>0 then
  if #num%3==0 then
    times=times-1
  end
  local result=string.gsub(string.reverse(num),"%d%d%d","%0,",times)
  return string.reverse(result)
 else
  return num
 end
end

-- name:           cOutLink 
-- description:    create outside link, open in new window 
-- parameter:      uri: url of outside link
--                 desc: link name
-- return value:   directly return the string
-- author:         Zhu Hong Lei

function cOutLink(uri,desc)
  print('<p><img src="img/link_icon.gif" class="bullet"/><a class="vtop" href="', uri, '" target="_blank">', desc, '</a></p>')
end

-- name:           split 
-- description:    split string by delimiter 
-- parameter:      self: the string for splitting
--                 inSplitPattern: delimiter pattern, such as "[.]" for IP address.
-- return value:   return the table including the split entry
-- author:         Zhu Hong Lei

function split( self,inSplitPattern)
  local  outResults = { }
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end


-- name:           includeIP 
-- description:    detect the given ip is in the range or out the range 
-- parameter:      ipStart: the string of start ip
--                 ipEnd: the string of end ip
--                 ipMask: the string of ip netmask
--                 ip: the string of given ip
-- return value:   return false: out of range, true: in the range
-- author:         Zhu Hong Lei

function includeIP(ipStart,ipEnd,ipMask,ip)
  local ipS=split(ipStart,"[.]")
  local ipE=split(ipEnd,"[.]")
  local ipM=split(ipMask,"[.]")
  local ipR=split(ip,"[.]")
  local maskN=0  
  local include=false

  --find the mask lengh how many 255
  for i=1,#ipM do
     if ipM[i]=="255" then
       maskN=maskN+1
     end
  end

  -- mask part must same
  for i=1,maskN do
     if ipR[i]~=ipS[i] then
        return include
     end
  end

  -- compare the last part
  maskN=maskN+1

  if (ipR[maskN]/1)<(ipE[maskN]/1) and (ipR[maskN]/1)>(ipS[maskN]/1) then
     include=true 
  end 

  return include 
end

-- name:           formatlines
-- description:    get a long string, split into pieces by "\r\n"
-- parameter:      s:string
-- return value:   a table store line by line, not contain "\r\n"
-- author:         Li Zhi Quan

function formatLines(s)
    local i, j = 0, 0
    local t = {}                        -- table to store the indices
    local strfind, strsub = string.find, string.sub
    
    if type(s) ~= "string" then return false end

    while true do
        i = strfind(s, "\r\n", j)       -- find 'next' newline
        if i == nil then break end
        t[#t+1] = strsub(s, j, i-1)
        j = i + 2
    end
    return t
end

-- name:           returnLines
-- description:    get a long string, split into pieces by "\r\n"
-- parameter:      s:string
-- return value:   a table store line by line, contain "\r\n"
-- author:         Eddie Hodemniac

function returnLines(s)
    local t = {}
    if type(s) ~= "string" then return false end
    for l in s:gmatch("([^%c]+)\r\n") do
        t[#t+1] = l
    end
    return t
end


-- name:           getBoardInfo 
-- description:    get board infomation, version, sn, 
-- parameter:
-- return value:   return table of info

function getBoardInfo()

 local result={}
 local env, error =  mbus.getParameters{{path = "ENV", param = "Value", filter = "(== Name _BUILD)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _PROD_FRIENDLY_NAME)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _PROD_SERIAL_NBR)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _BOARD_NAME)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _BUILDVARIANT)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _BOOTLOADER_VERSION)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _MACADDR)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _WL_MACADDR)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _MODEMLABEL)"},
                                        {path = "ENV", param = "Value", filter = "(== Name _WL_VERSION)"}}
 result.sversion=env["ENV"][1].param["Value"]
 result.pname=env["ENV"][2].param["Value"]
 result.sn=env["ENV"][3].param["Value"]
 result.bversion=env["ENV"][4].param["Value"]
 result.svariant=env["ENV"][5].param["Value"]
 result.bootversion=env["ENV"][6].param["Value"]
 result.mac=env["ENV"][7].param["Value"]
 result.wlmac=""
 if env["ENV"][8]~=nil and  env["ENV"][8]~="" then
 	result.wlmac=string.upper(tostring(env["ENV"][8].param["Value"]))  

 end        
 if env["ENV"][9]~=nil and  env["ENV"][9]~="" then
 	result.adslversion=env["ENV"][9].param["Value"]                               
 end
 if env["ENV"][10]~=nil and  env["ENV"][10]~="" then
	result.wlversion=env["ENV"][10].param["Value"]
 end
 return result
end


-- name:           getWlanEthIntf
-- description:    get ETH.Phys.? for wlan interface
-- parameter:      type: "main" for home ssid,  "openzone" for BT openzone SSID
-- return value    ETH.Phys.?

function getWlanEthIntf(type)
  if type=="main" then
    local EthInf, error =  mbus.getParameters{path = "ETH.Phys", param="Name", filter="(and (== Technology WLAN) (== Name wlif1))"}
    if (EthInf["ETH.Phys"][1]~=nil) and (EthInf["ETH.Phys"][1].param["Name"]~=nil) then
       return EthInf["ETH.Phys"][1].path
    else
       return ""
    end

  elseif type=="openzone" then
     local IPIntf, error =  mbus.getParameters{path = "IP.Intf", param="Name", filter="(== Name ipOpenzone)"}
     if (IPIntf["IP.Intf"][1]~=nil) and (IPIntf["IP.Intf"][1].param["Name"]~=nil) then
        return IPIntf["IP.Intf"][1].path
     else
        return ""
     end
  end
end


-- name:           makeTimeList
-- description:    produce a list of 24 hour period in 30 minute intervals (48 items)
-- parameter:      
-- return value    the time list

function makeTimeList()
    local timeList = {}
    for i=1, 48, 2 do
        timeList[i] = {}
        timeList[i+1] = {}
        timeList[i]["Show"] = string.format("%02u:%02u", i/2, 0)
        timeList[i]["Real"] = timeList[i]["Show"]
        timeList[i+1]["Show"] = string.format("%02u:%02u", i/2, 30)
        timeList[i+1]["Real"] = timeList[i+1]["Show"]
    end
    return timeList
end


-- name:           scaleNum
-- description:    calculate a real number from MBUS reply and a scale factor
-- parameter:      num: the number retrieved from MBUS
--                 scale: the scale factor
-- return value    calculated real number

function scaleNum(num, scale)
    local result = num
    local index = tonumber(scale)/10
    if index < 1 then index = 1 end

    if (string.len(num)<=index) then
        result = "0."..num
    else
        index = (-1)*index
        result = string.sub(num, 1, index-1).."."..string.sub(num, index)
    end
    
    return result
end


-- name:           getCommonString 
-- description:    get common strings on the Hub to do strength validation
-- parameter:
-- return value:   return table of info

function getCommonString()
 local result={}
 local n=1
 local prefix, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name _SSID_SERIAL_PREFIX)"}
 local ssid_prefix = prefix["ENV"][1].param["Value"]
 local env, error =  mbus.getParameters{{path = "ENV", param = {"Name", "Value"}, filter = "(== Name _BOARD_SERIAL_NBR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _PROD_SERIAL_NBR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _USB_MACADDR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _LUSB_MACADDR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _MACADDR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _LMACADDR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _WL_MACADDR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _LWL_MACADDR)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _WL0_WEPKEY_SERIAL)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _WL0_WPAKEY_SERIAL)"},
                                        {path = "ENV", param = {"Name", "Value"}, filter = "(== Name _WL0_SSID_SERIAL)"}}
 for i,v in pairs(env["ENV"]) do
    if (v.param["Name"]=="_WL0_SSID_SERIAL") then
      result[n] = ssid_prefix .. v.param["Value"]
    else
      result[n] = v.param["Value"]
    end
    n=n+1
 end
 return result
end


-- name:           getWlanCommonStr
-- description:    get WLAN ssid, wep key and wpa key 
-- parameter:      mpath: WLAN intf MBUS path 
-- return value    a table of ssid, wep key and wpa key info. 

function getWlanCommonStr(mpath)
  local result = {}
  local wlan_data, error = mbus.getParameters{ {path = mpath, param = "SSID" },
                                          {path = mpath..".Security.WEP", param ="WEPKey"},
                                          {path = mpath..".Security.WPAPSK", param = "PSK"} }
  result.ssid = wlan_data[mpath][1].param["SSID"]
  result.wep  = wlan_data[mpath..".Security.WEP"][1].param["WEPKey"]
  result.wpa  = wlan_data[mpath..".Security.WPAPSK"][1].param["PSK"]

  return result 
end


-- name:           format64BitData
-- description:    convert a 64 bit unsigned integer to the format of "xxxxxxx.xxx MB"
-- parameter:      high_str: the higher 32 bit in binary string format
--                 low_str: the lower 32 bit in binary string format
-- return value    a string in the format of "xxxxxxx.xxx MB".

function format64BitData(high_str, low_str)
  local KB_v, MB_v, GB_v = 0, 0, 0
  local buff = ">1048576 MB"
  
  if (high_str==nil) or (high_str=="") or (low_str==nil) or (low_str=="") then
    return "0.0 MB"
  end
  
  if (string.len(high_str) > 8) then
    -- count > 1048576 MB
    return buff
  end

  local len = string.len(low_str)
  if (len<11) and (tonumber(high_str)==0) then
    -- count < 1 KB
    return "0.0 MB"
  end

  -- calculate the KB, MB and GB value in low_str
  if (len > 20) then
    KB_v = tonumber(string.sub(low_str, -20, -11), 2)
    if (len > 30) then
      MB_v = tonumber(string.sub(low_str, -30, -21), 2)
      GB_v = tonumber(string.sub(low_str, 1, -31), 2)
    else
      MB_v = tonumber(string.sub(low_str, 1, -21), 2)
    end
  else
    KB_v = tonumber(string.sub(low_str, 1, -11), 2)
  end
  
  -- add the GB value in high_str
  GB_v = GB_v + tonumber(high_str.."00", 2)
  -- add GB to MB
  MB_v = MB_v + GB_v*1024
  
  KB_v= KB_v/10
  if (KB_v ~= 0) and (KB_v < 10) then
    buff = string.format("%u.0%u MB", MB_v, KB_v)
  else
    buff = string.format("%u.%u MB", MB_v, KB_v)
  end
  
  return buff
end

-- convert ip address to binary number

function ip2long(ip)
    local _,_,a,b,c,d =string.find(tostring(ip),"(%d+).(%d+).(%d+).(%d+)")
    return tonumber(a)*16777216+tonumber(b)*65536+tonumber(c)*256+tonumber(d)
end

-- convert binary number of ip address to xxx.xxx.xxx.xxx fromat
function long2ip(ipnumber)
    local temp1, temp2, seg1, seg2, seg3, seg4
    temp1= ipnumber%(256*256*256)
    seg1= (ipnumber-temp1)/(256*256*256)
    temp2= temp1%(256*256)
    seg2=(temp1-temp2)/(256*256)
    temp1= temp2%256
    seg3= (temp2-temp1)/256
    seg4= temp1
    return seg1.."."..seg2.."."..seg3.."."..seg4
end


-- return true when ip is in start and end

function inRange(ip, start, endip)
   if ip2long(ip)>=ip2long(start) and ip2long(ip)<=ip2long(endip) then
      return true 
   else
      return false
   end
end

--return the nat range from the ip and net mask
function natRange(ip, netmask)
	
	local ipLong=ip2long(ip)
	local maskLong=ip2long(netmask)

	local startip= bit:_and(ipLong,maskLong) + 1
	local endip = bit:_or(ipLong , bit:_not(maskLong)) - 1
	if ipLong == startip then startip=startip+1 end
	if ipLong == endip then endip=endip-1 end

	local beginip=long2ip(startip)
	local lastip=long2ip(endip)

	return beginip, lastip
end

function splitPath(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function validDirectory(pathStr)
        local flag = 1
        local startIndex = 1
        parts = splitPath(pathStr,'[\\/]+')

        for i=startIndex, #parts do
                tmp = splitPath(parts[i],'[.]+')
                if next(tmp)==nil then
                        flag = 0
                end
        end
        local valDir = io.open(pathStr)
        if not valDir then
                flag = 0
        end
return flag
end
%>

