<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
local POST=cgilua.POST 

local action
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	action = POST["action"]
end

if action == nil then
	return
end	
%>
<body onload="redirect()">

<div class='contentcontainer'>
<div class='contentitem'>
<form name="reset" method="post" action="">
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
                          <td class="errorMessage"><%=translate([==[Reboot modem being]==])%></td></tr>
              <tr><td class="errorDesc">
                <p><%=translate([==[Please wait]==])%>...</p>
                <p><%=translate([==[The modem is rebooting]==])%>!</p>
                <p><%=translate([==[During the next]==])%> <span id="COOL_REDIRECT">400</span> <%=translate([==[seconds all the LAN and Wi-Fi will be stopped]==])%>.<br/><%=translate([==[In this interval of time should not turn off the modem]==])%>.</p>
      </td></tr></table>
  </td></tr></table>
</form>
</div>
</div>

<script type="text/javascript" src="js/antiCSRF.js"></script>
<script type="text/javascript">

function redirect()
{
   var action="<%=action%>";
   if (action=="customerReset")
     coolRedirect("http://192.168.1.1",1);
   else
     coolRedirect("/",1);
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

/*function getFirstElemByName(id)
{
  var tagObjs = document.getElementsByName(name);
  if (tagObjs && (tagObjs.length > 0)) {
    return tagObjs[0];
  }
  else
    return false;
}

var rn = getFirstElemByName("rn");
if (false != rn) {
  rn = encodeURIComponent(rn.value);
}
else {
  rn = "";
} */

rn = encodeURIComponent(rn);

var urlStr="/resetAG.lp";
var xobj = sajax_init_object();
var parameters = "action="+"<%=action%>"+"&rn="+rn;

xobj.open('POST',urlStr,true);
xobj.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
xobj.setRequestHeader("Content-length", parameters.length);
xobj.setRequestHeader("Connection", "close");
xobj.send(parameters);

</script>
</body>
</html>
