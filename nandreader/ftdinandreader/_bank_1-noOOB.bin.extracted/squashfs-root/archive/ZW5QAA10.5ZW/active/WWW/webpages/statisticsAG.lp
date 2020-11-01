<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css" />
  <script language="JavaScript" type="text/javascript">
    if(window.parent.menu.document.getElementById("stcon")!=null && 
		window.parent.menu.document.getElementById("stcon") != "undefinded") {
		window.parent.menu.document.getElementById("stcon").className="";
	}
	
	if(window.parent.menu.document.getElementById("serte")!=null && 
		window.parent.menu.document.getElementById("serte") != "undefinded") {
		window.parent.menu.document.getElementById("serte").className="";
	}

	if(window.parent.menu.document.getElementById("lanst")!=null && 
		window.parent.menu.document.getElementById("lanst") != "undefinded") {
		window.parent.menu.document.getElementById("lanst").className="";
	}

	if(window.parent.menu.document.getElementById("wifist")!=null && 
		window.parent.menu.document.getElementById("wifist") != "undefinded") {
		window.parent.menu.document.getElementById("wifi2li").style.display="none";
		window.parent.menu.document.getElementById("wifi2li").style.display="none";
		window.parent.menu.document.getElementById("wifi5li").style.display="none";
		window.parent.menu.document.getElementById("wifist").className="";
		window.parent.menu.document.getElementById("wifi2").className="";
		window.parent.menu.document.getElementById("wifi5").className="";
		window.parent.menu.document.getElementById("wifi_guest").className="";
	}

	if(window.parent.menu.document.getElementById("asst")!=null && 
		window.parent.menu.document.getElementById("asst") != "undefinded") {
		window.parent.menu.document.getElementById("asst").className="";
	}

	if(window.parent.menu.document.getElementById("stat")!=null && 
		window.parent.menu.document.getElementById("stat") != "undefinded") {
		window.parent.menu.document.getElementById("stat").className="submenuselect";
	}
	if(window.parent.menu.document.getElementById("loac")!=null && 
		window.parent.menu.document.getElementById("loac") != "undefinded") {
		window.parent.menu.document.getElementById("loac").className="";
	}


	
  </script>
</head>
<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/common.lp")
cgilua.lp.include("lp/dsl.lp")
cgilua.lp.include("lp/ppp.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/connectionService.lp")


local translate = translate
local POST=cgilua.POST

-- ATM
local reply, error = mbus.getParameters{path = "Device.ATM.Link.1", param = "Enable", datamodel = "second"}
local atmEnable = reply["Device.ATM.Link.1"][1].param["Enable"]

-- DSL
local reply, error = mbus.getParameters{path = "Device.DSL.Line.1", param = {"Enable", "FirmwareVersion", "PowerManagementState"}, datamodel = "second"}
local dslEnable = reply["Device.DSL.Line.1"][1].param["Enable"]

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	ResetTrafficStat()
	if dslEnable == "true" or atmEnable == "true" then
		ResetADSLStat()
	end

	cgilua.redirect("statisticsAG.lp")
	return
end

--DSL paratmeter 
local dsl = getDSLInfo()

