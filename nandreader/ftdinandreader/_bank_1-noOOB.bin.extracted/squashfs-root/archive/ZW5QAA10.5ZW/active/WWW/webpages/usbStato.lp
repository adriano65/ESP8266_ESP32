<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/browserDetect.js"></script>
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
		window.parent.menu.document.getElementById("usbst").className="submenuselect1";
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
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {
		window.parent.menu.document.getElementById("stru").className="";
	}		
  </script>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/usb.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<%

--local tprint = require("tableprint")
local translate = translate
local POST = cgilua.POST

local usbState_page="block"
local resultko_unmount_page = "none"
if cgilua.QUERY["busy"]=="1" then
    usbState_page="none"
    resultko_unmount_page = "block"
end

local isRemote = isRemoteAccess()
local printer_info, usbdisk_info
local cs_state, cs_name = get_cs_state()
local ps_state = get_ps_state()

local cs_state_show = translate([==[Disabled]==])
if cs_state == "true" then
	cs_state_show = translate([==[Enabled]==]) 
	usbdisk_info = get_usbdisk_info(cs_name) 
end

local ps_state_show = translate([==[Disabled]==])
if ps_state == "true" then
	ps_state_show = translate([==[Enabled]==])
	printer_info = get_printer_info()
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then    
	local modify = {}
	local umount_dev =  POST["RemoveDisk"]
	local isUsbDiskBusy, usdDiskPath = is_usbdisk_busy(umount_dev)

	--  Fix for TESSA 450 - Warning message:53 is never show and the USB disk activities are breaked 
	-- if read/write operation is going on USB via GUI, flag isUsbDiskBusyGUI will be set
	local isUsbDiskBusyGUI = is_usbdisk_busy_GUI(umount_dev)

	-- umount usb disk
	if POST["ForceRemoveDisk"] == "1" and umount_dev ~= nil then        
	        	while isUsbDiskBusy do
	        		if(isUsbDiskBusy == false) then
		        	        break
			        end
		        	isUsbDiskBusy, usdDiskPath = is_usbdisk_busy(umount_dev)
		        end
		        if isUsbDiskBusyGUI then
		        	stop_USB_activity_GUI(umount_dev)
		        end
		table.insert(modify, {path=usdDiskPath, param = {DoUnMount="true"}})
		setMBUS(modify)
        
	else
		--If the usb is active, it should show the warning page.
		if isUsbDiskBusy or isUsbDiskBusyGUI then
			local to_page = "usbStato.lp?busy=1&devname="..tostring(POST["RemoveDisk"])
			cgilua.redirect(to_page)
			return
		end

		table.insert(modify, {path=usdDiskPath, param = {DoUnMount="true"}})
		setMBUS(modify)
        
	end
	sleep(3)
	--Fix for Tessa216
	--saveall(0,1)
	cgilua.redirect("usbStato.lp")
	return
end -- POST end
local connectUSBlist = getUSBNameList()
%>

<script language="javascript" src="js/script.js"></script>
<script language="javascript">
var isunMountTrigged=false;
function umount_submit(devname)
{
	isunMountTrigged = true;
	document.getElementById("remove").removeAttribute("href");
    document.getElementById("remove").onclick = null;
    document.getElementById("remove").className = "aClicked";
    document.getElementById("RemoveDisk").value = devname;
    document.usbForm.submit();
}

function confirm_unmount_submit()
{
    document.getElementById("ForceRemoveDisk").value = "1";
    document.usbForm.submit();
}

function cancelForm()
{
    document.getElementById("usbState").style.display="block";
    document.getElementById("resultko_unmount").style.display="none";
}

