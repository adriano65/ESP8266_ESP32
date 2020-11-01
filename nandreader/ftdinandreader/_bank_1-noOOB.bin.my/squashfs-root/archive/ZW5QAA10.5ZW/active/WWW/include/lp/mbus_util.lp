<%
-- filename:       mbus_util.lp
-- description:    supply useful api for mbus operation
-- project:        BT2.0 GUI

-- name:           setMBUS
-- description:    set parameter to MBUS 
-- parameter:      set:  a table for set info 
-- return value    null  
local tprint = require("tableprint")
function setMBUS(set)
  local result=0
  if #set>0 then
      local reply1, error1 = mbus.modify(
        function()
		local pcall_status, pcall_error = pcall(
		function()
	          local reply, error = mbus.setParameters(set)
        	  if error~=nil then result=1 end
	  	end)
		if (pcall_status ~= true) then
		   result=1
		   return result
	     end
        end)
  
	  if (error1 ~= nil) then
	  	result=1
	  end
  end
  return result
end

-- name:           setMBUS_IGD
-- description:    set parameter to MBUS IGD datamodel
-- parameter:      set:  a table for set info 
-- return value    null  

function setMBUS_IGD(set)
  local result=0
  set["datamodel"]="second"
  if #set>0 then
      local reply1, error1 = mbus.modify(
        function()
		local pcall_status, pcall_error = pcall(
                function()
		  local reply, error = mbus.setParameters(set)
		  if error~=nil then 
			  result=1 
		  end
		end)
		
		if (pcall_status ~= true) then 
				result=1
				return result
		end
		
        end,
		{datamodel="second"}
      )
	if (error1 ~=nil) then 
			result=1 
	end	  

  end
  return result
end



-- name:           sortList 
-- description:    sort list by key 
-- parameter:      list: the table need to sort 
--                 key: the index of table 
--                 order: "nil","more" means from little to large, "less" means from large to little
-- return value    null, function will change the argument passed to list. 
-- author:         Zhu Hong Lei (hong-lei.zhu@thomson.net)

function sortList(list, key, order)
   if order==nil then
      order="more"
   end
   if order=="more" then
     table.sort(list, function(x, y) return string.lower(x[key]) < string.lower(y[key]) end)
   elseif order=="less" then
     table.sort(list, function(x, y) return string.lower(x[key]) > string.lower(y[key]) end)
   end
end


-- name:           getList
-- description:    get MBUS info according correct path, filter and parameter names 
-- parameter:      dataPath: MBUS Atomic Data Model path
--                 fitlerString: complete fitler string, nil means no filter
--                 ...: variable numbers of arguments, means the MBUS parameters you want
-- return value    result table, include the path and the parameters you want, 
--                 Assuming you invoke getlist like this:  getlist(path, nil, "Name", "IPAddress")
--                 you can access them by:  result[i].path, result[i]["Name"], result[i]["IPAddress"]
-- author:         Zhu Hong Lei (hong-lei.zhu@thomson.net)

function getList(dataPath,filterString,...)
  local result={}
  local data
  local error
  local parameter={...}


  --get info from MBUS
  if dataPath~=nil then
    -- BT special implementation, if the userfriendlyname is same, and has connected and unconneted item, show connected one.if all connected or unconnected, show all.
      if filterString~=nil then
        data, error = mbus.getParameters{path = dataPath, param = parameter, filter=filterString}
      else
        data, error = mbus.getParameters{path = dataPath, param = parameter}  
      end 
  end 

  -- fill info into result
  if #data[dataPath]>0 then
    local n=1    
    for i=1, #data[dataPath] do
      local valid = 1
      result[n] = {}
      result[n].path = data[dataPath][i].path

      for j=1, #parameter do 
        result[n][parameter[j]]=data[dataPath][i].param[parameter[j]]        
        if (result[n][parameter[j]]==nil) then
          result[n] = nil
          valid = 0
          break
        end
      end
      
      if (valid==1) then
        n = n+1
      end
    end 
  end 
  
  return result
end


