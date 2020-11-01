<%
errMsgNoApp = "<p>" .. translate([==[Warning: Select an application or protocol from the list for the default port mapping rule that intends to create.]==]).. "</p>"
errMsgIP = "<p>" .. translate([==[Warning: The IP address is not in a valid format.]==]).. "</p>"
errMsgNAT = "<p>" .. translate([==[Warning: The IP address is not included in the range of NAT.]==]).. "</p>"
errMsgName = "<p>" .. translate([==[Warning: Enter a valid name for the rule you intends to create. Check if it is already in use or does not contain special characters or symbols which are not allowed.]==]).. "</p>"
errMsgPort = "<p>" .. translate([==[Warning: check the value entered in the port. Valid values are: 1-65535.]==]).. "</p>"
errMsgRange = "<p>" .. translate([==[Warning: the port range overlaps with an already defined range within the same application.]==]).. "</p>"
errMsgOverlap = "<p>" .. translate([==[Warning: Verify that the IP address and / or internal port configured not been previously assigned to another port mapping rule.]==]).. "</p>"

local tprint=require("tableprint")

--get Internal and External range for Port from NATAppList.App rules
function getInternalAndExternal(list)
	local protocol = ""
	local tcpRangeEx = ""
	local udpRangeEx = ""
	local tcpRangeIn = ""
	local udpRangeIn = ""
	local internal = ""
	local external = ""

	for j,w in pairs(list) do
  local rangeInternal = w["InboundPort"] 		
		local rangeExternal = w["OutboundPort"]
		local internalEnd = tonumber(w["OutboundPortRangeEnd"]) - tonumber(w["OutboundPort"]) + tonumber(w["InboundPort"])
		
		if internalEnd > tonumber(w["InboundPort"]) then 
			rangeInternal = w["InboundPort"] .. "-" .. tostring(internalEnd)
		end		

		if rangeInternal == "0" then 
			rangeInternal = "*"
		end

		if w["OutboundPort"] ~= w["OutboundPortRangeEnd"] then
			rangeExternal = w["OutboundPort"] .. "-" .. w["OutboundPortRangeEnd"]
		end	

		if rangeExternal == "0" then 
			rangeExternal = "*"
		end

		if w["Protocol"] == "TCP" then
			if tcpRangeEx == "" then
				tcpRangeEx = "TCP:" .. rangeExternal
    tcpRangeIn = "TCP:" .. rangeInternal
			else
				tcpRangeEx = tcpRangeEx .. "," .. rangeExternal
    tcpRangeIn = tcpRangeIn .. "," .. rangeInternal
			end						
		else
			if udpRangeEx == "" then
				udpRangeEx = "UDP:" .. rangeExternal
    udpRangeIn = "UDP:" .. rangeInternal
			else
				udpRangeEx = udpRangeEx .. "," .. rangeExternal
    udpRangeIn = udpRangeIn .. "," .. rangeInternal
			end			
		end
  
		if protocol == "" then
			protocol = w["Protocol"]
		else
			if protocol~=w["Protocol"] then
				protocol = "ALL"
			end
		end
	end
 
 internal = tcpRangeIn
 if internal=="" then
  internal = udpRangeIn
 elseif udpRangeIn~="" then
  internal = internal .. ";" .. udpRangeIn
 end
 
 external = tcpRangeEx
 if external=="" then
  external = udpRangeEx
 elseif udpRangeEx~="" then
  external = external .. ";" .. udpRangeEx
 end
 
	return internal, external, protocol
end

--Create the Virtual Server for IGD
function virtualServerCreate_IGD(name, ip, protocol, internalPort, externalPort, status, manualDisabled, intfDisabled)

	local virtualPath = "Device.NAT.PortMapping"
	local result=0
	if status == nil then
		status = "true"
	end
	if manualDisabled ==nil then
		manualDisabled = "false"
	end
	if intfDisabled ==nil then
		intfDisabled = "false"
	end
	local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.addObjects{ path = virtualPath, param = { Description = name, InternalClient=ip, InternalPort=internalPort, ExternalPort=externalPort, Protocol=protocol, Enable=status, Interface="Device.IP.Interface.2", X_000E50_GUIDisabled=manualDisabled, X_000E50_InterfaceDisabled=intfDisabled}, datamodel="second"}
			if error1~=nil or reply1[virtualPath][1]==nil then
			--the error1 is always not-nil
			--if reply1[virtualPath][1]==nil then
				result=1
			end
			--if error==nil then
			
			--else 
			
			--end 
			--if reply1[virtualPath][1]==nil then
			
			--else
			
			
			--end 
		end, {datamodel="second"})	
	
	if error~=nil then
		result = 1
		
	else
		
	end
	return result
