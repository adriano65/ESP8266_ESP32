<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Modem Telecom Italia</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <!-- <link rel="stylesheet" href="css/style.css" type="text/css" /> -->
  <link rel="stylesheet" href="css/master.css" type="text/css" />
  <script language="javascript" type="text/javascript" src="js/script.js"></script>
  <script language="JavaScript" type="text/javascript">
    if(window.parent.menu.document.getElementById("base")!=null && 
		window.parent.menu.document.getElementById("base") != "undefinded") {

	}   
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
		window.parent.menu.document.getElementById("wifi5li").style.display="none";
		window.parent.menu.document.getElementById("wifi_guestli").style.display="none";
		window.parent.menu.document.getElementById("wifist").className="";
		window.parent.menu.document.getElementById("wifi2").className="";
		window.parent.menu.document.getElementById("wifi5").className="";
		window.parent.menu.document.getElementById("wifi_guest").className="";
	}

	if(window.parent.menu.document.getElementById("asst")!=null && 
		window.parent.menu.document.getElementById("asst") != "undefinded") {
		window.parent.menu.document.getElementById("asst").className="";
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

<% cgilua.lp.include("lp/menu.lp") %>
<% cgilua.lp.include("lp/device.lp") %>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li>
			</ul>
		</div>	

		


<div class='contentcontainer'>
<div class='contentitem'>
<table cellspacing="0" cellpadding="0" border="0"  class="table2 fontSize width750" style="padding-top:10px;margin-left:0px;">
  
  <tr> 
    <td class="tablecontaint2 padleft40 fontSize">
      <p><%=translate([==[The modem Telecom Italia offers more services]==])%>.</p><p>&nbsp;</p>
      <p><%=translate([==[Those services enable you to protect your network, to ease sharing of games and applications with other people on the Internet, or manage your local network.]==])%></p>
      <table border='0' cellspacing='0' cellpadding='0' class="marleft40">
	  <tr><td colspan='3'><img src='/images/spacer.gif' width='0' height='25' border='0' alt=''><br></td></tr>
	  <tr>
	  <td><img src='/images/spacer.gif' width='265' height='1' border='0' alt=''><br></td>
	  <td><img src='/images/spacer.gif' width='20' height='1' border='0' alt=''><br></td>
	  <td><img src='/images/spacer.gif' width='265' height='1' border='0' alt=''><br></td></tr>
	  
      <%
	printLeftBlock("wanStatus.lp", "bbc__xl.png", translate([==[Connection Status]==]))
	printRightBlock("statoServizi.lp", "cintorxl.png", translate([==[Telecom Italia Services]==]))
	printLeftBlock("lanStatus.lp", "ieth__xl.png", "LAN")
	printRightBlock("wlanStatus.lp?wifiPage=wifi", "iwla__xl.png", "Wi-Fi")
        printLeftBlock("helpAssistenza.lp", "tech__xl.png", translate([==[Assistance]==]))
	printRightBlock("statisticsAG.lp", "stxx__xl.png", translate([==[Statistics]==]))
	if isRemoteAccess()==false then
	        printLeftBlock("loginMgm.lp", "isec__xl.png", translate([==[Local Access]==]))
	end
      %>
</table></td></tr></table></td></tr></table>
</div>
</div>
</div>
</body>
</html>