if dslEnable == "true" then
  dsl.fwVersion = reply["Device.DSL.Line.1"][1].param["FirmwareVersion"]
  dsl.pmState = reply["Device.DSL.Line.1"][1].param["PowerManagementState"]

  reply, error = mbus.getParameters{path = "Device.DSL.Line.1.Stats.Total", param = {"ErroredSecs", "SeverelyErroredSecs"}, datamodel = "second"}
  dsl.dslErroredSecs = reply["Device.DSL.Line.1.Stats.Total"][1].param["ErroredSecs"]
  dsl.dslSeverelyErroredSecs = reply["Device.DSL.Line.1.Stats.Total"][1].param["SeverelyErroredSecs"]
  if dsl.dslErroredSecs == "2147480000" then dsl.dslErroredSecs = "0" end
  if dsl.dslSeverelyErroredSecs == "2147480000" then dsl.dslSeverelyErroredSecs = "0" end

  dsl.dslState = translate([==[Unsynchronized]==])
  dsl.dslStateColor = "tdRed"
  if dsl.dsl_status == "Up" then
    dsl.dslState = translate([==[Actived]==])
    dsl.dslStateColor = "tdGreen"
  elseif dsl.dsl_status == "Initializing" then
    dsl.dslState = translate([==[In sync]==])
    dsl.dslStateColor = "tdOrange"
  end

  dsl.dslModulationType = ""
  if dsl.dsl_ModulationType == "ADSL_G.dmt" then
    dsl.dslModulationType = "ADSL"
  elseif dsl.dsl_ModulationType == "ADSL_G.dmt.bis" then
    dsl.dslModulationType = "ADSL2"
  elseif dsl.dsl_ModulationType == "ADSL_2plus" then
    dsl.dslModulationType = "ADSL2+"
  elseif dsl.dsl_ModulationType == "VDSL" then
    dsl.dslModulationType = "VDSL"
  end

  reply, error = mbus.getParameters{path = "Device.DSL.Channel.1", param = {"LinkEncapsulationUsed", "ACTINP", "UpstreamCurrRate", "DownstreamCurrRate"}, datamodel = "second"}
  dsl.LinkEncapsulationUsed = "ATM"
  if string.sub(tostring(reply["Device.DSL.Channel.1"][1].param["LinkEncapsulationUsed"]), -3, -1) == "PTM" then
    dsl.LinkEncapsulationUsed = "PTM"
  end
  dsl.ACTINP = reply["Device.DSL.Channel.1"][1].param["ACTINP"]
  dsl.UpstreamCurrRate = reply["Device.DSL.Channel.1"][1].param["UpstreamCurrRate"]
  dsl.DownstreamCurrRate = reply["Device.DSL.Channel.1"][1].param["DownstreamCurrRate"]

  reply, error = mbus.getParameters{path = "Device.DSL.Channel.1.Stats", param = "ShowtimeStart", datamodel = "second"}
  dsl.ShowtimeStart = reply["Device.DSL.Channel.1.Stats"][1].param["ShowtimeStart"]

  reply, error = mbus.getParameters{path = "Device.DSL.Channel.1.Stats.Total", param = {"XTURFECErrors", "XTURCRCErrors"}, datamodel = "second"}
  dsl.XTURFECErrors = reply["Device.DSL.Channel.1.Stats.Total"][1].param["XTURFECErrors"]
  dsl.XTURCRCErrors = reply["Device.DSL.Channel.1.Stats.Total"][1].param["XTURCRCErrors"]
  if dsl.XTURFECErrors == "2147480000" then dsl.XTURFECErrors = "0" end
  if dsl.XTURCRCErrors == "2147480000" then dsl.XTURCRCErrors = "0" end
end  -- dslEnable == "true"


-- ETH
local eth = {}
for i=1, 5 do
  eth[i] = getLanStatFromDev(i)
end

-- WiFi
local wifi = {}
local wifiStatsPath = "Device.WiFi.SSID.1.Stats"
reply, error = mbus.getParameters{path = wifiStatsPath, datamodel = "second"}
wifi.packetsReceived = reply[wifiStatsPath][1].param["PacketsReceived"]
wifi.packetsSent = reply[wifiStatsPath][1].param["PacketsSent"]
wifi.errorsReceived = reply[wifiStatsPath][1].param["ErrorsReceived"]
wifi.errorsSent = reply[wifiStatsPath][1].param["ErrorsSent"]

local wifi2 = {}
local wifiStatsPath = "Device.WiFi.SSID.2.Stats"
reply, error = mbus.getParameters{path = wifiStatsPath, datamodel = "second"}
wifi2.packetsReceived = reply[wifiStatsPath][1].param["PacketsReceived"]
wifi2.packetsSent = reply[wifiStatsPath][1].param["PacketsSent"]
wifi2.errorsReceived = reply[wifiStatsPath][1].param["ErrorsReceived"]
wifi2.errorsSent = reply[wifiStatsPath][1].param["ErrorsSent"]

local wifi3 = {}
local wifiStatsPath = "Device.WiFi.SSID.3.Stats"
reply, error = mbus.getParameters{path = wifiStatsPath, datamodel = "second"}
wifi3.packetsReceived = reply[wifiStatsPath][1].param["PacketsReceived"]
wifi3.packetsSent = reply[wifiStatsPath][1].param["PacketsSent"]
wifi3.errorsReceived = reply[wifiStatsPath][1].param["ErrorsReceived"]
wifi3.errorsSent = reply[wifiStatsPath][1].param["ErrorsSent"]


