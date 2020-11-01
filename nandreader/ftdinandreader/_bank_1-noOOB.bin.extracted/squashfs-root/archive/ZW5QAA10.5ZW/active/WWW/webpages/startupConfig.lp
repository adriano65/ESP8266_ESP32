<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css">
<link href="css/master.css" rel="stylesheet" type="text/css" />
<link href="css/layout.css" rel="stylesheet" type="text/css" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<%
cgilua.lp.include("lp/device.lp")
local tprint=require("tableprint")
local POST = cgilua.POST
local modify = {}

local redirectPage="home.lp"

if cgilua.QUERY["fromPage"] ~= nil and cgilua.QUERY["fromPage"] =="wlanGuestConfig" then
	redirectPage = "wlanGuestConfig.lp?display=fromStartup"
end


if cgilua.servervariable"REQUEST_METHOD" == "POST" then

	--if configure button is clicked otherwise "cancel" button is not pressed
	if ( POST["cancel"] ~= nil and POST["cancel"] ~= "1") then 
		if( POST["confpw"] ~= nil and POST["newpw"] ~= nil ) then



			
			local reply, error = mbus.modify(
					function()
						local reply, error = mbus.setParameters{ path="TI_STORE.TiUserIntf", param = {PasswordRequired="true", AdminPassword=POST["newpw"]} }
					end)

			local userpath="Users.User"
			local reply, error = mbus.modify(
					function()
						local reply, error = mbus.setParameters{ path=userpath, param={Password=POST["newpw"]}, filter="(== Name admin)"}
					end)
					
			saveall(0,1)
			cgilua.redirect("save_alert.lp", { u = redirectPage })
		end	
	else
		--cancel is clicked
		if( POST["dontshow"] ~= nil and POST["dontshow"] == "on" ) then




		    --set the env variable here...
			local isDontShowChecked = ""
			local reply, error = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name ".. "isDontShowChecked" ..")" }
			if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
				isDontShowChecked = reply["ENV"][1].param["Value"]
			end

					
			if isDontShowChecked=="" then
				local reply, error = mbus.modify(
				function()
					local reply, error = mbus.addObjects{path = "ENV", param = {Value = "true", Name = "isDontShowChecked"}}
				end)
			else
				local replyPath, errorPath = mbus.getParameters{ path = "ENV", param = { "Name", "Value" }, filter = "(== Name ".. "isDontShowChecked" ..")" }
				local showStartUpPath = replyPath["ENV"][1].path
				table.insert(modify, {path = showStartUpPath, param = {Value = "true"}})
				setMBUS(modify)
			end
			
		end
		cgilua.redirect(redirectPage)
	end	
end

local low = translate([==[Low]==])
local medium =  translate([==[Medium]==])
local high = translate([==[High]==])

%>
<script type="text/javascript">
function change_pwd()
{
tmp = checkPassword();
    
	var strength = document.getElementById("encryptionKeyStrengthDesc").innerHTML;
	
    if(1==tmp)
	{
		document.getElementById("set_pwd_table").style.display = "none";
		document.getElementById("result_start_identical").style.display = "block";
		return false;
		
	}   
    else if( (strength == "<%=translate([==[Low]==])%>") || (2==tmp) )
	{
		document.getElementById("set_pwd_table").style.display = "none";
		document.getElementById("result_start_fail").style.display = "block";
		return false;		
	}
	
	//check the keystrength.
	
	if(strength == "<%=translate([==[Medium]==])%>") 
	{
		document.getElementById("set_pwd_table").style.display = "none";
		document.getElementById("confirm_passwd_set").style.display = "block";
		return false;
	}
	submitConfirm();
}

