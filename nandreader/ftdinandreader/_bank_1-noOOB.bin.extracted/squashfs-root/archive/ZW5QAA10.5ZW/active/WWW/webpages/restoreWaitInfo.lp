<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<%
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/common.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/voip.lp")
cgilua.lp.include("lp/language.lp")
cgilua.lp.include("lp/xmlRestore.lp")
cgilua.lp.include("lp/mbus_util.lp")



local tprint = require("tableprint")
local translate = translate
local POST = cgilua.POST
local print = cgilua.print
local open = io.open
local fileDate= ""
local strfind = string.find
local strsub = string.sub
local strlen = string.len
local tinsert = table.insert
local strmatch = string.match
local fileName = cgilua.urlcode.unescape(cgilua.QUERY["fileName"])
if fileName == nil or fileName == "" then
  cgilua.redirect("tool.lp")
  return
end

local date = "%d%d%d%d%-%d%d%-%d%d"
local val = string.find(fileName,date)
if(val~=nil)then
 fileDate = string.sub(fileName, string.find(fileName,date))
end

local waitInfo_T = getWaitInfo()
if waitInfo_T["gatewayIpAddress"]==nil then
 cgilua.redirect("restoreKO.lp")
 return
end

local data, error = mbus.getParameters{path="Device.DeviceInfo", param={"Manufacturer"}, datamodel="second"}
local deviceSummary = data["Device.DeviceInfo"][1].param["Manufacturer"]

local deviceInfo, error_T = mbus.getParameters{path="Device.DeviceInfo", param={"ModelName"}, datamodel="second"}
local modelName = deviceInfo["Device.DeviceInfo"][1].param["ModelName"]

if waitInfo_T["Manufacturer"] == "X_TELECOMITALIA_IT_AGPLUSM4:1" then
    if deviceSummary ~= "X_TELECOMITALIA_IT_AGPLUSM4:1" then
        cgilua.redirect("restoreKO.lp")
        return
    end
elseif waitInfo_T["Manufacturer"] == "X_TELECOMITALIA_IT_AGPLUSM2:1" then
    if deviceSummary ~= "X_TELECOMITALIA_IT_AGPLUSM4:1" or deviceSummary ~= "X_TELECOMITALIA_IT_AGPLUSM2:1" then
        cgilua.redirect("restoreKO.lp")
        return
    end
elseif waitInfo_T["Manufacturer"] == "X_TELECOMITALIA_IT_AGPLUSM1:1" then
    if deviceSummary ~= "X_TELECOMITALIA_IT_AGPLUSM4:1" or deviceSummary ~= "X_TELECOMITALIA_IT_AGPLUSM2:1" or deviceSummary ~= "X_TELECOMITALIA_IT_AGPLUSM1:1" then
        cgilua.redirect("restoreKO.lp")
        return
    end
end

--Get all the application list for port mapping.
local appList = {}
local appPathStr  = "NATAppList.App"
local data, error = mbus.getParameters{path=appPathStr, param={"Name", "Category"}}
for i,v in pairs(data[appPathStr]) do
    table.insert(appList, {name=data[appPathStr][i].param["Name"], category=data[appPathStr][i].param["Category"]} )
end

--NAT Service Settings:
local natIpInitDefault, natIpFinalDefault = natRange(waitInfo_T["gatewayIpAddress"], waitInfo_T["subnetMask"])
local natService = translate([==[off]==])
if waitInfo_T["natService"]=="true" then
    natService = translate([==[Actived]==])
    if waitInfo_T["natIpInit"]=="0.0.0.0" or waitInfo_T["natIpFinal"]=="0.0.0.0" then
        waitInfo_T["natIpInit"] = natIpInitDefault
        waitInfo_T["natIpFinal"] = natIpFinalDefault        
    end
end

--To judge whether the ip is changed.
function isIpChanged()
    local ipInfo = getIPInfo()

    local ipAddr = ipInfo.ipaddress
    local ipMask = ipInfo.ipmask
    local dhcpIpBegin = ipInfo.beginip
    local dhcpIpEnd = ipInfo.endip

    if ipAddr ~= tostring(waitInfo_T["gatewayIpAddress"]) or ipMask ~= tostring(waitInfo_T["subnetMask"]) or dhcpIpBegin ~= tostring(waitInfo_T["dhcpIpInit"]) or dhcpIpEnd ~= tostring(waitInfo_T["dhcpIpFinal"]) then
        return true
    end

    return false
end

local round = 45 
local isLanChanged = isIpChanged()
if isLanChanged then
    round = 55 
end

local function convertMask(mask)
  return 2^8 - 2^(8 - mask)
end

--Begin of fixing CPE_P00102723
    local isDiffWanType = "false"
    local Path = "Device.ManagementServer"
    local reply, error = mbus.getParameters{ path = Path, param = "X_TELECOMITALIA_IT_ServiceRealm", datamodel = "second" }
    local realm = reply[Path][1].param["X_TELECOMITALIA_IT_ServiceRealm"]
    if realm~="alicenewborn.mgmt" then
      local AdslPath = "Device.ATM.Link.1"
      local replyAdsl, errorAdsl = mbus.getParameters{ path = AdslPath, param = "Enable", datamodel = "second" }
      local isAdsl = replyAdsl[AdslPath][1].param["Enable"]
      if isAdsl=="true" then
        if string.match(waitInfo_T["serviceProfile"], "ADSL")==nil then
          isDiffWanType = "true"
        end
      end
      local VdslPath = "Device.PTM.Link.1"
      local replyVdsl, errorVdsl = mbus.getParameters{ path = VdslPath, param = "Enable", datamodel = "second" }
      local isVdsl = replyVdsl[VdslPath][1].param["Enable"]
      if isVdsl=="true" then
        if string.match(waitInfo_T["serviceProfile"], "VDSL")==nil then
          isDiffWanType = "true"
        end
      end
      local EthPath = "Device.Ethernet.Interface.5"
      local replyEth, errorEth = mbus.getParameters{ path = EthPath, param = "Enable", datamodel = "second" }
      local isEth = replyEth[EthPath][1].param["Enable"]
      if isEth=="true" then
        if ((string.match(waitInfo_T["serviceProfile"], "ETH")==nil) and (string.match(waitInfo_T["serviceProfile"], "Fibra")==nil)) then
          isDiffWanType = "true"
        end
      end
    end

