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
local SIPPath = "Voice.SIP"

if cgilua.servervariable"REQUEST_METHOD" == "POST" then

    local modify = {}
    table.insert(modify, {path = SIPPath, param={ PrimRegServer = POST["PrimRegServer"], RegPort = POST["RegPort"], PrimProxyServer = POST["PrimProxyServer"], ProxyPort = POST["ProxyPort"], SecProxyServer = POST["SecProxyServer"], SecProxyPort = POST["SecProxyPort"], Expires = POST["Expires"] }})

    setMBUS(modify)
    cgilua.redirect("telephonyExpert.lp")
    return
end

%>

<script language="javascript" type="text/javascript">

function config_submit()
{
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
    document.getElementById("confirm").style.display = "none";
}

</script>
</head>
<body>
<table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="home.lp">casa</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="toolBox.lp">cassetta degli attrezzi</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephonyExpert.lp">telefonia</a></td><td align="right"><a href="telephonyStato.lp">visione d'insieme</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="telephonyConfig.lp">Configura</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Esperto Configura</em></td></tr>
</table>

<div class='contentcontainer' id="set_service_configuration">
<hr>
<hr>
<form method="POST" id="modify_serv_conf" action="">
<div class='contentitem'>
<table border="0" width="100%">
<tr>
    <td class='icon' style='vertical-align:top' width='100px'><img src='images/tel___xl.gif' alt=''></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr>
            <td align='left'><span class='itemtitle'><%=translate([==[Telephony]==])%></span></td>
        </tr>
        <tr><td>
            <br><!-- Begin of Service Configuration-->
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td><td style='vertical-align:top'>
            <span class='blocktitle'><%=translate([==[Service Configuration]==])%></span><br>
            <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;">
<%
            local PrimRegServer, RegPort, PrimProxyServer, ProxyPort, SecProxyServer, SecProxyPort, Expires
            local reply, error = mbus.getParameters{ path = SIPPath, param = {"PrimRegServer", "RegPort", "PrimProxyServer", "ProxyPort", "SecProxyServer", "SecProxyPort", "Expires"} }
            local v = reply[SIPPath][1]
            if v~=nil and v.param~=nil then
                PrimRegServer = v.param["PrimRegServer"]
                RegPort = v.param["RegPort"]
                PrimProxyServer = v.param["PrimProxyServer"]
                ProxyPort = v.param["ProxyPort"]
                SecProxyServer = v.param["SecProxyServer"]
                SecProxyPort = v.param["SecProxyPort"]
                Expires = v.param["Expires"]
%>
                <br><!-- Begin of DeviceInfo-->
                <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
                <tr><td width='90'><%=translate([==[Registrar]==])%>:</td><td colspan='3'><input type="text" name="PrimRegServer" value="<%=PrimRegServer%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Registrar Port]==])%>:</td><td colspan='3'><input type="text" name="RegPort" value="<%=RegPort%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Proxy]==])%>:</td><td colspan='3'><input type="text" name="PrimProxyServer" value="<%=PrimProxyServer%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Proxy Port]==])%>:</td><td colspan='3'><input type="text" name="ProxyPort" value="<%=ProxyPort%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Secondary Proxy]==])%>:</td><td colspan='3'><input type="text" name="SecProxyServer" value="<%=SecProxyServer%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Secondary Proxy Port]==])%>:</td><td colspan='3'><input type="text" name="SecProxyPort" value="<%=SecProxyPort%>"/></td></tr>
                <tr><td width='90'><%=translate([==[Expire Time]==])%>:</td><td colspan='3'><input type="text" name="Expires" value="<%=Expires%>"/></td></tr>
            <% end %>
            </table>
            <br>
            <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
            <tr><td style='vertical-align:top'>
                <input type="button" onclick="config_submit();" value="<%=translate([==[Apply]==])%>" name="thb8">&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" onclick='javascript: document.location.href="telephonyExpert.lp";' value="<%=translate([==[Cancel]==])%>" name="thb21">
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
</body>
</html>
