<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Content-Language" content="it">
<base target="mainFrame">
<title>Modem Telecom Italia</title>
<link href="css/master1.css" rel="stylesheet" type="text/css" />
<link href="css/layout.css" rel="stylesheet" type="text/css" />
<link href="css/cpe.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="css/table.css" type="text/css">
</head>
<% 
local tprint = require("tableprint")
cgilua.lp.include("lp/device.lp")
local is_remote = isRemoteAccess()


local subpage = "home.lp"
local menupage = "menu.lp"
if cgilua.QUERY["subpage"]~=nil then
	subpage =  cgilua.urlcode.escape(cgilua.QUERY["subpage"])
end
%>
<script type="text/javascript">
//<![CDATA[
function logout()
{
    document.logoutRemote.submit();
}
var se,m=0,h=0,s=0,ss=1;  

function second()
{
    if((ss%100)==0)
    {
        s+=1;
        ss=1;
    }
    if(s>0 && (s%60)==0)
    {
        m+=1;
        s=0;
    }
    if(m>0 && (m%60)==0)
    {
        h+=1;
        m=0;
    }
    t=h+" : "+m+" : "+s;
    document.getElementById("showtime").value=t;
    ss+=1;
}  

function startclock()
{
    se=setInterval("second()",1);
}
<%if is_remote then%>
	startclock();
<%end%>

//-------------------To suit the height of the body iframe------
function getIframeObj(iframeId){
	var iframeObj=document.all? document.all[iframeId] : document.getElementById(iframeId);
	return iframeObj;
}
var nAgt = navigator.userAgent;
function getIframeHeight(){
	var tmpHeight=0;

	var iframe = document.getElementById("body");
	if (document.getElementById) { 
		if (iframe.contentDocument && iframe.contentDocument.body && iframe.contentDocument.body.offsetHeight) { 			
			tmpHeight = iframe.contentDocument.body.offsetHeight; 	
		} else {			
			if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
				if(iframe.contentWindow && iframe.contentWindow.document && iframe.contentWindow.document.body && iframe.contentWindow.document.body.scrollHeight)
				{tmpHeight = iframe.contentWindow.document.body.scrollHeight;}
				else {tmpHeight = iframe.contentWindow.document.documentElement.scrollHeight; } 
			} else if (((verOffset=nAgt.indexOf("Opera"))!=-1) || ((verOffset=nAgt.indexOf("Safari"))!=-1) ) {
				if(iframe.contentWindow && iframe.contentWindow.document && iframe.contentWindow.document.documentElement && iframe.contentWindow.document.documentElement.scrollHeight)
				tmpHeight = iframe.contentWindow.document.documentElement.scrollHeight; 	
			} else {
				if(iframe.contentWindow && iframe.contentWindow.document && iframe.contentWindow.document.documentElement && iframe.contentWindow.document.documentElement.offsetHeight){
				tmpHeight = iframe.contentWindow.document.documentElement.offsetHeight; }
				else {tmpHeight = iframe.contentWindow.document.documentElement.scrollHeight; } 
			} 
		} 
	}
	
	if(tmpHeight<720)
	{
		tmpHeight = 1000;
	}

	return tmpHeight;
}

function reinitIframe(){
	var menuIframe = getIframeObj("menu");
	var bodyIframe = getIframeObj("body");
	
	if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
		bodyIframe.height = "100%";
	}
	
	var bodyHeight = getIframeHeight();

	if(bodyHeight>=1000){
		bodyIframe.height = bodyHeight;	
		menuIframe.height = bodyHeight;
	}
	
}

function runScroll(){
	window.setInterval("reinitIframe()", 600);
}
//]]>
</script>
<body onload="runScroll()">

