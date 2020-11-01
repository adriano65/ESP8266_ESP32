<!DOCTYPE  html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<title>Modem Telecom Italia </title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<!--<link rel="stylesheet" href="css/style.css" type="text/css">
<link rel="stylesheet" href="css/menu.css" type="text/css"/> -->
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
</head>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<%
local id = cgilua.QUERY["intf"]
local translate = translate
if id=="1" then
	WIntfPath ="WLAN.Intf.wlif1"
else
        WIntfPath="WLAN.Intf.wle_radio1_ssid0"
end
local modify ={}

table.insert(modify, {path=WIntfPath, param= {ChannelMode="Auto"}, flags="KEYPATH"})
setMBUS(modify)
%>
<body onload="coolRedirect('wlanStatus.lp?wifiPage=wifi')">
<div class='contentcontainer'>
<div class='contentitem'>
  <table cellspacing='0' cellpadding='0' width='100%' class="width790 marleft5 martop5">
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
                          <td class="errorMessage"><%=translate([==[Find Wi-Fi channel current]==])%></td></tr>
              <tr><td class="errorDesc">
                <p><%=translate([==[Please wait]==])%>...</p>
                <p><%=translate([==[Search the Wi-Fi channel current]==])%>!</p>
                <p><%=translate([==[During the next]==])%> <span id="COOL_REDIRECT">10</span> <%=translate([==[seconds Wi-Fi connections will interrupted]==])%><br>
                <%=translate([==[In this interval of time should not turn off the modem]==])%></p>
              </td></tr>
            </table>
          </td></tr></table>
</div>
</div>
</body>
</html>