if POST["diffWanType"]=="1" then
    cgilua.redirect("restoreKO.lp")
    return
end
--End of fixing CPE_P00102723

--check the backup file if contain the Device.PPP.Interface.i.Name == "User session", if yes, return the has_user_session = "1"
local has_user_session = "0"
if waitInfo_T["pppUser1Name"] == "User session" or waitInfo_T["pppUser2Name"] == "User session" then
    has_user_session = "1"
end

local active_str = translate([==[Active]==])
local inactive_str = translate([==[Inactive]==])
local notactive_str = translate([==[Not active]==])
local disabled_str = translate([==[Disabled]==])

local function translate_enable(state)
  if state == "enabled" then
    return "Attivo"
  else
    return disabled_str
  end
end

local function translate_state(state)
  if state == "enabled" then
    return "Attivo"
  else
    return "Non attivo"
  end
end

%>

</head>
<script type="text/javascript">
function sajax_init_object() {
        var A;
        try {
                A=new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
                try {
                        A=new ActiveXObject("Microsoft.XMLHTTP");
                } catch (oc) {
                        A=null;
                }
        }
        if(!A && typeof XMLHttpRequest != "undefined")
                A = new XMLHttpRequest();
        return A;
}

//Submit the action of xml restore by ajax.
function submitOk(event)
{
    //Begin of fixing CPE_P00102723
    //check the provision WANType is same to the using WANType or not.
    var difWanType = "<%=isDiffWanType%>";
    if(difWanType=="true")
    {
        document.getElementById("diffWanType").value = "1";
        document.restore.submit();
    }
    else
    {
    //End of fixing CPE_P00102723
	    //display the process bar
        document.getElementById("waitInfo").style.display="none";
        document.getElementById("waitInfo").style.visibility="hidden";
        document.getElementById("processBar").style.display="block";
        document.getElementById("processBar").style.visibility="visible";
        coolRedirect("http://<%=waitInfo_T["gatewayIpAddress"]%>/index.lp?subpage=restoreOK.lp",1);

        var urlStr = "/restoreMod.lp?filename=<%=cgilua.urlcode.escape(fileName)%>";
        var param = "physUpdateFlag=<%=isLanChanged%>&natIpInit=<%=natIpInitDefault%>&natIpFinal=<%=natIpFinalDefault%>";
        var xobj = sajax_init_object();
        urlStr = urlStr + "?" + param;
            xobj.open('GET',urlStr,true);
            xobj.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xobj.setRequestHeader("Connection", "close");
            xobj.send("");
    }
}
</script>
<body>

<div class="contentContainer">
	 	<table cellspacing='0' cellpadding='0' width="100%">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="tool.lp"><%=translate([==[Tools]==])%></a></li>
			</ul>
		</div>	</table>

<div class='contentcontainer'>
<div class='contentitem'>
<div id="waitInfo">
<form id="restore" name="restore" method="post" action="">
<input type="hidden" id="diffWanType" name="diffWanType" value="0" />
  <table cellspacing='0' cellpadding='0' width="100%" style="word-break:break-all; word-wrap:break-word;"><tr>
    <td class='icon' style='vertical-align:top' width='50px'><img src='images/maxx__xl.png' alt='Technicolor Gateway'></td>
    <td class='data' style='vertical-align:top'>
      <table cellspacing='0' cellpadding='0' width="100%"><tr><td>
        <table cellspacing='0' cellpadding='0' width='100%'>
          <tr><td>
		  <table cellspacing='0' cellpadding='0' width='100%'>
          <tr><td class="midareainfo" style='vertical-align:top'>
            Info</td></tr></table><br>
            <table width='100%' cellspacing='0' cellpadding='0' style="font-size:1em; font-weight:normal;border:1px solid #CACACA;margin:-10px 0px 0px 0px;">
              <tr><td class="trScura tableTitle"><%=translate([==[Restore modem configuration]==])%></td></tr>
              <tr><td class="tdBiancaC fontSize" style="text-align:left; font-weight:normal;width:100%;">
                <p align="center"><%=translate([==[Warning: The backup file selected by name]==])%> 
                <font color="#0000FF">&quot;<%=fileName%>&quot;</font> <%if fileDate~="" then%><%=translate([==[generated on]==])%> <%end%>
               
                <%if fileDate~="" then%><font color="#0000FF">&quot;<%=fileDate%>&quot; </font> <%end%><br/><%=translate([==[contains the following information to restore:]==])%></p>
                <p align="center">
                <span style="font-weight: 400">#################################################################</span>
                </p>
<%
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRow(translate([==[Backup file]==]), fileName)
writeSectionRow(translate([==[Apparatus]==]), waitInfo_T["apparatus"])
if waitInfo_T["serviceProfile"] ~= "" then
    writeSectionRow(translate([==[Profile]==]), waitInfo_T["serviceProfile"])
end
endBlock_restore()

writeBlockTitle_restoreHeader("Configurazione LAN")
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Configurazione IP del modem")
writeSectionRow(translate([==[Gateway IP Address]==]), waitInfo_T["gatewayIpAddress"])
writeSectionRow("Maschera di Sottorete", waitInfo_T["subnetMask"])
endBlock_restore()

local dhcpState = "Non Attiva"
if waitInfo_T["dhcpService"]=="true" then
    dhcpState = "Attiva"
end
              
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Configurazione DHCP")
writeSectionRow(translate([==[Setting up DHCP service]==]), dhcpState)
writeSectionRow(translate([==[start IP]==]), waitInfo_T["dhcpIpInit"])
writeSectionRow(translate([==[end IP]==]),   waitInfo_T["dhcpIpFinal"])
endBlock_restore()
              
local natState = "Non Attiva"
if waitInfo_T["natService"]=="true" then
    natState = "Attiva"
end

