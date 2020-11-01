<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<%
cgilua.lp.include("lp/ppp.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/style.lp")

local translate = translate
local POST = cgilua.POST
local ipAddress = ""
local reply, error = mbus.getParameters{path = "Device.IP.Interface.2.IPv4Address.1",datamodel = "second" }
	ipAddress = reply["Device.IP.Interface.2.IPv4Address.1"][1].param["IPAddress"]


local function get_RemoteAccess()
  local result = {}
  result.radPath = ""
  result.enable = "false"
  result.status = "Disabled"
  result.port = "4443"

  local replyGui, error = mbus.getParameters{ path = "Device.UserInterface.RemoteAccess", datamodel = "second"}
  if (replyGui["Device.UserInterface.RemoteAccess"]~= nil)then
    result.radPath = replyGui["Device.UserInterface.RemoteAccess"][1].path
    result.enable = replyGui["Device.UserInterface.RemoteAccess"][1].param["Enable"]
  --  result.status = replyGui["Device.UserInterface.RemoteAccess"][1].param["Status"]
    if replyGui["Device.UserInterface.RemoteAccess"][1].param["Port"] ~= "0" then
      result.port = replyGui["Device.UserInterface.RemoteAccess"][1].param["Port"]
    end
    result.url = "https://" .. ipAddress .. ":" .. result.port
  end

  return result
end

local function get_Group()
  local reply, error = mbus.getParameters{ path = "Users.Group", param = "Name", filter = "(== Name TechnicalSupport)" }  
  return reply["Users.Group"][1].path
end

local set_pwd_disp = "none"
local raccess = get_RemoteAccess()

if raccess.status == "Active" then
  set_pwd_disp = ""
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
  local result = {}
  result.group = get_Group()
  
  if POST["radState"] == "0" and raccess.enable == "true" then
    local reply, error = mbus.modify(
      function()
        mbus.setParameters{ path = raccess.radPath, param = {Enable = "false"} }
      end)
  
  elseif POST["radState"] == "1" then
    local radPath = ""
    if raccess.radPath == "" then
      -- Create new RemoteAccess object
      local reply, error = mbus.modify(
        function()
          local replyRadAdd, errorRadAdd = mbus.addObjects{ path = "RemoteAccess", param={ Name = "remoteaccess" } }
          radPath = replyRadAdd["RemoteAccess"][1].path
        end)
    else
      -- Use existing RemoteAccess object
      radPath = raccess.radPath
      if raccess.enable == "true" then
        local modify = {}
        table.insert(modify, { path = radPath, param = {Enable = "false"} })
        setMBUS(modify)
      end
    end

    -- Create new user
    local reply, error = mbus.modify(
      function()
        mbus.deleteObjects{ path = "Users.User", filter = "(== AdminGroup " .. result.group .. ")" }
        local reply2 = mbus.addObjects{ path = "Users.User" }
        result.user =  reply2["Users.User"][1].path
        mbus.setParameters{ path = result.user, param = { Name = POST["username"], AdminGroup = result.group, DefaultRemoteAdmin = "1" } }
      end)

    -- Configure the parameters of RemoteAccess object
    local modify = {}
    table.insert(modify, { path = radPath, param = {Port = POST["port"], Mode = "Permanent", RandomPassword = "false", Secure = "1"}})
    table.insert(modify, { path = radPath, param = {Group = result.group} })
    table.insert(modify, { path = radPath, param = {User = result.user} })
    table.insert(modify, { path = result.user, param = {Password = POST["newpw"]} })
    table.insert(modify, { path = radPath, param = {Enable = "true"} })
    setMBUS(modify)
  end

  saveall(0, 1)
  --cgilua.redirect("save_alert.lp", { u="remoteAccess.lp?flag=true" })
  cgilua.redirect("save_alert.lp", { u="remoteAccess.lp" })
  return
end