function isValidPassward(str)
{
	var reg = /^[\da-zA-Z]{4,8}$/;
	//var reg = /^[\da-zA-Z!@#$%^&*()+\-={}?_~\[\]`|;:\\]{4,8}$/;
	//alert("reg"+ reg.test(str));
	return reg.test(str);
}
var passwordnew;
var passwordverif;
function checkPassword()
{
  passwordnew=document.getElementById("newpw");
  passwordverif=document.getElementById("confpw");

  if( passwordnew && passwordverif && passwordnew.value!=passwordverif.value)
  {   
	passwordnew=document.getElementById("newpw").value;
	passwordverif=document.getElementById("confpw").value;	
    return 1;
  }

  if ((!isValidPassward(passwordnew.value))||(!isValidPassward(passwordverif.value))||(passwordnew.value.indexOf(" ")!=-1))
  {  
	passwordnew=document.getElementById("newpw").value;
	passwordverif=document.getElementById("confpw").value;	 
    return 2;
  }

  return 0;
}

function submitConfirm()
{
  document.getElementById("form1").submit();  
}

function cancelConfirm()
{
  document.getElementById("newpw").value = "";
  document.getElementById("confpw").value = "";
  document.getElementById("set_pwd_table").style.display = "block";
  document.getElementById("confirm_passwd_set").style.display = "none";
  document.getElementById("result_start_fail").style.display = "none";
  document.getElementById("result_start_identical").style.display = "none";
  document.getElementById("keyStrength").style.display="none";
}

var desc = new Array();
	
desc[1] = "<%=low%>";
desc[2] = "<%=medium%>";
desc[3] = "<%=high%>";
	
	
function indicateEncryptionKeyStrength(password,id)
{

	//alert(id);
    if( id == "keyStrength")
	{
	//alert("blocking to keystren");
		document.getElementById("keyStrength").style.display="block";
	}
	
	
	var score   = 1;
//	var isSpecialCharExists = false;	
	var isAlphaNumericCharExists = false;
	var isAnyAlphaExists = false;
	var length =  password.length;
	
	
	
	//is any uppercase, lowervase and a number presents
	isAlphaNumericCharExists = (( password.match(/[a-z]/) ) && ( password.match(/[A-Z]/) )  && ( password.match(/\d+/) ));
	isAnyAlphaExists = (( password.match(/[a-z]/) ) || ( password.match(/[A-Z]/) )  || ( password.match(/\d+/) ));
	//if password has at least one special caracther give 1 point
	//isSpecialCharExists =  password.match(/.[!,@,#,$,%,^,&,*,(,),+,\-,=,{,},?,_,~,\[,\],`,|,;,:,\\]/);
	
	
	if ( length >= 4  && isAlphaNumericCharExists ) {
			score = 2;
		}
    if ( length == 8  && isAlphaNumericCharExists ){
		score = 3;
	}	
	
	if( isValidPassward(password) == false )
	{
		score = 1;
	}
	//document.getElementById("encryptionKeyStrengthDesc").innerHTML = desc[score];
	//document.getElementById("encryptionKeyStrength").className = "strength" + score;
	
	if( id == "keyStrength" )
	{
		//alert("assigning to keystreng");
		document.getElementById("encryptionKeyStrengthDesc").innerHTML = desc[score];
		document.getElementById("encryptionKeyStrength").className = "strength" + score;	
	}

	return score;
}
	
function fnRedirect()
{
	var check =	document.form1.dontshow.checked;
	document.getElementById("cancel").value = "1";
	submitConfirm();
}
</script>
</head>
<body>


<div>

<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0"  leftmargin="0" topmargin="0">
	<tr>	

<div id="content">
	<td height="500" width="835" style='vertical-align:top;padding-top:20px'>
<div>
<div id="confirm_passwd_set" style="display:none">
<%cgilua.lp.include("webparts/resultStartFail.lp")%>
</div>
<div id="result_start_fail" style="display:none">
<div class='contentcontainer'>
<div class='contentitem1'>
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
                          <td class="errorMessage"><%=translate([==[Operation failed]==])%>.</td></tr>
                             <tr><td class="errorDesc"><p><%=translate([==[Warning: The password you entered is not valid. Make sure the passwords are to respect the minimum and maximum allowed, which contain at least one character of each of the following sets: [0-9], [a - z], [A - Z], or does not contain special characters or symbols not allowed]==])%></p>
							 <br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				   <a style='color:black' onclick="cancelConfirm()">
				<div class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
            </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>