if has_user_session == "1" then
    writeBlockNoTitle_restoreWithoutHeader()
    writeSectionRowHeader("Configurazione NAT")
    writeSectionRow(translate([==[Impostazione servizio NAPT]==]), natState)
    writeSectionRow(translate([==[start IP]==]), waitInfo_T["natIpInit"])
    writeSectionRow(translate([==[Indirizzo IP finale]==]), waitInfo_T["natIpFinal"])
    endBlock_restore()
end

if waitInfo_T["passwordSetting"] == "true" then

    writeBlockNoTitle_restoreWithoutHeader()
    writeSectionRowHeader("Configurazione Password")
    writeSectionRow(translate([==[Setting password]==]), active_str)
    writeSectionRow(translate([==[Password]==]), waitInfo_T["passwordValue"])
    endBlock_restore()
end

--Setting Firewall:
local firewallSetting = "Disattivato"
if waitInfo_T["firewallSetting"]=="Low" then
    firewallSetting = translate([==[Actived]==])
end

if has_user_session == "1" then
    writeBlockNoTitle_restoreWithoutHeader()
    writeSectionRowHeader("Configurazione del firewall")
    writeSectionRow(translate([==[Impostazione Firewall]==]), firewallSetting)
    endBlock_restore()
end

--Setting IP pre-assignment:
local isDisplayIPTitle = "false"
for l,m in pairs(waitInfo_T["StaticAddress"]) do
    if m["preEnable"]=="true" then
        isDisplayIPTitle = "true"
    end
end

if isDisplayIPTitle=="true" then
    writeBlockTitle_WaitInfoHeader("Impostazioni IP prenotati")
    --endBlock_restore()
    writeBlock_RestoreWithoutHeader()
    writeTableBlockHeaderRestore_new(3, translate([==[MAC address]==]), translate([==[IP]==]), translate([==[Host Name]==]))

    local preIpMac, preIpAddress, hostName
    for i,v in pairs(waitInfo_T["StaticAddress"]) do
        if v["preEnable"]=="true" then
            preIpMac = v["preAllocatedMacAddress"]
            preIpAddress = v["preAllocatedIp"]
            for j,k in pairs(waitInfo_T["Host"]) do
                local macAddr = k["wifiMacAddress"]
                if macAddr~=nil then
                    if string.match(preIpMac, macAddr)~=nil then
                        hostName = k["hostName"]                
                    end
                end
            end
            local rowStyle = "oddrow"
            if i%2==1 then
                rowStyle = "oddrow"
            else
                rowStyle = "evenrow"
            end
            writeTableBlockRowRestore_new(3, rowStyle, preIpMac, preIpAddress, hostName)
        end
    end
    endBlock_restore()
end

--Setting portMapping
local AppPath  = "NATAppList.App"
local isPrintTitle = 0
for j,t in pairs(waitInfo_T["PortMapping"]) do
    local replyPortMapping, error = mbus.getParameters{path=AppPath, param="Name"}
    local natDescription, natIp, natStato, natIntPort, natExtPort, natProtocol
    for u,w in pairs(replyPortMapping[AppPath]) do
        if t["portMappingDescription"]==w.param["Name"] then
            if isPrintTitle==0 then
				writeBlockNoTitle_restoreWithoutHeader()
				writeSectionRowHeader("Configurazione protocollo internet voci")
                writeSectionRow(translate([==[Impostazioni Virtual Server per protocolli Internet]==]), "")
                endBlock_restore()
                writeBlock_RestoreWithoutHeader()
                writeTableBlockHeaderRestore_new(3, translate([==[Applicazione]==]), "IP", "Stato")
                isPrintTitle = 1
            end
            natDescription = t["portMappingDescription"]
            natIp = t["hostAddress"]
            natStato = t["portMappingEnabled"]
            if natStato=="true" then
                natStato = "Attivo"
            else
                natStato = "Non Attivo"
            end
            local rowStyle = "oddrow"
            if u%2==1 then
                rowStyle = "oddrow"
            else
                rowStyle = "evenrow"
            end 
            writeTableBlockRowRestore_new(3, rowStyle, natDescription, natIp, natStato)
        end
    end
end

isPrintTitle = 0
for i,v in pairs(waitInfo_T["PortMapping"]) do
    local portFlag = false
    local replyPortMapping, error = mbus.getParameters{path=AppPath, param="Name"}
    local natDescription, natIp, natStato, natIntPort, natExtPort, natProtocol
    for u,w in pairs(replyPortMapping[AppPath]) do
        if v["portMappingDescription"]==w.param["Name"] then
            portFlag = true
            break
        end
    end
    if portFlag==false then
        if isPrintTitle==0 then
		
			writeBlockNoTitle_restoreWithoutHeader()
			writeSectionRow_WaitInfoHeader("Configurazione di voci personalizzate")
            writeSectionRow(translate([==[Impostazioni altri Virtual Server]==]), "")
            endBlock_restore()
            writeBlockNoTitle_restoreWithoutHeader()
            writeTableBlockHeaderRestore_BR(6, translate([==[Name]==]), "IP", "Porta Int", "Porta Est", "Protocollo", "Stato")
            isPrintTitle = 1
        end
        natDescription = v["portMappingDescription"]
        natIp = v["hostAddress"]
        natStato = v["portMappingEnabled"]
        if natStato=="true" then
            natStato = "Attivo"
        else
            natStato = "Non Attivo"
        end
        natIntPort = v["internalPort"]
        natExtPort = v["externalPort"]
        natProtocol = v["portMappingProtocol"]
        local rowStyle = "oddrow"
        if i%2==1 then
            rowStyle = "oddrow"
        else
            rowStyle = "evenrow"
        end
        writeTableBlockRowRestore_BR(6, rowStyle, natDescription, natIp, natIntPort, natExtPort, natProtocol, natStato)
    end
end

--Setting wifi params
local ssid = waitInfo_T["wifiSsid"]
local modeEnable2 = waitInfo_T["wifiBeaconType"]

