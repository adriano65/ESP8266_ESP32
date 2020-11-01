<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
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
		window.parent.menu.document.getElementById("stat").className="";
	}
	if(window.parent.menu.document.getElementById("loac")!=null && 
		window.parent.menu.document.getElementById("loac") != "undefinded") {
		window.parent.menu.document.getElementById("loac").className="submenuselect";
	}

	
  </script>
<% 
cgilua.lp.include("lp/language.lp")
cgilua.lp.include("lp/common.lp") 
cgilua.lp.include("lp/device.lp")
cgilua.lp.include("lp/ppp.lp") 
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/style.lp")

local translate = translate
local POST=cgilua.POST

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
  if POST["R1"] == "active" then
	  -- set PasswordRequired, it will help us to add/del user and config defuser. 
	local reply, error = mbus.modify(
			function()
				local reply, error = mbus.setParameters{ path="TI_STORE.TiUserIntf", param = {PasswordRequired="1", AdminPassword=POST["newpw"]} }
			end)

	local userpath="Users.User"
	local reply, error = mbus.modify(
			function()
				local reply, error = mbus.setParameters{ path=userpath, param={Password=POST["newpw"]}, filter="(== Name admin)"}
			end)

  else
	local reply, error = mbus.modify(
			function()
				local reply1, error1 = mbus.setParameters{ path="TI_STORE.TiUserIntf", param={ PasswordRequired="0", AdminPassword="admin"}}
				local reply2, error2 = mbus.setParameters{ path="Users.User", param={Password="admin"}, filter="(== Name admin)"}
			end)
  end

  saveall(0, 1)
  cgilua.redirect("save_alert.lp", { u="logout.lp" })  
  return
  
end


local active=0
local set_pwd_disp = "none"

local reply, error = mbus.getParameters{ path="TI_STORE.TiUserIntf", param = "PasswordRequired"}

if tostring(reply["TI_STORE.TiUserIntf"][1].param["PasswordRequired"]) == "true" then
  active = 1
  set_pwd_disp = ""
end

local function get_active_checked()
  local checkInfo=" "
  if active==1 then
    checkInfo = "checked='checked'"
  end
  return checkInfo
end

local function get_off_checked()
  local checkInfo=" "
  if active==0 then
    checkInfo = "checked='checked'"
  end
  return checkInfo
end


local low = translate([==[Low]==])
local medium =  translate([==[Medium]==])
local high = translate([==[High]==])

%>

<script language="javascript" type="text/javascript">
//<![CDATA[
var uri = "<%= cgilua.servervariable"SCRIPT_NAME" %>";

function change_pwd()
{
  if(document.getElementById("R_off").checked == true)
  {
    document.getElementById("set_pwd_table").style.display = "none";
    document.getElementById("confirm").style.display = "block";
  }
  else
  {
    tmp = checkPassword();
	var strength = document.getElementById("encryptionKeyStrengthDesc").innerHTML;
	if( strength == "<%=translate([==[Low]==])%>" || 2==tmp ) 
	{
	  document.location.href="resultKO_passFail.lp";
	  return false;
	}
	else if(1==tmp)
	{
	  document.location.href="resultKO_passMatch.lp";
	  return false;
	}
	else if(strength == "<%=translate([==[Medium]==])%>") 
	{
		document.getElementById("set_pwd_table").style.display = "none";
		document.getElementById("confirm_passwd_set_yellow").style.display = "block";
		return false;
	}
	else
	{
	  document.getElementById("set_pwd_table").style.display = "none";
	  document.getElementById("confirm_passwd_set").style.display = "block";
	}
  }
}

function submitConfirm()
{
  document.getElementById("change_pwd_form").submit();  
}

function cancelConfirm()
{
  document.getElementById("set_pwd_table").style.display = "";
  document.getElementById("confirm").style.display = "none";
  document.getElementById("confirm_passwd_set").style.display = "none";
  document.getElementById("confirm_passwd_set_yellow").style.display = "none";
  document.getElementById("newpw").value = "";
  document.getElementById("confpw").value = "";
  document.getElementById("keyStrength").style.display="none";
  body_onload();
}

function isValidPassward(str)
{
	var reg = /^[\da-zA-Z]{4,8}$/;
	return reg.test(str);
}

function checkPassword()
{
  var passwordnew=document.getElementById("newpw");
  var passwordverif=document.getElementById("confpw");

  if( passwordnew && passwordverif && passwordnew.value!=passwordverif.value)
  {
    passwordnew.value="";
    passwordverif.value="";
    return 1;
  }

  if ((!isValidPassward(passwordnew.value))||(!isValidPassward(passwordverif.value))||(passwordnew.value.indexOf(" ")!=-1))
  {
    passwordnew.value="";
    passwordverif.value="";
    return 2;
  }

  return 0;
}

var desc = new Array();
	
desc[1] = "<%=low%>";
desc[2] = "<%=medium%>";
desc[3] = "<%=high%>";

function indicateKeyStrength(password,id)
{
  //alert(id);
    if( id == "keyStrength")
	{
	//alert("blocking to keystren");
		document.getElementById("keyStrength").style.display="block";
	}
	
	var score = 1;
	var isAlphaNumericCharExists = false;
	var length =  password.length;
	
	
	
	//is any uppercase, lowervase and a number presents
	isAlphaNumericCharExists = ( Boolean(password.match(/[a-z]/)) && Boolean( password.match(/[A-Z]/) )  && Boolean( password.match(/\d+/) ));	
	
	isAnyAlphaExists = (( password.match(/[a-z]/) ) || ( password.match(/[A-Z]/) )  || ( password.match(/\d+/) ));
	
	if ( length >= 4 && isAlphaNumericCharExists ) {
			score = 2;
		}
    if ( length == 8 && isAlphaNumericCharExists ){
		score = 3;
	}	
	
	if( isValidPassward(password) == false )
	{
		score = 1;
	}

	if( id == "keyStrength" )
	{
		//alert("assigning to keystreng");
		document.getElementById("encryptionKeyStrengthDesc").innerHTML = desc[score];
		document.getElementById("encryptionKeyStrength").className = "strength" + score;	
	}
	return score;
}

