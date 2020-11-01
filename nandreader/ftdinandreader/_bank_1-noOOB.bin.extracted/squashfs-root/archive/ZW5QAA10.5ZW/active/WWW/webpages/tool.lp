<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/portmap.js"></script>

<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/common.lp")
cgilua.lp.include("lp/style.lp")
cgilua.lp.include("lp/usb.lp")
cgilua.lp.include("lp/voip.lp")
cgilua.lp.include("lp/xml.lp")

local translate = translate
local POST=cgilua.POST
local TI_info = getTIInfo()

local cs_state, cs_name = get_cs_state()
local usbdisk_info
if cs_state == "true" then
    usbdisk_info = get_usbdisk_info()
end

local logPath = "TI_STORE.TiUserIntf"
local logStop = 0
local logAddress = ""
local logError = ""
local logErrorNoUSB = translate([==[Could not activate log file! Verify that the service "Remote Disk" is active and at least]==]) .. " " .. "<br/>" .. translate([==[one USB device is connected to the modem.]==])
local logErrorUSB = translate([==[Can not perform the requested operation on the connected USB devices.]==]) .. " " .. "<br/>" .. translate([==[Connect a new device and try again.]==])

--power description
local powerGreen=translate([==[Modem OK]==])
local powerRed=translate([==[Diagnostic Test Failed]==])
local powerFlashingGreen=translate([==[Reading/Writing on USB device]==])
local powerOff=""

--adsl description
local linkName = "ADSL/FIBRA"
local linkOff = translate([==[Physical connection is not determined]==])
local linkGreen = linkOff
local linkFlashingGreen = linkOff
local reply, error = mbus.getParameters{ path = "WANSensing", param = "CurrentMode"}
local wanConnType = reply["WANSensing"][1].param["CurrentMode"]
if wanConnType == "ADSL" then
  linkName = "ADSL"
  linkGreen = translate([==[ADSL line synchronized]==])
  linkFlashingGreen = translate([==[ADSL Synchronization in progress]==])
  linkOff = translate([==[ADSL line unsynchronized]==])
elseif wanConnType == "ETH" then
  linkName = "FIBRA"
  linkGreen = translate([==[WAN Ethernet connection active]==])
  linkFlashingGreen = ""
  linkOff = translate([==[WAN Ethernet connection is not active]==])
elseif wanConnType == "VDSL" then
  linkName = "ADSL"
  linkGreen = translate([==[VDSL line synchronized]==])
  linkFlashingGreen = translate([==[VDSL Synchronization in progress]==])
  linkOff = translate([==[VDSL line unsynchronized]==])
end

--internet description
local internetGreen=translate([==[Active data connection routed]==])
local internetOff=translate([==[Routed data connection is not active]==])

local wifiGreenDesc=translate([==[The Wi-Fi active radio interfaces are configured in secure mode (WPA-PSK)]==])
local wifiRedDesc=translate([==[At least one of the Wi-Fi radio interfaces is turned on and used in non safe mode]==]) .. " " .. "<br/>" .. translate([==[(WEP or disabled)]==])
local wifiFlashingGreen=translate([==[Procedure WPS (Wireless Protected Setup) in the course]==])
local wifiOff=translate([==[Both Wi-Fi radio interfaces are not active]==])

--service description
local serviceGreenDesc=translate([==[Additional services are configured correctly]==])
local serviceRedDesc=translate([==[Additional services not properly configured. Power cycle the modem]==])
local serviceFlashingGreen=translate([==[Configuration Tasks of ongoing service]==])
local serviceOff=translate([==[Additional services are not configured]==])

--DECT description
local DECTGreen=translate([==[Active interface, and properly used by at least one cordless DECT]==])
local DECTRed=translate([==[Interface is active but not used: Cordless DECT is not registered or not associated]==]) .. " " .. "<br/>" .. translate([==[with error number or VoIP]==])
local DECTFlashingGreen=translate([==[Pairing cordless underway]==])
local DECTOff=translate([==[Interface is not active]==])