--Wireless Network Setup: encryption method and key
local wifiEncryptionMethod = translate([==[No]==])
if modeEnable2~="None" then
    if modeEnable2=="WEP-128" then
        wifiEncryptionMethod = "WEP"
    elseif modeEnable2=="WPA-Personal" then
        wifiEncryptionMethod = "WPA-PSK TKIP"
    elseif modeEnable2=="WPA2-Personal" then
        wifiEncryptionMethod = "WPA-PSK AES"
    elseif modeEnable2=="WPA-WPA2-Personal" then
        wifiEncryptionMethod = "WPA-PSK TKIP-AES"
    end
end

local wifiState2 = "Non Attiva"
if waitInfo_T["wifiRadioEnable"]=="true" then
    wifiState2 = "Attiva"
end

local channel2 = waitInfo_T["wifiChannel"] .. "(Manuale)"
if waitInfo_T["wifiAutoChannel"]=="true" then
    channel2 = "Automatico"
end

local accessCon = "Disabilitato"
if waitInfo_T["wifiAccessControl"]=="true" then
    accessCon = "Abilitato"
end

local wepKey2 = waitInfo_T["wifiWEPKey"]
local keyPass2 = waitInfo_T["wifiKeyPassphrase"]
local BandWidth2 = waitInfo_T["wifiRadio1OperatingChannelBandwidth"]
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Impostazione rete Wireless 2.4 GHz")
writeSectionRow(translate([==[Stato Interfaccia Wi-Fi]==]), wifiState2)
writeSectionRow(translate([==[Wi-Fi network (SSID)]==]), ssid)
writeSectionRow(translate([==[Channel]==]), channel2)
writeSectionRow(translate([==[Bandwidth]==]), BandWidth2)
writeSectionRow(translate([==[Access control]==]), accessCon)
writeSectionRow(translate([==[Methods of encryption]==]), wifiEncryptionMethod)
writeSectionRow(translate([==[Chiave di cifratura]==]).." WEP", wepKey2)
writeSectionRow(translate([==[Chiave di cifratura]==]).." WPA", keyPass2)
endBlock_restore()

function macStr2Table(mac_str)
  if type(mac_str) ~= "string" then
     return nil 
   end 
  local mac_T = {}
  string.gsub(mac_str, "(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)",
        function(s)
          table.insert(mac_T, s)
          return s 
        end)
  return mac_T
end

local wifiAlMac = waitInfo_T["wifiAllowMac"]
local wifiAllowMacAddr = macStr2Table(wifiAlMac)
--add the host of wifi2.4G
if accessCon=="Abilitato" then
    writeBlockNoTitle_conWithoutHeader()
    writeSectionRow(translate([==[Authorized terminals]==]), "")
    endBlock_restore()
    writeBlock_RestoreWithoutHeader()
    writeTableBlockHeaderRestore_new(3, translate([==[MAC address]==]), "IP", translate([==[Host Name]==]))
    local wifiIpAddress, wifiHostName
    for a,wifiMac in pairs(wifiAllowMacAddr) do
        for i,v in pairs(waitInfo_T["Host"]) do
            local rowStyle = "oddrow"
            if i%2==1 then
                rowStyle = "oddrow"
            else
                rowStyle = "evenrow"
            end
            if v["wifiMacAddress"]==wifiMac then
                wifiIpAddress = v["wifiIp"]
                wifiHostName = v["hostName"]
                writeTableBlockRowRestore_new(3, rowStyle, wifiMac, wifiIpAddress, wifiHostName)
                break
            else
                writeTableBlockRowRestore_new(3, rowStyle, wifiMac, "", "")
                break
            end
        end
    end
    endBlock_restore()
end

local ssid5 = waitInfo_T["wifi5Ssid"]
local modeEnable5 = waitInfo_T["wifi5BeaconType"]

local wifi5EncryptionMethod = translate([==[No]==])
if modeEnable5~="None" then
    if modeEnable5=="WEP-128" then
        wifi5EncryptionMethod = "WEP"
    elseif modeEnable5=="WPA-Personal" then
        wifi5EncryptionMethod = "WPA-PSK TKIP"
    elseif modeEnable5=="WPA2-Personal" then
        wifi5EncryptionMethod = "WPA-PSK AES"
    elseif modeEnable5=="WPA-WPA2-Personal" then
        wifi5EncryptionMethod = "WPA-PSK TKIP-AES"
    end
end

local wifiState5 = "Non Attiva"
if waitInfo_T["wifi5RadioEnable"]=="true" then
    wifiState5 = "Attiva"
end

local channel5 = waitInfo_T["wifi5Channel"] .. "(Manuale)"
if waitInfo_T["wifi5AutoChannel"]=="true" then
    channel5 = "Automatico"
end

local accessCon5 = "Disabilitato"
if waitInfo_T["wifi5AccessControl"]=="true" then
    accessCon5 = "Abilitato"
end

local wepKey5 = waitInfo_T["wifi5WEPKey"]
local keyPass5 = waitInfo_T["wifi5KeyPassphrase"]
local BandWidth5 = waitInfo_T["wifiRadio2OperatingChannelBandwidth"]

writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Impostazione rete Wireless 5 GHz")
writeSectionRow(translate([==[Stato Interfaccia Wi-Fi]==]), wifiState5)
writeSectionRow(translate([==[Wi-Fi network (SSID)]==]), ssid5)
writeSectionRow(translate([==[Channel]==]), channel5)
writeSectionRow(translate([==[Bandwidth]==]), BandWidth5)
writeSectionRow(translate([==[Access control]==]), accessCon5)
writeSectionRow(translate([==[Methods of encryption]==]), wifi5EncryptionMethod)
writeSectionRow(translate([==[Chiave di cifratura]==]).." WPA", keyPass5)
endBlock_restore()
--add the host of wifi5G
local wifi5AlMac = waitInfo_T["wifi5AllowMac"]
local wifi5AllowMacAddr = macStr2Table(wifi5AlMac)
if accessCon5=="Abilitato" then
    writeBlockNoTitle_conWithoutHeader()
    writeSectionRow(translate([==[Authorized terminals]==]), "")
    endBlock_restore()
    writeBlock_RestoreWithoutHeader()
    writeTableBlockHeaderRestore_new(3, translate([==[MAC address]==]), "IP", translate([==[Host Name]==]))
    local wifi5IpAddress, wifi5HostName
    for a,wifi5Mac in pairs(wifi5AllowMacAddr) do
        for i,v in pairs(waitInfo_T["Host"]) do
            local rowStyle = "oddrow"
            if i%2==1 then
                rowStyle = "oddrow"
            else
                rowStyle = "evenrow"
            end
            if v["wifiMacAddress"]==wifi5Mac then
                wifi5IpAddress = v["wifiIp"]
                wifi5HostName = v["hostName"]
                writeTableBlockRowRestore_new(3, rowStyle, wifi5Mac, wifi5IpAddress, wifi5HostName)
                break
            else
                writeTableBlockRowRestore_new(3, rowStyle, wifi5Mac, "", "")
                break
            end
        end
    end
    endBlock_restore()
