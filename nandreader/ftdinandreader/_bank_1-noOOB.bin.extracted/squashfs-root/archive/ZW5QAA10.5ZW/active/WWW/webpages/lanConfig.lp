<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<style>
.iebuttonLeft{
padding-left:0px
}
.buttonLeft{
padding-left:200px
}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<script src="js/lan.js" type="text/javascript"></script>
<script src="js/portmap.js" type="text/javascript"></script>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/lan.lp") %>
<%
local translate = translate
local POST=cgilua.POST

-- get handler
local ppp_management = getPPP("PPP.Intf.1")
local ppp = getPPP("PPP.Intf.2")
local TI_info = getTIInfo()
local ipInfo = getIPInfo()
local TI_Device = getTIInfo_Device()
local device_PPP = getDevice_PPP()

local ipAddr = ipInfo.ipaddress
local ipMask = ipInfo.ipmask
local dhcpState = ipInfo.enable
local dhcpIpBegin = ipInfo.beginip
local dhcpIpEnd = ipInfo.endip
local natState , natIntfPath, natIpBegin, natIpEnd

if ppp~=nil then
	natState , natIntfPath = getNatStatus(ppp.ipintf)
	natIpBegin = ppp.natStartIPAddress
	natIpEnd = ppp.natEndIPAddress
end

function getTIServiceType()
	local replyType, error = mbus.getParameters{ path = "Device.Services", param="X_TELECOMITALIA_IT_VoIPServiceType" , datamodel = "second" } 	
	local serviceType = replyType["Device.Services"][1].param["X_TELECOMITALIA_IT_VoIPServiceType"]	
	return serviceType
end

local devices = reassignlist()

if cgilua.servervariable"REQUEST_METHOD" == "POST" then