--local usernameValue, passwordValue 
local usernameValue, passwordValue = "", "" 
local reply, error = mbus.getParameters{ path = "Device.UserInterface.RemoteAccess", param = { "Enable" } } 
local remoteAccessEnable = reply["Device.UserInterface.RemoteAccess"][1].param["Enable"]
local replyName, error = mbus.getParameters{ path = "Device.Users.User.1", param = { "Name", "Password" } }
if remoteAccessEnable~="false" then
    if replyName["Device.Users.User.1"]~=nil and replyName["Device.Users.User.1"][1]~=nil then
        usernameValue = replyName["Device.Users.User.1"][1].param["Name"]
        passwordValue = replyName["Device.Users.User.1"][1].param["Password"]
    end
end

local errPort = "<p>" .. translate([==[Error: check the value entered in the port. Valid values are: 0-65535.]==]).. "</p>"
local errPortNum = "<p>" .. translate([==[Error. Ports 443 and 8443 are already in use for system applications. Please enter a different port.]==]).. "</p>"
local errUsernamePwd = "<p>" .. translate([==[Error in the Username field (resp. Password). Use only characters allowed and comply with the minimum and maximum length . Insert at least one special character.]==]).. "</p>"
local errConfirmPwd = "<p>" .. translate([==[Attention: the password you entered are not identical .   Verify that the password you entered in the fields "SetPassword" and "Repeat Password" are identical.]==]).. "</p>"

local warnPort = "<p>" .. translate([==[Warning: This port can not be used to service Port Mapping.]==]).. "</p>"
local warnEnable = "<p>" .. translate([==[Warning: Enabling this feature makes the modem accessible from the Internet. We recommend you to activate the feature only when necessary and disable it when not in use]==]).. "</p>"
local warnPassword = "<p>" .. translate([==[Warning: You should periodically change your password for remote access.]==]).. "</p>"
%>

<script language="javascript" type="text/javascript">
//<![CDATA[
function isValidPort(str)
{
  var reg = /^[\d]{1,5}$/;
  return reg.test(str);
}

function isValidPassword(str)
{
	var reg = /^([\da-zA-Z0-9]){6,12}$/;
	if(reg.test(str))
	{
		return true;
	}
	return false;
}