end

local ssidGuest = waitInfo_T["wifiGuestSsid"]
local modeEnableGuest2 = waitInfo_T["wifiGuestBeaconType"]

--Wireless Network Setup: encryption method and key
local wifiGuestEncryptionMethod = translate([==[No]==])
if modeEnableGuest2~="None" then
    if modeEnableGuest2=="WEP-128" then
        wifiGuestEncryptionMethod = "WEP"
    elseif modeEnableGuest2=="WPA-Personal" then
        wifiGuestEncryptionMethod = "WPA-PSK TKIP"
    elseif modeEnableGuest2=="WPA2-Personal" then
        wifiGuestEncryptionMethod = "WPA-PSK AES"
    elseif modeEnableGuest2=="WPA-WPA2-Personal" then
        wifiGuestEncryptionMethod = "WPA-PSK TKIP-AES"
    end
end

local wifiStateGuest2 = "Non Attiva"
if waitInfo_T["wifiGuestAccEnable"]=="true" then
    wifiStateGuest2 = "Attiva"
end

local accessGuestCon = "Disabilitato"
if waitInfo_T["wifiGuestAccessControl"]=="true" then
    accessGuestCon = "Abilitato"
end

local wepKeyGuest2 = waitInfo_T["wifiGuestWEPKey"]
local keyPassGuest2 = waitInfo_T["wifiGuestKeyPassphrase"]

writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Impostazione rete Wireless Ospiti 2.4 GHz")
writeSectionRow(translate([==[Stato Interfaccia Wi-Fi]==]), wifiStateGuest2)
writeSectionRow(translate([==[Wi-Fi network (SSID)]==]), ssidGuest)
writeSectionRow(translate([==[Access control]==]), accessGuestCon)
writeSectionRow(translate([==[Methods of encryption]==]), wifiGuestEncryptionMethod)
writeSectionRow(translate([==[Chiave di cifratura]==]).." WEP", wepKeyGuest2)
writeSectionRow(translate([==[Chiave di cifratura]==]).." WPA", keyPassGuest2)
endBlock_restore()
--add the host of wifi guest 2.4G
local wifiGuestAlMac = waitInfo_T["wifiGuestAllowMac"]
local wifiGuestAllowMacAddr = macStr2Table(wifiGuestAlMac)
if accessGuestCon=="Abilitato" then
    writeBlockNoTitle_conWithoutHeader()
    writeSectionRow(translate([==[Authorized terminals]==]), "")
    endBlock_restore()
    writeBlock_RestoreWithoutHeader()
    writeTableBlockHeaderRestore_new(3, translate([==[MAC address]==]), "IP", translate([==[Host Name]==]))
    local wifiGuestIpAddress, wifiGuestHostName
    for a,wifiGuestMac in pairs(wifiGuestAllowMacAddr) do
        for i,v in pairs(waitInfo_T["Host"]) do
            local rowStyle = "oddrow"
            if i%2==1 then
                rowStyle = "oddrow"
            else
                rowStyle = "evenrow"
            end
            if v["wifiMacAddress"]==wifiGuestMac then
                wifiGuestIpAddress = v["wifiIp"]
                wifiGuestHostName = v["hostName"]
                writeTableBlockRowRestore_new(3, rowStyle, wifiGuestMac, wifiGuestIpAddress, wifiGuestHostName)
                break
            else
                writeTableBlockRowRestore_new(3, rowStyle, wifiGuestMac, "", "")
                break
            end
        end
    end
    endBlock_restore()
end

local ssidGuest5 = waitInfo_T["wifiGuest5Ssid"]
local modeEnableGuest5 = waitInfo_T["wifiGuest5BeaconType"]

--Wireless Network Setup: encryption method and key
local wifiGuest5EncryptionMethod = translate([==[No]==])
if modeEnableGuest5~="None" then
    if modeEnableGuest5=="WEP-128" then
        wifiGuest5EncryptionMethod = "WEP"
    elseif modeEnableGuest5=="WPA-Personal" then
        wifiGuest5EncryptionMethod = "WPA-PSK TKIP"
    elseif modeEnableGuest5=="WPA2-Personal" then
        wifiGuest5EncryptionMethod = "WPA-PSK AES"
    elseif modeEnableGuest5=="WPA-WPA2-Personal" then
        wifiGuest5EncryptionMethod = "WPA-PSK TKIP-AES"
    end
end

local wifiStateGuest5 = "Non Attiva"
if waitInfo_T["wifiGuest5AccEnable"]=="true" then
    wifiStateGuest5 = "Attiva"
end

local accessGuest5Con = "Disabilitato"
if waitInfo_T["wifiGuest5AccessControl"]=="true" then
    accessGuest5Con = "Abilitato"
end

local wepKeyGuest5 = waitInfo_T["wifiGuest5WEPKey"]
local keyPassGuest5 = waitInfo_T["wifiGuest5KeyPassphrase"]

writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Impostazione rete Wireless Ospiti 5 GHz")
writeSectionRow(translate([==[Stato Interfaccia Wi-Fi]==]), wifiStateGuest5)
writeSectionRow(translate([==[Wi-Fi network (SSID)]==]), ssidGuest5)
writeSectionRow(translate([==[Access control]==]), accessGuest5Con)
writeSectionRow(translate([==[Methods of encryption]==]), wifiGuest5EncryptionMethod)
writeSectionRow(translate([==[Chiave di cifratura]==]).." WPA", keyPassGuest5)
endBlock_restore()
--add the host of wifi guest 5G
local wifiGuest5AlMac = waitInfo_T["wifiGuest5AllowMac"]
local wifiGuest5AllowMacAddr = macStr2Table(wifiGuest5AlMac)
if accessGuest5Con=="Abilitato" then
    writeBlockNoTitle_conWithoutHeader()
    writeSectionRow(translate([==[Authorized terminals]==]), "")
    endBlock_restore()
    writeBlock_RestoreWithoutHeader()
    writeTableBlockHeaderRestore_new(3, translate([==[MAC address]==]), "IP", translate([==[Host Name]==]))
    local wifiGuest5IpAddress, wifiGuest5HostName
    for a,wifiGuest5Mac in pairs(wifiGuest5AllowMacAddr) do
        for i,v in pairs(waitInfo_T["Host"]) do
            local rowStyle = "oddrow"
            if i%2==1 then
                rowStyle = "oddrow"
            else
                rowStyle = "evenrow"
            end
            if v["wifiMacAddress"]==wifiGuest5Mac then
                wifiGuest5IpAddress = v["wifiIp"]
                wifiGuest5HostName = v["hostName"]
                writeTableBlockRowRestore_new(3, rowStyle, wifiGuest5Mac, wifiGuest5IpAddress, wifiGuest5HostName)
                break
            else
                writeTableBlockRowRestore_new(3, rowStyle, wifiGuest5Mac, "", "")
                break
            end
        end
    end
    endBlock_restore()
end

--Setting USB
local usbStato, printStato = "Non attivo", "Non attivo"
if waitInfo_T["usbService"]=="Both" then
    usbStato = "Attivo"
    printStato = "Attivo"
elseif waitInfo_T["usbService"]=="FileSharing" then
    usbStato = "Attivo"
elseif waitInfo_T["usbService"]=="PrintSharing" then
    printStato = "Attivo"
end

writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Configurazione del servizio USB")
writeSectionRow(translate([==[Service Remote Disc]==]), usbStato)
writeSectionRow(translate([==[Servizio Print Sharing]==]), printStato)
endBlock_restore()

--Setting urlFilter
if has_user_session == "1" then
    local urlEnable = "Non attivo"
    if waitInfo_T["urlEnable"]=="true" then
        urlEnable = "Attivo"
    end
    local url = waitInfo_T["urlFilterUrls"]
    local block = "Non attivo"
    if waitInfo_T["urlexcludeEnable"]=="true" then
        block = "Attivo"
    end
    writeBlockNoTitle_restoreWithoutHeader()
    writeSectionRowHeader("Configurazione del servizio URL filtering")
    writeSectionRow(translate([==[Blocco URL]==]), urlEnable)
    writeSectionRow(translate([==[Blocked URL]==]), url)
    writeSectionRow(translate([==[Inversione blocco]==]), block)
    endBlock_restore()
end

-- Dynamic DNS Configuration
if has_user_session == "1" then
    local dynPro, dynDom, dynUser, dynPwd, dynDNSEnable
    local dynEnable = "Non attivo"
    -- writeBlockTitle_WaitInfoHeader("DNS Dinamici")
	writeBlockNoTitle_restoreWithoutHeader()
	writeSectionRowHeader("Configurazione DNS dinamici")
	writeSectionRow(translate([==[DNS Dinamici]==]), "")
	endBlock_restore()
	
    writeBlockNoTitle_restoreWithoutHeader()
	%>
    	
		  <tr> 

    <td class="midarea2 tableTitle" style="width:140px;"><%=translate([==[Fornitore del servizio]==])%></td>
	<td class="midarea2 tableTitle" style="width:135px;">Dominio registrato</td> 
	<td class="midarea2 tableTitle width90px">Username</td>
	<td class="midarea2 tableTitle width90px">Password</td>
	<td class="midarea2 tableTitle width90px"><%=translate([==[State]==])%></td>

  </tr>  
	
	<%
    for i,v in pairs(waitInfo_T["X_TELECOMITALIA_IT_DynamicDNS"]) do
        dynPro = v["dynProvider"]
        dynDom = v["dynDomain"]
        dynUser = v["dynUsername"]
        dynPwd = v["dynPassword"]
        dynDNSEnable = v["dynEnable"]
        if dynDNSEnable=="true" then
            dynEnable = "Attivo"
        end
        local rowStyle = "oddrow"
        if i%2==1 then
            rowStyle = "oddrow"
        else
            rowStyle = "evenrow"
        end
		
		%>
    	
		  <tr> 

    <td class="<%=rowStyle%> midarea2" style="width:140px;"><%=dynPro%></td>
	<td class="<%=rowStyle%> midarea2" style="width:135px;"><%=dynDom%></td> 
	<td class="<%=rowStyle%> midarea2 width90px"><%=dynUser%></td>
	<td class="<%=rowStyle%> midarea2 width90px"><%=dynPwd%></td>
	<td class="<%=rowStyle%> midarea2 width90px"><%=dynEnable%></td>

  </tr>  
	
	<%
        
    end

    endBlock_restore()
end
--Setting Remote access configuration
local rmdata, error = mbus.getParameters{path="Device.UserInterface.RemoteAccess", datamodel="second"}
local status = "Non attivo"
if rmdata["Device.UserInterface.RemoteAccess"][1].param["Enable"] == "true" then
	status = "Attivo"