function getList_keystr(dataPath,filterString,...)
  local result={}
  local data
  local error
  local parameter={...}

  --get info from MBUS
  if dataPath~=nil then
    -- BT special implementation, if the userfriendlyname is same, and has connected and unconneted item, show connected one.if all connected or unconnected, show all.
      if filterString~=nil then
        data, error = mbus.getParameters{path = dataPath, param = parameter, filter=filterString, flags="KEYPATH"}
      else
        data, error = mbus.getParameters{path = dataPath, param = parameter, flags="KEYPATH"}
      end
  end

  -- fill info into result
  if #data[dataPath]>0 then
    local n=1
    for i=1, #data[dataPath] do
      local valid = 1
      result[n] = {}
      result[n].path = data[dataPath][i].path
      for j=1, #parameter do
        result[n][parameter[j]]=data[dataPath][i].param[parameter[j]]
        if (result[n][parameter[j]]==nil) then
          result[n] = nil
          valid = 0
          break
        end
      end

      if (valid==1) then
        n = n+1
      end
    end
  end

  return result
end

-- name:           getList_IGD
-- description:    get MBUS info according correct path, filter and parameter names 
-- parameter:      dataPath: MBUS IGD Data Model path
--                 fitlerString: complete fitler string, nil means no filter
--                 ...: variable numbers of arguments, means the MBUS parameters you want
-- return value    result table, include the path and the parameters you want, 

function getList_IGD(dataPath,filterString,...)
  local result={}
  local data
  local error
  local parameter={...}

  --get info from MBUS
  if dataPath~=nil then
      if filterString~=nil then
        data, error = mbus.getParameters{path = dataPath, param = parameter, filter=filterString, datamodel="second"}
      else      
        data, error = mbus.getParameters{path = dataPath, param = parameter, datamodel="second"}  
      end 
  end 

  -- fill info into result
  if #data[dataPath]>0 then
    local n=1    
    for i=1, #data[dataPath] do
      local valid = 1
      result[n] = {}
      result[n].path = data[dataPath][i].path

      for j=1, #parameter do 
        result[n][parameter[j]]=data[dataPath][i].param[parameter[j]]        
        if (result[n][parameter[j]]==nil) then
          result[n] = nil
          valid = 0
          break
        end
      end
 
      if (valid==1) then
        n = n+1
      end
    end 
  end 

  return result
end

--get virtual eth intf 
function getVirtualEthIntf()     
    local ethPath=""
    local eth, error = mbus.getParameters{path="ETH.Phys", param="Technology", filter="(== Technology VIRTUAL)"}
    if (eth["ETH.Phys"][1]~=nil) and (eth["ETH.Phys"][1].path~=nil) then
        ethPath = eth["ETH.Phys"][1].path
    end
    return ethPath
end

--get eth packet & error Info
function getLanStat(name)     
    local result={}
    local ethPath = ""
    local eth, error = mbus.getParameters{path="ETH.Phys", param="Status", filter="(== Name " .. name .. ")"}
    if (eth["ETH.Phys"][1]~=nil) and (eth["ETH.Phys"][1].path~=nil) then        	
        ethPath = eth["ETH.Phys"][1].path
        result.interface = ethPath
        if eth["ETH.Phys"][1].param["Status"] == "Connected" then
            result.state = "Active"
        else
            result.state = "Inactive"
        end

        local eth, error = mbus.getParameters{path=ethPath..".Stats", param={"PacketsReceived","PacketsSent"}}
        result.packetsReceived = eth[ethPath..".Stats"][1].param["PacketsReceived"]
        result.packetsSent = eth[ethPath..".Stats"][1].param["PacketsSent"]	
    end
    return result
end

function getLanStatFromDev(n)     
    local result={}
    local ethPath = "Device.Ethernet.Interface."..n
    local eth, error = mbus.getParameters{path = ethPath, param = {"Enable", "Status"}, datamodel = "second"}
    if (eth[ethPath][1]~=nil) and (eth[ethPath][1].path~=nil) then
        result.interface = ethPath
        result.enable = eth[ethPath][1].param["Enable"]
        if eth[ethPath][1].param["Status"] == "Up" then
            result.state = translate([==[Active]==])
        else
            result.state = translate([==[Inactive]==])
        end

        local statsPath = ethPath..".Stats"
        local eth, error = mbus.getParameters{path = statsPath, datamodel = "second"}
        result.packetsReceived = eth[statsPath][1].param["PacketsReceived"]
        result.packetsSent = eth[statsPath][1].param["PacketsSent"]
        result.errorsReceived = eth[statsPath][1].param["ErrorsReceived"]
        result.errorsSent = eth[statsPath][1].param["ErrorsSent"]
    end
    return result