<div id="container">
	<div id="header" class="heightImg">
		<form id="logoutRemote" name="logoutRemote" action="/logoutRemote.lp" target="_self">
			<table cellspacing='0' cellpadding='0' width="100%" style="text-align:center">
				<tr><td colspan="3">&nbsp;</td></tr>
				<tr><% if is_remote then %>
					<td></td>
					<td style="text-valign:bottom">
					<span class='itemtitle'><%=translate([==[Remote connection active]==])%></span>&nbsp;&nbsp;&nbsp;
						<input name="showtime" style="color:#ff0000;width:100px;text-align:center;" id="showtime" type="text" value="0 : 0 : 0">&nbsp;&nbsp;&nbsp;
						<input type=button class=button onclick='javascript:logout();' value="<%=translate([==[Dis-connect]==])%>" name="thb8">
					</td>
					<td></td>
					<% else %>
					<td width="180"></td>
					<td align="left" class='itemtitle'>
					<div style="height:27px">
<%
	local isRemoteAccess = 0
	
	
	
	local reply, error = mbus.getParameters{ path = "RemoteAccess", param = "Enable", filter = "(== Name remoteaccess)" }
    local usernameValue = ""
	if reply["RemoteAccess"][1] ~= nil and reply["RemoteAccess"][1].param ~= nil and reply["RemoteAccess"][1].param["Enable"] == "true" then
		isRemoteAccess = xml_encryption_remote()
		
	end
    if isRemoteAccess==1 then
        local reply, error = mbus.getParameters{ path = "RemoteAccess", param = "User" } 
        local userPath = reply["RemoteAccess"][1].param["User"]
        local replyName, error = mbus.getParameters{ path = userPath, param = "Name" }
        if replyName[userPath]~=nil and replyName[userPath][1]~=nil then
            usernameValue = replyName[userPath][1].param["Name"]
        end
%>
<%=translate([==[Dial-up under way for the user]==])%>:<%=usernameValue%>
<%
    else
	
	local tempreply, temperror = mbus.getParameters{ path = "TI_STORE.TiUserIntf", param = "PasswordRequired"}
	
	local isPasswordRequired = tempreply["TI_STORE.TiUserIntf"][1].param["PasswordRequired"]

	local isDontShowChecked = ""
	local reply, error = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name ".. "isDontShowChecked" ..")" }
	if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
		isDontShowChecked = reply["ENV"][1].param["Value"]
	end
			
	if( isPasswordRequired == "false" and(  isDontShowChecked == "" or isDontShowChecked ~= "true" ) ) then
		subpage = "startupConfig.lp"
		menupage = "leftContainer.lp"
	end
	
%>
&nbsp;
<%
    end
%>
					</div>
					</td>
<%
end 
%>
				</tr>
			</table>
			 
		</form>
		<div style="margin-top:5px;">
		<hr>
		</div>
		<div style="float:left;width:100%;">
		
		<div style="float:left;margin-left:15%;font-size:15px" >
			GESTIONE MODEM
		</div>
		<div style=" color:#808080;font-size:11px;margin-left:74%">Release Modem: <%=getVersion()%></div>
	
	</div>
	
	</div>
	<div style="margin-bottom:-5px;">
		<hr>
		</div>
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0"  leftmargin="0" topmargin="0">
       <tr>
              <td width="169" height="1000" style="background-color:#E9EEF2;">
					 
                    <iframe id="menu" name="menu" width=100% height=100% frameborder=0 scrolling="no" src="<%=menupage%>" allowTransparency="true"></iframe>
					<div id="bottom" class="bottomImg"><table><tr></tr>
					<tr></tr></table></div><div style="height:10px"></div>
              </td>
			  
			  <div id="content">
             <!-- <td height="500" style="BORDER-left: #eeeeee 3px solid;BORDER-top: #e4e4e4 3px solid;BORDER-bottom:#e4e4e4 3px solid;">-->
			<td height="1000" width="835">
                   <iframe id="body" name="body" frameborder=0 width=100% height=100% scrolling="no" src="<%=subpage%>"></iframe>
              </td>
			  
			   <td height="1000" class="rightContainer"></td>
			  
			  </div>
			 
       </tr>
</table>


 <div class="clrBth"></div>
  <div id="footer"> 
    <div class="footer_copyrights"> 
      <div>&copy; 2013 Telecom Italia&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; 
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