end
local protocal = rmdata["Device.UserInterface.RemoteAccess"][1].param["Protocol"]
local port = rmdata["Device.UserInterface.RemoteAccess"][1].param["Port"]
local rmdata, error = mbus.getParameters{path="Device.Users.User.1", datamodel="second"}
local uname = rmdata["Device.Users.User.1"][1].param["Username"]
local upassword = rmdata["Device.Users.User.1"][1].param["Password"]
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Configurazione accesso remoto")
writeSectionRow("Stato", status)
writeSectionRow("Protocollo", protocal)
writeSectionRow("Porta", port)
writeSectionRow(translate([==[Username]==]), uname)
writeSectionRow(translate([==[Password]==]), upassword)
endBlock_restore()

--Setting media
local mediaActive = "Non attivo"
if waitInfo_T["upnpMedia"]=="true" then
    mediaActive = "Attivo"
end
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Configurazione del media server UPnP")
writeSectionRow(translate([==[Media Server]==]), mediaActive)
endBlock_restore()

--Setting telephony
local uaPath, pstnIn, pstnOut, posCon
local incomingCall, outgoingCall = "-", "-"
local fxsLine1 = "Device.Services.VoiceService.1.PhyInterface.1"
local fxsLine2 = "Device.Services.VoiceService.1.PhyInterface.2"
local dectLine1 = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset.1"
local dectLine2 = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset.2"
local dectLine3 = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset.3"
local dectLine4 = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset.4"

function getIncomingCallList(linePath)
    local lineNumberAll, lineNumber, fromua
    for j,w in pairs(waitInfo_T["X_TELECOMITALIA_IT_UAMap"]) do
        if w["toVP"]==linePath then
            fromua = w["fromUA"]
            if fromua~=nil then
                lineNumber = getCallNum(fromua)
            else
                lineNumber = "-"
            end
        end
        if lineNumber~="-" then
            if lineNumberAll==nil then
                lineNumberAll = lineNumber
            else
                lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)
            end
        else
            lineNumberAll = "-"
        end
    end
    return lineNumberAll
end
function getOutgoingCallList(linePath)
    local lineNumberAll, lineNumber, toua
    for j,w in pairs(waitInfo_T["X_TELECOMITALIA_IT_VoicePortMap"]) do
        if w["fromVP"]==linePath then
            toua = w["toUA"]
            if toua~=nil then
                lineNumber = getCallNum(toua)
            else
                lineNumber = "-"
            end
        end
        if lineNumber~="-" then
            if lineNumberAll==nil then
                lineNumberAll = lineNumber
            else
                lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)
            end
        else
            lineNumberAll = "-"
        end
    end
    return lineNumberAll
end

local fxoNumber = waitInfo_T["fxonumber"]
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRowHeader("Configurazione Servizi di Telefonia")
--writeSectionRow(translate([==[Servizi di Telefonia]==]), "")
local replyfb, errorfb = mbus.getParameters{path = "Device.Services.VoiceService.1.VoiceProfile.1", param = "Enable", datamodel = "second" }
local fbEnable= replyfb["Device.Services.VoiceService.1.VoiceProfile.1"][1].param["Enable"]
if fbEnable == "Enabled" then
	writeSectionRow(translate([==[Fallback su PSTN]==]), "Attivo")
else
	writeSectionRow(translate([==[Fallback su PSTN]==]), "Non attivo")
