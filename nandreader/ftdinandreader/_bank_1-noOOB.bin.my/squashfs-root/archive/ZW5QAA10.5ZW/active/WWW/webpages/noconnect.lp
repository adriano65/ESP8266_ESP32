<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<% cgilua.lp.include("lp/device.lp") %>
<base target="mainFrame">
<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
<link href="css/master.css" rel="stylesheet" type="text/css" />

</head>
<script language="javascript" type="text/javascript">

</script>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/dsl.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<%
local translate = translate

local err1=translate([==[Warning: the DSL connection is not active. Check the DSL cable is connected and verify proper operation of the line. Press the "Next" button to access the Management of modems.]==])
local err2=translate([==[Warning: the Ethernet WAN connection is not active. Check that the Ethernet cable is connected and verify the correct operation of the line. Press the "Next" button to access the Management of modems.]==])
local err3=translate([==[Warning: the automatic connection modem is disconnected or NAT is disabled. To access the Internet you must enable connection manually, or by modem activate the NAT service. Press the "Next" button to access the Management of modems.]==])
local err4=translate([==[Warning: PPPoE on the PC is off. To access the Internet you must connect manually on your PC to the Internet. Press the "Next" button to access the Management of modems.]==])
local err5=translate([==[Warning: the requested URL is blocked. To access, change the configuration of the barring service URLs. Press the "Next" button to access the Management of modems.]==])







local reason = ""
local msg = ""
local msgLog = ""
local dsl = getDSLInfo()
local data, error = mbus.getParameters{path = "TI_STORE.TiUserIntf", param = {"LANOption"}}
local lanopt = data["TI_STORE.TiUserIntf"][1].param["LANOption"]
local data, error = mbus.getParameters{path = "PPP.Intf.2", param = {"TI_Enable", "Status"}}
local ppp_enabled = data["PPP.Intf.2"][1].param["TI_Enable"]
local ppp_status =  data["PPP.Intf.2"][1].param["Status"]

local TI_info = getTIInfoHome()
local ppp = getPPP("PPP.Intf.2")
local natStatus = nil
if ppp~=nil then
  natStatus = getNatStatus(ppp.ipintf)
end

local wanType
local reply, error = mbus.getParameters{ path = "System", param = "WANMode"}
local wanConnType = reply["System"][1].param["WANMode"]
if wanConnType == "ETH" then
    wanType = "ETH" 
else
    wanType = "DSL"
end

local ETHConn
local eth, error = mbus.getParameters{path="ETH.Phys", param="Status", filter="(== Name " .. "ethif5" .. ")"}
if (eth["ETH.Phys"][1]~=nil) and (eth["ETH.Phys"][1].path~=nil) then
    if eth["ETH.Phys"][1].param["Status"] == "Connected" then
        ETHCon = 1 
    else
        ETHCon = 0
    end
end

local remote_ip = ""
if cgilua.servervariable"REMOTE_ADDR" ~= nil then
  remote_ip = tostring(cgilua.servervariable"REMOTE_ADDR")
end

if wanType=="DSL" and dsl.dsl_status ~="Up" then
   msg=err1
elseif wanType=="ETH" and ETHCon==0 then
   msg=err2
elseif lanopt == "res-br" or lanopt == "biz-br" or ppp_enabled == nil then
   msg=err4
   msgLog = "WAN: access denied to host IP " .. remote_ip .. " - required PPPoE from host"
elseif ppp_status ~= "Connected" then
   msg=err3
   msgLog = "WAN: access denied to host IP " .. remote_ip .. " - NAT not enable or IP out of range"
elseif ppp_status == "Connected" and natStatus ~= "enabled" and ( TI_Device.lanOption == "res-rt-napt" or TI_Device.lanOption == "biz-rt-napt-ena" or TI_Device.lanOption == "res-rt-napt-ipv6"
or TI_Device.lanOption == "biz-rt-napt-ipv6")  then
   msg=err3
   msgLog = "WAN: access denied to host IP " .. remote_ip .. " - NAT not enable or IP out of range"   
else
   msg=err5
end

if msgLog ~= nil and msgLog ~= "" then
   local reply, error = mbus.modify(
				    function()
				       local reply, error = mbus.setParameters{ path="TI_STORE.TiUserIntf", param={ writeLog=msgLog}}
				    end)
end

%>
<body>

<div class='contentcontainer'>
<div class='contentitem'>
<table cellspacing='0' cellpadding='0' width="100%" class="width750 martop5">
                  <tr>
                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td>
                  </tr>
                  <tr>
                    <td class="verticalAlign">
                      <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" style="text-align:left">
                        <tr>
                          <td class="errorMessage"><%=translate([==[Operation failed]==])%>.</td></tr>
                             <tr><td class="errorDesc"><p><%=msg%></p>
							 <br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				   <a style='color:black' onclick='javascript:top.location.href="/";'>
				<div class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a>
            </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>

</body>
</html>
