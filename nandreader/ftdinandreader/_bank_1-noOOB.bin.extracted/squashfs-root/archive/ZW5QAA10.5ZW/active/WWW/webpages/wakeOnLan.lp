<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/util.lp")
cgilua.lp.include("lp/device.lp")

local translate = translate
local POST = cgilua.POST
local hostPath = "Hosts.Host"
local host_slen = string.len(hostPath) + 1
local wol_flag = 0

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
  if (POST["wol_id"] ~= nil) and (POST["wol_id"] ~= "0") then
    local modify = {}
    table.insert(modify, { path = hostPath .. "." .. POST["wol_id"], param = {WolEnable = "true"} })
    setMBUS(modify)
    wol_flag = 1

  elseif (POST["remove_id"] ~= nil) and (POST["remove_id"] ~= "0") then
    local reply, error = mbus.modify(
      function()
        local reply1, error1 = mbus.deleteObjects{ path = hostPath .. "." .. POST["remove_id"] }
      end)
    saveall(0, 1)
    cgilua.redirect("save_alert.lp", { u="wakeOnLan.lp" })
    return
  end
end

local deviceList, error = getList(hostPath, nil, "Active", "HostName", "MACAddress", "IPAddress", "Interface", "IPv6Address")

local isRemote = isRemoteAccess()
%>

<script type="text/javascript">
//<![CDATA[
function submitWol(id)
{
  document.getElementById("wol_id").value = id;
  document.getElementById("wol_form").submit();
}

function removeHost(id)
{
  document.getElementById("remove_id").value = id;
  document.getElementById("wol_form").submit();
}

