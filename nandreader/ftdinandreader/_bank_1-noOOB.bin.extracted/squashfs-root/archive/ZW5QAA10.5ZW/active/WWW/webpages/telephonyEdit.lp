<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/style.css" type="text/css"/>
<link rel="stylesheet" href="css/menu.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<%
local translate = translate
local POST=cgilua.POST
local QUERY=cgilua.QUERY
local ProfilePath = "Voice.Profile"
local PortmapPath = "Voice.Portmap."
local voicePortsPath = "Voice.Ports"
local voicePortsPathLen = string.len(voicePortsPath) + 2 
local tprint = require("tableprint")

--Delete voice profile.
function delete_voice_profile(voiceProfilePath)
    local reply, error = mbus.modify(
    function()
        local reply1, error1 = mbus.deleteObjects{ path = voiceProfilePath }
    end)
end


--Create a new voip profile
function voip_profile_create(sipUri, username, password, voicePort, displayName, abbrNumber)
    local voipProfilePathStr = ""
    local reply, error = mbus.modify(
        function()
            local reply, error = mbus.addObjects{ path = "Voice.Profile",
                                                    param = { Username = username,
                                                              Password = password,
                                                              ["SIP-URI"] = sipUri,
                                                              VoicePort = voicePort,
                                                              DisplayName = displayName,
                                                              AbbrNumber = abbrNumber } }
        end)
end

--Get the voice port by port map path 
function find_voip_port(voicePortPath)
    local reply, error = mbus.getParameters{ path = voicePortPath, param = "Name"}
    if reply[voicePortPath][1]~=nil then
        return tostring(reply[voicePortPath][1].param["Name"])
    end 
    return ""
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    if POST["pathId"] ~= "nil" then
        local voiceProfilePath = "Voice.Profile."..tostring(POST["pathId"])
        delete_voice_profile(voiceProfilePath)
        local voipProfilePathStr = voip_profile_create(POST["SIPURI2"], POST["Username"], POST["Password"], POST["VoicePort"], POST["DisplayName"], POST["AbbrNumber"])
    else
        local voipProfilePathStr = voip_profile_create(POST["SIPURI2"], POST["Username"], POST["Password"], POST["VoicePort"], POST["DisplayName"], POST["AbbrNumber"])
    end
    cgilua.redirect("telephonyConfig.lp")
    return
end

local Username, SIPURI2, Password, ConfirmPassword, DisplayName, AbbrNumber, VoicePort, portmapPathId, voipPortPathId = "", "", "", "", "", "", "", "", ""
if QUERY["pathId"] ~= nil then
    ProfilePath = "Voice.Profile."..QUERY["pathId"]
    local reply, error = mbus.getParameters{ path = ProfilePath, param = {"Username", "SIP-URI", "Password", "DisplayName", "AbbrNumber" } }
    if reply[ProfilePath][1]~=nil then
        SIPURI2 = reply[ProfilePath][1].param["SIP-URI"]
        Username = reply[ProfilePath][1].param["Username"]
        Password = reply[ProfilePath][1].param["Password"]
        DisplayName = reply[ProfilePath][1].param["DisplayName"]
        AbbrNumber = reply[ProfilePath][1].param["AbbrNumber"]
        local portPath = reply[ProfilePath][1].path
            
        local replyPort, error = mbus.getParameters{ path = "Voice.Portmap", param = "VoicePort", filter = "(== UserAgent "..tostring(portPath)..")"}
        if replyPort["Voice.Portmap"][1]~=nil then
            if #(replyPort["Voice.Portmap"]) == 8 then
                VoicePort = "COMMON"
            elseif #(replyPort["Voice.Portmap"]) == 6 then
                VoicePort = "DECT"
            else
                VoicePort = find_voip_port(replyPort["Voice.Portmap"][1].param["VoicePort"])
            end
            voipPortPathId = string.sub(VoicePort, voicePortsPathLen)
            portmapPathId = string.sub(replyPort["Voice.Portmap"][1].path, 15)
        end
    end
end
%>
<script language="javascript" type="text/javascript">