--Line1 description
local cli_in = getAllInCallNum1("Device.Services.VoiceService.3.VoiceProfile.1.Line.1")
local cli_out = getAllOutCallNum1("Device.Services.VoiceService.3.VoiceProfile.1.Line.1")
if cli_in==nil then
    cli_in = ""
end
if cli_out==nil then
    cli_out = ""
end
--[[local LineOneGreen=translate([==[Interface OK. Number associated with input]==]) .. " " .. cli_in .. " , " .. translate([==[number associated output]==]) .. " " .. cli_out .. " "]]

local LineOneGreen=translate([==[Active Interface toward PSTN]==])
local LineOneGreen1=translate([==[OK Interface. Associated Number: <<CLI>>]==])
local LineOneFlashingRed=translate([==[Fault in the course]==])

local LineOneRed=translate([==[Error VoIP port]==])
local LineOneFlashingGreen=translate([==[Interface OK, but no number associated with other terminal.]==])
local LineOneOff=translate([==[Interface is not active]==])
local lineOneNoNum=isFXSMapNumExist("Device.Services.VoiceService.1.PhyInterface.1")
local lineOneEnable=getFXSEnable("Device.Services.VoiceService.1.PhyInterface.1")
if lineOneEnable=="false" then
    LineOneOff=translate([==[Interface is not active]==])
elseif lineOneEnable=="true" and lineOneNoNum=="true" then
    LineOneOff=translate([==[Active interface, no other terminal]==])
end

--Line2 description
local cli_two_in = getAllInCallNum1("Device.Services.VoiceService.3.VoiceProfile.1.Line.1")
local cli_two_out = getAllOutCallNum1("Device.Services.VoiceService.3.VoiceProfile.1.Line.1")
if cli_two_in==nil then
    cli_two_in = ""
end
if cli_two_out==nil then
    cli_two_out = ""
end
--[[local LineTwoGreen=translate([==[Interface OK. Number associated with input]==]) .. " " .. cli_two_in .. " , " .. translate([==[number associated output]==]) .. " " .. cli_two_out .. " "]]
local LineTwoGreen=translate([==[Active Interface toward PSTN]==])
local LineTwoGreen1=translate([==[OK Interface. Associated Number: <<CLI>>]==])
local LineTwoFlashingRed=translate([==[Fault in the course]==])
local LineTwoRed=translate([==[Error VoIP port]==])
local LineTwoFlashingGreen=translate([==[Interface OK, but no number associated with other terminal.]==])
local LineTwoOff=translate([==[Interface is not active]==])
local lineTwoNoNum=isFXSMapNumExist("Device.Services.VoiceService.1.PhyInterface.2")
local lineTwoEnable=getFXSEnable("Device.Services.VoiceService.1.PhyInterface.2")
if lineTwoEnable=="false" then
    LineTwoOff=translate([==[Interface is not active]==])
elseif lineTwoEnable=="true" and lineTwoNoNum=="true" then
    LineTwoOff=translate([==[Active interface, no other terminal]==])
end

local ledDesc = {	Power={Green=powerGreen, Red=powerRed, FlashingGreen=powerFlashingGreen, Off=powerOff},
			ADSL={Green=linkGreen, FlashingGreen=linkFlashingGreen, Off=linkOff},
			Internet={Green=internetGreen, Off=internetOff},
			Wifi={Green=wifiGreenDesc, Red=wifiRedDesc, FlashingGreen=wifiFlashingGreen, Off=wifiOff},
			Service={Green=serviceGreenDesc, Red=serviceRedDesc, FlashingGreen=serviceFlashingGreen, Off=serviceOff},
			DECT={Green=DECTGreen, Red=DECTRed, FlashingGreen=DECTFlashingGreen, Off=DECTOff},
			Line1={Green=LineOneGreen, Red=LineOneRed, FlashingGreen=LineOneFlashingGreen, Off=LineOneOff, FlashingRed=LineOneFlashingRed},
			Line2={Green=LineTwoGreen, Red=LineTwoRed, FlashingGreen=LineTwoFlashingGreen, Off=LineTwoOff, FlashingRed=LineTwoFlashingRed}
			}
local led_list = { "Power", "ADSL", "Internet", "Wifi", "Service", "DECT", "Line1", "Line2" }