end

--Delete the Virtual Server for IGD path
function virtualServerDelete_IGD(virtualPath)
	local isError = true
	local reply, error = mbus.modify(
	function()
		local reply1, error1 = mbus.deleteObjects{ path = virtualPath, datamodel="second"}
	end,
	{datamodel="second"})
	
	if error == nil then
		isError = false
	end
	return isError
end

--To check it is existed in the edit list.
function isInEditList(name, editList)
	for i,v in pairs(editList) do	
		if tostring(v["Name"])==name then
			return true
		end
	end
	return false
end

--To check it is existed in the port mapping list.
function isInPortMappingList(appName, portMappingList)
	for i,v in pairs(portMappingList) do	
		if tostring(v["Description"])==appName then
			return true
		end
	end
	return false
end

--split the application list for port mapping
function getListForPortMapping(list, pathLength, portMappingList)
	local gameSelectList,gameEditList,protocolSelectList,protocolEditList,appGameList,appProtocolList,virtualList={},{},{},{},{},{},{}
	
	for i,v in pairs(list) do	
		if isInPortMappingList(tostring(v["Name"]), portMappingList)==false then	
			v.path = string.sub(v.path, pathLength + 1)
			table.insert(gameSelectList, v)
		else					
				--game edit list
				table.insert(appGameList, v)
   -- add to game select list, TI require even assigned game must appear in list
			 v.path = string.sub(v.path, pathLength + 1)
				table.insert(gameSelectList, v)
		end
	end
	
	for i,v in pairs(portMappingList) do
		if isInEditList(v["Description"], appGameList) then
			table.insert(gameEditList, v)
		else
			table.insert(virtualList, v)
		end	
	end	
	return gameSelectList, gameEditList, protocolSelectList, protocolEditList, virtualList
end

--Format the port type and port range for game edit list
function formatPortTypeAndRange(protocol, portRange)
	if protocol == "ALL" then
		protocol = "TCP<br/>UDP"
		portRange = string.gsub(portRange, "(%w+):(.+);(%w+):(.+)", function(tcp,tcpRange,udp,udpRange) 
						return tcpRange .. "<br/>" .. udpRange end)
	else
		portRange = string.gsub(portRange, "(%w+):(.+)", function(protocol,range) 
						return range end)
	end

	return protocol, portRange
end

--Get the detail info from the list
function getDetailInfoByPath(pathStr, list)
	local nameInfo, ipInfo, protocalInfo, internalRange, externalRange, enable, guiDisabled
	for i,v in pairs(list) do
		if pathStr == v.path then
			nameInfo = v["Description"]
			ipInfo = v["InternalClient"]
			protocalInfo = v["Protocol"]
			internalRange = v["InternalPort"]
			externalRange = v["ExternalPort"]
			enable = v["Enable"]
			guiDisabled = v["X_000E50_GUIDisabled"]
		end
	end
	if externalRange == "0" then
		externalRange = "*"
	end
	return nameInfo, ipInfo, protocalInfo, internalRange, externalRange, enable, guiDisabled
end

function getLANOption()
 local reply, error = mbus.getParameters{ path = "TI_STORE.TiUserIntf", param="LANOption" }
 return reply["TI_STORE.TiUserIntf"][1].param["LANOption"] or "" 
end

--Get the Destination IP list from host which should in the range of nat.
function getHostIpList(NATStart, NATEnd)
	local hostIpList , error = getList("Hosts.Host", "(or (== Active 1) (== EnableDHCPStaticAddress 1))", "IPAddress", "NewIPAddress")
	local deviceList = {}
	for i,v in pairs(hostIpList) do
		local ip = v["IPAddress"]
		local new = v["NewIPAddress"]
		if ip ~= "0.0.0.0" then
			table.insert(deviceList, {IPAddress=ip})
		end
		if ip ~= new then
			table.insert(deviceList, {IPAddress=new})
		end
	end
	return deviceList
end

%>

