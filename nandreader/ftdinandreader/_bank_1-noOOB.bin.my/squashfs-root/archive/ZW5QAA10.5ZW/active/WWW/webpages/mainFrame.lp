<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<base target="mainFrame">
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/style.css" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
</head>
<% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
%>
<body>
<div style="position:absolute; left:20px; top:5px; width:670px; height:690px; z-index:1; overflow: auto; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->
<table border="0" width="640" id="table15">
	<tr>
		<td class="titolo" width="100%">Modem Telecom</td>
	</tr>
	<table border="1" class="tableBg" width="640" id="table15">
	<tr>
		<td class="trScura" colspan="5" width="100%"><%=translate([==[User interface of the modem Telecom]==])%></td>
	</tr>
	<tr>
		<td class="tdBiancaC" width="100%"><br>
				<%=translate([==[Using this]==])%>
				<%=translate([==[interface, the user can configure and customize]==])%><br>
				<%=translate([==[services]==])%>
				<%=translate([==[potentiality provided by Telecom and exploit all]==])%> 
				<%=translate([==[potentiality]==])%><br>
				<%=translate([==[modem associated supply]==])%><p><%=translate([==[To proceed with the]==])%> 
		<%=translate([==[configuration is necessary to authenticate with the appropriate credentials]==])%>
		<%=translate([==[user supplied with the apparatus]==])%></p>
		<p><%=translate([==[Tap]==])%> &quot;<b><%=translate([==[Forward]==])%></b>&quot; <%=translate([==[to proceed with authentication]==])%><br>
&nbsp;</td>
		</tr>
		<tr>
		<td class="tdChiara50">
			<INPUT enabled type=button onclick='javascript: document.location.href="loginMask.lp";' value="<%=translate([==[Forward]==])%>" name="thb2"></td>
		</tr>
</table>
</div>
</body>
</html>
