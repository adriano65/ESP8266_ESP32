<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
         <link href="css/master.css" type="text/css" rel="stylesheet"/>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
%>
</head>
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
                          <td class="errorMessage"><%=translate([==[Operation failed]==])%>.</td></tr>
                             <tr><td class="errorDesc"><p><%=translate([==[Warning: the passwords are not identical. Verify that the password entered in the "Set Password" and "Repeat Password" are identical]==])%></p>
							<br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				   <a href="./loginMgm.lp">
				<div name="thb11" class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
            </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>
</body>
</html>