local function getVendorLogFilename()
  local result = ""
  local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_File_1_tmp)"}
  if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
    result = reply["ENV"][1].param["Value"] or ""
  end
  return result
end

local function getVendorLogAddress()
  local result = ""
  local addr = ""
  local reply, error = mbus.getParameters{ path = logPath, param = {"logPath"} }
  if reply[logPath][1]~=nil and reply[logPath][1].param~=nil then
    result = reply[logPath][1].param["logPath"] or ""
  end
  if result ~= "" then
	  addr = "\\\\modemtelecom\\Disk_"..string.gsub(result, ".*sd", "")
  end
  return addr
end


function isDiskMoreThan2MB(freeDiskSize)
	local isPos = string.find(freeDiskSize, "GB")
	if isPos ~= nil then
		return true
	end
	
	local isPos = string.find(freeDiskSize, "MB")
	if isPos ~= nil then
		local diskSize = string.gsub(freeDiskSize, " MB", "")
		if tonumber(diskSize) >= 2 then
			return true
		end
	end
	
	return false
end

function isUsbReadOnly()
    for i=1, #usbdisk_info do
        for j=1,#usbdisk_info[i].part do
            local disk = usbdisk_info[i].part[j]
            if disk.readOnly ~= "true" then
                return false
            end
        end
    end
    return true
end

