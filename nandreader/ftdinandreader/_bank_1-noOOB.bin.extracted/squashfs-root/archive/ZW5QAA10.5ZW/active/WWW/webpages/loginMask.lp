<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<base target="mainFrame">
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/style.css" type="text/css">
<script type="text/javascript" src="js/md5.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
</head>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<%
local translate = translate
local preauth_data
local wrong=false
  if cgilua.servervariable"REQUEST_METHOD" == "GET" then
    local url = cgilua.QUERY.url
    if url ~= nil and cgilua.hasrights(tostring(url)) == true then
      -- If this page is linked from CGILua error (url~=nil), most likely it is because of session timeout. If user can access the original page, redirect to resultKO.lp to indiate configuration failure. Otherwise ask user to login.
      cgilua.redirect("index_auth.lp")
      return
    else
      preauth_data = cgilua.preauth()
      -- preauth_data contains realm, nonce, qop
    end
  elseif cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local auth_error= cgilua.auth({ username = "admin",
                     method = "GET",
                     uri = cgilua.servervariable"SCRIPT_NAME",
                     nc = "00000001",
                     cnonce = "xyz",
                     response = cgilua.POST["hidepw"],
                     redirect_flag = 0})
    if auth_error==false then
      local TI_info = getTIInfo()
	  local TI_Device = getTIInfo_Device()
      if TI_Device.lanOption == "biz-rt-napt-ena" and TI_info.adminPassword == "admin" then
        cgilua.redirect("password_alert.lp")
      else
        cgilua.redirect("/")
      end
	return
    else
	cgilua.redirect("passwordKO.lp")
	return
    end
  end

%>

<script type="text/javascript">
//<![CDATA[
var realm = "<%= preauth_data.realm %>";
var nonce = "<%= preauth_data.nonce %>";
var qop = "<%= preauth_data.qop %>";
var uri = "<%= cgilua.servervariable"SCRIPT_NAME" %>";

function submitAuthentication()
{
  var user = "admin";
  var pwd  = document.getElementById("password").value;

  document.getElementById("password").disabled=true;
  var HA1 = MD5(user + ":" + realm + ":" + pwd);
  var HA2 = MD5("GET" + ":" + "<%= cgilua.servervariable"SCRIPT_NAME"%>");
  document.getElementById("hidepw").value = MD5(HA1 + ":" + nonce +
                          ":" + "00000001" + ":" + "xyz" + ":" + qop + ":" + HA2);

  document.getElementById("authform").submit();
}
//]]>
</script>
<body>
<div style="position:absolute; left:20px; top:5px; width:670px; height:690px; z-index:1; overflow: auto; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->
<form method="post" action="loginMask.lp" name="authform" id="authform" onsubmit="return false">
<input type="hidden" name="hidepw" id="hidepw" value=""/>
<table border="0" width="640" id="table1">
	<tr>
		<td class="titolo" colspan="2"><%=translate([==[Modem Authentication]==])%></td>
	</tr>
	<table border="1" width="640" class="tableBg" id="table1">
	<tr>
		<td class="trScura" colspan="2"><%=translate([==[Password access]==])%></td>
	</tr>
	<tr>
	<td class="trChiara" colspan="2"><%=translate([==[Enter a password]==])%></td>
	</tr>
	<tr>
		<td class="tdScura" width="25%">&nbsp;Password: </td>
		<td class="tdBianca">
		&nbsp;
		<input id="password" name="password" size="8" style="font-weight: 700" type="password">&nbsp;
		<b>[ 4 - 8 <%=translate([==[characters]==])%> ]</font></td>
	</tr>
	</table>
	<table width="640">
	<tr>
		<td class="tdChiara50" colspan="2">
				<INPUT enabled type=button class=button onclick='javascript:submitAuthentication();' value="<%=translate([==[Login]==])%>" name="thb8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<INPUT enabled type=button class=button onclick='javascript: document.location.href="loginMask.lp";' value="<%=translate([==[Cancel]==])%>" name="thb9"></td>
	</tr>
</table>
</form>
</div>
<script src="js/antiCSRF.js"></script>
</body>
</html>