end
endBlock_restore()
writeBlockNoTitle_restoreContentTable()
--writeTableBlockHeader_restore(6, translate([==[connection]==]), translate([==[Number of input]==]), translate([==[Number of outgoing]==]), "PSTNIN", "PSTNOUT", "POSConfig")
writeTableBlockHeader_restore(3, translate([==[connection]==]), translate([==[Extension ]==]).." "..translate([==[Number]==]), translate([==[Associated Number]==]))
local connectionList = { "FXS1", "FXS2", "DECT1", "DECT2", "DECT3", "DECT4"}
local profilePath = "Device.Services.VoiceService.3.VoiceProfile.1.Line.1"
local rowStyle = "oddrow"
--[[local rowNum = 0
for i,v in pairs(connectionList) do
    rowNum = rowNum + 1
    if rowNum%2==1 then
        rowStyle = "oddrow"
    else
        rowStyle = "evenrow"
    end
	local inOutCall = getAllInOutCallNum(profilePath)
	if inOutCall ~= nil and inOutCall ~= "" then
			local inOutCallArray = split(inOutCall,"##")					
			incomingCall = inOutCallArray[1]			
			outgoingCall = inOutCallArray[2]
	end
    local connectType = tostring(v)
    if tostring(v)=="FXS1" then
        uaPath = fxsLine1
     --   incomingCall = getIncomingCallList(uaPath)
     --   outgoingCall = getOutgoingCallList(uaPath)		
        pstnIn = waitInfo_T["pstnin1"]
        pstnOut = waitInfo_T["pstnout1"]
        posCon = waitInfo_T["pos1"]
    end
    if tostring(v)=="FXS2" then
        uaPath = fxsLine2
     --  incomingCall = getIncomingCallList(uaPath)
     --  outgoingCall = getOutgoingCallList(uaPath)	   
        pstnIn = waitInfo_T["pstnin2"]
        pstnOut = waitInfo_T["pstnout2"]
        posCon = waitInfo_T["pos2"]
    end
    if tostring(v)=="DECT1" then
        uaPath = dectLine1
     -- incomingCall = getIncomingCallList(uaPath)
     -- outgoingCall = getOutgoingCallList(uaPath)
        pstnIn = waitInfo_T["pstnin3"]
        pstnOut = waitInfo_T["pstnout3"]
        posCon = waitInfo_T["pos3"]
    end
    if tostring(v)=="DECT2" then
        uaPath = dectLine2
     -- incomingCall = getIncomingCallList(uaPath)
     -- outgoingCall = getOutgoingCallList(uaPath)
        pstnIn = waitInfo_T["pstnin3"]
        pstnOut = waitInfo_T["pstnout3"]
        posCon = waitInfo_T["pos3"]
    end
    if tostring(v)=="DECT3" then
        uaPath = dectLine3
     -- incomingCall = getIncomingCallList(uaPath)
     -- outgoingCall = getOutgoingCallList(uaPath)
        pstnIn = waitInfo_T["pstnin3"]
        pstnOut = waitInfo_T["pstnout3"]
        posCon = waitInfo_T["pos3"]
    end
    if tostring(v)=="DECT4" then
        uaPath = dectLine4
     -- incomingCall = getIncomingCallList(uaPath)
     -- outgoingCall = getOutgoingCallList(uaPath)
        pstnIn = waitInfo_T["pstnin3"]
        pstnOut = waitInfo_T["pstnout3"]
        posCon = waitInfo_T["pos3"]
    end
	writeTableBlockRow_restore(6, rowStyle, connectType, incomingCall, outgoingCall, pstnIn, pstnOut, posCon)
	end]]--
	local phoneType
	local FXSIndex = 1
	local phyIntf_T = getConnectionInfo()
	for i=1, #phyIntf_T do
		local v = phyIntf_T[i]
		if(v.name ~= nil)then
			phoneType = v.name
		end
		if string.find(tostring(phoneType),"FXS") ~= nil then 
			phoneType = "FXS" .. tostring(i)		 
			local incomingCallNum = "-"
			local switchPath = "Device.Services.VoiceService.1.PhyInterface."..tostring(i)
			local inOutCall = getAllInOutCallNum1(FXSIndex)
			if(FXSIndex<12)then
					FXSIndex = FXSIndex+11
			end
			if inOutCall ~= nil and inOutCall ~= "" then
				local inOutCallArray = split(inOutCall,"##")					
				incomingCallNum = inOutCallArray[1]
				if(incomingCallNum == "" or incomingCallNum == nil)then
					incomingCallNum = "-"						
				end					 
			end
			writeTableBlockRow_restore(3, rowStyle, phoneType, v.val, incomingCallNum)
			if rowStyle == "oddrow" then
				rowStyle = "evenrow"
			else
				rowStyle = "oddrow"
			end
		elseif phoneType=="DECT" then
			local index = 13
			for j=1,5 do
				phoneType = "DECT" .. tostring(j)
				local incomingCallNum = "-"
				local inOutCall = getAllInOutCallNum1(index)
				local dectNumber
				if(phyIntf_T[(2+j)] ~= nil) then  
				if(phyIntf_T[(2+j)].linename == "FXO") then
					if(phyIntf_T[(3+j)] ~= nil) then
					dectNumber = phyIntf_T[(3+j)].val
					end
				else
					dectNumber = phyIntf_T[(2+j)].val
				end	
				end
				index=index+1
				if inOutCall ~= nil and inOutCall ~= "" then
					local inOutCallArray = split(inOutCall,"##")			
				end	
				writeTableBlockRow_restore(3, rowStyle, phoneType, dectNumber, incomingCallNum)
				if rowStyle == "oddrow" then
					rowStyle = "evenrow"
				else
					rowStyle = "oddrow"
				end
			end			
		end		
	end
	local phyIntf_IP = getIPConnectionInfo()
	if #phyIntf_IP > 0 then
		local phoneIPType
		for i=1, #phyIntf_IP do
			local v = phyIntf_IP[i]		
			phoneIPType = v.name
			if phoneIPType == nil then
				phoneIPType = v.directory
			end
			local incomingCallNum = "-"	
			local inOutCall = getAllInOutCallNum1(i)
		    if inOutCall ~= nil and inOutCall ~= "" then
				local inOutCallArray = split(inOutCall,"##")
				incomingCallNum = inOutCallArray[1]
				if(incomingCallNum == "" or incomingCallNum == nil)then
					incomingCallNum = "-"						
				end	
			end
			writeTableBlockRow_restore(3, rowStyle, phoneIPType, v.directory, incomingCallNum)
			if rowStyle == "oddrow" then
				rowStyle = "evenrow"
			else
				rowStyle = "oddrow"
			end
		end
	end
writeBlockNoTitle_restoreWithoutHeader()
writeSectionRow(translate([==[FXONumber]==]), fxoNumber)
endBlock_restore()
endBlock_restore()

%>
                <br>
                <p align="center">
                <span style="font-weight: 400">#################################################################</span>
                </p>
                <p align="center"><%=translate([==[Check that the selected file contains the settings you want. The configuration of the modem ]==])%><br/>
                <%=translate([==[will be overwritten with that present in the selected file.]==])%></p>
                <p align="center"><%=translate([==[Press "Confirm" to confirm the import of the configuration, or press "Cancel" to ]==])%><br/>
                <%=translate([==[select another configuration or return to the previous page.]==])%></p>
              </td></tr>
            </table>
          </td></tr>
          <tr><td align='center' colspan='2'>
		   <table width="100%" cellspacing="0" cellpadding="0" class="martop15 fontSize">
			<tbody><tr>
				<td class="fright verticalAlign padleft40">
				<a class="fright" onclick="submitOk(event)" href="#">
				<div name="thb11" class="midarea6-1 mainButton"><%=translate([==[Confirm]==])%></div></a>
				</td>
				<td class="verticalAlign padleft40">
				<a href="tool.lp">
				<div name="thb12" class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
				</td>
				</tr>
				</tbody>
				</table>
           
          </td></tr></table>
      </td></tr></table>
  </td></tr></table>
</form>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>

<div id="processBar" style="display:none;">
  <table cellspacing='0' cellpadding='0' width="100%"><tr>
    <td class='data' style='vertical-align:top'>
      <table cellspacing='0' cellpadding='0' width="100%"><tr><td>
        <table cellspacing='0' cellpadding='0' width='100%'>
          <tr><td>
		  <table cellspacing='0' cellpadding='0' width='100%'>
          <tr>                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td></tr></table>
            <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage">
              <tr><td class="errorMessage"><%=translate([==[Saving]==])%></td></tr>
              <tr><td class="errorDesc">
                <p><%=translate([==[Please wait]==])%>...</p>
                <p><%=translate([==[Restore of configuration in progress]==])%>. <%=translate([==[During the next]==])%> <span id="COOL_REDIRECT">600</span> <%=translate([==[seconds must not turn off the modem]==])%>.</p>
              </td></tr>
            </table>
          </td></tr></table>
      </td></tr></table>
  </td></tr></table>
</div>

</div>
</div>
</body>
</html>