--Post Handler
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    --customer reset is done by restartAGing.lp
    --save and restart the model are done in restartingAG.lp
    
    --generate the backup file
    if POST["backupFlag"]=="1" then
        --Delete the old file if it is existed
        os.remove ("/tmp/AGConfig.cfg")
        os.remove ("/tmp/AGConfig.kry")

        --Create the xml file. 
        xmlCreateBR()

         mbus.modify(
         function()
                     mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {writeLog = "Backup: generated a backup file"}}
                             end)
        --Fix For CQ CPE_P00120870 Starts
        local mode = 1
        local err = xmlEncryptAndDecrypt(mode)

	--Fix for security issue in TI_M5
	--Merge Label MOD_ARCHIVE_DANT-V_r10.5_r10.5.e_WIPRO_V1.0.2-x from TI_BHS
        --Delete the AGConfig.xml file after encryption is completed
        os.remove ("/tmp/AGConfig.xml")

	if err == 1 then
        	cgilua.redirect("resultKO.lp")
                return
        else 
                os.rename("/tmp/AGConfig.kry", "/tmp/AGConfig.cfg")
                --Fix For CQ CPE_P00120870 Ends
                cgilua.redirect("/AGConfig.cfg")
                return
        end


    --restore the backup file
    elseif POST["restoreFlag"]=="1" then
        sleep(2)
        --Delete the old file if it is existed
        os.remove ("/tmp/AGConfig.cfg")
        os.remove ("/tmp/AGConfig.xml")

        --Change the upload file name to suit for decrypting input file name.
        local fileName = cgilua.POST["restoreFile"].filename
        local filePath="/tmp/" .. fileName
        os.rename(filePath, "/tmp/AGConfig.kry")

        mbus.modify(
            function()
                mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {writeLog = "Restore: restored a backup file"}}
            end)

	--Fix for Tessa 324
	--M4 .cfg file is unencrypted so no need to do decryption over an unencrypted .cfg file
	local temp = "telecomitalia"
	local path = "/tmp/AGConfig.kry"
	local fh = io.open(path)
	if fh~=nil then
		content = fh:read("*a")
	end
	fh:close()
	local val = string.find(content,temp)
	local err = 0
	if(val~=nil)then
		os.rename("/tmp/AGConfig.kry", "/tmp/AGConfig.xml")
	else
	        --Fix for CQ CPE_P00121582 Unable to do Restore via GUI
	
		--Decrypt the kry file to xml file, the param mode=0 means decrypt operation.
		local mode = 0
	        err = xmlEncryptAndDecrypt(mode)
	end
        if err == 1 then 
        	--If the decrypt operation is wrong, it would go to the restore warning page.
        	cgilua.redirect("restoreKO.lp")
        else
        	--Redirect to the restore page to parse the xml file
        	cgilua.redirect("restoreWaitInfo.lp?fileName=" .. fileName)
        end
	return

  elseif POST["logFlag"]=="1" or POST["logFlag"]=="2" then
    if POST["logFlag"] == "1" then
      -- start log
      if usbdisk_info == nil or #usbdisk_info == 0 then
        logError = logErrorNoUSB
      else
        for i=1, #usbdisk_info do
          local disk = ""
          local fstype = ""
          for j=1,#usbdisk_info[i].part do
            disk = usbdisk_info[i].part[j]
            fstype = tostring(disk.fstype)
            if fstype ~= "EXT2" and fstype ~= "EXT3" and disk.mount_point ~= "" and disk.readOnly ~= "true" then
              local part_size = 0
              if disk.ok == 1 and isDiskMoreThan2MB(disk.part_size) then
                -- write log to mount point
                local modify = {}
                table.insert(modify, {path = logPath, param = {logPath = "/var/usbmount/"..disk.device_name}})
                table.insert(modify, {path = logPath, param = {logState= "true"}})
                setMBUS(modify)
                
                logAddress = disk.sharing_addr
                local filename = getVendorLogFilename()
                logError = translate([==[Operation performed. Log]==]) .. " " .. filename .. " " .. translate([==[started on]==]) .. " " .. logAddress
                break
              end
            end
          end
        end
        if logAddress == "" then
          logError = logErrorUSB
        end
      end
      
    else
      -- stop log
      logAddress = getVendorLogAddress()
      local filename = getVendorLogFilename()

      local modify = {}
      table.insert(modify, {path = logPath, param = {logState = "false"}})
      setMBUS(modify)
      
      logStop = 1
      logError = translate([==[Operation performed. Log]==]) .. " " .. tostring(filename) .. " " .. translate([==[successfully created on]==]) .. " " .. tostring(logAddress) .. ".<br>" .. translate([==[To read the file, access the resource.]==])
    end

    --config the led Power mode 
    elseif POST["ledConfigFlag"]=="1" then
      local modify = {}
      table.insert(modify, {path = "TI_STORE.TiUserIntf", param = {LowConsumptionLED = POST["lcled"]}})
      setMBUS(modify)
      saveall(0, 1)
    end
  end

  local ledServiceColor=TI_info.static
  local ledServiceStatus="Solid"
  local isRedColor=string.find (ledServiceColor,"red_")
  if isRedColor~=nil then
      ledServiceColor="Red"
  else
      if ledServiceColor~="off" then		
          if ledServiceColor=="green_blink" then
              ledServiceStatus="Flash"
          end
          ledServiceColor="Green"
      else
          ledServiceColor="Off"
      end
  end

  local ledConfigList = getList("TI_STORE.TiUserIntf",nil,"LowConsumptionLED")
local activeChecked=""
local unactiveChecked=""

if ledConfigList[1]["LowConsumptionLED"]=="true" then
	activeChecked="checked='checked'"
else
	unactiveChecked="checked='checked'"
end

--log info
local log_status_str = translate([==[Inactived]==])
local in_progress, log_error = "false", "0"
local reply, error = mbus.getParameters{ path = logPath, param = {"logState", "logError"} }
local v = reply[logPath][1]

if v~=nil and v.param~=nil and v.param["logState"]~=nil then
    in_progress = v.param["logState"]
    log_error = v.param["logError"]

    if in_progress=="true" then
        logAddress = getVendorLogAddress()
        log_status_str = translate([==[In progress with]==]) .. " " .. logAddress
    else
        if log_error=="1" then
            log_status_str = translate([==[Finished - Error]==])
        elseif logStop == 1 then
            log_status_str = translate([==[Finished OK]==])
            if usbdisk_info == nil then
                log_status_str = translate([==[Finished - Error]==])
            end
        end
    end
end
%>

<script type="text/javascript">
//<![CDATA[

function backupClick()
{
	document.getElementById("backupFlag").value="1";
	document.backup.submit();
}