function pcall_MainLanMethod()
	--dhcp setting start
	if dhcpState ~= POST["dhcpState"] then
		setDhcpPoolState(POST["dhcpState"])
	end
	
	--Change DHCP netmask/gateway/poolrange setting:
	--1. Get the Linux MAC to store all DHCP manual lease, delete all lease and disable dhcp pool.
	--2. Change pool range/gateway/netmask.
	--3. Enable dhcp pool, add linux lease back and update samba port mapping.
	if dhcpIpBegin ~= POST["dhcpIpBegin"] or dhcpIpEnd ~= POST["dhcpIpEnd"] then
		local LMAC = getLinuxMac()
		local DHCP_manual = getDhcpLease_T(LMAC)
		dhcpLeaseDelete()
		setDhcpPoolState("false")

		--change pool range/gateway/netmask 
		local modify = {}
		if dhcpIpBegin ~= POST["dhcpIpBegin"] then
			table.insert(modify, {path=ipInfo.poolpath, param= {MinAddress=POST["dhcpIpBegin"]}})
		end
		if dhcpIpEnd ~= POST["dhcpIpEnd"] then
			table.insert(modify, {path=ipInfo.poolpath, param= {MaxAddress=POST["dhcpIpEnd"]}})
		end
		if ipAddr ~= POST["ipAddr"] then
 			table.insert(modify, {path=ipInfo.poolpath, param= {Gateway=POST["ipAddr"]}})

		-- CPE_P00103537 - Changing the LAN IP results in fail of REGISTER of intua to sipserver
		--[[
		if getTIServiceType() == "SIP_GW" then

			local voicePath = "Voice.SIP" 
			local reply_37, error_37 = mbus.getParameters{ path = voicePath, param = {"UserAgentDomain","PrimProxyServer","SecProxyServer","PrimRegServer","SecRegServer","Realm"} }
			local usrAgent = POST["ipAddr"]
			local  primProxy = POST["ipAddr"]
			local  secProxy = POST["ipAddr"]
			local  primReg = POST["ipAddr"]
			local  secReg = POST["ipAddr"]
			local  realm = POST["ipAddr"]
			
			if(reply_37[voicePath][1].param["UserAgentDomain"] ~= "") then		
				local spArray = split(reply_37[voicePath][1].param["UserAgentDomain"],"[.]")
				if (#spArray == 4) then					
					if(tonumber(spArray[1]) ~= nil) then						
						table.insert(modify, {path="Voice.SIP", param= { UserAgentDomain=POST["ipAddr"] }})
					end
				end
			else 
				table.insert(modify, {path="Voice.SIP", param= { UserAgentDomain=POST["ipAddr"] }})
			end

			if(reply_37[voicePath][1].param["PrimProxyServer"] ~= "") then		
				local spArray = split(reply_37[voicePath][1].param["PrimProxyServer"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then	
						table.insert(modify, {path="Voice.SIP", param= { PrimProxyServer=POST["ipAddr"] }})
					end
				end
			else
				table.insert(modify, {path="Voice.SIP", param= { PrimProxyServer=POST["ipAddr"] }})
			end


			if(reply_37[voicePath][1].param["SecProxyServer"] ~= "") then		
				local spArray = split(reply_37[voicePath][1].param["SecProxyServer"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then	
						table.insert(modify, {path="Voice.SIP", param= { SecProxyServer=POST["ipAddr"] }})
					end
				end
			else
				table.insert(modify, {path="Voice.SIP", param= { SecProxyServer=POST["ipAddr"] }})
			end

			if(reply_37[voicePath][1].param["PrimRegServer"] ~= "") then		
				local spArray = split(reply_37[voicePath][1].param["PrimRegServer"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then	
						table.insert(modify, {path="Voice.SIP", param= { PrimRegServer=POST["ipAddr"] }})
					end
				end
			else
				table.insert(modify, {path="Voice.SIP", param= { PrimRegServer=POST["ipAddr"] }})	
			end

			if(reply_37[voicePath][1].param["SecRegServer"] ~= "") then		
				local spArray = split(reply_37[voicePath][1].param["SecRegServer"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then	
						table.insert(modify, {path="Voice.SIP", param= { SecRegServer=POST["ipAddr"] }})
					end
				end
			else
				table.insert(modify, {path="Voice.SIP", param= { SecRegServer=POST["ipAddr"] }})
			end

			if(reply_37[voicePath][1].param["Realm"] ~= "") then		
				local spArray = split(reply_37[voicePath][1].param["Realm"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then
						table.insert(modify, {path="Voice.SIP", param= { Realm=POST["ipAddr"] }})
					end
				end
			else
				table.insert(modify, {path="Voice.SIP", param= { Realm=POST["ipAddr"] }})
			end
			
		local modify_dev = {}		
		for i=1,10 do
			local voicePath3 = "Device.Services.VoiceService.3.VoiceProfile."..i..".SIP" 
			local reply_38, error_38 = mbus.getParameters{ path = voicePath3, param = {"UserAgentDomain","OutboundProxy","X_TELECOMITALIA_IT_AuthRealm"} , datamodel = "second" }
			
			if(reply_38[voicePath3][1].param["UserAgentDomain"] ~= "") then		
				local spArray = split(reply_38[voicePath3][1].param["UserAgentDomain"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then
						table.insert(modify_dev, {path=voicePath3, param= { UserAgentDomain=POST["ipAddr"] }, datamodel = "second"})
					end
				end
			else
				table.insert(modify_dev, {path=voicePath3, param= { UserAgentDomain=POST["ipAddr"] }, datamodel = "second"})
			end

			if(reply_38[voicePath3][1].param["OutboundProxy"] ~= "") then		
				local spArray = split(reply_38[voicePath3][1].param["OutboundProxy"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then
						table.insert(modify_dev, {path=voicePath3, param= { OutboundProxy=POST["ipAddr"] }, datamodel = "second"})
					end
				end
			else
				table.insert(modify_dev, {path=voicePath3, param= { OutboundProxy=POST["ipAddr"] }, datamodel = "second"})
			end

			if(reply_38[voicePath3][1].param["X_TELECOMITALIA_IT_AuthRealm"] ~= "") then		
				local spArray = split(reply_38[voicePath3][1].param["X_TELECOMITALIA_IT_AuthRealm"],"[.]")
				if (#spArray == 4) then
					if(tonumber(spArray[1]) ~= nil) then
						table.insert(modify_dev, {path=voicePath3, param= { X_TELECOMITALIA_IT_AuthRealm=POST["ipAddr"] }, datamodel = "second"})
					end
				end
			else
				table.insert(modify_dev, {path=voicePath3, param= { X_TELECOMITALIA_IT_AuthRealm=POST["ipAddr"] }, datamodel = "second"})
			end	
		end

		setMBUS_IGD(modify_dev)	
			
		end
		]]
		
		end
		if ipMask ~= "255.255.255." .. POST["maskEnd"] then
			table.insert(modify, {path=ipInfo.poolpath, param= {SubnetMask="255.255.255." .. POST["maskEnd"]}})
		end
		setMBUS(modify)

		setDhcpPoolState("true")		
		dhcpLeaseCreate(POST["dhcpIpEnd"], LMAC, POST["ipAddr"], ipInfo.poolpath)

		--  add back DHCP manual lease if it is in range of DHCP 
		for i, v in pairs(DHCP_manual) do 
			if inRange(v.ip, POST["dhcpIpBegin"], POST["dhcpIpEnd"]) and v.ip~=POST["dhcpIpEnd"] and v.ip~=POST["ipAddr"] then
				dhcpLeaseCreate(v.ip, v.mac, POST["ipAddr"], ipInfo.poolpath)
			end
		end 
			
		 sambaPortMappingUpdate(POST["ipAddr"], POST["dhcpIpEnd"])	
			
	end	--dhcp setting end

	--Nat setting start
	if (device_PPP.enable == "true") and (TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6") then
		--If change the nat state from enable to disable,
		--it would disable port mapping first and then disable nat state.

		if POST["natState"]=="disabled" then
			setPortMappingStateForNat(natIntfPath, POST["natState"], POST["natIpBegin"], POST["natIpEnd"])
		end
		if natState ~= POST["natState"] then
			setNatState(natIntfPath, POST["natState"])
            mbus.modify(
                function()
                    mbus.setParameters{path = "ENV.NAT_CHANGED_BY_ACS", param = {Value = "0"},flags = "KEYPATH"}
            end)
		end
		
		--Change the nat range if it is different with older one.
		local modify = {}
		if ip2long(natIpBegin) > ip2long(POST["natIpBegin"])then
			table.insert(modify, {path=ppp.ppp_path, param= {NATStartIPAddress=POST["natIpBegin"]}})
		end
		if ip2long(natIpEnd) < ip2long(POST["natIpEnd"]) then
			table.insert(modify, {path=ppp.ppp_path, param= {NATEndIPAddress=POST["natIpEnd"]}})
		end
		setMBUS(modify)	

		--If change the nat state from disable to enable,
		--it would enable nat first and then enable port mapping.
		if POST["natState"]=="enabled" then
			setPortMappingStateForNat(natIntfPath, POST["natState"], POST["natIpBegin"], POST["natIpEnd"])
		end

		--Change the nat range if it is different with older one.
		local modify = {}
		if ip2long(natIpBegin) < ip2long(POST["natIpBegin"])then
			table.insert(modify, {path=ppp.ppp_path, param= {NATStartIPAddress=POST["natIpBegin"]}})
            mbus.modify(
                function()
                    mbus.setParameters{path = "ENV.NAT_CHANGED_BY_ACS", param = {Value = "0"},flags = "KEYPATH"}
            end)
		end
		if ip2long(natIpEnd) > ip2long(POST["natIpEnd"]) then
			table.insert(modify, {path=ppp.ppp_path, param= {NATEndIPAddress=POST["natIpEnd"]}})
            mbus.modify(
                function()
                    mbus.setParameters{path = "ENV.NAT_CHANGED_BY_ACS", param = {Value = "0"},flags = "KEYPATH"}
            end)
		end
		setMBUS(modify)	
	end	--nat setting end

	--assign ip
	for i=1,tonumber(POST["preNum"]) do

		local mac= POST["newmac"..i]
		local newip=POST["newip"..i] 
		local ismanual=POST["ismanual"..i]

		local hostPath=getHostPathByMac(mac)

		-- Pre-assign ip: must make sure newip is in dhcp pool range			
		if POST["ipReserve"..i]=="true" and newip~="" and inRange(newip, POST["dhcpIpBegin"], POST["dhcpIpEnd"])==true then			
			if hostPath ~="" then
				updateIpReserved(hostPath, newip, "1")				
			end
		-- manual lease to auto lease
		elseif  POST["ipReserve"..i]~="true" then
			if hostPath ~="" then
				updateIpReserved(hostPath, "0.0.0.0", "0")				
			end
		end
	end --for
	
	--Add new ip reserve for disconnected host
	if POST["reserveIpAddingFlag"]=="1" then
		if POST["reserveIpRadio"]=="true" then
			--the dhcp lease has been added by updateIpReserved function.
			--dhcpLeaseCreate(POST["reserveIp"], POST["reserveMac"], POST["ipAddr"], ipInfo.poolpath)

			addIpReserved(POST["reserveMac"], POST["reserveIp"])
		end
	end	
end

	if pcall(pcall_MainLanMethod) then			
		if ipAddr~= POST["ipAddr"] or ipMask ~= "255.255.255." .. POST["maskEnd"] then
			cgilua.redirect("restarting.lp",{ip=POST["ipAddr"], mask="255.255.255." .. POST["maskEnd"], path=ipInfo.ippath, natState=POST["natState"], natIntfPath=natIntfPath })
		elseif dhcpIpBegin ~= POST["dhcpIpBegin"] or dhcpIpEnd ~= POST["dhcpIpEnd"] then
			saveall(0, 1)
			cgilua.redirect("save_alert_dhcp.lp",{ u = "lanConfig.lp" , r="20"})
		else
			saveall(0, 1)
			cgilua.redirect("save_alert.lp", { u = "lanStatus.lp" })
		end
		return
	else
		saveall(0, 1)
		cgilua.redirect("save_alert.lp", { u = "lanStatus.lp" })
		return
	end
end

--The warning or error message for lan config.
local ipWarning_T={ipInvalid=translate([==[Warning: Verify that the IP address entered is invalid]==]), 
			ipForamtWrong=translate([==[Warning: The IP address of the modem is not in a valid format]==]), 
			ipZero=translate([==[Warning: The IP address of the modem can not be .0]==]), 
			ipBroadcast=translate([==[Warning: The IP address of the modem can not be the broadcast address]==]),
			ipRang=translate([==[Warning: Addressing entered includes public addresses used by the modem for access to network services. Configure another address.]==])}

local natWarning_T={natStartIpFormatWrong=translate([==[Warning: The address "NAT Start IP" is not in a valid format]==]),
			natEndIpFormatWrong=translate([==[Warning: The address "NAT End IP" is not in a valid format]==]), 
			natStartIpRangeWrong=translate([==[Warning: the address "initial IP NAT" does not belong to the modems subnet]==]), 
			natEndIpRangeWrong=translate([==[Warning: the address "final IP NAT" does not belong to the modems subnet]==]), 
			natIpRangeWrong=translate([==[Warning: The address "NAT End IP" address must be equal to or greater than "NAT Start IP"]==]), 
			natIpWrong=translate([==[Warning: The IP address of the modem can not be included in the range NAT]==])}

local dhcpWarning_T={dhcpStartIpFormatWrong=translate([==[Warning: The address "DHCP Start IP" is not in a valid format]==]), 
			dhcpEndIpFormatWrong=translate([==[Warning: The address "DHCP End IP" is not in a valid format]==]), 
			dhcpStartIpRangeWrong=translate([==[Warning: the address "initial IP DHCP" does not belong to the modems subnet]==]), 
			dhcpEndIpRangeWrong=translate([==[Warning: The address "DHCP End IP" does not belong to the modems subnet]==]), 
			dhcpIpRangeWrong=translate([==[Warning: The address "DHCP End IP" must be equal to or greater than the address "DHCP Start IP"]==]), 
			dhcpIpWrong=translate([==[Warning: The IP address of the modem can not be included in the DHCP range]==])}

local ipReserveWarning_T={reserveIpInvalid=translate([==[Warning: Verify that the IP address entered is invalid]==]), 
			macAddressInavlid=translate([==[Invalid MAC Address: only use hexadecimal characters (0-9, a-f) and respect the length of 12 characters]==])}

%>
<script language="JavaScript" type="text/javascript">
function newip_valid_check(newIp, dhcpIpBegin4, dhcpIpEnd4, ipAddr, ipAddr1_3)
{
	var arrNewip = newIp.split(".");
	var newip_prefix = arrNewip[0]+"."+arrNewip[1]+"."+arrNewip[2];

	if(isValidIPAddress(newIp)!=true || ipAddr==newIp || newip_prefix != ipAddr1_3 || parseInt(arrNewip[3])<parseInt(dhcpIpBegin4) || parseInt(dhcpIpEnd4) < parseInt(arrNewip[3]))
	{
		return false;
	}
	return true;
}


//Check reserve ip
function ip_check_conflict(newIp, mac)
{
	// get the IP address that is used in LAN
	var hostIPList=new Array();
	var macList=new Array();
	<%
		local reply, error = mbus.getParameters{path = "Hosts.Host", param ={"MACAddress", "IPAddress", "NewIPAddress"}, filter = "(or (== Active 1) (== EnableDHCPStaticAddress 1))"}
		local i = 0
		for m, v in pairs(reply["Hosts.Host"]) do
			local host_mac = v.param["MACAddress"]
			local ip = v.param["IPAddress"]
			local new_ip = v.param["NewIPAddress"]
			cgilua.put("hostIPList["..i.."]='"..tostring(ip).."';\n")
			cgilua.put("macList["..i.."]='"..tostring(host_mac).."';\n")
			i = i + 1
			if ip ~= new_ip then
				cgilua.put("hostIPList["..i.."]='"..tostring(new_ip).."';\n")
				cgilua.put("macList["..i.."]='"..tostring(host_mac).."';\n")
				i = i + 1
			end
		end
	%>


	for (var j = 0; j < hostIPList.length; j++)
	{
		if(hostIPList[j] == newIp && mac != macList[j])
		{
			return false;
		}
	}
	return true;
}

//check if IP LAN configuration is changed or not
function checkLanChange(ipAddr)
{
	var oldIp = "<%=ipAddr%>";
	var oldMask = "<%=ipMask%>";
	var oldArrMask = oldMask.split(".");
	var isLANChange=((ipAddr!=oldIp) || (document.getElementById("maskEnd").value!=oldArrMask[3]));
	return isLANChange;
}

//Query whether the ip addr could be updated by ajax
function checkIpMod(ipAddr)
{
	var urlStr = "/ipModCheckByAjax.lp";
	var params="ipAddr="+ipAddr;
	ajax_get(urlStr, params, ipMod_cb);
	
}

//If ip could not be updated, it should show error msg.
function ipMod_cb(ajax_obj)
{	
	var isIpUpdateFlag = ajax_obj.responseText.replace(/\s/g,"");
	if(isIpUpdateFlag=="false")
	{		
		document.getElementById("confirmConfig").style.display="none";
		showErrorMsg('<%=ipWarning_T["ipInvalid"]%>');
		return false; 
	}
}

//checking Gateway IP address
function checkGatewayIp(ipAddr,mask4)
{
  var ipCheck=isValidIPAddress_mask(ipAddr,mask4);
	if(ipCheck=="formatWrong" || ipCheck=="outOfRange")
	{
		showErrorMsg('<%=ipWarning_T["ipForamtWrong"]%>');
		return false;
	}else if(ipCheck=="localAddr"){
		showErrorMsg('<%=ipWarning_T["ipZero"]%>');
		return false;
	}else if(ipCheck=="broadcastAddr"){
		showErrorMsg('<%=ipWarning_T["ipBroadcast"]%>');
		return false;
	}	

	if(ipAddr == "192.168.100.1")
        {
		showErrorMsg('<%=ipWarning_T["ipInvalid"]%>');
		return false; 
        }

	//Fix for Tessa 253	
	var tempAddr = ipAddr.substring(0,ipAddr.lastIndexOf("."));
	
	<%
	local ipv4FwdPath = "Device.Routing.Router.1.IPv4Forwarding"
	local reply, error = mbus.getParameters{path = "Device.Routing.Router.1.IPv4Forwarding", param = {"Alias","DestIPAddress"},datamodel="second"} 
	local destIP=""
	local aliasName=""
	for i, v in pairs(reply["Device.Routing.Router.1.IPv4Forwarding"]) do		
		if(v.param["Alias"] ~=nil and v.param["Alias"] ~="") then
			aliasName = tostring(v.param["Alias"]);
			if(aliasName =="ACS Route" or (string.len(aliasName) > 8 and  string.sub(aliasName, 1, 9) == "NTP Route")) then
				destIP = v.param["DestIPAddress"]
	%>
				var dIP = "<%=destIP%>";
				dIP = dIP.substring(0,dIP.lastIndexOf("."));				
				if(tempAddr == dIP){
					document.getElementById("lanConfig").style.display="none";
					document.getElementById("resultKO").style.display="block";
					return false;
				}
	<%
			end
		end
	end
	local reply, error = mbus.getParameters{path = "Device.DNS.Client.Server", param = {"Alias","DNSServer"},datamodel="second"} 
	local dnsIP=""
	local dnsAlias=""
	for i, v in pairs(reply["Device.DNS.Client.Server"]) do		
		if(v.param["Alias"] ~=nil and v.param["Alias"] ~="") then
			dnsAlias = tostring(v.param["Alias"])
			if((string.len(dnsAlias) > 16 and string.sub(dnsAlias, 1, 17) == "DNS Interbusiness") or (string.len(dnsAlias) > 7 and string.sub(dnsAlias, 1, 8) == "IPCP DNS")) then
				dnsIP = v.param["DNSServer"]
	%>
				var dnsIP = "<%=dnsIP%>";
				dnsIP = dnsIP.substring(0,dnsIP.lastIndexOf("."));				
				if(tempAddr == dnsIP){
					document.getElementById("lanConfig").style.display="none";
					document.getElementById("resultKO").style.display="block";
					return false;
				}
	<%
			end
		end
	end
	%>
	
	//check ip whether it could be updated
	checkIpMod(ipAddr);
	
	return true;
}

//checking NAT range IP address
function checkNatRange(startip, endip, ipAddr1, ipAddr2, ipAddr3, ipAddr4)
{
	if(("<%=device_PPP.enable%>" == "true") && ("<%=TI_Device.lanOption%>" == "biz-rt-napt-ena" || "<%=TI_Device.lanOption%>" == "res-rt-napt" || "<%=TI_Device.lanOption%>" == "res-rt-napt-ipv6" || "<%=TI_Device.lanOption%>" == "biz-rt-napt-ipv6" ))	
	{
		var natIpBegin1 = document.getElementById("natIpBegin1").value;
		var natIpBegin2 = document.getElementById("natIpBegin2").value;
		var natIpBegin3 = document.getElementById("natIpBegin3").value;
		var natIpBegin4 = document.getElementById("natIpBegin4").value;
		var natIpBegin = natIpBegin1+"."+natIpBegin2+"."+natIpBegin3+"."+natIpBegin4;
		document.getElementById("natIpBegin").value = natIpBegin;
		
		var natIpEnd1 = document.getElementById("natIpEnd1").value;
		var natIpEnd2 = document.getElementById("natIpEnd2").value; 
		var natIpEnd3 = document.getElementById("natIpEnd3").value;
		var natIpEnd4 = document.getElementById("natIpEnd4").value;
		var natIpEnd = natIpEnd1+"."+natIpEnd2+"."+natIpEnd3+"."+natIpEnd4;
		document.getElementById("natIpEnd").value = natIpEnd;
		//Check if the NAT START IP is wrong format or out of range.
		var ipCheck=isValidIPAddress(natIpBegin);
		if(ipCheck=="formatWrong")
		{
			showErrorMsg('<%=natWarning_T["natStartIpFormatWrong"]%>');
			return false;
		}else if(ipCheck=="outOfRange"|| Number(natIpBegin4)<startip || natIpBegin1!=ipAddr1 || natIpBegin2!=ipAddr2 || natIpBegin3!=ipAddr3){
			showErrorMsg('<%=natWarning_T["natStartIpRangeWrong"]%>');
			return false;
		}
		//Check if the NAT END IP is wrong format or out of range.
		ipCheck=isValidIPAddress(natIpEnd);
		if(ipCheck=="formatWrong")
		{
			showErrorMsg('<%=natWarning_T["natEndIpFormatWrong"]%>');
			return false;
		}else if(ipCheck=="outOfRange" || Number(natIpEnd4)>endip || natIpEnd1!=ipAddr1 || natIpEnd2!=ipAddr2 || natIpEnd3!=ipAddr3){
			showErrorMsg('<%=natWarning_T["natEndIpRangeWrong"]%>');
			return false;
		}
		//Check if the nat ip range includes the modem ip.
		if(((ipAddr1==natIpBegin1&&ipAddr1==natIpEnd1&&ipAddr2==natIpBegin2&&ipAddr2==natIpEnd2
      &&ipAddr3==natIpBegin3&&ipAddr3==natIpEnd3)&&(ipAddr4*1>=natIpBegin4*1&&ipAddr4*1<=natIpEnd4*1)))
		{
			showErrorMsg('<%=natWarning_T["natIpWrong"]%>');
			return false;			
		}
		//Check if the NAT START IP is great than the NAT END IP.
		if(Number(natIpBegin4)>Number(natIpEnd4))
		{
			showErrorMsg('<%=natWarning_T["natIpRangeWrong"]%>');
			return false;
		}
	}
	return true;
}

//checking DHCP range IP address
function checkDhcpRange(startip, endip, ipAddr1, ipAddr2, ipAddr3, ipAddr4)
{
	var dhcpIpBegin1 = document.getElementById("dhcpIpBegin1").value; 
	var dhcpIpBegin2 = document.getElementById("dhcpIpBegin2").value;
	var dhcpIpBegin3 = document.getElementById("dhcpIpBegin3").value;
	var dhcpIpBegin4 = document.getElementById("dhcpIpBegin4").value;
	var dhcpIpBegin = dhcpIpBegin1+"."+dhcpIpBegin2+"."+dhcpIpBegin3+"."+dhcpIpBegin4;
	document.getElementById("dhcpIpBegin").value = dhcpIpBegin;		
	
	var dhcpIpEnd1 = document.getElementById("dhcpIpEnd1").value; 
	var dhcpIpEnd2 = document.getElementById("dhcpIpEnd2").value;
	var dhcpIpEnd3 = document.getElementById("dhcpIpEnd3").value;
	var dhcpIpEnd4 = document.getElementById("dhcpIpEnd4").value;
	var dhcpIpEnd = dhcpIpEnd1+"."+dhcpIpEnd2+"."+dhcpIpEnd3+"."+dhcpIpEnd4;
	document.getElementById("dhcpIpEnd").value = dhcpIpEnd;

	//Check if the DHCP START IP is wrong format or out of range.
	var ipCheck=isValidIPAddress(dhcpIpBegin);
	if(ipCheck=="formatWrong")
	{
		showErrorMsg('<%=dhcpWarning_T["dhcpStartIpFormatWrong"]%>');
		return false;
	}else if(ipCheck=="outOfRange" || Number(dhcpIpBegin4)<startip ||dhcpIpBegin1!=ipAddr1|| dhcpIpBegin2!=ipAddr2 || dhcpIpBegin3!=ipAddr3){
		showErrorMsg('<%=dhcpWarning_T["dhcpStartIpRangeWrong"]%>');
		return false;
	}
	//Check if the DHCP END IP is wrong format or out of range.
	ipCheck=isValidIPAddress(dhcpIpEnd);
	if(ipCheck=="formatWrong")
	{
		showErrorMsg('<%=dhcpWarning_T["dhcpEndIpFormatWrong"]%>');
		return false;
	}else if(ipCheck=="outOfRange" || Number(dhcpIpEnd4)>endip || dhcpIpEnd1!=ipAddr1 || dhcpIpEnd2!=ipAddr2 || dhcpIpEnd3!=ipAddr3){
		showErrorMsg('<%=dhcpWarning_T["dhcpEndIpRangeWrong"]%>');
		return false;
	}
	//Check if the dhcp ip range  includes the modem ip.
	if(((ipAddr1==dhcpIpBegin1&&ipAddr1==dhcpIpEnd1&&ipAddr2==dhcpIpBegin2
		&&ipAddr2==dhcpIpEnd2&&ipAddr3==dhcpIpBegin3&&ipAddr3==dhcpIpEnd3)
    &&(ipAddr4*1>=dhcpIpBegin4*1&&ipAddr4*1<=dhcpIpEnd4*1)))
	{
		showErrorMsg('<%=dhcpWarning_T["dhcpIpWrong"]%>');
		return false;
	}
	//Check if the DHCP START IP is great than the DHCP END IP.
      	if(Number(dhcpIpBegin4)>Number(dhcpIpEnd4))
	{
		showErrorMsg('<%=dhcpWarning_T["dhcpIpRangeWrong"]%>');
		return false;
	}
	//Check if the ppp0 or ppp management is in the dhcp range.
	var ppp0_ip = "<%=ppp.ipaddr%>";
	var ppp_management_ip = "<%=ppp_management.ipaddr%>";
	if(isInIPRange(ppp0_ip, dhcpIpBegin, dhcpIpEnd) || isInIPRange(ppp_management_ip, dhcpIpBegin, dhcpIpEnd))
	{
		showErrorMsg('<%=ipWarning_T["ipInvalid"]%>');
		return false;
	}
	return true;
}
//check preassigned ip(ipAddr) with new preassign ip to avoid ip conflict.
function reserved_ip_check_conflict(preNum, ipAddr, index)
{
	for(var i=1;i<=preNum;i++)
	{
		var new_ip = document.getElementById("newip"+i).value;
		var reserved = document.getElementById("ipReserve1"+i).checked;
		if(i==index)
			continue;
		if(reserved==true && ipAddr==new_ip)
		{
			return false;
		}
	}
	return true;
}
//checking assigned new IP address
function checkPreAssignIp(ipAddr, ipAddr1, ipAddr2, ipAddr3)
{
	var oldip = "<%=ipAddr%>"; //if user change ip address, don't need check pre-assign IP.
	var olddhcpIpBegin = "<%=dhcpIpBegin%>";
	var olddhcpIpEnd = "<%=dhcpIpEnd%>";
	var ipAddr1_3 = ipAddr1+"."+ipAddr2+"."+ipAddr3;
	var preNum = parseInt(document.getElementById("preNum").value);
	if((oldip==ipAddr)&&(document.getElementById("dhcpIpBegin").value==olddhcpIpBegin)&&(document.getElementById("dhcpIpEnd").value==olddhcpIpEnd))
        {          
		for(var i=1;i<=preNum;i++)
		{
			var mac = document.getElementById("newmac"+i).value;
			if(document.getElementById("ipReserve1"+i).checked==true && document.getElementById("newip"+i).value!="" && document.getElementById("newip"+i).value != document.getElementById("dynamicIp"+i).value)
			{
				var newIp = document.getElementById("newip"+i).value;
				var dhcpIpBegin4 = document.getElementById("dhcpIpBegin4").value;	
				var dhcpIpEnd4 = document.getElementById("dhcpIpEnd4").value;
				if(!newip_valid_check(newIp, dhcpIpBegin4, dhcpIpEnd4, ipAddr, ipAddr1_3))
				{
					showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
					return false;
				}

				if(!ip_check_conflict(newIp, mac))
				{
					showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
					return false;	
				}

				if(!reserved_ip_check_conflict(preNum, newIp, i))
				{
					showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
					return false;	
				}
			}	
			else if(document.getElementById("ipReserve1"+i).checked==false )
			{
				continue;// don't assign manual IP address, don't need check IP address
			}
			else if(document.getElementById("ipReserve1"+i).checked==true && document.getElementById("newip"+i).value == document.getElementById("dynamicIp"+i).value)
			{
				continue;// assign the same ip to newip, don't need check IP address
			}
			else
			{
				// check the assign checkbox but not fill IP address
				showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
				return false;
			}
		}	
	}
	return true;
}

//check the new reserved ip address which is added first.
function checkAddedPreAssignIp(ipAddr, ipAddr1, ipAddr2, ipAddr3)
{
	var reserveIpAddingFlag = document.getElementById("reserveIpAddingFlag").value;
	if(reserveIpAddingFlag=="1")
	{
		var reserveMac=document.getElementById("reserveMac").value;
		if(!CheckMac(reserveMac))
		{
			showErrorMsg('<%=ipReserveWarning_T["macAddressInavlid"]%>');
			return false;
		}

		reserveMac = reserveMac.toLocaleLowerCase();
		reserveMac = reserveMac.replace(/\s*/g, "");

		var reserveIp=document.getElementById("reserveIp").value;
		var dhcpIpBegin4 = document.getElementById("dhcpIpBegin4").value;	
		var dhcpIpEnd4 = document.getElementById("dhcpIpEnd4").value;
		var ipAddr1_3 = ipAddr1+"."+ipAddr2+"."+ipAddr3;

		if(!newip_valid_check(reserveIp, dhcpIpBegin4, dhcpIpEnd4, ipAddr, ipAddr1_3))
		{
			showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
			return false;
		}

		if(!ip_check_conflict(reserveIp, reserveMac))
		{
			showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
			return false;
		}

		var preNum = parseInt(document.getElementById("preNum").value);	
		for(var i=1;i<=preNum;i++)
          	{	
			var newmac = document.getElementById("newmac"+i).value;
			if(newmac == reserveMac)
			{
				showErrorMsg('<%=ipReserveWarning_T["macAddressInavlid"]%>');
				return false;
			}

			var newIp = document.getElementById("newip"+i).value;
			var reserved = document.getElementById("ipReserve1"+i).checked;
			if(newIp == reserveIp && reserved == true)
			{
				showErrorMsg('<%=ipReserveWarning_T["reserveIpInvalid"]%>');
				return false;
			}	
		}
	}
	return true;
}

//check the public ip and submask
function checkPublicIp(ipAddr)
{
	<%if ipInfo.pubIp ~= nil then%>
		var pubIp = "<%=ipInfo.pubIp%>";
		var pubSubmask = "<%=ipInfo.pubSubmask%>";
		var submask = "255.255.255." + document.getElementById("maskEnd").value;

		var newStartRange = GetStartRange(ipAddr,submask);
		var newEndRange = GetEndRange(ipAddr,submask);
		if((ipAddr==pubIp) || ((submask!=pubSubmask) && isIPMatch(ipAddr, pubIp, pubSubmask)) || isInIPRange(pubIp, newStartRange, newEndRange) || 	isInIPRange(ipAddr, GetStartRange(pubIp,pubSubmask), GetEndRange(pubIp,pubSubmask)))		
		{
			showErrorMsg('<%=ipWarning_T["ipInvalid"]%>');
			return false; 
		}	
	<%end%>
	return true;
}

//Show the confirm information for lan configuration
function showConfirmInfo(ipAddr)
{
	document.getElementById("lanConfig").style.display="none";
	document.getElementById("confirmConfig").style.display="block";
	if(checkLanChange(ipAddr))
	{
		document.getElementById("ipChanging").style.display="block";
		document.getElementById("natDisabled").style.display="none";
		document.getElementById("dhcpDisabled").style.display="none";
		return false;
	}

	if("<%=dhcpState%>"=="true" && document.getElementById("dhcpState2").checked == true)
	{	
		document.getElementById("ipChanging").style.display="none";
		document.getElementById("natDisabled").style.display="none";
		document.getElementById("dhcpDisabled").style.display="block";
		return false;
	}

	if(("<%=device_PPP.enable%>" == "true") && ("<%=TI_Device.lanOption%>" == "biz-rt-napt-ena" || "<%=TI_Device.lanOption%>" == "res-rt-napt" || "<%=TI_Device.lanOption%>" == "res-rt-napt-ipv6" || "<%=TI_Device.lanOption%>" == "biz-rt-napt-ipv6"))
	{
		if("<%=natState%>"=="enabled" && document.getElementById("natState2").checked == true)
		{			
			document.getElementById("ipChanging").style.display="none";
			document.getElementById("natDisabled").style.display="block";
			document.getElementById("dhcpDisabled").style.display="none";
			return false;
		}
	}
}

//To check the input of the ip config form.
function configSubmit()
{
	var ipAddr1 = document.getElementById("ipAddr1").value; 
	var ipAddr2 = document.getElementById("ipAddr2").value;
	var ipAddr3 = document.getElementById("ipAddr3").value;
	var ipAddr4 = document.getElementById("ipAddr4").value;
	var mask4 = document.getElementById("maskEnd").value;
	var ipAddr = ipAddr1+"."+ipAddr2+"."+ipAddr3+"."+ipAddr4;
	document.getElementById("ipAddr").value = ipAddr;
	
	//check Gateway IP address
	if(!checkGatewayIp(ipAddr,mask4))
	{
		return false;
	}

	//recalculate the nat range by ip and netmask, to avoid user config wrong ip and netmask, use ipnet address or broadcast address.
      var mask = document.getElementById("maskEnd").value;
      var netip=(ipAddr4*1) & (mask*1) ;
      var castip = netip + (~(mask*1) & 255);
      var startip=netip + 1;
      var endip = castip - 1;
      if (startip==ipAddr4)
	{  
		startip++;
	}
      if (endip==ipAddr4)  
	{
		endip--;
	}

	if (ipAddr4*1==netip || ipAddr4*1==castip)
	{
		showErrorMsg('<%=ipWarning_T["ipInvalid"]%>');
		return false;
	}

	//checking DHCP range IP address
	if(!checkDhcpRange(startip, endip, ipAddr1, ipAddr2, ipAddr3, ipAddr4))
	{
		return false;
	}
        
	//checking NAT range IP address	
	if(!checkNatRange(startip, endip, ipAddr1, ipAddr2, ipAddr3, ipAddr4))
	{		
	  	return false;		
	}
        
      	//check assigned new IP address
	if(!checkPreAssignIp(ipAddr, ipAddr1, ipAddr2, ipAddr3))
	{
		return false;
	}

	//check the new reserved ip address which is added first.
	if(!checkAddedPreAssignIp(ipAddr, ipAddr1, ipAddr2, ipAddr3))
	{
		return false;
	}

	//check the public ip and submask
	if(!checkPublicIp(ipAddr))
	{
		return false;
	}

	// if LAN Configuration is not changed (IP address and netmask), don't need show confirm lan page
	showConfirmInfo(ipAddr);
	
}

//Change the dhcp and nat range.
//any change will invoke: all fields of NAT and DHCP range change
function change_DHCP_NAT()
{
	// caculate the fourth field of ip address
	var tmp=document.getElementById("ipAddr4").value;
	var mask = document.getElementById("maskEnd").value;
	var startip=((tmp*1) & (mask*1)) + 1;
	var endip = startip -1 + (~(mask*1) & 255) - 1;
	if (startip==tmp)  
		startip++;
	if (endip==tmp)  
		endip--;

	for (var i=1; i<5; i++)
	{
		<%
		if (device_PPP.enable == "true") and (TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6") then
		%>
		if (i==4)
		{
			document.getElementById("natIpBegin"+i).value=startip;
			document.getElementById("natIpEnd"+i).value=endip;
		}
		else
		{
			document.getElementById("natIpBegin"+i).value=document.getElementById("ipAddr"+i).value;
			document.getElementById("natIpEnd"+i).value=document.getElementById("ipAddr"+i).value;
		}
		<%end%>

		if (i==4)
		{
			document.getElementById("dhcpIpBegin"+i).value=startip;
			document.getElementById("dhcpIpEnd"+i).value=endip;
		}
		else
		{
			document.getElementById("dhcpIpBegin"+i).value=document.getElementById("ipAddr"+i).value;
			document.getElementById("dhcpIpEnd"+i).value=document.getElementById("ipAddr"+i).value;
		}
	}
}
</script>
</head>
	<body>
	<div class="contentContainer">
	<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="lanStatus.lp"><%=translate([==[LAN]==])%></a></li>
			</ul>
		</div>	

						<div class="contentTab" id="content">
							<ol id="tocTab">
								
								<li><a href="lanStatus.lp">
									<div class="tab">
										<span class="tabIcon_stlan"></span>  
										<span class="contTabTxt transform"><%=translate([==[LAN State]==])%></span>
									</div>
									<div class="clrBth">
									</div></a></li>
								<li><a href="#"  class="current margin15">
									<div class="tab">
									<span class="contTabTxt transform"><%=translate([==[LAN Configuration]==])%></span></div></a></li>
							</ol>
						</div>
						
<!-- 		<table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
			<tr>
				<td align="left" width="90%"><a href="standard.lp">Standard</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="lanConfig.lp"><%=translate([==[LAN Configuration]==])%></a></td><td nowrap align="right"><a href="lanStatus.lp">Stato</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em></td>
			</tr>
		</table> -->

	<div class="contentcontainer">
<hr> 
<form id="lanConfig" name="lanConfig" action="" method="POST">
<input type="hidden" id="ipAddr" name="ipAddr" value="" />
<input type="hidden" id="natIpBegin" name="natIpBegin" value="" />
<input type="hidden" id="natIpEnd" name="natIpEnd" value="" />
<input type="hidden" id="dhcpIpBegin" name="dhcpIpBegin" value="" />
<input type="hidden" id="dhcpIpEnd" name="dhcpIpEnd" value="" />
<input type="hidden" id="reserveIpAddingFlag" name="reserveIpAddingFlag" value="0" />

	<div class='contentitem' id="lanConfig">
		<table cellspacing='0' cellpadding='0' width="100%"> 
			<tr>
				<!-- <td class='icon' style='vertical-align:top' width='100px'><img src='images/ieth__xl.gif' alt='Interfacce'></td>  -->
				<td class='data verticalAlign'>
		<table cellspacing='0' cellpadding='0' width="100%">
			<tr>
				<td class="midarea2 tableTitle martop15"><%=translate([==[LAN interface Management]==])%></td>
			</tr>
			<tr>
				<td>
<!-- Begin of private LAN-->			
		
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize martop5">
			<tr>
				
				<td class="midarea2 tableTitle"><%=translate([==[LAN Configure]==])%></td>
				<!-- <td><br> -->
		<table width='100%' class='infotable datatable fontSize' cellspacing='0' cellpadding='0' style="line-height:150%;"> 
			<tr>
				<td width='300' class="padleft40"><%=translate([==[IP address of the modem]==])%>:</td>
				<td colspan='3'>
				<input id="ipAddr1" name="ipAddr1" size="3" maxlength="3" class="inputClass" value="" onchange="change_DHCP_NAT()" /><b>.</b>
				<input id="ipAddr2" name="ipAddr2" size="3" maxlength="3" class="inputClass" value="" onchange="change_DHCP_NAT()" /><b>.</b>
				<input id="ipAddr3" name="ipAddr3" size="3" maxlength="3" class="inputClass" value="" onchange="change_DHCP_NAT()" /><b>.</b>
				<input id="ipAddr4" name="ipAddr4" size="3" maxlength="3" class="inputClass" value="" onchange="change_DHCP_NAT()" /></td>
			</tr> 
			<tr>
				<td width='300' class="alignMid padleft40"><%=translate([==[Subnet Mask]==])%>:</td>
				<td colspan='3' class="alignMid">255<b>.</b>255<b>.</b>255<b>.</b>
					<select size="1" id="maskEnd" name="maskEnd" class="inputClass" onchange="change_DHCP_NAT()">
					<option value="0">0</option>
					<option value="128">128</option>
					<option value="192">192</option>
					<option value="224">224</option>
					<option value="240">240</option>
					<option value="248">248</option>
					<option value="252" disabled="disabled">252</option>
					</select>
				</td>
			</tr> 
		</table> 
				</td>
			</tr>
		</table>

			<table id="dhcpBlock" cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr>
				
				<td class="midarea2 tableTitle"> 
			<%=translate([==[DHCP Service Settings]==])%></td>
		<table width='100%' class='infotable datatable fontSize' cellspacing='0' cellpadding='0'  class="fontSize" style="line-height:150%;"> 
			<!-- <tr>
				<td></td>
				<td width='30px'></td>
				<td width='220px'></td>
				<td width='50px'></td>
			</tr> -->
			<tr >
				<td width='300' class="padleft40"><%=translate([==[DHCP State]==])%>:</td>
				<td colspan='3'>		
					<input type="radio" value="true" id="dhcpState1" name="dhcpState" />&nbsp;<%=translate([==[ON]==])%>&nbsp;&nbsp;&nbsp;&nbsp; 
					<input type="radio" value="false" id="dhcpState2" name="dhcpState" />&nbsp;<%=translate([==[OFF]==])%>
				</td>
			</tr>
			<tr >
				<td width='300' class="padleft40"><%=translate([==[start IP]==])%>:</td>
				<td colspan='3'><input id="dhcpIpBegin1" name="dhcpIpBegin1" size="3" maxlength="3" class="inputClass" value="192" /><b>.</b><input id="dhcpIpBegin2" name="dhcpIpBegin2" size="3" maxlength="3" class="inputClass" value="168" /><b>.</b><input id="dhcpIpBegin3" name="dhcpIpBegin3" size="3" maxlength="3" class="inputClass" value="1" /><b>.</b><input id="dhcpIpBegin4" name="dhcpIpBegin4" size="3" maxlength="3" class="inputClass" value="2" /></td>
			</tr>
			<tr>
				<td width='300' class="padleft40"><%=translate([==[end IP]==])%> (<%=translate([==[Reserved for internal use]==])%>):</td>
				<td colspan='3'><input id="dhcpIpEnd1" name="dhcpIpEnd1" size="3" maxlength="3" class="inputClass" value="192" /><b>.</b><input id="dhcpIpEnd2" name="dhcpIpEnd2" size="3" maxlength="3" class="inputClass" value="168" /><b>.</b><input id="dhcpIpEnd3" name="dhcpIpEnd3" size="3" maxlength="3" class="inputClass" value="1" /><b>.</b><input id="dhcpIpEnd4" name="dhcpIpEnd4" size="3" maxlength="3" class="inputClass" value="254" /></td>
			</tr>
		</table> 
				</td>
			</tr>
		</table>
		<% if (device_PPP.enable == "true") and (TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption =="res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6") then%>
		
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize padtop10">
			<tr>
				
				<td class="midarea2 tableTitle" ><%=translate([==[NAT Service Settings]==])%></td></tr><tr><td>
		<table width='100%' class='infotable datatable fontSize' cellspacing='0' cellpadding='0' style="line-height:150%;"> 
			<tr >
				<td width='300' class="padleft40"><%=translate([==[NAT State]==])%>:</td>
				<td colspan='3'>
					<input type="radio" value="enabled" id="natState1" name="natState" />&nbsp;<%=translate([==[ON]==])%>&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" value="disabled" id="natState2" name="natState" />&nbsp;<%=translate([==[OFF]==])%>
				</td>
			</tr> 
			<tr >
				<td width='300' class="padleft40"><%=translate([==[start IP]==])%>:</td>
				<td colspan='3'><input id="natIpBegin1" name="natIpBegin1" size="3" maxlength="3" class="inputClass" value="" /><b>.</b><input id="natIpBegin2" name="natIpBegin2" size="3" maxlength="3" class="inputClass" value="" /><b>.</b><input id="natIpBegin3" name="natIpBegin3" size="3" maxlength="3" class="inputClass" value="" /><b>.</b><input id="natIpBegin4" name="natIpBegin4" size="3" maxlength="3" class="inputClass" value="" /></td>
			</tr>
			<tr  >
				<td width='300' class="padleft40"><%=translate([==[end IP]==])%>:</td>
				<td colspan='3'><input id="natIpEnd1" name="natIpEnd1" size="3" maxlength="3"  class="inputClass"  class="inputClass" value="" /><b>.</b><input id="natIpEnd2" name="natIpEnd2" size="3" maxlength="3"  class="inputClass" value="" /><b>.</b><input id="natIpEnd3" name="natIpEnd3" size="3" maxlength="3"  class="inputClass" value="1" /><b>.</b><input id="natIpEnd4" name="natIpEnd4" size="3" maxlength="3"  class="inputClass" value="255" /></td>
			</tr>
	</table> 
		</td>
			</tr>
	</table>
<%end%>		
<!-- End of private LAN State-->

<!-- Begin of LAN Links-->
		
		<table cellspacing='0' cellpadding='0' width='100%' class="fontSize width770 padtop10">
			<tr>
				
				<td class="midarea2 tableTitle"><%=translate([==[IP Reservation]==])%></td>
		<table class='edittable fontSize valueSpace ipReserve width700' width='100%' cellspacing='0' cellpadding='0' border='0'> 

			<tr>
				<td class="tableHd width175"  align='left'><%=translate([==[HOST Name]==])%></td>
				<td class="tableHd width175" align='left'><%=translate([==[MAC Address]==])%></td>
				<td  class="tableHd width175" align='left' ><%=translate([==[IP Address]==])%></td>
				<td  class="tableHd width175" align='left' ><%=translate([==[Reservation Status]==])%></td>
			</tr>
			<tr>
				<td colspan='4'><!-- <img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br> --></td>
			</tr>
			<tr>
				<td colspan='4' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td>
			</tr>
				<% 
				local rowStyle = "oddrow"
				local rowNum = 0
				local preNum = 0
				for i,v in pairs(devices) do 
					local isReserveChecked = ""
					local isUnreserveChecked = ""
              			preNum=preNum+1
              			if v.staticenable=="true" then 
                				isReserveChecked = "checked" 
              			else
						v.newip=v.ip
						isUnreserveChecked = "checked"
					end

					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow"
					else
						rowStyle = "evenrow"
					end
				%>
			<tr>
				<td  class='<%=rowStyle%>' colspan='4'><!-- <img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br> --></td>
			</tr>
			<tr>				
				<td  class="<%=rowStyle%> alignMid"><%=v.name%></td>
				<td class="<%=rowStyle%> alignMid"><%=v.mac%></td>
				<td class="<%=rowStyle%> alignMid">
					<input type="hidden" id="dynamicIp<%=preNum%>" name="dynamicIp<%=preNum%>" value="<%=v.ip%>" />
					<input type="hidden" id="newmac<%=preNum%>" name="newmac<%=preNum%>" value="<%=v.mac%>" />
					<input type="text" id="newip<%=preNum%>" name="newip<%=preNum%>" size="12" class="inputClass" value="<%=v.newip%>" />
				</td>	
				<td class="<%=rowStyle%> alignMid">
					<input type="radio" value="true" id="ipReserve1<%=preNum%>" name="ipReserve<%=preNum%>"  <%=isReserveChecked%> />&nbsp;<%=translate([==[Reserved]==])%><br/>
					<input type="radio" value="false" id="ipReserve2<%=preNum%>" name="ipReserve<%=preNum%>" <%=isUnreserveChecked%> />&nbsp;<%=translate([==[Unreserved]==])%>				
				</td>
			</tr>
			<tr>
				<td class="<%=rowStyle%>" colspan='4'><!-- <img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br> --></td>
			</tr>
				<% end %><input type="hidden" id="preNum" name="preNum" value="<%=preNum%>" />
				<!-- Add new row for ip reservation -->
				<%
				rowNum = rowNum + 1
				if rowNum%2==1 then
					rowStyle = "oddrow"
				else
					rowStyle = "evenrow"
				end
				%>

			<tr id="reserveIpAdding" style="visibility:hidden;">				
				<td class="<%=rowStyle%> alignMid">---</td>
				<td class="<%=rowStyle%> alignMid"><input type="text" id="reserveMac" name="reserveMac" size="15" class="inputClass" /></td>
				<td class="<%=rowStyle%> alignMid"><input type="text" id="reserveIp" name="reserveIp" size="12" class="inputClass" /></td>	
				<td class="<%=rowStyle%> alignMid">
					<input type="radio" value="true" id="reserveIpRadio1" name="reserveIpRadio" checked />&nbsp;<%=translate([==[Reserved]==])%><br/>
					<input type="radio" value="false" id="reserveIpRadio2" name="reserveIpRadio" />&nbsp;<%=translate([==[Unreserved]==])%>				
				</td>
			</tr>
				<!--<tr><td class="<%=rowStyle%>" colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> end of adding new row for ip reservation-->
		</table>
				</td>
			</tr>
		</table>
<!-- End of LAN Links-->

		<table cellspacing='0' cellpadding='0' width='100%' class="txtAlignCenter fontSize">
			<tr><td>
				<table><tr>
				<td id="lanBtn">
					<a onclick="addIpReservation()" href="#" id="addIpReserveBtn">
						<div class="midarea6-1 mainButton" name="thb9"><%=translate([==[Add]==])%></div>
					</a>
				</td>
				
				<td style="padding-left: 50px">
					<a onclick="configSubmit()" href="#">
						<div class="midarea6-1 mainButton" name="thb9"><%=translate([==[Save]==])%></div>
					</a>
				</td>
				
				<td style="padding-left: 50px">
					<a href="lanStatus.lp">
						<div class="midarea6-1 mainButton" name="thb10"><%=translate([==[Cancel]==])%></div>
					</a>
				</td>
				</tr></table>
				</td>
			</tr>
		</table>
				</td>
			</tr>
		</table>
				</td>
			</tr>
		</table>
	</div>

</form>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>
<div id="confirmConfig" style="display:none">
<%cgilua.lp.include("webparts/confirmLan.lp")%>
</div>
<div id="resultKO" style="display:none">
<%cgilua.lp.include("webparts/resultKO_IP.lp")%>
</div>

<script language="javascript" type="text/javascript">
var ip = "<%=ipAddr%>";
var arrIp = ip.split(".");
document.getElementById("ipAddr1").value = arrIp[0];
document.getElementById("ipAddr2").value = arrIp[1];
document.getElementById("ipAddr3").value = arrIp[2];
document.getElementById("ipAddr4").value = arrIp[3];

var mask = "<%=ipMask%>";
var arrMask = mask.split(".");
document.getElementById("maskEnd").value = arrMask[3];

var dhcpState = "<%=dhcpState%>";
	
if(dhcpState=="true"){
	document.getElementById("dhcpState1").checked = true;
}else{
	document.getElementById("dhcpState2").checked = true;
}
	
var dhcpIpBegin = "<%=dhcpIpBegin%>";
var arrDhcpIpBegin = dhcpIpBegin.split(".");
document.getElementById("dhcpIpBegin1").value = arrDhcpIpBegin[0];
document.getElementById("dhcpIpBegin2").value = arrDhcpIpBegin[1];
document.getElementById("dhcpIpBegin3").value = arrDhcpIpBegin[2];
document.getElementById("dhcpIpBegin4").value = arrDhcpIpBegin[3];

var dhcpIpEnd = "<%=dhcpIpEnd%>";
var arrDhcpIpEnd = dhcpIpEnd.split(".");
document.getElementById("dhcpIpEnd1").value = arrDhcpIpEnd[0];
document.getElementById("dhcpIpEnd2").value = arrDhcpIpEnd[1];
document.getElementById("dhcpIpEnd3").value = arrDhcpIpEnd[2];
document.getElementById("dhcpIpEnd4").value = arrDhcpIpEnd[3];

if(("<%=device_PPP.enable%>" == "true") && ("<%=TI_Device.lanOption%>" == "biz-rt-napt-ena" || "<%=TI_Device.lanOption%>" == "res-rt-napt" || "<%=TI_Device.lanOption%>" == "res-rt-napt-ipv6" || "<%=TI_Device.lanOption%>" == "biz-rt-napt-ipv6" ))	
{	
 	var natState = "<%=natState%>";
 	if(natState=="enabled"){
 		document.getElementById("natState1").checked = true;
 	}else{
 		document.getElementById("natState2").checked = true;
 	}

 	var natIpBegin = "<%=natIpBegin%>";
 	var arrNatIpBegin = natIpBegin.split(".");
 	document.getElementById("natIpBegin1").value = arrNatIpBegin[0];
 	document.getElementById("natIpBegin2").value = arrNatIpBegin[1];
 	document.getElementById("natIpBegin3").value = arrNatIpBegin[2];
 	document.getElementById("natIpBegin4").value = arrNatIpBegin[3];

 	var natIpEnd = "<%=natIpEnd%>";
 	var arrNatIpEnd = natIpEnd.split(".");
 	document.getElementById("natIpEnd1").value = arrNatIpEnd[0];
  	document.getElementById("natIpEnd2").value = arrNatIpEnd[1];
 	document.getElementById("natIpEnd3").value = arrNatIpEnd[2];
	document.getElementById("natIpEnd4").value = arrNatIpEnd[3];
}
<%
if TI_info.dhcpServerConfigurable=="true" then
%>
document.getElementById("dhcpBlock").style.display= "";
<%end%>

//fuction for detecting the browser details
function detectBrowserDetails() 
{
	var nVer = navigator.appVersion;
	var nAgt = navigator.userAgent;
	var browserName  = navigator.appName;
	var fullVersion  = ''+parseFloat(navigator.appVersion); 
	var majorVersion = parseInt(navigator.appVersion,10);
	var nameOffset,verOffset,ix;

// In Opera, the true version is after "Opera" or after "Version"
if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
	 browserName = "Opera";
	 fullVersion = nAgt.substring(verOffset+6);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
	   fullVersion = nAgt.substring(verOffset+8);
}
// In MSIE, the true version is after "MSIE" in userAgent
else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
	 browserName = "Microsoft Internet Explorer";
	 fullVersion = nAgt.substring(verOffset+5);
}
// In Chrome, the true version is after "Chrome" 
else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
	 browserName = "Chrome";
	 fullVersion = nAgt.substring(verOffset+7);
}
// In Safari, the true version is after "Safari" or after "Version" 
else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
	 browserName = "Safari";
	 fullVersion = nAgt.substring(verOffset+7);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
	   fullVersion = nAgt.substring(verOffset+8);
}
// In Firefox, the true version is after "Firefox" 
else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
	 browserName = "Firefox";
	 fullVersion = nAgt.substring(verOffset+8);
}
// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < 
          (verOffset=nAgt.lastIndexOf('/')) ) 
{
	 browserName = nAgt.substring(nameOffset,verOffset);
	 fullVersion = nAgt.substring(verOffset+1);
	 if (browserName.toLowerCase()==browserName.toUpperCase()) {
	  browserName = navigator.appName;
 }
}
// trim the fullVersion string at semicolon/space if present
if ((ix=fullVersion.indexOf(";"))!=-1)
   fullVersion=fullVersion.substring(0,ix);
if ((ix=fullVersion.indexOf(" "))!=-1)
   fullVersion=fullVersion.substring(0,ix);

   majorVersion = parseInt(''+fullVersion,10);

	if (isNaN(majorVersion)) {
		fullVersion  = ''+parseFloat(navigator.appVersion); 
		majorVersion = parseInt(navigator.appVersion,10);
	}


if (browserName == "Microsoft Internet Explorer")
{
	
	if (majorVersion <= 7) 
	{
		
		if(document.getElementById("lanBtn"))
		{
			document.getElementById("lanBtn").className="iebuttonLeft";
		}
		
	}
	else
	{
		
		if(document.getElementById("lanBtn"))
		{
			document.getElementById("lanBtn").className="buttonLeft";
		}
	}
}
else 
{
		
		if(document.getElementById("lanBtn"))
		{
			document.getElementById("lanBtn").className="buttonLeft";
		}
}
}
	detectBrowserDetails();


</script>
</body>
</html>