end

--get voice statitics info
function getVoiceStat(n)    
    local result={}
    local voicePath = "Device.Services.VoiceService.1.PhyInterface."..n..".X_TELECOMITALIA_IT_Stats"
    local voice, error = mbus.getParameters{path = voicePath, param = {"IncomingCallsAnswered", "IncomingCallsFailed", "OutgoingCallsAnswered", "OutgoingCallsFailed"}, datamodel = "second"}
    if (voice[voicePath][1]~=nil) and (voice[voicePath][1].path~=nil) then
        result.inAns = voice[voicePath][1].param["IncomingCallsAnswered"]
        result.inFail = voice[voicePath][1].param["IncomingCallsFailed"]
        result.outAns = voice[voicePath][1].param["OutgoingCallsAnswered"]
        result.outFail = voice[voicePath][1].param["OutgoingCallsFailed"]
    end 
    return result
end
--Reset Path = TI_STORE.TiUserIntf ,  Param = ResetLANStats, ResetWANStats
--		Path = WLAN.Intf.1.Stats ,    Param = Reset
--		Path = Device.Services.VoiceService.1.PhyInterface.i.X_TELECOMITALIA_IT_Stats ,(i=1,2,3)    Param = ResetStatistics
function ResetTrafficStat()     
    
	local reply, error = mbus.modify(
			function()
			local reply1, error1 = mbus.setParameters{path="TI_STORE.TiUserIntf", param={ResetLANStats="1", ResetWANStats="1"}}
			end)

	local reply, error = mbus.modify(
			function()
			local reply1, error1 = mbus.setParameters{{path="WLAN.Intf.wlif1.Stats", param={Reset="true"},flags="KEYPATH"},
                                                      {path="WLAN.Intf.wl_ssid1_local0.Stats", param={Reset="true"},flags="KEYPATH"},
													  {path="WLAN.Intf.wle_radio1_ssid0.Stats", param={Reset="true"},flags="KEYPATH"},
													  {path="WLAN.Intf.wle_radio1_ssid1.Stats", param={Reset="true"},flags="KEYPATH"}
                                                     }
			end)

	local reply, error = mbus.modify(
		function()
			mbus.setParameters{ path = "PPP.RelayStats", param = {ResetRelayStats = "true"} }
			mbus.setParameters{ path = "TI_STORE.TIBridging", param = {IPTVBridgeStatsReset = "true"} }
		end)

	local reply, error = mbus.modify(
		function()
            for i=1,3 do
    			mbus.setParameters{ path = "Device.Services.VoiceService.1.PhyInterface."..tostring(i)..".X_TELECOMITALIA_IT_Stats", param = {ResetStatistics= "true"}, datamodel = "second" }
            end
		end, {datamodel="second"})

		mbus.modify(
		function()
			mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {writeLog = "Reset stats"}}
		end)
end

--Reset Path = DSL, Param = ResetStats
function ResetADSLStat()     
    
	local reply, error = mbus.modify(
			function()
			local reply1, error1 = mbus.setParameters{path="TI_STORE.DSLSTATS", param={Reset="1"}}
			end)
end

--save configuration
function saveall(seconds, nosync)
local delay = "60"
if seconds~=nil and type(seconds)=="number" and seconds>=0 then
  delay = tostring(seconds)
end
local reply, error = mbus.modify(
       function()
         if nosync==1 then
           local reply, error = mbus.setParameters{path="DeviceConfig", param={ConfigSaveDelay=delay, ConfigSaveNoSync="1"}}
         else
           local reply, error = mbus.setParameters{path="DeviceConfig", param={ConfigSaveDelay=delay, ConfigSave="1"}}
         end
       end)
end
%>