function restoreClick()
{
    var fileName = document.getElementById("restoreFile").value;
    var fileArray = fileName.split(".");
    var len = fileArray.length;
    var fileSuffix = fileArray[len-1]; 
    if(fileSuffix != "cfg")
    {
        document.getElementById("tools").style.display="none";
        document.getElementById("restoreKO").style.display="block";
    }
    else
    {
        document.getElementById("restoreFlag").value="1";
        document.restore.submit();
    }
}

function resetClick()
{	
	document.getElementById("tools").style.display="none";
	document.getElementById("defaultWait").style.display="block";
}

function logClick(n)
{
  if(n==1)
  {
    //start
    document.getElementById("tools").style.display="none";
    document.getElementById("logWarn").style.display="block";
  }
  else
  {
    //stop
    document.getElementById("logFlag").value = n;
    document.logForm.submit();
  }
}

function submitStartLog()
{
  document.getElementById("logFlag").value = 1;
  document.logForm.submit();
}

function submitConfirm()
{
  document.gwReset.submit();
}

function cancelConfirm()
{
	document.getElementById("tools").style.display="block";
	document.getElementById("defaultWait").style.display="none";
	document.getElementById("logWarn").style.display="none";
<% if logError ~= "" then %>
	document.getElementById("logResult").style.display="none";
<% end %>
}

function submit_lcled()
{
	document.getElementById("ledConfigFlag").value="1";
	document.ledEnergyConfig.submit();
}

function closeRestoreKO(){
	document.getElementById("tools").style.display="block";
	document.getElementById("restoreKO").style.display="none";	 
}
//Query the log state in every 2 seconds by ajax
function changeLogStatus()
{
    var urlStr = "/log_ajax.lp";
    var params="";
    <% if in_progress == "true" then %>
        ajax_get(urlStr, params, logStatusUpdate_cb);
    <% end %>
}

//Callback handle to log status update
function logStatusUpdate_cb(ajax_obj)
{
        var isUsbDisconnected = ajax_obj.responseText.replace(/\s/g,"");
        if(isUsbDisconnected == "true") {
        var logStatusStr = document.getElementById("logStatus").innerHTML;
                if(logStatusStr != "<%=translate([==[Finished - Error]==])%>")
                {
                        document.getElementById("logStatus").innerHTML = "<%=translate([==[Finished - Error]==])%>";
                }
        }
}

window.setInterval("changeLogStatus()", 2000);
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
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {
		window.parent.menu.document.getElementById("stru").className="submenuselect1";
	}		
  </script>
</head>
<body>

<div class="contentContainer">
	 	<table cellspacing='0' cellpadding='0' width="100%">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="tool.lp"><%=translate([==[Tools]==])%></a></li>
			</ul>
		</div>	</table>