function show_pwd_input()
{
  if(document.getElementById("R_active").checked == true)
  {
    document.getElementById("set_pwd").style.display = "";
    document.getElementById("set_pwd1").style.display = "";
    document.getElementById("set_pwd2").style.display = "";
	document.getElementById("encryptionKeyStrength").style.display = "";
	document.getElementById("encryptionKeyStrengthDesc").style.display = "";
  }
  else
  {
    document.getElementById("set_pwd").style.display = "none";
    document.getElementById("set_pwd1").style.display = "none";
    document.getElementById("set_pwd2").style.display = "none";
	document.getElementById("encryptionKeyStrength").style.display = "none";
	document.getElementById("encryptionKeyStrengthDesc").style.display = "none";	
  }
}

function body_onload()
{
<% if active==1 then %>
  document.getElementById("R_active").checked = true;
  document.getElementById("R_off").checked = false;
<% else %>
  document.getElementById("R_active").checked = false;
  document.getElementById("R_off").checked = true;
<% end %>

  show_pwd_input(); 
}
//]]>
</script>

</head>
<body  onload='body_onload()'>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li><li><a href="loginMgm.lp"><%=translate([==[Local Access]==])%></a></li>
			</ul>
		</div>	

<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="loginMgm.lp" class="current">
				<div class="tab">
				<span class="tabIconLocalAccess"></span>  
				<span class="contTabTxt transform"><%=translate([==[Local Access]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>


<div class='contentcontainer'>
<div id="set_pwd_table" class='contentitem'>
<form method="post" id="change_pwd_form" action="">

<%
writeBlockRowNoTitle_Access()
%>
<tr><td colspan="2" class="tableTitle padtop5"><%=translate([==[Safety Management Local Access Modem]==])%></td></tr>
<tr><td class="padtop5" colspan="2">&nbsp;</td></tr>
	<tr><td class="oddrow accessRowContent" colspan="2">
		<input type="radio" value="active" name="R1" id="R_active" <%=get_active_checked()%> onclick='show_pwd_input();' class="alignMid" />&nbsp;<span class="alignMid" ><%=translate([==[Active]==])%></span> 
		<span class="padleft40"><input type="radio" value="off" name="R1" id="R_off" <%=get_off_checked()%> onclick='show_pwd_input();'  class="alignMid"/>&nbsp;<span class="alignMid" ><%=translate([==[Disable]==])%> </span></span>
	</td></tr>
    <tr><td class="oddrow" colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<tr><td colspan='2'>&nbsp;</td></tr>
	
	<tr id="set_pwd"><td colspan="2"><%=translate([==[The password must be from 4 to 8 characters long and contain at least one character of each of the following sets [0-9], [a - z], [A - Z].]==])%></td></tr>
	<tr height="20">
				<td colspna="2"></td>
			</tr>

	<tr id="set_pwd1" style="display:<%=set_pwd_disp%>">
		<td class="evenrow width140 accessRowContent"><%=translate([==[Set Password: ]==])%></td>
		<td class="evenrow accessRowContent"><input  type="password" name="newpw" id="newpw" value="" maxlength="8" onkeyup="indicateKeyStrength(this.value,'keyStrength')"  autocomplete="off" />&nbsp;[ 4 - 8 <%=translate([==[characters]==])%>]</td>
		</tr>
		<tr>
		<td></td>
		<td class="tdBianca" rowspan="1" align="left">
			<table border="0" cellspacing="0" cellpadding="0" id="keyStrength" style="display:none">
			<tr>
			
			<td>				
			<table>
				<tr>
					<td>
					<div id="encryptionKeyStrengthDesc" value="Low">Password not entered</div>
					</td>
				</tr>
				<tr>
					<td>
					<div id="encryptionKeyStrength" class="strength0"></div>	
					</td>
				</tr>
			</table>
			</td>
			</tr>
			</table></td></tr>            	
<tr><td colspan='2'>&nbsp;</td></tr>

	<tr><td colspan='2'>&nbsp;</td></tr>
	<tr id="set_pwd2" style="display:<%=set_pwd_disp%>">
		<td class="oddrow width140 accessRowContent"><%=translate([==[Repeat Password: ]==])%></td>		
		<td class="oddrow accessRowContent"><input name="T6"  type="password" id="confpw" value="" maxlength="8" autocomplete="off" />&nbsp;[ 4 - 8 <%=translate([==[characters]==])%>]</td>				
		
	</tr>

<%endBlock()%>
	

		<table cellspacing='0' cellpadding='0' width='100%' class="martop15 fontSize">
			<tr>
				<td class="fright verticalAlign" >
				<a onclick="change_pwd()" href="#" class="fright">
				<div name="thb10" class="midarea6-1 mainButton"><%=translate([==[Save]==])%></div></a>
				</td>
				<td class="verticalAlign padleft40">
				<a href="standard.lp" >
				<div name="thb11" class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
				</td>
			</tr>
		</table>
      
	  

<%endPage()%>

</div>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
<div id="confirm_passwd_set" style="display:none">
<%cgilua.lp.include("webparts/confirmPasswdSet.lp")%>
</div>
<div id="confirm_passwd_set_yellow" style="display:none">
<%cgilua.lp.include("webparts/resultStartFail.lp")%>
</div>

<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
</body>
</html>