function linkToUsb()
{	
	
		var id = "";
	if(window.parent.menu.document.getElementById("home")!=null && 
		window.parent.menu.document.getElementById("home") != "undefinded") {
		window.parent.menu.document.getElementById("home").style.display="block";
		window.parent.menu.document.getElementById("home").className="";
	}
	if(window.parent.menu.document.getElementById("base")!=null && 
		window.parent.menu.document.getElementById("base") != "undefinded") {
		window.parent.menu.document.getElementById("base").className="block";
	}
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
		window.parent.menu.document.getElementById("usbst").className="submenuselect1";
	}
	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="";
	}
	if(window.parent.menu.document.getElementById("ipv6")!=null && 
		window.parent.menu.document.getElementById("ipv6") != "undefinded") {
		window.parent.menu.document.getElementById("ipv6").className="";
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
	/*if(window.parent.menu.document.getElementById("reac")!=null && 
		window.parent.menu.document.getElementById("reac") != "undefinded") {	
		window.parent.menu.document.getElementById("reac").className="";
	}*/
	if(window.parent.menu.document.getElementById("waon")!=null && 
		window.parent.menu.document.getElementById("waon") != "undefinded") {	
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {	
		window.parent.menu.document.getElementById("stru").className="";
	}
	if(window.parent.menu.document.getElementById("advance")!=null && 
		window.parent.menu.document.getElementById("advance") != "undefinded") {	
		window.parent.menu.document.getElementById("advance").className="Icons";
	}
	if(window.parent.menu.document.getElementById("d3")!=null && 
		window.parent.menu.document.getElementById("d3") != "undefinded") {
		window.parent.menu.document.getElementById("d3").style.display="block";
	}
	
}

<%
local usbLstStrng = ""
if connectUSBlist ~= nil then
	for i=1,#connectUSBlist do
		if connectUSBlist[i].name ~= nil then
			usbLstStrng = usbLstStrng.."|"..connectUSBlist[i].name
		end
	end
end
%>
var usbliststr = "<%=usbLstStrng%>";
function usbResponse(data){
	var rsps = data.responseText;
	if(rsps.indexOf("true") > -1 && !isunMountTrigged){		 
		window.location = "usbStato.lp";
	}
	setTimeout(function() {
	validateUSBEjct();},3000);	 
}
function validateUSBEjct(){
	if(usbliststr != null && usbliststr != ""){
		var urlStr = "/application_ajax.lp"
		var params="isUSB=true&usbNames="+usbliststr;		
		sajax_get(urlStr, params, usbResponse);		 	
	}
}
validateUSBEjct();
</script>
<body onload="javascript:linkToUsb();">
<div class="contentContainer">
	<div class="breadCrumbContainer">
		<ul class="brdCrumb">
			<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="usbStato.lp"><%=translate([==[USB services]==])%></a></li> 
		</ul>
	</div>
		
	<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="usbStato.lp" class="current">
		<div class="tab">
			<span class="tabIcon_stusb"></span>  
			<span class="contTabTxt transform"><%=translate([==[USB services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemote==false then%> 
			<li><a class="margin15" href="usbConfig.lp">
		<div class="tab">
			<span class="contTabTxt transform"><%=translate([==[Configure]==])%> <%=translate([==[USB services]==])%></span></div></a></li>
		<% end %> 
		</ol>
	</div>
	
	<div class='contentcontainer' id="usbState" style="display:<%=usbState_page%>;">
		<hr>
		<div class='contentitem'>
		<form method="POST" name="usbForm" action="">
		<input type="hidden" id="RemoveDisk" name="RemoveDisk" value="<%=cgilua.QUERY["devname"]%>" />
		<input type="hidden" id="ForceRemoveDisk" name="ForceRemoveDisk" value="0" />
		<table border="0" width="100%" class="fontSize">
			<tr><td>
			<table cellspacing='0' cellpadding='0' width='100%'>
				<tr>
					<td class='midarea2 tableTitle'><%=translate([==[Management USB port]==])%></td>
				</tr>
				<tr>
				<td>
				<table width='100%' cellspacing='0' cellpadding='0' class="midarea4_telmain27 marleft40">
					<tr>
						<td width='300' style="padding:10px 0 0 0;"><%=translate([==[Disk Sharing]==])%>:</td>
						<td><span><%=cs_state_show%></span></td>
					</tr>
					<tr>
						<td width='300' style="padding:10px 0 0 0 ;"><%=translate([==[Printer Sharing]==])%>:</td>
						<td><span><%=ps_state_show%></span></td>
					</tr>
				</table>
				</td>
				</tr> 
			</table>

			</td>
			</tr>
		</table>
 		<%
		if usbdisk_info~=nil or printer_info~=nil then 
		-- when no usb disk, not display below tables
		%>			
			<table cellspacing='0' cellpadding='0' width='100%' class="fontSize" style="margin-left:2px;">
			<tr><td class="midarea2 tableTitle padtop10"><%=translate([==[USB devices]==])%></td></tr>
			<tr><td>
				<%if usbdisk_info~=nil then%>
				<table class='edittable width750 marleft40' width='100%' cellspacing='0' cellpadding='0' border='0'>
					<tr>
						<td colspan='6' align='center' class="midarea2 tableTitle" style="height:25px;padding-left:0px"><%=translate([==[Remote Disk]==])%></td>
					</tr>
					
					<tr>
						<th width="20%" class="tableHd" align='left' style="padding-left:0px;"><%=translate([==[Description]==])%></th>
						<th width="5%" class="tableHd" align='left'><%=translate([==[Standard USB]==])%></th>
						<th width="35%" class="tableHd" align='left'><%=translate([==[Device Address]==])%></th>
						<th width="20%" class="tableHd" align='left'><%=translate([==[Dimensions]==]).." "%></th>
						<th width="15%" class="tableHd" align='left'><%=translate([==[Partition Name]==])%></th>
						<th width="5%" class="tableHd" align='left'><%=translate([==[Removal]==])%></th>
					</tr>

					<%
					local device_part_name = {}
					local part_name = {}
					local part_size = {}
					local sharing_addr = {}
					local sharing_addr_smb = {}
					local remote_addr
					local rowStyle = "oddrow_firewall"
					local rowNum = 0

					for i=1,#usbdisk_info do
						part_name[i] = ""
						part_size[i] = ""
						sharing_addr[i] = ""
						sharing_addr_smb[i] = ""
						local part_num = #usbdisk_info[i].part

						rowNum = rowNum + 1
						if rowNum%2==1 then
							rowStyle = "oddrow_firewall"
						else
							rowStyle = "evenrow_firewall"
						end
					%>

					<%
						for j=1,part_num do
						if j == 1 then
					%>
					<tr>
					<td rowspan="<%=part_num%>" class="<%=rowStyle%> padcell"><%=usbdisk_info[i].description%></td>
					<%
						end
							device_part_name[i]=tostring(usbdisk_info[i].part[j].device_name)
							part_name[i]=tostring(usbdisk_info[i].part[j].friendly_name)
							part_size[i] = tostring(usbdisk_info[i].part[j].part_size)
							sharing_addr[i] = string.gsub(tostring(usbdisk_info[i].part[j].sharing_addr), "\\", "\\\\")
							sharing_addr_smb[i] = tostring(usbdisk_info[i].part[j].sharing_addr_smb)
							remote_addr = "/var/usbmount/" .. tostring(device_part_name[i])
							if usbdisk_info[i].part[j].ok == 0 then
							%>
					<td class="<%=rowStyle%> padcell" colspan="5"><%=translate([==[Device not recognized. Try to run from a PC Safely]==])%></td>
					</tr>
					<%
					else
					%>
					<% if j == 1 then%>
					<td rowspan="<%=part_num%>" class="<%=rowStyle%> padcell"><%=usbdisk_info[i].usbversion%></td>
						<%end%>
					<td class="<%=rowStyle%> padcell">
							<script type="text/javascript">
									show_link("<%=sharing_addr[i]%>","<%=sharing_addr_smb[i]%>");
							</script>
					</td>
					<td class="<%=rowStyle%> padcell"><%=part_size[i]%></td>
					<td class="<%=rowStyle%> padcell">
						<%if isRemote then%>
						<a href="javascript:window.location.href='remoteAccessUsb.lp?filePath=<%=remote_addr%>';"/><%=part_name[i]%></a>
						<%else%>
						<a href="javascript:window.location.href='remoteAccessUsb.lp?filePath=<%=remote_addr%>';"/><%=part_name[i]%></a>
						<%end%>
					</td>
					<% if j == 1 then%>
					<td rowspan="<%=part_num%>" class="<%=rowStyle%> padcell" width="82" class="alignMid">
					<% if isRemote==false then%>
					<a href="#" onclick="umount_submit('<%=usbdisk_info[i].devname%>')"  id="remove" class="alignMid">
					<div class="midarea6-1 mainButton"><%=translate([==[Remove]==])%></div>
					</a>
					<%end%>
					</td>
					<%end%>
					</tr>
					<%
					end
					end
					%>

						
							</td>
							</tr>
							<%end%>
						</table>
					<%end%>
                
					<%
					if printer_info~=nil then
					%>
					<br>
						<table class='edittable width750 marleft40' width='100%' cellspacing='0' cellpadding='0' border='0'>
						<tr>
							<td colspan='3' align='center' class="midarea2 tableTitle"><%=translate([==[USB Print Server]==])%></td>
						</tr>
						
                		<tr>
							<th align='left' class="tableHd"><%=translate([==[Description]==])%></th>
							<th align='left' class="tableHd"><%=translate([==[Standard USB]==])%></th>
							<th align='left' class="tableHd"><%=translate([==[Device Address]==])%></th>
						</tr>
						<tr>
							<td colspan="3"> <img width="1" height="5" border="0" alt="" src="images/spacer.gif"></td>
						</tr>
						<%
						local rowStyle = "oddrow_firewall"
						local rowNum = 0
						for i = 1, #printer_info do
							if printer_info[i].name == "" then
								printer_info[i].name="PRINTER"
							end
							rowNum = rowNum + 1
							if rowNum%2==1 then
								rowStyle = "oddrow_firewall"
							else
								rowStyle = "evenrow_firewall"
							end
						local path_name = "\\\\" .. cs_name .."\\" .. printer_info[i].name
						%>
						<tr>
							<td width='33%' class='<%=rowStyle%>' colspan='3'></td>
						</tr>
						<tr>
							<td class="<%=rowStyle%>"><%=printer_info[i].description%></td>
							<td class="<%=rowStyle%>"><%=printer_info[i].usbversion%></td>
							<td class="<%=rowStyle%>"><%=path_name%></td>
						</tr>
						<tr>
							<td class="<%=rowStyle%>" colspan='3'></td>
						</tr>
					</table>
				<%end%>
		<%end%> 

			
		</td>
		</tr>
	</table>
	


						       <%
end -- for usbConfig void page
%>
			

		
	</form>
				<script src="js/antiCSRF.js" type="text/javascript"></script>
		</div>
	</div>
		<div id="resultko_unmount" style="display: <%=resultko_unmount_page%>;">
<%cgilua.lp.include("webparts/USBEnvRemove.lp")%>	
		</div>
	</body>
	</html>