<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="tool.lp" class="current">
				<div class="tab">
				<span class="tabIconTool"></span>  
				<span class="contTabTxt transform"><%=translate([==[Tools]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>
						
						
<div class='contentcontainer'>
<div class='contentitem'>
<div id="tools" class="fontSize">

<table cellspacing='0' cellpadding='0' width='100%'>
	<tr>		<td valign='top'>
			<table cellspacing='0' cellpadding='0'>
			<tr><td class="midarea2 tableTitle"><%=translate([==[Modem Configuration Backup]==])%></td></tr>
			</table>
			<table width='100%' cellspacing='0' cellpadding='0' class="width650" style='line-height:150%;'> 
		
			<tr><td  class="textColor" colspan='4'>
			 <form name="backup" method="post" action="">
			 <input type="hidden" id="backupFlag" name="backupFlag" value="0" />
			<table border='0' cellspacing='0' cellpadding='0' width='100%'  >
			<tr>
					<td class="padleft250">
					<a onclick="backupClick()" href="#">
					<div class="midarea7-1 mainButton"><%=translate([==[Save configuration]==])%></div></a>
					</td><td>&nbsp;</td>
			</tr>
			</table>
			</form>
			</td></tr>
			<tr><td  class="textColor padleft40"><p><font color="#FF0000"><%=translate([==[Warning]==])%>:</font> <%=translate([==[clicking on]==])%> <font color="#0000FF">&quot;<%=translate([==[Save configuration]==])%>&quot;</font> <%=translate([==[the backup file will be generated on the configuration of modem and saved on your computer at the location indicated in]==])%>&nbsp;<%=translate([==[rescue]==])%>.</p></td></tr>
			</table>
		</td>
	</tr>
</table>

<table cellspacing='0' cellpadding='0' width='100%' class="martop15">
	<tr>		<td  valign='top'>
		<table cellspacing='0' cellpadding='0'>
		<tr><td class="midarea2 tableTitle"><%=translate([==[Restore Configuration]==])%></td></tr>
		</table>
		<table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;' class="width650"> 

<%
	--get the upload id (new feature in R842)
	local id= cgilua.session.storefilepath("/tmp/","",1)
%>
		<tr><td class="textColor padleft40" colspan='4' >
		<form name="restore" method="post" action="tool.lp?id=<%=id%>" enctype='multipart/form-data'>
		<input type="hidden" id="restoreFlag" name="restoreFlag" value="0" />
		<table cellspacing='0' cellpadding='0'>
		<tr><td  class="textColor">
		<p><%=translate([==[Select the backup file to restore, then press]==])%> <font color="#0000FF"> &quot;<%=translate([==[Restore Configuration]==])%>&quot;:</font></p>
		</td></tr>
		<tr><td>
		<font face="Arial">
		<input type="file"  id="restoreFile" name="restoreFile" size="65"  class="inputClass"/><br/>
		</font>
		</td></tr>
		<tr><td class="padleft210">
		<table border='0' cellspacing='0' cellpadding='0' width='100%' class="martop5">
			<tr>
				<td>
				<a onclick="restoreClick()" href="#">
				<div class="midarea7-1 mainButton"><%=translate([==[Restore Configuration]==])%></div></a>
				</td><td>&nbsp;</td>
			</tr>
		</table>
		</td></tr></table>
		</form>
		</td></tr>
    
		<tr>
			<td class="textColor padleft40">
		<p><font color="#FF0000"><%=translate([==[Warning]==])%></font>: <%=translate([==[clicking on]==])%> <font color="#0000FF">&quot;<%=translate([==[Restore Configuration]==])%>&quot;</font> <%=translate([==[modem configuration will be updated with that present in the selected backup file]==])%>.</p>
		</td></tr>
		
		</table></td></tr></table>
		
		<table cellspacing='0' cellpadding='0' width='100%' class="martop15">
	<tr>		<td valign='top'>
			<table cellspacing='0' cellpadding='0'>
			<tr><td class="midarea2 tableTitle"><%=translate([==[Reset factory settings]==])%></td></tr>
			</table>
			<table width='100%' cellspacing='0' cellpadding='0' class="width650" style='line-height:150%;'> 

	<tr><td class="padleft230"><form name="gwReset" method="post" action="restartingAG.lp">
	<input type="hidden" name="action" id="resetAction" value="customerReset" />
	<table border='0' cellspacing='0' cellpadding='0' width='100%'>
			<tr>
				<td>
				<a onclick="resetClick()" href="#">
				<div class="midarea7-4 mainButton"><%=translate([==[Reset factory settings]==])%></div></a>
				</td><td>&nbsp;</td>
			</tr>
		</table>
    </form></td></tr>
	<tr><td class="textColor padleft40">
    <p><font color="#FF0000"><%=translate([==[Warning]==])%></font>: <%=translate([==[clicking on]==])%> <font color="#0000FF">&quot;<%=translate([==[Reset factory settings]==])%>&quot;</font> <%=translate([==[will be restored to the modem initial configurations and will therefore lose all user customizations.]==])%></p>
  </td></tr>
  </table>
  </td></tr></table>
 
  <table cellspacing='0' cellpadding='0' width='100%' class="martop15">
  <tr>
  <td valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle"><%=translate([==[Modem activity log]==])%></td></tr></table>
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;' class="width650"> 
  <tr><td class="textColor padleft40" ><%=translate([==[Log status]==])%>:&nbsp;&nbsp;&nbsp;&nbsp;<span id="logStatus"><%=log_status_str%></span></td></tr>
  <tr><td colspan='4' class="padtop5">
    <form name="logForm" method="post" action="">
      <input type="hidden" id="logFlag" name="logFlag" value="" />
	<% if in_progress == "false" then %>
	<table border='0' cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
			<tr>
				<td class="textColor padleft305">
				<a onclick="logClick(1)" href="#">
				<div class="midarea6-1 mainButton" name="thbS3">Start</div></a>
				</td>
			</tr>
		</table>
	<% else %>
	<table border='0' cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
			<tr>
				<td class="textColor padleft305">
				<a onclick="logClick(2)" href="#">
				<div class="midarea6-1 mainButton" name="thbS4">Stop</div></a>
				</td>
			</tr>
		</table>
	<% end %>
    </form>
	
    <p class="textColor padleft40"><font color="#FF0000"><%=translate([==[Warning]==])%></font>: <%=translate([==[clicking on]==])%> <font color="#0000FF">&quot;Start&quot;</font> <%=translate([==[mode will active modem Log activity. In this mode, the modem Telecom records all activities on a connected USB device. The recording will be active until the maximum size of the log file (2MBytes) is reached or until you press the button]==])%> <font color="#0000FF">&quot;Stop&quot;</font>.</p>
  </td></tr>
<%
endBlock()
%>

  <table cellspacing='0' cellpadding='0' width='100%' class="martop15">
  <tr>
    <td valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle"><%=translate([==[Configuration]==])%> LED</td></tr></table>
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 

	

<form name="ledEnergyConfig" method="post" action="">
  <tr>
  <td class="textColor padleft40 width160"><%=translate([==[Power mode]==])%>:
      <input type="hidden" id="ledConfigFlag" name="ledConfigFlag" value="0" /></td>
	  <td class="textColor width120">
      <input type="radio" value="true" name="lcled" onclick="submit_lcled()" <%=activeChecked%> />&nbsp;<%=translate([==[ON]==])%>
     </td>
	 <td class="textColor">
	 <input type="radio" value="false" name="lcled" <%=unactiveChecked%> onclick="submit_lcled()" />&nbsp;<%=translate([==[NOT ACTIVE]==])%>
  </td></tr>
    </form></table>
<%
	endBlock()
%>

 
  <table cellspacing='0' cellpadding='0' width='100%' class="martop15"><tr>
  <td valign='top'>
  <span class="midarea2 tableTitle"><%=translate([==[LED Modem State]==])%></span><br>
  <table class='edittable valueSpace fontSize width750 servizitable marleft36' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
writeTableContHeader(3, translate([==[LED]==]), translate([==[State]==]), translate([==[Description]==]))
local rowStyle = "oddrow"
local rowNum = 0

for i,v in pairs(led_list) do
	local ledName=tostring(v)
	local led_gui_name = ledName 
	local pled = "LEDS.LED"
 local ledColor = ""
 local ledState = ""

	if ledName == "Service" then
		ledColor = ledServiceColor
		ledState = ledServiceStatus
	else
		local ledobj, err = mbus.getParameters{path = pled, param = {"Color", "State"}, filter = "(== Name "..ledName..")" }
		if ledobj[pled][1]~=nil and ledobj[pled][1].param~=nil and ledobj[pled][1].param["Color"]~=nil then
			ledColor = tostring(ledobj[pled][1].param["Color"])
			ledState = tostring(ledobj[pled][1].param["State"])
		end
	end
	if ledColor=="None" or ledColor=="" then
		ledColor="Off"
	end

	local styleColor="tdGreen"
	if ledColor=="Red" then
		styleColor="tdRed"
	elseif ledColor=="Off" then
		styleColor="tdBianca"
	end

	local isFlash=string.find (ledState,"Flash")
	if isFlash~=nil then
		ledColor = "FlashingGreen"
	end

	local ledColorTranslate=translate([==[Green]==])
	if ledColor == "FlashingGreen" then 
		ledColorTranslate=translate([==[FlashingGreen]==])
	elseif ledColor == "FlashingRed" then
		ledColorTranslate=translate([==[FlashingRed]==])
	elseif ledColor == "Red" then
		ledColorTranslate=translate([==[Red]==])
	elseif ledColor == "Off" then
		ledColorTranslate=translate([==[Off]==])
	end
	
	if ledName == "Wifi" then 
		led_gui_name = "Wi-Fi" 
	elseif ledName == "ADSL" then 
		led_gui_name = linkName
  if linkName == "ADSL/FIBRA" then
    ledColorTranslate = translate([==[Unknown]==])
  end
	end

  rowNum = rowNum + 1
  if rowNum%2==1 then
    rowStyle = "oddrow"
  else
    rowStyle = "evenrow"
  end
  
  local desc = ledDesc[ledName][ledColor]
  if desc==nil or desc=="" then
    desc = "&nbsp;"
  end
%>

  <tr>
    <td class="<%=rowStyle%> fontSize  width140"><div><%=led_gui_name%></div></td>
    <td class="<%=rowStyle%> <%=styleColor%> fontSize width110"><div><%=ledColorTranslate%></div></td>
    <td class="<%=rowStyle%> fontSize wordWrap width450 whiteWrap"></div><%=desc%></div></td>
  </tr>
  
<%
end
endBlock()

	
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="martop15"><tr>
  <td>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle"><%=translate([==[Restart Modem]==])%></td></tr></table>
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
  <tr><td class="textColor padleft250" colspan='4'>
    <form name="gwRestart" method="post" action="restartingAG.lp">
	<input type="hidden" name="action" id="restartAction" value="saveRestart" />
	<table border='0' cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
			<tr>
				<td>
				<a href="javascript:document.gwRestart.submit();">
				<div class="midarea7-1 mainButton"><%=translate([==[Save and Restart]==])%></div></a>
				</td><td>&nbsp;</td>
			</tr>
		</table>
    </form>
	</td></tr>
	<tr><td class="textColor padleft40">
    <p><font color="#FF0000"><%=translate([==[Warning]==])%>:</font><br/> <%=translate([==[clicking on]==])%> <font color="#0000FF">"<%=translate([==[Save and Restart]==])%>"</font> <%=translate([==[saves the current configuration and reboots the modem. You may need to authenticate again to access the modem management console if security is enabled for access]==])%>.</p>
  </td></tr>
<%
	endBlock()

endPage()
%>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</div>

<div id="logWarn" style="display:none">
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
                          <td class="errorMessage"><%=translate([==[Modem activity log]==])%></td></tr>
              <tr><td id="logWarnMsg" class="errorDesc">
              <p> <%=translate([==[Warning: Pressing the "Next" button will activate the modem Telecom recording mode of the Log File on the first USB device available.]==])%><br><%=translate([==[Verify that the Remote Disk is "Active" and that is connected to at least one memory device.]==])%><br><%=translate([==[Warning: this may slow down the operation mode of the modem.]==])%></p>
              <p class="paddtop10"><%=translate([==[Click "Next" to confirm or click "Cancel" to return to previous page]==])%>.</p>
              <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="submitStartLog()" href="#">
                <div class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a>
                </td>
                <td  class="verticalAlign" style="padding-left:15px;">
                <a onclick="cancelConfirm()" href="#">
                <div class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
                </td>
                </tr>
                </table>
           </td></tr></table>
</div>

<% if logError ~= "" then %>
<div id="logResult" style="display:none">
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
                          <td class="errorMessage"><%=translate([==[Modem activity log]==])%></td></tr>
              <tr><td class="errorDesc"><p><%=logError%></p><br/>
        </td></tr></table>
        </td></tr>
        <tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
          <a onclick="cancelConfirm()">
                <div class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
            </td></tr></table>
  </td></tr></table>
</div>
<script type="text/javascript">
document.getElementById("tools").style.display="none";
document.getElementById("logResult").style.display="";
</script>
<% end %>

<div id="defaultWait" style="display:none">
<%cgilua.lp.include("webparts/defaultWait.lp")%>
</div>
<div id="restoreKO" style="display:none">
<%cgilua.lp.include("webparts/restoreKO.lp")%>
</div>

</div>
</div>
</div>
</body>
</html>