local wifi4 = {}
local wifiStatsPath = "Device.WiFi.SSID.4.Stats"
reply, error = mbus.getParameters{path = wifiStatsPath, datamodel = "second"}
wifi4.packetsReceived = reply[wifiStatsPath][1].param["PacketsReceived"]
wifi4.packetsSent = reply[wifiStatsPath][1].param["PacketsSent"]
wifi4.errorsReceived = reply[wifiStatsPath][1].param["ErrorsReceived"]
wifi4.errorsSent = reply[wifiStatsPath][1].param["ErrorsSent"]

-- IP
local ip_stats = {}
for i=1, 2 do
  ip_stats[i] = {}
  local ipStatsPath = "Device.IP.Interface." .. i .. ".Stats"
  reply, error = mbus.getParameters{path = ipStatsPath, datamodel = "second"}
  ip_stats[i].packetsReceived = reply[ipStatsPath][1].param["PacketsReceived"]
  ip_stats[i].packetsSent = reply[ipStatsPath][1].param["PacketsSent"]
  ip_stats[i].errorsReceived = reply[ipStatsPath][1].param["ErrorsReceived"]
  ip_stats[i].errorsSent = reply[ipStatsPath][1].param["ErrorsSent"]
end

--wan sencing type
local wanConnType, wanConnTitle = getWANConnectionType()

--telephony services
local voice = {}
for i=1, 3 do
    voice[i] = getVoiceStat(i)
end
%>
<body>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li><li><a href="statisticsAG.lp"><%=translate([==[Statistics]==])%></a></li>
			</ul>
		</div>	

