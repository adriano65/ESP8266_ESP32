<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<title>Modem Telecom Italia </title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css">
<link rel="stylesheet" href="css/menu.css" type="text/css"/> -->
</head>
<%
local translate = translate
local str = " 2.4 GHz"
local id = cgilua.QUERY["intf"]
if id=="3" then
  str = " 5 GHz"
end
%>
<html>
<body>
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
                          <td class="errorMessage"><%=translate([==[Find Wi-Fi channel]==])%></td></tr>
              <tr><td class="errorDesc">
                <p><%=translate([==[Warning: the channel search may cause the disconnection of Wi-Fi hosts at]==])%><%=str%>.<%=translate([==[Proceed]==])%>?</p>
                <p class="paddtop10"><%=translate([==[Press]==])%> &quot;<%=translate([==[Forward]==])%>&quot; <%=translate([==[to confirm or press]==])%>&quot;<%=translate([==[Cancel]==])%>&quot; <%=translate([==[to return to previous page]==])%>.</p>
             <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick='javascript: document.location.href="refresh_chan_wait.lp?intf=<%=id%>";'><div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Forward]==])%></div></a></td>
				 <td  class="verticalAlign" style="padding-left:15px;">
				<a onclick='javascript:window.history.back();'><div class="midarea6-1 mainButton" name="thb12"><%=translate([==[Cancel]==])%></div></a></td>
			</tr> 
		  </table>
  </td>
  </tr>
  </table>
</div>
</div>
</body>
</html>
