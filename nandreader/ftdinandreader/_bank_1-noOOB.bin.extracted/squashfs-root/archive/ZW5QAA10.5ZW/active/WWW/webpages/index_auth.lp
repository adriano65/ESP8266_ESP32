<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<%
local translate = translate
local preauth_data
local wrong=false
local loginmask_disp
local pwdko_disp
local is_remote = isRemoteAccess()

  if cgilua.servervariable"REQUEST_METHOD" == "GET" then
      preauth_data = cgilua.preauth()
      loginmask_disp = ""
      pwdko_disp = "none"
    -- preauth_data contains realm, nonce, qop
  elseif cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local post_username = "admin"
    if is_remote then
      post_username = cgilua.POST["username"]
    end
    local auth_error= cgilua.auth({ username = post_username,
                     method = "GET",
                     uri = cgilua.servervariable"SCRIPT_NAME",
                     nc = "00000001",
                     cnonce = "xyz",
                     response = cgilua.POST["hidepw"],
                     redirect_flag = 0})

    if auth_error==false then
        local TI_info = getTIInfo()
		local TI_Device = getTIInfo_Device()
		--This check commented for tessa 258
        --if TI_Device.lanOption == "biz-rt-napt-ena" and TI_info.adminPassword == "admin" and tostring(is_remote)~="true" then
		if TI_info.adminPassword == "admin" then
          cgilua.redirect("frame_pwd_alert.lp")
        else
          cgilua.redirect("/")
        end
        return
    else
        loginmask_disp = "none"
        pwdko_disp = ""

        preauth_data = cgilua.preauth()

    end
  end

%>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

<title>Modem Telecom Italia</title>
<link href="css/master1.css" rel="stylesheet" type="text/css" />
<link href="css/layout.css" rel="stylesheet" type="text/css" />
<link href="resources/cpe.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" href="css/master.css" type="text/css">
<!-- <link href="css/basic.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="css/menu.css" type="text/css">
<link rel="stylesheet" href="css/style.css" type="text/css"> -->

<script type="text/javascript" src="js/md5.js"></script>
<script type="text/javascript">
//<![CDATA[
var realm = "<%= preauth_data.realm %>";
var nonce = "<%= preauth_data.nonce %>";
var qop = "<%= preauth_data.qop %>";
var uri = "<%= cgilua.servervariable"SCRIPT_NAME" %>";

function submitAuthentication()
{
  var user = "admin";
<% if is_remote then %>
  user = document.getElementById("username").value;
<% end %>
  var pwd  = document.getElementById("password").value;

  document.getElementById("password").disabled=true;
  var HA1 = MD5(user + ":" + realm + ":" + pwd);
  var HA2 = MD5("GET" + ":" + "<%= cgilua.servervariable"SCRIPT_NAME"%>");
  document.getElementById("hidepw").value = MD5(HA1 + ":" + nonce +
                          ":" + "00000001" + ":" + "xyz" + ":" + qop + ":" + HA2);

  document.getElementById("authform").submit();
}

function loginmask_cancel_onclick()
{
  //document.getElementById("login_face").style.display = "none";
  document.getElementById("loginMask").style.display = "";
}

function passwordko_onclick()
{
  document.getElementById("passwordko").style.display = "none";
  document.getElementById("loginMask").style.display = "";
}

//]]>
</script>

</head>

<body  onload="javascript: if(top !== self) top.location.href= '/';">

<div id="container">
	<div id="header" class="heightImg">
		
		<table cellspacing='0' cellpadding='0' width="100%" style="text-align:center">
			<tr><td colspan="3">&nbsp;</td></tr>
			<tr>
				<td width="180"></td>
				<td align="left" class='itemtitle'>
				<div style="height:27px">&nbsp;</div>
				
				</td>
			</tr>
		</table>

		<div style="margin-top:5px;"><hr></div>
		<div style="float:left;width:100%;">
			<div style="float:left;margin-left:15%;font-size:15px" >GESTIONE MODEM</div>
			<div style=" color:#808080;font-size:11px;margin-left:74%">Release Modem: <%=getVersion()%></div>
		</div>
	
	</div>
	<div style="margin-bottom:-7px;"><hr></div>
	
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0"  leftmargin="0" topmargin="0">
	<tr>
	
	<td bgcolor='#E9EEF2' width="169" height="1000">
		<div style="height:941px"></div><div id="bottom" class="bottomImg"></div><div style="height:10px"></div>
    </td>
