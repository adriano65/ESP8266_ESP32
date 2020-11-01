<%
cgilua.lp.include("lp/language.lp")
local translate = translate

--Translated the type of dsl
function translateDSLMode(dslType)
	local dslModulationType = dslType
	if dslType == "ADSL_G.dmt" then
		dslModulationType = "G.DMT"
	elseif dslType == "ADSL_G.dmt.bis" then
		dslModulationType = "ADSL2"
	elseif dslType == "ADSL_2plus" then
		dslModulationType = "ADSL2+"
	end
	return dslModulationType
end

--Translated the state of dsl
function translateDSLState(state)
	local dslState = translate([==[Inactived ]==])
	local dslStateColor = "tdRed"
	if state == "Up" then
		dslState = translate([==[Actived]==])
		dslStateColor = "tdGreen"
	elseif state == "Initializing" or state == "EstablishingLink" then
		dslState = translate([==[Activation in progress]==])
		dslStateColor = "tdOrange"
	end
	return dslState, dslStateColor
end

--Translated the state of dsl link for servizi
function translateDSLState_Servizi(state)
	local dslState = translate([==[Not synchronized]==])
	local dslStateColor = "tdRed"
	if state == "Up" then
		dslState = translate([==[Actived]==])
		dslStateColor = "tdGreen"
	elseif state == "Initializing" or state == "EstablishingLink" then
		dslState = translate([==[In synchronization]==])
		dslStateColor = "tdOrange"
	end
	return dslState, dslStateColor
end

--Get the status of PPP Management 
function getPPPManagementState()
	local connectionStatus = "Unconfigured"
	local reply, error = mbus.getParameters{path="Device.PPP.Interface", param="ConnectionStatus", filter="(== Name 'Telecom Italia')", datamodel = "second"}       

	if reply["Device.PPP.Interface"][1]~=nil then
		connectionStatus = reply["Device.PPP.Interface"][1].param["ConnectionStatus"]               		
	end
	return connectionStatus
end

--Translated the state of management PPP
function translateManagementPPPState(pppState, ipaddr, connectionTrigger, dslState)
	local pppStatus = translate([==[Anomaly]==])
	local pppStatusColor = "tdRed"

	if pppState == "Connected" and getCWMPState() == "Connected" then
   		pppStatus = translate([==[Current configuration]==])
		pppStatusColor = "tdOrange"
	elseif pppState == "Connected" then
		pppStatus = translate([==[Active]==])
		pppStatusColor = "tdGreen"
	elseif ipaddr == "0.0.0.0" or dslState ~= "Up" then
		if connectionTrigger == "AlwaysOn" then
			pppStatus = translate([==[Inactived]==])
			pppStatusColor = "tdRed"
		elseif connectionTrigger ~= "AlwaysOn" then
			pppStatus = translate([==[Not active]==])
			pppStatusColor = "tdGreen"
		end
	elseif pppState == "Connecting" then 
		pppStatus = translate([==[In activation]==])
		pppStatusColor = "tdOrange"
	end
	return pppStatus, pppStatusColor
end

--Translated the state of data PPP 
function translateDataPPPState(pppState, connectionTrigger, pppStatus, pppStatusColor, connectType)

	if pppState == "Connected" then
		pppStatus = translate([==[Active]==])
		pppStatusColor = "tdGreen"
	end

	if connectionTrigger == "Manual" then 
		connectType = "Manuale"
	end
	
	return pppStatus, pppStatusColor, connectType
end

--Get the type of WAN Connection:ADSL Connection/VDSL Connection/Fiber Connection
function getWANConnectionType()	
	local wanConnTitle, wanConnType, wanConnType1, wanConnType_temp
        wanConnType = "ADSL"
        local reply2, error2 = mbus.getParameters{ path = "DSL", param = "Status_Value"}
        local DSLConnected =  reply2["DSL"][1].param["Status_Value"]
	if DSLConnected == "Up" then
		local reply, error = mbus.getParameters{ path = "DSL", param = "ModulationType_Value"}
	     	wanConnType_temp = reply["DSL"][1].param["ModulationType_Value"]
		wanConnType = string.sub(wanConnType_temp,1,4)
        else 
        	local reply1, error1 = mbus.getParameters{ path = "ETH.Phys.ethif5", param = "Status", flags = "KEYPATH"}
        	wanConnType1 = reply1["ETH.Phys.ethif5"][1].param["Status"]
		if wanConnType1 == "Connected" then
			wanConnType = "ETH"
		end
	end
	if wanConnType == "ETH" then	
		wanConnTitle = translate([==[Fiber Ethernet Link]==])
	elseif wanConnType == "VDSL" then 
		wanConnTitle = translate([==[VDSL Link]==])
	else
		wanConnTitle = translate([==[ADSL Link]==])
	end
	
	return wanConnType, wanConnTitle
end

--Enable of disable the data PPP
function setDataPPP(pathStr, status, flag)
	local modify ={}
	table.insert(modify, {path="NAT.Intf.ppp_0", param= {Status=status}, flags = "KEYPATH"})
	table.insert(modify, {path=pathStr, param= {TI_Enable=flag}})                 
	table.insert(modify, {path=pathStr, param= {Enable=flag}})                 
	setMBUS(modify)
end


--Check whether the ppp is active or not
function isDataPPPNotConnected()
	local data, error = mbus.getParameters{path = "PPP.Intf.2", param = {"Status"}}
	local ppp_status =  data["PPP.Intf.2"][1].param["Status"]
	if ppp_status ~= "Connected" then
		return true
	end
	return false
end

%>
