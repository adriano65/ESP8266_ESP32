<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Modem Telecom Italia</title>
    <link rel="stylesheet" href="css/master.css" type="text/css">
<% 
cgilua.lp.include("lp/language.lp")
cgilua.lp.include("lp/style.lp")
local translate = translate
%>
  <script language="JavaScript" type="text/javascript">
    if(window.parent.menu.document.getElementById("stcon")!=null && 
		window.parent.menu.document.getElementById("stcon") != "undefinded") {
		window.parent.menu.document.getElementById("stcon").className="";
	}
	
	if(window.parent.menu.document.getElementById("serte")!=null && 
		window.parent.menu.document.getElementById("serte") != "undefinded") {
		window.parent.menu.document.getElementById("serte").className="";
	}

	if(window.parent.menu.document.getElementById("lanst")!=null && 
		window.parent.menu.document.getElementById("lanst") != "undefinded") {
		window.parent.menu.document.getElementById("lanst").className="";
	}

	if(window.parent.menu.document.getElementById("wifist")!=null && 
		window.parent.menu.document.getElementById("wifist") != "undefinded") {
		window.parent.menu.document.getElementById("wifi2li").style.display="none";
		window.parent.menu.document.getElementById("wifi2li").style.display="none";
		window.parent.menu.document.getElementById("wifi5li").style.display="none";
		window.parent.menu.document.getElementById("wifist").className="";
		window.parent.menu.document.getElementById("wifi2").className="";
		window.parent.menu.document.getElementById("wifi5").className="";
		window.parent.menu.document.getElementById("wifi_guest").className="";
	}

	if(window.parent.menu.document.getElementById("asst")!=null && 
		window.parent.menu.document.getElementById("asst") != "undefinded") {
		window.parent.menu.document.getElementById("asst").className="submenuselect";
	}

	if(window.parent.menu.document.getElementById("stat")!=null && 
		window.parent.menu.document.getElementById("stat") != "undefinded") {
		window.parent.menu.document.getElementById("stat").className="";
	}
	if(window.parent.menu.document.getElementById("loac")!=null && 
		window.parent.menu.document.getElementById("loac") != "undefinded") {
		window.parent.menu.document.getElementById("loac").className="";
	}



  </script>
</head>
<body>

<div class="contentContainer">
	 	<table cellspacing='0' cellpadding='0' width="100%">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp">Impostazioni Base</a></li><li>|</li><li><a href="helpAssistenza.lp"><%=translate([==[Assistance]==])%></a></li>
			</ul>
		</div>	</table>
		
			<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a class="current">
		<div class="tab">
			<span class="tabIcon_help"></span>  
			<span class="contTabTxt transform"><%=translate([==[Assistance]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>
	
<div class='contentcontainer'>		
<div class='contentitem'>
<%
   writePageHeader_new()
   writeTableBlockNoTitle()
   local headerName = translate([==[Access to technical support for Telecom]==])
   local uppercaseHeader = string.upper(headerName)
   
   writeTableRowHeader_Header(2, uppercaseHeader, "") 
   --writeTableRowHeader_Header(2, translate([==[Access to technical support for Telecom]==]), "")
%>

    <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
    <tr>
		<td class="alignMid" bgcolor="#E9EEF2" align="center" width='55%' height="100"><a target="_blank" href="http://www.telecomitalia.it/"><img border="0" src="images/logo1.png"></a></td>
        <td class="tableHd alignMid" bgcolor="#E9EEF2"  align="center" width='55%' height="100"><a target="_blank" href="http://www.telecomitalia.it/"><div style="text-decoration:underline"><%=translate([==[Business Support]==])%></div></a></td>
    </tr>
    <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

    <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
    <tr>
        <td class="alignMid" bgcolor="white"  align="center" width='45%' height="100"><a target="_blank" href="http://assistenzatecnica.telecomitalia.it/"><img border="0" src="images/logo_at.gif" ></a></td>
        <td class="tableHd alignMid" bgcolor="white"  align="center" width='45%' height="100"><a href="http://assistenzatecnica.telecomitalia.it/" target="_blank"><div style="text-decoration:underline"><%=translate([==[Technical Support]==])%></div></a></td>
    </tr>
    <tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>

<%
   endBlock()
   endPage()
%>

</div>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>
