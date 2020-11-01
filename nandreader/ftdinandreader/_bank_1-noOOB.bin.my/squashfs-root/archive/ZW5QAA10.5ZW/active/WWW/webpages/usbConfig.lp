<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/browserDetect.js"></script>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/usb.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<%


local translate = translate
local POST = cgilua.POST
local print = cgilua.print

local usbConfig_page="block"
local resultko_unmount_page = "none"
if cgilua.QUERY["busy"]=="1" then
    usbConfig_page="none"
    resultko_unmount_page = "block"
end

local isRemote = isRemoteAccess()

local printer_info, usbdisk_info
local cs_state, cs_name = get_cs_state()
local ps_state = get_ps_state()

if cs_state == "true" then
	usbdisk_info = get_usbdisk_info(cs_name) 
end

if ps_state == "true" then
	printer_info = get_printer_info()
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    	local contentSharingState = POST["contentsharing"]
		local printSharingState = POST["printersharing"]	
		local save = 0

    	if POST["usbMgmFlag"]=="1" and (cs_state ~= contentSharingState or ps_state ~= printSharingState) then			

		-- enable/disable print sharing
		if ps_state ~= printSharingState then
			local ps_modify={}	
			table.insert(ps_modify, {path = "PrinterSharing.LPD", param = {Enable = printSharingState}})
			table.insert(ps_modify, {path = "ENV", param = {Value = printSharingState}, filter = "(== Name %PS_GUI_STATE)"})
			setMBUS(ps_modify)
			save = 1
		end

		-- enable/disable content sharing
		if cs_state ~= contentSharingState then
			local modify = {}
			table.insert(modify, {path="ContentSharing.CIFS", param= {Enable=contentSharingState}})
			setMBUS(modify)
			save = 1
		end
		
		if save == 1 then
			saveall(0, 1)
		end

		if cs_state ~= contentSharingState then
			--enable the content sharing, it should remount the usb.
			if contentSharingState == "true" then
				--remount usb 
				remount_usbdisk()
			end
		end

		cgilua.redirect("save_alert.lp", { u = "usbConfig.lp" })
		return		
	end

	-- umount usb disk
	if POST["removeMgmFlag"]=="1" then
		local modify = {}
		local umount_dev =  POST["RemoveDisk"]
		local isUsbDiskBusy, usdDiskPath = is_usbdisk_busy(umount_dev)

		-- Fix for TESSA 450 - Warning message: 53 is never show and the USB disk activities are breaked
	        -- if read/write operation is going on USB via GUI, flag isUsbDiskBusyGUI will be set
		-- Adding write operation i.e., uploading, to show warning message 53 as per spec	
		
		local isUsbDiskBusyGUI, usbMode = is_usbdisk_busy_GUI(umount_dev)

		-- umount usb disk
		if POST["ForceRemoveDisk"] == "1" and umount_dev ~= nil then       
			while isUsbDiskBusy do
 	                       if(isUsbDiskBusy == false) then
		                       break
		               end
			       isUsbDiskBusy, usdDiskPath = is_usbdisk_busy(umount_dev)
			       --isUsbDiskBusyGUI = is_usbdisk_busy_GUI(umount_dev)
			end 
			if isUsbDiskBusyGUI then
			      	stop_USB_activity_GUI(umount_dev)
			end
			table.insert(modify, {path=usdDiskPath, param = {DoUnMount="true"}})
			setMBUS(modify)
        
		else
			--If the usb is active, it should show the warning page.
			if isUsbDiskBusy or isUsbDiskBusyGUI then
				local to_page = "usbConfig.lp?busy=1&devname="..tostring(POST["RemoveDisk"])
				cgilua.redirect(to_page)
				return
			end

			table.insert(modify, {path=usdDiskPath, param = {DoUnMount="true"}})
			setMBUS(modify)
        
		end
		sleep(3)
		--Fix for Tessa 216
		--saveall(0,1)
		cgilua.redirect("usbConfig.lp")
		return
	end 
end
local connectUSBlist = getUSBNameList()
local usbLstStrng = ""
if connectUSBlist ~= nil then
	for i=1,#connectUSBlist do
		if connectUSBlist[i].name ~= nil then
			usbLstStrng = usbLstStrng.."|"..connectUSBlist[i].name
		end
	end
end
%>
<script language="javascript" src="js/script.js"></script>
<script language="javascript"> 
var isunMountTrigged = false;
function umount_submit(devname)
{
	isunMountTrigged = true;
	document.getElementById("remove").removeAttribute("href");
    document.getElementById("remove").onclick = null;
    document.getElementById("remove").className = "aClicked";
	document.getElementById("removeMgmFlag").value = "1";
	document.getElementById("RemoveDisk").value = devname;
	document.usbForm.submit();
}

function confirm_submit()
{
        document.getElementById("usbMgmFlag").value = "1";
        document.usbForm.submit();
}

function confirm_unmount_submit()
{
	document.getElementById("removeMgmFlag").value = "1";
	document.getElementById("ForceRemoveDisk").value = "1";
	document.usbForm.submit();
}