function cancelConfirm()
{
  document.getElementById("wolTable").style.display = "block";
  <% if wol_flag == 1 then %>
  document.getElementById("wolWarning").style.display = "none";
  <% end %>
}
//]]>
</script>
    <script language="JavaScript" type="text/javascript">
	if(window.parent.menu.document.getElementById("tele")!=null && 
		window.parent.menu.document.getElementById("tele") != "undefinded") {
		window.parent.menu.document.getElementById("tele").className="";
	}
	
	if(window.parent.menu.document.getElementById("teleSub")!=null && 
		window.parent.menu.document.getElementById("teleSub") != "undefinded") {
		window.parent.menu.document.getElementById("teleSub").style.display="none";	
	}

	if(window.parent.menu.document.getElementById("usbst")!=null && 
		window.parent.menu.document.getElementById("usbst") != "undefinded") {
		window.parent.menu.document.getElementById("usbst").className="";
	}

	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="";
	}

	if(window.parent.menu.document.getElementById("ipv6")!=null && 
		window.parent.menu.document.getElementById("ipv6") != "undefinded") {
		window.parent.menu.document.getElementById("ipv6").className="";
		if(window.parent.menu.document.getElementById("ipv6list")) {
			window.parent.menu.document.getElementById("ipv6firewall").className="";
			window.parent.menu.document.getElementById("ipv6list").style.display="none";
		}
	}

	if(window.parent.menu.document.getElementById("port")!=null && 
		window.parent.menu.document.getElementById("port") != "undefinded") {
		window.parent.menu.document.getElementById("port").className="";
	}

	if(window.parent.menu.document.getElementById("dns")!=null && 
		window.parent.menu.document.getElementById("dns") != "undefinded") {
		window.parent.menu.document.getElementById("dns").className="";
	}
	if(window.parent.menu.document.getElementById("firewa")!=null && 
		window.parent.menu.document.getElementById("firewa") != "undefinded") {
		window.parent.menu.document.getElementById("firewa").className="";
	}
	if(window.parent.menu.document.getElementById("urlfi")!=null && 
		window.parent.menu.document.getElementById("urlfi") != "undefinded") {
		window.parent.menu.document.getElementById("urlfi").className="";
	}

	if(window.parent.menu.document.getElementById("waon")!=null && 
		window.parent.menu.document.getElementById("waon") != "undefinded") {
		window.parent.menu.document.getElementById("waon").className="submenuselect1";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {
		window.parent.menu.document.getElementById("stru").className="";
	}
  </script>
</head>
<body>
<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="wakeOnLan.lp"><%=translate([==[Wake on LAN]==])%></a></li>
			</ul>
		</div>	
<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="wakeOnLan.lp" class="current">
				<div class="tab">
				<span class="tabIconWakeOnLan"></span>  
				<span class="contTabTxt transform"><%=translate([==[Wake on LAN]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>
<div class='contentcontainer'>
<div class='contentitem' id="wolTable">
<form method="POST" id="wol_form" action="">
<input type="hidden" name="wol_id" id="wol_id" value="0" />
<input type="hidden" name="remove_id" id="remove_id" value="0" />
<table cellspacing='0' cellpadding='0' width='100%' class="fontSize">
  <tr>
    <td class="midarea4">
      <%=translate([==[The feature allows you to send the command to remotely switch Ethernet devices designed to Wake on LAN. Warning: are activated a maximum of 8 devices for each Ethernet port]==])%>
    </td>
  </tr>
  <tr><td>&nbsp;</td></tr>
  <tr><td>
<% 
  writeBlockRowNoTitle()
  local ipv6Enable = getIPv6("Device.IP")
  if ipv6Enable == "true" then 
	writeTableContHeader(7, translate([==[HOST Name]==]), translate([==[MAC Address]==]), translate([==[IP Address]==]), translate([==[IPv6 Address]==]), translate([==[Ethernet Port]==]), "", "")
  else
	writeTableContHeader(6, translate([==[HOST Name]==]), translate([==[MAC Address]==]), translate([==[IP Address]==]), translate([==[Ethernet Port]==]), "", "")
  end
	
  local rowStyle = "oddrow"
  local count = 0
  for i,v in pairs(deviceList) do
    if v["Active"] == "false" and (v["Interface"] == "ETH.Phys.1" or v["Interface"] == "ETH.Phys.2" or v["Interface"] == "ETH.Phys.3" or v["Interface"] == "ETH.Phys.4") then
      local pathId = string.sub(v.path, host_slen + 1)
      local intf = "Ethernet " .. string.sub(v["Interface"], -1)
      count = count + 1
      if count%2==1 then
        rowStyle = "oddrow"
      else
        rowStyle = "evenrow"
      end

	if count <= 8 then
	 if isRemote==false then
		if ipv6Enable == "true" then 
			writeTableBlockRow(7, rowStyle, v["HostName"], v["MACAddress"], v["IPAddress"], v["IPv6Address"], intf, [[<a onclick="submitWol(]] .. pathId .. [[)" href="#"><div class="midarea6-1 mainButton">]] .. translate([==[Wake on LAN]==]) .. [[</div></a>]], [[<a onclick="removeHost(]] .. pathId .. [[)"><div class="midarea_WakeOnLan mainButton mainButton">]] .. translate([==[Remove]==]) .. [[</div></a>]])
		else
			writeTableBlockRow(6, rowStyle, v["HostName"], v["MACAddress"], v["IPAddress"], intf, [[<a onclick="submitWol(]] .. pathId .. [[)" href="#"><div class="midarea6-1 mainButton">]] .. translate([==[Wake on LAN]==]) .. [[</div></a>]], [[<a onclick="removeHost(]] .. pathId .. [[)"><div class="midarea_WakeOnLan mainButton mainButton">]] .. translate([==[Remove]==]) .. [[</div></a>]])
		end
	else
		if ipv6Enable == "true" then 
			writeTableBlockRow(7, rowStyle, v["HostName"], v["MACAddress"], v["IPAddress"], v["IPv6Address"], intf)
		else
			writeTableBlockRow(6, rowStyle, v["HostName"], v["MACAddress"], v["IPAddress"], intf)
		end
     end
    end
    end
  end
  endBlock()
%>
</td></tr></table>

<%
endPage()
%>
</form>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>

<% if wol_flag == 1 then %>
<div id="wolWarning" style="display:none" class="contentitem">
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
                          <td class="errorMessage"><%=translate([==[Warning]==])%></td></tr>
              <tr><td class="errorDesc"><p><%=translate([==[Power Control sent successfully. Warning: Wake on LAN does not provide a confirmation of receipt of the command from the remote device. In case of power failure, verify the correctness of the MAC address and the correct configuration / connection of the remote device.]==])%></p><br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				<a style="color:black" onclick="cancelConfirm()">
				<div class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
				</td>
			</tr>
		</table>
  </td></tr></table>
</div>
<script type="text/javascript">
document.getElementById("wolTable").style.display="none";
document.getElementById("wolWarning").style.display="";
</script>
<% end %>
</div>
</body>
</html>
