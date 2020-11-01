<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<% cgilua.lp.include("lp/device.lp") %>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link href="css/master.css" rel="stylesheet" type="text/css" />
<link href="css/master1.css" rel="stylesheet" type="text/css" />
<link href="css/layout.css" rel="stylesheet" type="text/css" />
</head>

<body>

<div id="container">

	<div id="header" class="heightImg">
		
		<table cellspacing='0' cellpadding='0' width="100%" style="text-align:center">
			<tr><td colspan="3">&nbsp;</td></tr>
			<tr>
				<td width="180"></td>
				<td align="left" class='itemtitle'>
				<div style="height:27px">&nbsp;</div>
				
				</td>
			</tr>
		</table>

		<div style="margin-top:10px;"><hr></div>
		<div style="float:left;width:100%;">
			<div style="float:left;margin-left:15%;font-size:15px" >GESTIONE MODEM</div>
			<div style=" color:#808080;font-size:11px;margin-left:74%">Release Modem: <%=getVersion()%></div>
		</div>
	
	</div>
	<div style="margin-bottom:-7px;"><hr></div>


<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0"  leftmargin="0" topmargin="0">
	<tr>
		<td bgcolor='#E9EEF2' width="169">
		<div id="bottom" class="bottomImg"><table><tr></tr>
		<tr></tr></table></div><div style="height:10px"></div></td>
		<td height="1000" width="835">
					<iframe name="body" frameborder=0 width=100% height=100% scrolling="no" src="password_alert.lp"></iframe>
		</td>
		<td height="1000" class="rightContainer"></td>
	</tr>
</table>


<div class="clrBth"></div>
  <div id="footer"> 
    <div class="footer_copyrights"> 
      <div style="margin-left:-1%; width:100%">&copy; 2013 Telecom Italia&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; 
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
