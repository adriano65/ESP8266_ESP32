<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<!-- <link rel="stylesheet" href="css/menu.css" type="text/css"/>
<link rel="stylesheet" href="css/style.css" type="text/css"/> -->
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
local QUERY=cgilua.QUERY

local ip = QUERY["ip"]
local mask = QUERY["mask"]
local path = QUERY["path"]
local natState = QUERY["natState"]
local natIntfPath = QUERY["natIntfPath"]

%>
<body onload="redirect2home()">
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
                          <td class="errorMessage"><%=translate([==[Rebooting the modem being]==])%>.</td></tr>
            <tr><td class="errorDesc">
		<p><%=translate([==[Please wait]==])%>...</p>
		<p><%=translate([==[The modem is restart to apply the changes made]==])%>!</p>		
		<p><%=translate([==[During the next]==])%> <span id="COOL_REDIRECT">120</span> <%=translate([==[second connection to the LAN will]==])%> 
		<%=translate([==[interrupted]==])%><br/>
		<%=translate([==[In this interval of time should not turn off the modem]==])%></p>
		<br/></td></tr></table>
		</td></tr>		
		</table>
</div>
</div>

<script src="js/antiCSRF.js"></script>

<script type="text/javascript">

function redirect2home()
{ 
  var ip="<%=ip%>";
  var URL="http://"+ip;
  coolRedirect(URL, 1);
}



function sajax_init_object() {
        var A;
        try {
                A=new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
                try {
                        A=new ActiveXObject("Microsoft.XMLHTTP");
                } catch (oc) {
                        A=null;
                }
        }
        if(!A && typeof XMLHttpRequest != "undefined")
                A = new XMLHttpRequest();
        return A;
}


        var ip = "<%=ip%>";
        var mask = "<%=mask%>";
        var path = "<%=path%>";
        var natState = "<%=natState%>";
        var natIntfPath = "<%=natIntfPath%>";
        var urlStr = "/ipmod.lp";

	rn = encodeURIComponent(rn);
	var params="ip="+ip+"&mask="+mask+"&path="+path+"&natState="+natState+"&natIntfPath="+natIntfPath+"&tag=ip&rn="+rn;
	var xobj = sajax_init_object();         
	xobj.open('POST',urlStr,true);	 
	xobj.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	xobj.setRequestHeader("Content-length", params.length);
	xobj.setRequestHeader("Connection", "close");
	xobj.send(params);

</script>

</body>
</html>