<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="statisticsAG.lp" class="current">
				<div class="tab">
				<span class="tabIconStatisticsAG"></span>  
				<span class="contTabTxt transform"><%=translate([==[Statistics]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>

<div class='contentcontainer'>
<div class='contentitem'>

<table cellspacing='0' cellpadding='0' width="100%" class="fontSize"><tr>
    <td>
<%


if dslEnable == "true" then
  writeBlockRowTitle(translate([==[DSL]==]))
  writeBlockRow_Desc(translate([==[Firmware version]==]),                     dsl.fwVersion)
  writeBlockRow_Desc(translate([==[State]==]),                                dsl.dslState)
  writeBlockRow_Desc(translate([==[Transmission system]==]),                  dsl.dslModulationType)
  writeBlockRow_Desc(translate([==[Transmission mode]==]),                    dsl.latency_type)
  if dsl.dslModulationType == "VDSL" then
    local profile = ""
    local reply, error = mbus.getParameters{path = "Device.DSL.Line.1", param = "CurrentProfile", datamodel = "second"}
    if reply["Device.DSL.Line.1"][1] ~= nil and reply["Device.DSL.Line.1"][1].param ~= nil then
      profile = reply["Device.DSL.Line.1"][1].param["CurrentProfile"] or ""
    end
    writeBlockRow_Desc(translate([==[Profile]==]),                            profile)
  end
  writeBlockRow_Desc(translate([==[Power State]==]),                          dsl.pmState)
  writeBlockRow_Desc(translate([==[Maximum transmission rate]==]).." (Kbps)", dsl.upstreamMax)
  writeBlockRow_Desc(translate([==[Maximum receiving rate]==]).." (Kbps)",    dsl.downstreamMax)
  writeBlockRow_Desc("SNR Upstream (dB)",                                     dsl.up_noisemargin)
  writeBlockRow_Desc("SNR Downstream (dB)",                                   dsl.down_noisemargin)
  writeBlockRow_Desc(translate([==[Attenuation]==]).." Upstream (dB)",        dsl.up_attenuation)
  writeBlockRow_Desc(translate([==[Attenuation]==]).." Downstream (dB)",      dsl.down_attenuation)
  writeBlockRow_Desc(translate([==[Transmission power]==]).." (dB)",          dsl.up_power)
  writeBlockRow_Desc(translate([==[Receiving power]==]).." (dB)",             dsl.down_power)
  writeBlockRow_Desc(translate([==[Total ES (Errored Secs)]==]),              dsl.dslErroredSecs)
  writeBlockRow_Desc(translate([==[Total SES (Severely Errored Secs)]==]),    dsl.dslSeverelyErroredSecs)
  writeBlockRow_Desc(translate([==[Encapsulation Type]==]),                   dsl.LinkEncapsulationUsed)
  writeBlockRow_Desc(translate([==[Impulse Noise Protection (INP)]==]),       dsl.ACTINP)
  writeBlockRow_Desc(translate([==[Transmission rate]==]).." (Kbps)",         dsl.UpstreamCurrRate)
  writeBlockRow_Desc(translate([==[Receiving rate]==]).." (Kbps)",            dsl.DownstreamCurrRate)
  writeBlockRow_Desc(translate([==[Up time]==]),                              dsl.ShowtimeStart)
  writeBlockRow_Desc(translate([==[Total FEC Errors]==]),                     dsl.XTURFECErrors)
  writeBlockRow_Desc(translate([==[Total CRC Errors]==]),                     dsl.XTURCRCErrors)
  endBlock()
end

if atmEnable == "true" and wanConnType ~= "ETH" then
  writeBlockRowTitle(translate([==[ATM Statistics]==]))
  writeBlockRowTitle("PVC 8/35")
  writeBlockRow_Desc(translate([==[VPI/VCI]==]),                              dsl.pvc)
  writeBlockRow_Desc(translate([==[CRC errors]==]).." (PVC 8/35)",            dsl.crcErrors)
  writeBlockRowTitle("PVC 8/36")
  writeBlockRow_Desc(translate([==[VPI/VCI]==]),                              dsl.pvc_1)
  writeBlockRow_Desc(translate([==[CRC errors]==]).." (PVC 8/36)",            dsl.crcErrors_2)
  endBlock()
end

writeTableRowTitle_statisticsAG(translate([==[LAN interfaces]==]))
%>
  
  <tr>
    <td colspan="6" class="tableHd"><%=translate([==[Interface]==])%></td>
    <td colspan="6" class="tableHd"><%=translate([==[State]==])%></td>
    <td colspan="6" class="tableHd"><%=translate([==[Packets Sent]==])%></td>
    <td colspan="6" class="tableHd"><%=translate([==[Packets Received]==])%></td>
    <td colspan="6" class="tableHd"><%=translate([==[Error Packets Sent]==])%></td>
    <td colspan="6" class="tableHd"><%=translate([==[Error Packets Received]==])%></td>
  </tr> 
  
<%
local rowStyle = "oddrow"
local rowNum = 0
for i=1, 4 do
  if eth[i].enable == "true" then
    rowNum = rowNum + 1
    if rowNum%2==1 then
      rowStyle = "oddrow"
    else
      rowStyle = "evenrow"
    end
    writeTableRow_statisticsAG(6, rowStyle, "Ethernet "..i, eth[i].state, eth[i].packetsSent, eth[i].packetsReceived, eth[i].errorsSent, eth[i].errorsReceived)
  end
end
endBlock()

if eth[5].enable == "true" then
  writeTableRowTitle_statisticsAG(translate([==[WAN Ethernet Interface]==]))
%>
  <tr>
    <td colspan='6' class="tableHd"><%=translate([==[Interface]==])%></td>
    <td colspan='6' class="tableHd"><%=translate([==[State]==])%></td>
    <td colspan='6' class="tableHd"><%=translate([==[Packets Sent]==])%></td>
    <td colspan='6' class="tableHd"><%=translate([==[Packets Received]==])%></td>
    <td colspan='6' class="tableHd"><%=translate([==[Error Packets Sent]==])%></td>
    <td colspan='6' class="tableHd"><%=translate([==[Error Packets Received]==])%></td>
  </tr> 
<%
  writeTableRow_statisticsAG(6, "oddrow", "Ethernet 5", eth[5].state, eth[5].packetsSent, eth[5].packetsReceived, eth[5].errorsSent, eth[5].errorsReceived)
  endBlock()
end

writeTableRowTitle_statisticsAG(translate([==[Wi-Fi@2.4 GHz]==]))
writeTableRowHeader_Header(4, translate([==[Packets Sent]==]), translate([==[Packets Received]==]), translate([==[Errors Sent]==]), translate([==[Errors Received]==]))
writeTableRow_statisticsAG(4, "oddrow", wifi.packetsSent, wifi.packetsReceived, wifi.errorsSent, wifi.errorsReceived)
endBlock()

writeTableRowTitle_statisticsAG(translate([==[Wi-Fi@5 GHz]==]))
writeTableRowHeader_Header(4, translate([==[Packets Sent]==]), translate([==[Packets Received]==]), translate([==[Errors Sent]==]), translate([==[Errors Received]==]))
writeTableRow_statisticsAG(4, "oddrow", wifi2.packetsSent, wifi2.packetsReceived, wifi2.errorsSent, wifi2.errorsReceived)
endBlock()

writeTableRowTitle_statisticsAG(translate([==[Wi-Fi Guests]==]).."@2.4 GHz")
writeTableRowHeader_Header(4, translate([==[Packets Sent]==]), translate([==[Packets Received]==]), translate([==[Errors Sent]==]), translate([==[Errors Received]==]))
writeTableRow_statisticsAG(4, "oddrow", wifi3.packetsSent, wifi3.packetsReceived, wifi3.errorsSent, wifi3.errorsReceived)
endBlock()

writeTableRowTitle_statisticsAG(translate([==[Wi-Fi Guests]==]).."@5 GHz")
writeTableRowHeader_Header(4, translate([==[Packets Sent]==]), translate([==[Packets Received]==]), translate([==[Errors Sent]==]), translate([==[Errors Received]==]))
writeTableRow_statisticsAG(4, "oddrow", wifi4.packetsSent, wifi4.packetsReceived, wifi4.errorsSent, wifi4.errorsReceived)
endBlock()

local reply, error = mbus.getParameters{path = "Device.PTM.Link.1", param = {"Enable", "Status"}, datamodel = "second"}
local ptm_vdsl_status = ""
if reply["Device.PTM.Link.1"][1].param["Enable"] == "true" then
  ptm_vdsl_status = reply["Device.PTM.Link.1"][1].param["Status"]
end
local wan_eth_status = eth[5].enable

local IPTV_Ser = get_IPTVService()
local reply, error = mbus.getParameters{path = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage", param ={"LANOption"},datamodel = "second"}
if reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["LANOption"] ~= "biz-br" and reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["LANOption"] ~= "biz-rt-napt-ena" and reply["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["LANOption"] ~= "biz-rt-napt-ipv6" then

	local IPTV_Ser = get_IPTVService()
	if IPTV_Ser ~= "OFF" and IPTV_Ser ~= "Off" then
	  writeTableRowTitle_statisticsAG(translate([==[IPTV Statistics]==]))
	%>
	  <tr>
		<td colspan='5'  class="tableHd"><%=translate([==[Port]==])%></td>
		<td colspan='5'  class="tableHd"><%=translate([==[Packets Sent]==])%></td>
		<td colspan='5'  class="tableHd"><%=translate([==[Packets Received]==])%></td>
		<td colspan='5'  class="tableHd"><%=translate([==[Errors Sent]==])%></td>
		<td colspan='5'  class="tableHd"><%=translate([==[Errors Received]==])%></td>
	  </tr> 
	<%
	  local rowNum = 0
	  reply, error = mbus.getParameters{path = "Device.ATM.Link.2", param = {"Enable", "Status"}, datamodel = "second"}
	  if reply["Device.ATM.Link.2"][1].param["Enable"] == "true" and reply["Device.ATM.Link.2"][1].param["Status"] == "Up" then
		reply, error = mbus.getParameters{path = "Device.Bridging.Bridge.2.Port.5.Stats", datamodel = "second"}
		local v = reply["Device.Bridging.Bridge.2.Port.5.Stats"][1].param
		writeTableRow_statisticsAG(5, "oddrow", "PVC 8/36", v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
		rowNum = 1
	  end

	  if ptm_vdsl_status == "Up" then
		reply, error = mbus.getParameters{path = "Device.Bridging.Bridge.2.Port.6.Stats", datamodel = "second"}
		local v = reply["Device.Bridging.Bridge.2.Port.6.Stats"][1].param
		local rowStyle = "evenrow"
		if rowNum == 0 then
		  rowStyle = "oddrow"
		end
		writeTableRow_statisticsAG(5, rowStyle, "PTM VDSL", v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
		rowNum = rowNum + 1
	  end
	  
	  if wan_eth_status == "true" then
		reply, error = mbus.getParameters{path = "Device.Bridging.Bridge.2.Port.7.Stats", datamodel = "second"}
		local v = reply["Device.Bridging.Bridge.2.Port.7.Stats"][1].param
		local rowStyle = "oddrow"
		if rowNum == 1 then
		  rowStyle = "evenrow"
		end
		writeTableRow_statisticsAG(5, rowStyle, translate([==[WAN Ethernet Interface]==]), v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
	  end

	  endBlock()
	end
end

writeTableRowTitle_statisticsAG(translate([==[Managed TV]==]))
reply, error = mbus.getParameters{path = "Device.DHCPv4.Client.1", param = {"Status"}, datamodel = "second"}
%>
  <tr>
	<td colspan='4'  class="tableHd"><%=translate([==[Packets Sent]==])%></td>
	<td colspan='4'  class="tableHd"><%=translate([==[Packets Received]==])%></td>
	<td colspan='4'  class="tableHd"><%=translate([==[Errors Sent]==])%></td>
	<td colspan='4'  class="tableHd"><%=translate([==[Errors Received]==])%></td>
  </tr> 
<%
if reply["Device.DHCPv4.Client.1"][1].param["Status"] == "Enabled" then
	reply, error = mbus.getParameters{path = "Device.IP.Interface.4.Stats", datamodel = "second"}
	local v = reply["Device.IP.Interface.4.Stats"][1].param
	writeTableRow_statisticsAG(4, "oddrow", v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
end

writeTableRowTitle_statisticsAG(translate([==[PPPoE Bridged Statistics]==]))
%>
  <tr>
    <td colspan='5'  class="tableHd"><%=translate([==[Port]==])%></td>
    <td colspan='5'  class="tableHd"><%=translate([==[Packets Sent]==])%></td>
    <td colspan='5'  class="tableHd"><%=translate([==[Packets Received]==])%></td>
    <td colspan='5'  class="tableHd"><%=translate([==[Errors Sent]==])%></td>
    <td colspan='5'  class="tableHd"><%=translate([==[Errors Received]==])%></td>
  </tr> 
<%
local rowNum = 0
reply, error = mbus.getParameters{path = "Device.ATM.Link.1", param = {"Enable", "Status"}, datamodel = "second"}
if reply["Device.ATM.Link.1"][1].param["Enable"] == "true" and reply["Device.ATM.Link.1"][1].param["Status"] == "Up" then
  reply, error = mbus.getParameters{path = "Device.Bridging.Bridge.3.Port.7.Stats", datamodel = "second"}
  local v = reply["Device.Bridging.Bridge.3.Port.7.Stats"][1].param
  writeTableRow_statisticsAG(5, "oddrow", "PVC 8/35", v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
  rowNum = 1
end
if ptm_vdsl_status == "Up" then
  reply, error = mbus.getParameters{path = "Device.Bridging.Bridge.3.Port.8.Stats", datamodel = "second"}
  local v = reply["Device.Bridging.Bridge.3.Port.8.Stats"][1].param
  local rowStyle = "evenrow"
  if rowNum == 0 then
    rowStyle = "oddrow"
  end
  writeTableRow_statisticsAG(5, rowStyle, "PTM VDSL", v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
  rowNum = rowNum + 1
end
if wan_eth_status == "true" then
  reply, error = mbus.getParameters{path = "Device.Bridging.Bridge.3.Port.9.Stats", datamodel = "second"}
  local v = reply["Device.Bridging.Bridge.3.Port.9.Stats"][1].param
  local rowStyle = "oddrow"
  if rowNum == 1 then
    rowStyle = "evenrow"
  end
  writeTableRow_statisticsAG(5, rowStyle, translate([==[WAN Ethernet Interface]==]), v["PacketsSent"], v["PacketsReceived"], v["ErrorsSent"], v["ErrorsReceived"])
end
endBlock()

writeTableRowTitle_statisticsAG(translate([==[Remote control]==]))
writeTableRowHeader_Header(4, translate([==[Packets Sent]==]), translate([==[Packets Received]==]), translate([==[Error Packets Sent]==]), translate([==[Error Packets Received]==]))
writeTableRow_statisticsAG(4, "oddrow", ip_stats[1].packetsSent, ip_stats[1].packetsReceived, ip_stats[1].errorsSent, ip_stats[1].errorsReceived)
endBlock()

local serviceTypePath = "Device.DeviceInfo"
local serviceReply, serviceError = mbus.getParameters{ path = serviceTypePath, param = "X_TELECOMITALIA_IT_ServiceType", datamodel = "second"}
local serviceType = serviceReply[serviceTypePath][1].param["X_TELECOMITALIA_IT_ServiceType"]
if string.match(tostring(serviceType), "MIA")~=nil then
    writeTableRowTitle_statisticsAG(translate([==[Telephony Statistics]==]))
%>
  <tr>
    <td colspan='5' class="tableHd"><%=translate([==[Interface]==])%></td>
    <td colspan='5' class="tableHd"><%=translate([==[IncomingCallsAnswered]==])%></td>
    <td colspan='5' class="tableHd"><%=translate([==[IncomingCallsFailed]==])%></td>
    <td colspan='5' class="tableHd"><%=translate([==[OutgoingCallsAnswered]==])%></td>
    <td colspan='5' class="tableHd"><%=translate([==[OutgoingCallsFailed]==])%></td>
  </tr> 
<%
    local rowStyle = "oddrow"
    local rowNum = 0
    for i=1, 3 do
        rowNum = rowNum + 1
        if rowNum%2==1 then
          rowStyle = "oddrow"
        else
          rowStyle = "evenrow"
        end
        if i==1 or i==2 then
            writeTableRow_statisticsAG(5, rowStyle, "FXS"..i, voice[i].inAns, voice[i].inFail, voice[i].outAns, voice[i].outFail) 
        else
            writeTableRow_statisticsAG(5, rowStyle, "DECT", voice[i].inAns, voice[i].inFail, voice[i].outAns, voice[i].outFail) 
        end
    end
    endBlock()
end

reply, error = mbus.getParameters{ path = "TI_STORE.TiUserIntf", param = "LANOption" }
local lanOption = reply["TI_STORE.TiUserIntf"][1].param["LANOption"] or ""
local TI_Device = getTIInfo_Device()
local device_PPP = getDevice_PPP();
if (TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption =="res-rt-napt-ipv6" or TI_Device.lanOption == "biz-rt-napt-ipv6") and device_PPP.name== "User session" then 
  writeTableRowTitle_statisticsAG(translate([==[Data connection]==]))
  writeTableRowHeader_Header(4, translate([==[Packets Sent]==]), translate([==[Packets Received]==]), translate([==[Error Packets Sent]==]), translate([==[Error Packets Received]==]))
  writeTableRow_statisticsAG(4, "oddrow", ip_stats[2].packetsSent, ip_stats[2].packetsReceived, ip_stats[2].errorsSent, ip_stats[2].errorsReceived)
  endBlock()
end
%>

<br><form id="ResetForm1" method="POST" name="ResetForm1" action="">
<table cellspacing='0' cellpadding='0' width='100%' style="text-align:center" class="fontSize">
	<tr>	
		<td style="float:right;padding-right:10px;vertical-align:top">
		<a href="statisticsAG.lp" style="float:right;text-align:right">
		<div class="midarea6-1 mainButton"><%=translate([==[Update]==])%></div></a></td>
		<td style="width:215px;vertical-align:top">
		<a href="javascript:submitStatistics()">
		<div class="midarea7-1 mainButton" name="reset_traffic_button"><%=translate([==[Reset Statistics]==])%></div></a>
		<!-- <input type="submit" class='midarea6-2' value="<%=translate([==[Reset Statistics]==])%>" name="reset_traffic_button" /> --></td>
		<td  style="float:left;vertical-align:top">
		<a href="standard.lp">
		<div class="midarea6-1 secondaryButton"><%=translate([==[Back]==])%></div></a></td>
	</tr>
</table>
</form>

<% endPage() %>

</div>
</td></tr></table>
</div>
</div>
</div>
<script language="javascript">
function submitStatistics()
{
	document.ResetForm1.submit();
	}
</script>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>