function change_pwd()
{
  if(document.getElementById("R_disable").checked == true)
  {
    submitConfirm();
  }
  else
  {
    var portValue = document.getElementById("port").value;
    if (portValue==0)
    {
        var port = portValue;
    }
    else
    {
        var portStr = portValue.replace(/^0+/g,' ');
        var port = parseInt(portStr);
    }
    if ((!isValidPort(portValue)) || (portValue.indexOf(" ")!=-1) || isNaN(port) || (port>65535))
    {
      document.getElementById("errMsg").innerHTML = "<%=errPort%>";
      document.getElementById("set_pwd_table").style.display = "none";
      document.getElementById("resultKO").style.display = "block";
      return false;
    }

    if (port == "443" || port == "8443")
    {
      document.getElementById("errMsg").innerHTML = "<%=errPortNum%>";
      document.getElementById("set_pwd_table").style.display = "none";
      document.getElementById("resultKO").style.display = "block";
      return false;
    }

    var user = document.getElementById("username").value;
    if ((!isValidPassword(user)) || (user.indexOf(" ")!=-1))
    {
      document.getElementById("errMsg").innerHTML = "<%=errUsernamePwd%>";
      document.getElementById("set_pwd_table").style.display = "none";
      document.getElementById("resultKO").style.display = "block";
      return false;
    }

    var tmp = checkPassword();
    if(2==tmp) 
    {
		
      document.getElementById("errMsg").innerHTML = "<%=errUsernamePwd%>";
      document.getElementById("set_pwd_table").style.display = "none";
      document.getElementById("resultKO").style.display = "block";
    }
    else if(1==tmp)
    {
      document.getElementById("errMsg").innerHTML = '<%=errConfirmPwd%>';
      document.getElementById("set_pwd_table").style.display = "none";
      document.getElementById("resultKO").style.display = "block";
    }
    else
    {
      document.getElementById("set_pwd_table").style.display = "none";
      document.getElementById("confirm").style.display = "block";
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
  document.getElementById("resultKO").style.display = "none";
}

function checkPassword()
{
  var passwordnew = document.getElementById("newpw");
  var passwordverif = document.getElementById("confpw");

  if(passwordnew && passwordverif && passwordnew.value!=passwordverif.value)
  {
    passwordnew.value="";
    passwordverif.value="";
    document.getElementById("isShow").style.display="none";
    return 1;
  }

  if ((!isValidPassword(passwordnew.value))||(!isValidPassword(passwordverif.value))||(passwordnew.value.indexOf(" ")!=-1))
  {
    passwordnew.value="";
    passwordverif.value="";
    document.getElementById("isShow").style.display="none";
    return 2;
  }
  return 0;
}

function show_pwd_input()
{
  if(document.getElementById("R_enable").checked == true)
  {
    document.getElementById("set_url").style.display = "";
    document.getElementById("set_port").style.display = "";
    document.getElementById("set_username").style.display = "";
    document.getElementById("set_username_hint").style.display = "";
    document.getElementById("set_pwd1").style.display = "";
    document.getElementById("set_pwd2").style.display = "";
    document.getElementById("set_pwd_hint").style.display = "";
	document.getElementById("set_pwd_hint1").style.display = "";
  }
  else
  {
    document.getElementById("set_url").style.display = "none";
    document.getElementById("set_port").style.display = "none";
    document.getElementById("set_username").style.display = "none";
    document.getElementById("set_username_hint").style.display = "none";
    document.getElementById("set_pwd1").style.display = "none";
    document.getElementById("set_pwd2").style.display = "none";
    document.getElementById("set_pwd_hint").style.display = "none";
	document.getElementById("set_pwd_hint1").style.display = "none";
  }
}

function body_onload()
{
<% if raccess.status == "Active" then %>
  document.getElementById("R_enable").checked = true;
<% else %>
  document.getElementById("R_disable").checked = true;
<% end %>
  show_pwd_input(); 
  detectBrowserDetails();
}

var browserName=navigator.appName; 
var browserVer=navigator.appVersion;

function detectBrowserDetails() 
{
	var nVer = navigator.appVersion;
	var nAgt = navigator.userAgent;
	var browserName  = navigator.appName;
	var fullVersion  = ''+parseFloat(navigator.appVersion); 
	var majorVersion = parseInt(navigator.appVersion,10);
	var nameOffset,verOffset,ix;

// In Opera, the true version is after "Opera" or after "Version"
if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
	 browserName = "Opera";
	 fullVersion = nAgt.substring(verOffset+6);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
	   fullVersion = nAgt.substring(verOffset+8);
}
// In MSIE, the true version is after "MSIE" in userAgent
else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
	 browserName = "Microsoft Internet Explorer";
	 fullVersion = nAgt.substring(verOffset+5);
}
// In Chrome, the true version is after "Chrome" 
else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
	 browserName = "Chrome";
	 fullVersion = nAgt.substring(verOffset+7);
}
// In Safari, the true version is after "Safari" or after "Version" 
else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
	 browserName = "Safari";
	 fullVersion = nAgt.substring(verOffset+7);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
	   fullVersion = nAgt.substring(verOffset+8);
}
// In Firefox, the true version is after "Firefox" 
else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
	 browserName = "Firefox";
	 fullVersion = nAgt.substring(verOffset+8);
}
// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < 
          (verOffset=nAgt.lastIndexOf('/')) ) 
{
	 browserName = nAgt.substring(nameOffset,verOffset);
	 fullVersion = nAgt.substring(verOffset+1);
	 if (browserName.toLowerCase()==browserName.toUpperCase()) {
	  browserName = navigator.appName;
 }
}
// trim the fullVersion string at semicolon/space if present
if ((ix=fullVersion.indexOf(";"))!=-1)
   fullVersion=fullVersion.substring(0,ix);
if ((ix=fullVersion.indexOf(" "))!=-1)
   fullVersion=fullVersion.substring(0,ix);

   majorVersion = parseInt(''+fullVersion,10);

	if (isNaN(majorVersion)) {
		fullVersion  = ''+parseFloat(navigator.appVersion); 
		majorVersion = parseInt(navigator.appVersion,10);
	}


