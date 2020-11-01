<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/style.css" type="text/css" />
<% cgilua.lp.include("lp/language.lp") %>
</head>
<body>
<div style="position:absolute; left:20px; top:5px; width:670px; height:690px; z-index:1; overflow: auto; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->

<table border="0" width="640">
	<tr>
		<td class="titolo">Info</td>
	</tr>
	<tr><td>
	<table width="640" id="table20" border="1" class="tableBg">
	<tr>
		<td class="trScura">&nbsp;<%=translate([==[Operation failure]==])%></td>
	</tr>
	<tr>
		<td class="tdBiancaC">
		<p><%=translate([==[Rule already active]==])%></p>
		<p><%=translate([==[Warning: Verify that the IP address, the inner door and / or the external port configured]==])%><br/><%=translate([==[have not been assigned to another rule of port mapping / virtual server]==])%>.</p> 	
		<p><%=translate([==[Press "Continue" to return to previous page]==])%></p>
        </td>
	</tr>
	</table>
	</td>
	</tr>
	<tr><td>
	<table width="640" >
	<tr>
	<td class="tdChiara50">
		<input type="button" onclick="javascript:window.history.back();" value="<%=translate([==[Continue]==])%>" name="thb11"></td>
	</tr>
	</table>
	</td></tr>
</table>
</div>
</body>
</html>