function save_submit()
{
	document.getElementById("save").removeAttribute("href");
	document.getElementById("save").onclick = null;
	document.getElementById("save").className = "aClicked";
	var cs_off=document.getElementById("cs2").checked;
	var ps_off=document.getElementById("ps2").checked;
	var gw_cs_state="<%=cs_state%>";
	var gw_ps_state="<%=ps_state%>";

	if(gw_cs_state=="true" && cs_off==true)
	{
		document.getElementById("confirmConfig").style.display="block";
		document.getElementById("usbConfig").style.display="none";
	}else{
		document.getElementById("usbMgmFlag").value = "1";
		document.usbForm.submit();
	}
}

function cancelForm()
{
	window.location = "usbConfig.lp";
}

//body onload
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
var usbliststr = "<%=usbLstStrng%>";
function usbResponse(data){
	var rsps = data.responseText;
	if(rsps.indexOf("true") > -1 && !isunMountTrigged){
		window.location = "usbConfig.lp";
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

</head>
	<body onload="javascript:linkToUsb();">
	<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
	<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="usbConfig.lp"></a></td><td align="right"><a href="usbStato.lp">Stato</a>&nbsp;&nbsp;|&nbsp;&nbsp;<em>Configura</em></td></tr>
	</table> -->
		<div class="contentContainer">
			<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp">
				<%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="usbConfig.lp"><%=translate([==[USB services]==])%></a></li> 
				</ul>
		</div>	

	<div class="contentTab" id="content">
	<ol id="tocTab">
		<li><a href="usbStato.lp" >
			<div class="tab">
			<span class="tabIcon_stusb"></span>  
			<span class="contTabTxt transform"><%=translate([==[USB services]==])%></span>
		</div><div class="clrBth"></div></a></li>
		<li><a href="usbConfig.lp" class="current margin15">
			<div class="tab">
				<span class="contTabTxt transform"><%=translate([==[Configure]==])%> <%=translate([==[USB services]==])%></span></div></a></li>
	</ol>
</div>

		<div class='contentcontainer' id="usbConfig" style="display:<%=usbConfig_page%>;">
			<hr>
		<div class='contentitem'>
		<form method="POST" name="usbForm" action="">
			<input type="hidden" id="RemoveDisk" name="RemoveDisk" value="<%=cgilua.QUERY["devname"]%>">
			<input type="hidden" id="ForceRemoveDisk" name="ForceRemoveDisk" value="0">
			<input type="hidden" id="usbMgmFlag" name="usbMgmFlag" value="0">
			<input type="hidden" id="removeMgmFlag" name="removeMgmFlag" value="0">
		<table border="0" width="100%" class="fontSize">
			<tr>
				<td>
        <table cellspacing='0' cellpadding='0' width='100%'>
			<tr>
				<td class="midarea2 tableTitle" style="font-weight:bold;"><%=translate([==[Management USB port]==])%></td>
			</tr>
			<tr>
				<td>
        <table width='100%' cellspacing='0' cellpadding='0' class="midarea4_telmain27 marleft40">
            <tr>
				<td class='wifiMidarea4-2' width='150' style="padding-left:0px;"><%=translate([==[Disk Sharing]==])%>:</td>
                <td>
                <input type="radio" value="true" id="cs1" name="contentsharing" />&nbsp;<%=translate([==[Enable]==])%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" value="false" id="cs2" name="contentsharing" />&nbsp;Disabilita</td></tr>
            <tr>
				<td class='wifiMidarea4-2' width='150' style="padding-left:0px;"><%=translate([==[Printer Sharing]==])%>:</td>
                <td>
                <input type="radio" value="true" id="ps1" name="printersharing" />&nbsp;<%=translate([==[Enable]==])%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" value="false" id="ps2" name="printersharing" />&nbsp;Disabilita</td>
			</tr>
            </table>
				</td>
			</tr>
		</table>

        <table cellspacing='0' cellpadding='0' style="text-align:center" class="">
            <tr>
				
				<td class="midarea4-2 verticalAlign" style="float:right;padding-left:120px;">
					<a onclick="save_submit()" href="#" id='save' style="float:right">
						<div class="midarea6-1 mainButton"><%=translate([==[Save]==])%></div>
					</a>
				</td>
				<td class="midarea4-3 padleft50 verticalAlign">
					<%if usbdisk_info==nil and printer_info==nil then%>
					<a href = "advance.lp">
						<div class="midarea6-1 secondaryButton"><%=translate([==[Back]==])%></div>
					</a>
					<%end%>
				</td>
			</tr>
		</table>
				</td>
			</tr>
		</table>
					<%
					if (usbdisk_info~=nil or printer_info~=nil)then 
					-- when no usb disk, not display below tables
					%>
			<tr>
				<td>
        <table cellspacing='0' cellpadding='0' width='100%' class="fontSize" style="margin-left:2px;">
			<tr >
				<!-- <td style="font-weight:bold;">
				</td> -->
				<td class="midarea2 tableTitle"><p><%=translate([==[USB devices]==])%></p></td></tr>
				<tr ><td>
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
                local part_name = {}
                local part_size = {}
                local sharing_addr = {}
                local sharing_addr_smb = {}
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
            <tr>
				<td width='33%' class='<%=rowStyle%>' colspan='6'></td>
			</tr>
				<%
                    for j=1,part_num do
						if j == 1 then
				%>
			<tr bgcolor="#f8f4f1">
				<td rowspan="<%=part_num%>" class="<%=rowStyle%>"><%=usbdisk_info[i].description%></td>
				<%
						end
						part_name[i]=tostring(usbdisk_info[i].part[j].friendly_name)
						part_size[i] = tostring(usbdisk_info[i].part[j].part_size)
						sharing_addr[i] = string.gsub(tostring(usbdisk_info[i].part[j].sharing_addr), "\\", "\\\\")
						sharing_addr_smb[i] = tostring(usbdisk_info[i].part[j].sharing_addr_smb)
						if usbdisk_info[i].part[j].ok == 0 then
						%>
				<td class="<%=rowStyle%>" colspan="5"><%=translate([==[Device not recognized. Try to run from a PC Safely]==])%></td>
			</tr>
						
						<%else%>
						<% if j == 1 then%>
			<td bgcolor="#f8f4f1" rowspan="<%=part_num%>" class="<%=rowStyle%>"><%=usbdisk_info[i].usbversion%></td>
						<%end%>
			<td bgcolor="#f8f4f1" class="<%=rowStyle%>">
								<script type="text/javascript">
									show_link("<%=sharing_addr[i]%>","<%=sharing_addr_smb[i]%>");
								</script>
			</td>
			<td bgcolor="#f8f4f1" class="<%=rowStyle%>"><%=part_size[i]%></td>
			<td bgcolor="#f8f4f1" class="<%=rowStyle%>"><%=part_name[i]%></td>
						<% if j == 1 then%>
			<td bgcolor="#f8f4f1" rowspan="<%=part_num%>" class="<%=rowStyle%>" width="82" style="padding-top:10px">
						<% if isRemote==false then%>
					<a href="#" id="remove" onclick="umount_submit('<%=usbdisk_info[i].devname%>')">
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
            <tr>
				<td class="<%=rowStyle%>" colspan='6'></td>
			</tr>
				</td>
			</tr>
             <%end%>
		</table>
			 <%end%>
  


              
                <%
                if printer_info~=nil then
                %>
            <br>
            <table class='edittable width750 marleft40'  width='100%' cellspacing='0' cellpadding='0' border='0'>
                <tr>
					<td colspan='3' align='center' class="midarea2 tableTitle"><%=translate([==[USB Print Server]==])%></td>
				</tr>
                <tr>
					<td colspan='3'></td>
				</tr>
                <tr>
					<td colspan='3'></td>
				</tr>
                <tr>
					<th align='left' class="tableHd" ><%=translate([==[Description]==])%></th>
					<th align='left' class="tableHd" ><%=translate([==[Standard USB]==])%></th>
					<th align='left' class="tableHd"><%=translate([==[Device Address]==])%></th>
				</tr>
				<tr>
					<td colspan='3'> <img src='images/spacer.gif' border='0' width='1' height='5' alt=''></td>
				</tr>
				<tr>
					<td colspan='3'></td>
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
                <td bgcolor="#f8f4f1" class="<%=rowStyle%>"><%=printer_info[i].description%></td>
                <td bgcolor="#f8f4f1" class="<%=rowStyle%>"><%=printer_info[i].usbversion%></td>
                <td bgcolor="#f8f4f1" class="<%=rowStyle%>"><%=path_name%></td>
			</tr>
            <tr>
				<td class="<%=rowStyle%>" colspan='3'></td>
			</tr>
			</table>  
		<%end%>
	
		<%end%>              
				
            <table cellspacing='0' cellpadding='0' width='100%' class="martop15" style="text-align:center">
					<td style="width:30%">
						</td>
						<td class="midarea3" style="vertical-align:top;width:300px;">
					<a href ="advance.lp">
						<div class="midarea6-1 secondaryButton"> <%=translate([==[Back]==])%> </div></a>
				</td>
							</tr>
			</table>
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
				<div id="confirmConfig" style="display:none">
			<%cgilua.lp.include("webparts/USBShareOff.lp")%>
		</div>
					<div id="unmount" style="display:<%=resultko_unmount_page%>">
			<%cgilua.lp.include("webparts/USBEnvRemove.lp")%>
		</div>
	</body>
</html>

<script language="javascript">
var cs_state= "<%=cs_state%>";
var ps_state= "<%=ps_state%>";
if(cs_state=="true"){
        document.getElementById("cs1").checked = true;
}else{
        document.getElementById("cs2").checked = true;
}
if(ps_state=="true"){
        document.getElementById("ps1").checked = true;
}else{
        document.getElementById("ps2").checked = true;
}
</script>