if (browserName == "Microsoft Internet Explorer")
{
	
	if (majorVersion <= 7) 
	{
		
		if(document.getElementById("configButton"))
		{
			document.getElementById("configButton").style.paddingLeft = "250px";
		}
		
	} else {
		if(document.getElementById("set_port2"))
		{
			document.getElementById("set_port2").style.paddingLeft = "5px";
		}
	}
} else {
		if(document.getElementById("set_port2"))
		{
			document.getElementById("set_port2").style.paddingLeft = "5px";
		}
	}
}	
//]]>
</script>
<style type="text/css">
.tdType1 {
	width: 330px;
	padding-left: 35px;
}

.tdType2 {
	width: 370px;
}
</style>
</head>
<body onload='body_onload()'>

<div class="contentContainer fontSize">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="remoteAccess.lp"><%=translate([==[Remote Access]==])%></a></li>
			</ul>
		</div>	

<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="remoteAccess.lp" class="current">
				<div class="tab">
				<span class="tabIconRemote"></span>  
				<span class="contTabTxt transform"><%=translate([==[Remote Access]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>		
		
<div class='contentcontainer'>
<div id="set_pwd_table" class='contentitem'>
<form method="post" id="change_pwd_form" action="">
<table cellspacing='0' cellpadding='0' class="infotable marleft36 padtop10">
	<tr>
		<td class="sectionArea-1 "><%=translate([==[State]==])%>:</td>
		<td class="tdType2">
			<input type="radio" value="1" id="R_enable" name="radState" onclick='show_pwd_input();' />&nbsp;<%=translate([==[active]==])%>&nbsp;&nbsp;&nbsp;&nbsp;    
			<input type="radio" value="0" id="R_disable" name="radState" onclick='show_pwd_input();' />&nbsp;<%=translate([==[Disable]==])%>
		</td>
	</tr>
	
	<tr id="set_url">
		<td class="sectionArea-1 "><%=translate([==[Router accessible from the web at]==])%>:</td>
		<td class="tdType2"><%=raccess.url%></td>
	</tr>
	
	<tr id="protocol">
		<td class="sectionArea-1 "><%=translate([==[Protocol]==])%>:</td>
		<td class="tdType2">HTTPS</td>
	</tr>

	<tr id="set_port">
		<td class="sectionArea-1 "><%=translate([==[Port]==])%>:</td>
		<td  class="tdType2"  >
			<input type="text" name="port" id="port" value="<%=raccess.port%>" maxlength="5" autocomplete="off" class="fontSize width130" />
		</td>
	</tr>
	
	<tr id="set_username" style="display:<%=set_pwd_disp%>;">
		<td class="sectionArea-1 "><%=translate([==[Username]==])%>:</td>
		<td class="tdType2">
		<div style="float:left;">
			<input type="text" name="username" id="username" value="<%=usernameValue%>" maxlength="12" autocomplete="off" class="fontSize width130"/>
		</div>
		<div style="float:left;margin-left:5%;" >
			* <%=translate([==[[8-12 characters].]==])%>
		</div>
		</td>
	</tr>
	
	<tr  id="set_username_hint" style="display:<%=set_pwd_disp%>;">
		<td class="sectionArea-1 ">&nbsp;</td>
		<td class="tdType2"> <%=translate([==[Use only alphanumeric characters (a-z, A-Z, 0-9). and contain at least one special character in the set:!@#$%^& * ( )_+ = { } , . / <>?  ~ [ ] | ; :]==])%></td>
	</tr>
	
	<tr  id="set_pwd1" style="display:<%=set_pwd_disp%>">
		<td class="sectionArea-1 padtop5"><%=translate([==[Set Password]==])%>:</td>
		<%if remoteAccessEnable=="true" then%>
			<td class="tdType2 padtop5">
				<input type="password" name="newpw" id="newpw" value="" maxlength="12" autocomplete="off" class="fontSize width130" />
			</td>
		<%else%>
			<td class="tdType2 padtop5">
			<div style="float:left;margin-top:3%">
				<input class="fontSize width130" type="password" name="newpw" id="newpw" value="" maxlength="12" autocomplete="off" />
				</div>
				<div style="float:left;margin-left:5%;margin-top:3%" >
			* <%=translate([==[[8-12 characters].]==])%>
		</div>
			</td>
		<%end%>
	</tr>
	
	<tr id="set_pwd_hint" style="display:<%=set_pwd_disp%>;">
		<td class="sectionArea-1 ">&nbsp;</td>
		
		<td class="tdType2 ">
		
		<div>
			 <%=translate([==[Use only alphanumeric characters (a-z, A-Z, 0-9). and contain at least one special character in the set:!@#$%^& * ( )_+ = { } , . / <>?  ~ [ ] | ; : ]==])%>
		</div>
		</td>
	</tr>
	
	<tr  id="set_pwd2" style="display:<%=set_pwd_disp%>">
		<td class="sectionArea-1 padtop5"><%=translate([==[Confirm Password]==])%>:</td>
		<td class="tdType2 padtop5">
			<div style="float:left;margin-top:3%">
			<input name="T6" type="password" id="confpw" value="" maxlength="12" autocomplete="off" class="fontSize width130" />
			</div>
				<div style="float:left;margin-left:5%;margin-top:3%" >
			* <%=translate([==[[8-12 characters].]==])%>
		</div>
		</td>
	</tr>
	
	<tr id="set_pwd_hint1" style="display:<%=set_pwd_disp%>; line-height:120%; height: 45px;">
		<td class="sectionArea-1 ">&nbsp;</td>
		<td class="tdType2"><div>
			 <%=translate([==[ Use only alphanumeric characters (a-z, A-Z, 0-9). and contain at least one special character in the set:!@#$%^& * ( )_+ = { } , . / <>?  ~ [ ] | ; :]==])%>
		</div></td>
	</tr>
</table>

<table cellspacing='0' cellpadding='0' width='100%' border='0' class="padtop10">
    <tr>
		<table border='0' width='100%' cellspacing='0' cellpadding='0' class="fontSize txtAlignCenter">
    <td class="txtAlignCenter">		
				<tr>
					<td style="float:right;text-align:left">
						<a style="float:right;text-align:left" onclick="change_pwd()" href="#">
							<div class="midarea6-1 mainButton" name="thb10" ><%=translate([==[Configure]==])%></div>
						</a>
					</td>
					<td class="verticalAlign padleft50">
						<a href="advance.lp">
						<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Cancel]==])%></div></a>
					</td>
				</tr>
				
				</table>

        </td>
    </tr>
    <tr id='isShow'><td class="verticalAlign ">
<%if passwordValue~="" then%>
        <p class=" txtAlignCenter paddtop10" style="padding-right:75px;"><%=translate([==[User created successfully]==])%></p>
       <%end%>
    </td></tr>
</table>

<%endPage()%>
</div>
</div>

<script src="js/antiCSRF.js" type="text/javascript"></script>
<div class='contentcontainer fontSize'>
<div id="confirm" style="display:none" class="contentitem">
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
                          <td class="errorMessage"><%=translate([==[You are about to make changes]==])%>.</td></tr>
              <tr><td class="errorDesc" id="warnMsg">
                <p><%=warnEnable%></p>
                <p><%=warnPassword%></p>
                <p><%=warnPort%></p>
                <p><%=translate([==[Are you sure you want to make changes?]==])%></p>
                <p class="paddtop10"><%=translate([==[Click "Next" to confirm or click "Cancel" to return to previous page]==])%>.</p>
				<br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="submitConfirm()" href="#" class="padright15 fright">
				<div class="midarea6-1 mainButton"  name="thb13"><%=translate([==[Next]==])%></div></a>
				</td>
				<td class="verticalAlign" style="padding-left:15px;">
				<a onclick="cancelConfirm()" href="#">
				<div class="midarea6-1 mainButton" name="thb12"><%=translate([==[Cancel]==])%></div></a>
      </td></tr></table>
  </td></tr></table>
</div>
</div>
<div class='contentcontainer fontSize'>
<div id="resultKO" style="display:none" class="contentitem">
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
                          <td class="errorMessage"><%=translate([==[Operation failure]==])%></td></tr>
              <tr><td class="errorDesc" id="errMsg"><br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
		  <a onclick="cancelConfirm()" href="#">
				<div class="midarea6-1 mainButton" name="thb12" ><%=translate([==[Continue]==])%></div></a>
          </td></tr></table>
      </td></tr></table>
</div>
</div>
</div>

</body>
</html>