function config_submit()
{
    if (document.getElementById("Password").value != document.getElementById("ConfirmPassword").value)
    {
        document.getElementById("set_service_configuration").style.display = "none";
        document.getElementById("passwordCheck").style.display = "block";
        return false;
    }

    document.getElementById("set_service_configuration").style.display = "none";
    document.getElementById("confirm").style.display = "block";
}

function submitConfirm()
{
    document.getElementById("modify_serv_conf").submit();
}

function cancelConfirm()
{
    document.getElementById("set_service_configuration").style.display = "";
    document.getElementById("passwordCheck").style.display = "none";
}

</script>
</head>
<body>
<table cellspacing='0' cellpadding='0' width="100%" class="NavBar"> <tr><td align="left"><a href="home.lp">casa</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="toolBox.lp">cassetta degli attrezzi</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephony.lp">telefonia</a></td><td align="right"><a href="telephonyStato.lp">visione d'insieme</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="telephonyExpert.lp">Esperto Configura</a></td></tr>
</table>

<div class='contentcontainer' id="set_service_configuration">
<hr>
<hr>
<form method="POST" id="modify_serv_conf" action="">
<input type="hidden" id="pathId" name="pathId" value="<%=QUERY["pathId"]%>" />
<input type="hidden" id="portmapPathId" name="portmapPathId" value="<%=portmapPathId%>" />
<div class='contentitem'>
<table border="0" width="100%">
<tr>
    <td class='icon' style='vertical-align:top' width='100px'><img src='images/csharing__xl.gif' alt='Interface'></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr>
            <td align='left'><span class='itemtitle'><%=translate([==[Telephony Identity]==])%></span></td>
        </tr>
        <tr><td>
            <br><!-- Begin of Service Configuration-->
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td><td style='vertical-align:top'>
            <span class='blocktitle'><%=translate([==[Telephony Identity]==])%></span><br>
            <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;">
                <br><!-- Begin of DeviceInfo-->

                <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
                <tr><td width='90'><%=translate([==[URI]==])%>:</td><td colspan='3'><input type="text" name="SIPURI2" value="<%=SIPURI2%>"/></td></tr>
                <tr><td width='90'><%=translate([==[User Name]==])%>:</td><td colspan='3'><input type="text" name="Username" value="<%=Username%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Password]==])%>:</td><td colspan='3'><input type="password" id="Password" name="Password" value="<%=Password%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Confirm Password]==])%>:</td><td colspan='3'><input type="password" id="ConfirmPassword" name="ConfirmPassword" value="<%=Password%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Display Name]==])%>:</td><td colspan='3'><input type="text" name="DisplayName" value="<%=DisplayName%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Abbr.Number]==])%>:</td><td colspan='3'><input type="text" name="AbbrNumber" value="<%=AbbrNumber%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Port]==])%>:</td><td colspan='3'>
                    <select id="VoicePort" name="VoicePort">
                    <option value="COMMON">COMMON</option>
                    <option value="FXS1">FXS1</option>
                    <option value="FXS2">FXS2</option>
                    <option value="DECT">DECT</option>
                    <option value="DECT1">DECT1</option>
                    <option value="DECT2">DECT2</option>
                    <option value="DECT3">DECT3</option>
                    <option value="DECT4">DECT4</option>
                    <option value="DECT5">DECT5</option>
                    <option value="DECT6">DECT6</option>
                    </select>
                </td></tr>
            </table>
            <br>
            <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
            <tr><td style='vertical-align:top'>
                <input type="button" onclick="config_submit();" value="<%=translate([==[Apply]==])%>" name="thb8">&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" onclick='javascript: document.location.href="telephonyConfig.lp";' value="<%=translate([==[Cancel]==])%>" name="thb21">
            </td></tr></table>
            </td></tr></table>
        </td></tr></table>
</td></tr></table>
</div>
</form>
</div>
<script src="js/antiCSRF.js"></script>
<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="passwordCheck" style="display:none">
<%cgilua.lp.include("webparts/passwordCheck.lp")%>
</div>
<script language="javascript" type="text/javascript">
var VoicePort = "<%=VoicePort%>";
if(VoicePort != "")
{
    document.getElementById("VoicePort").value=VoicePort;
}
</script>
</body>
</html>