<div id="content">
	<td height="500" width="835" style='vertical-align:top;padding-top:20px'>
<div>
<div id="loginMask" style="display:<%=loginmask_disp%>; left:50px; top:150px; width:100%; height:690px; z-index:1; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->
<form method="post" action="index_auth.lp" name="authform" id="authform" style="text-align:left" onsubmit="return false">
<input type="hidden" name="hidepw" id="hidepw" value=""/>

<div class='contentcontainer'>

<div class='contentitem'>
<table cellspacing='0' cellpadding='0' width="100%" class="marleft40 width750">
<tr>
    <td class="icon verticalAlign width65"><img src='images/usrs__xl.png' alt='Technicolor Gateway'></td>
    <td  class='data verticalAlign'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr><td>
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td class='verticalAlign'>
<% if is_remote then %>
            <span  class='itemtitle verticalAlign'><%=translate([==[Remote access to the modem Telecom Italy]==])%></span><br/><br/>   
<% else %>
            <span class='itemtitle verticalAlign'><%=translate([==[Safety Authentication Local Access Modem]==])%></span><br/><br/>   
<% end %>
            <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" height='110px;'>
<% if is_remote then %>
            <tr><td style="text-align: left; height: 15px;" class="errorMessage" colspan="2" ><%=translate([==[Password to access local]==])%>.</td></tr>
            <tr><td colspan="2"><span class='blocktitle'><%=translate([==[Use valid username and password for remote access to the modem]==])%></span></td></tr>
            <tr><td class="tdBianca width110" >Username:</td><td><input id="username" name="username" maxlength="12" style="font-weight: 700; width: 100px;" type="text"></td></tr>
            <tr><td class="tdBianca width110">Password:</td><td><input id="password" name="password" maxlength="12" style="font-weight: 700; width: 100px;" type="password">&nbsp;<b>[ 6 - 12 <%=translate([==[characters]==])%> ]</b></td></tr>
<% else %>
            <tr><td style="text-align: left; height: 15px;" class="errorMessage" colspan="2" ><%=translate([==[Password to access local]==])%>.</td></tr>
            <tr><td colspan="2" style="padding-top: 10px; height: 20px;"><span class='blocktitle'><%=translate([==[Enter a password]==])%></span></td></tr>
            <tr><td class="tdBianca width110" style="height: 20px; padding-top: 10px;">Password:</td><td><input id="password" name="password" size="8" maxlength="8" style="font-weight: 700" type="password">&nbsp;
		<b>[ 4 - 8 <%=translate([==[characters]==])%> ]</b></td></tr>
<% end %>
		</table><br/>
                   </td></tr>
                   <tr><td>
				   
				   		<table  cellspacing='0' cellpadding='0' class="fontSize padtop10">
		<tr>
		<td class="verticalAlign padleft200">
		<a onclick='javascript:submitAuthentication();' href="#"><div name="thb8" class='midarea6-1 mainButton'><%=translate([==[Login]==])%></div></a></td></td>
		<td  class="verticalAlign padleft50">
		<a onclick='javascript: loginmask_cancel_onclick();' href="#"><div name="thb9" class='midarea6-1 mainButton'><%=translate([==[Cancel]==])%></div></a></td></tr></table></td>

		</tr>
					</table>
					</td></tr>
                   </table>
        </td></tr></table>

</div>

</div>
</form>
</div>
<script src="js/antiCSRF.js"></script>
<div id="passwordko" style="display:<%=pwdko_disp%>">
<%cgilua.lp.include("webparts/passwordKO.lp")%>
</div>
</td>

</div>
<td height="500" class="rightContainer"></td>



</tr>
</table>
<div class="clrBth"></div>
  <div id="footer"> 
    <div class="footer_copyrights" style="font-size: 11px;"> 
      <div style="margin-left:7%;width:100%"">&copy; 2013 Telecom Italia&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; 
        | &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Partita IVA : <span id="partialValue"></span></div>
    </div>
  </div>

</div>
<script type="text/javascript">
var partialValue ="00488410010"
document.getElementById("partialValue").innerHTML=partialValue;
</script>
</body>
</html>
