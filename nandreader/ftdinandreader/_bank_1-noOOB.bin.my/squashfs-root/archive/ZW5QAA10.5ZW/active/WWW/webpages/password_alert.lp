<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
%>
<body>
<div class='contentcontainer'>
<div class='contentitem'>
 <table cellspacing='0' cellpadding='0' width='100%' class="width790 marleft5 martop5">
                  <tr>
                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/usrs__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td>
                  </tr>
                  <tr>
                    <td class="verticalAlign">
                      <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" style="text-align:left">
                        <tr>
                          <td class="errorMessage"><%=translate([==[Password access to change]==])%>.</td></tr>
            <tr><td class="errorDesc">
<p><%=translate([==[Caution: The password entered is that of initial activation.]==])%></p>
		<p><%=translate([==[We suggest you change it to make access safer.]==])%></p>
		<br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
						<a onclick='javascript: window.parent.location.href="index.lp";'>
							<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Continue]==])%></div>
						</a>
                     						   </td></tr>
                   </table>
        </td></tr></table>
</div>
</div>

</body>
</html>