</div>
<div id="result_start_identical" style="display:none">
<div class='contentcontainer'>
<div class='contentitem1'>
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
                          <td class="errorMessage"><%=translate([==[Operation failed]==])%>.</td></tr>
                             <tr><td class="errorDesc"><p><%=translate([==[Attention: the password you entered were not identical. Make sure that the password entered in the fields "Set Password" and "Confirm Password" are identical.]==])%></p>
							 <br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				   <a style='color:black' onclick="cancelConfirm()">
				<div class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
            </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>
</div>


<div id="set_pwd_table">
<form id="form1" name="form1" action="" method="post">

<input type="hidden" name="cancel" id="cancel" value="0"/>

<div class='contentcontainer'>

<div class='contentitem1'>
<table cellspacing='0' cellpadding='0' width="90%">
<tr><td width="5%">&nbsp;</td>
    <td class='icon' style='vertical-align:top;padding-right:15px' style='vertical-align:top' width='60px'><img src='images/user__xl.png' alt='Technicolor Gateway'></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr><td>
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td style='vertical-align:top'>

			<span style='padding-top:0px;font-weight:bold;font-size:12px' class='midarea2_telmain verticalAlign'><%=translate([==[Warning: not configured a password for access to the pages of Management modem.]==])%><br><%=translate([==[It is recommended for safety reasons to set this password.]==])%><br><%=translate([==[The configuration makes must enter the password each time you access to the pages of modem management.]==])%></span>
			
			<br /><br />
            <table width='94%' cellspacing='0' cellpadding='0' class="PageMessage">
			<tr><td colspan="2"><%=translate([==[The password must be from 4 to 8 characters long and contain at least one character of each of the following sets [0-9], [a - z], [A - Z].]==])%></td></tr>
			<tr height="20">
				<td colspna="2"></td>
			</tr>
            <tr><td class="tdBianca" align="right" style="padding-right:75px"><%=translate([==[Set Password: ]==])%></td><td><input name="newpw" id="newpw" value="" onkeyup="indicateEncryptionKeyStrength(this.value,'keyStrength')" autocomplete="off" size="12" maxlength="8" style="font-weight: 700" type="password">&nbsp;&nbsp;<b>[ 4 - 8 <%=translate([==[characters]==])%> ]</b></td></tr><br /><br />
				<tr><td></td><td class="tdBianca" rowspan="1" align="left">
			<table border="0" cellspacing="0" cellpadding="0" id="keyStrength" style="display:none">
			<tr>
			
			<td>				
			<table>
				<tr>
					<td>
					<div id="encryptionKeyStrengthDesc" value="Low">Low</div>
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
			
	<tr><td>&nbsp;</td></tr>
	<tr><td>&nbsp;</td></tr>
            <tr><td class="tdBianca" align="right" style="padding-right:75px"><%=translate([==[Repeat Password: ]==])%></td><td><input name="confpw" id="confpw" value="" autocomplete="off" size="12" maxlength="8" style="font-weight: 700" type="password">&nbsp;&nbsp;<b>[ 4 - 8 <%=translate([==[characters]==])%> ]</b></td></tr><br /><br />
			
		</table><br/>
                   </td></tr>

				   <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center;margin-left:50px" class='padtop10'>
                   <tr >
                   <td class="fright">
						<a class="fright" style='color:black;' onclick='javascript:change_pwd();'><div class='midarea6-1 mainButton' name="thb8"><%=translate([==[Configure]==])%></div></a>
					</td>
					 <td style="vertical-align:top">
						<a onclick="return fnRedirect()"><div name="thb9" class='midarea7-4 secondaryButton'><%=translate([==[Continue without setting password]==])%></div></a></td>
				</tr>
				</table>
				<tr align="left"><td><span class="alignMid"><input type="checkbox" id="dontshow" class="alignMid" name="dontshow"></span>&nbsp;&nbsp;<span class="alignMid">(<%=translate([==[Dont show any more]==])%>)</span></td></tr>
                   </table>
        </td></tr></table>
    </td>
</tr>
</table>
</div>
</div>
</form>
</div>
</div>
</td>
</div>
</tr>
</table>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>
</body>
</html>

	 
	
