<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

<link rel="stylesheet" href="css/master.css" type="text/css" />

<style type="text/css">

.backBtnPadding {
   padding-left:68px;
}

.backBtnPadding-ie6nOpera {
   padding-left:75px;
}

.backBtnPadding-Chrome {
   padding-left:72px;
}
</style>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/usb.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<%

local translate = translate
local POST = cgilua.POST

local tprint = require("tableprint")
local isRemote = isRemoteAccess()

local uuid
local dlna_count = 0
local usbdisk_info
local cs_state, cs_name = get_media_cs_state()
local cs_state_show = translate([==[Unsynchronized]==])
local mbusDlna = true
local isUSBConnected = false
if cs_state == "true" then

	cs_state_show = translate([==[Actived]==]) 
	usbdisk_info = get_usbdisk_info(cs_name) 
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local modify = {}
	if POST["mediaServerMgmFlag"] == "1" then
		local contentSharingState = POST["contentsharing"]
		if cs_state ~= contentSharingState then
			table.insert(modify, {path="ContentSharing.UPnPAV", param= {Enable=contentSharingState}})
--			table.insert(modify, {path="UPnP", param= {Enable=contentSharingState}})
--			if contentSharingState == "true" then
--				table.insert(modify, {path="System", param= {UPnP="true"}})
--			end
			setMBUS(modify)
			saveall(0, 1)
			cgilua.redirect("save_alert.lp", { u = "mediaServer.lp" })
			return
		end

	-- umount usb disk
	elseif POST["removeMgmFlag"] == "1" then

		local umount_dev =  POST["RemoveDisk"]
		local isUsbDiskBusy, usdDiskPath = is_usbdisk_busy(umount_dev)

		modify = {}
		table.insert(modify, {path="ContentSharing.UPnPAV", param= {Enable="0"}})
		setMBUS(modify)
		sleep(2)
		
		modify = {}
		table.insert(modify, {path=usdDiskPath, param = {DoUnMount="true"}})
		setMBUS(modify)

		sleep(3)
		modify = {}
		table.insert(modify, {path="ContentSharing.UPnPAV", param= {Enable="1"}})
		setMBUS(modify)
		
		sleep(2)
		cgilua.redirect("mediaServer.lp")
		return		
	
	elseif POST["dlnaServerFlag"] == "1" then 
		mbusDlna = false			
		local partitionPath=POST["partitionPath"]
		local uuid_id = "uuid_"..partitionPath	
		local pName = POST["pname_"..partitionPath]	
		local postedUuid=POST[uuid_id]		
		local directoryName=POST["directoryName"]
		local enableMovie=POST["movieFlag"]
		local enableMusic=POST["musicFlag"]
		local enablePicture=POST["pictureFlag"]		
		local contentSharingState = POST["contentsharing"]			
		
		local compare, error = mbus.getParameters{path = "ContentSharing.UPnPAV.IndexRules"}
		local rule = {}		
		for i=1, #compare["ContentSharing.UPnPAV.IndexRules"] do		
			rule[i] = {}										
			rule[i].DirectoryName = compare["ContentSharing.UPnPAV.IndexRules"][i].param["DirectoryName"]			
			rule[i].UUID = compare["ContentSharing.UPnPAV.IndexRules"][i].param["UUID"]
			if directoryName == rule[i].DirectoryName  and postedUuid == rule[i].UUID then				
				--cgilua.redirect("directoryAlreadyExist.lp")	
				local reply2, error2 = mbus.modify(
                		function()
					local reply1, error1 = mbus.deleteObjects{ path = "ContentSharing.UPnPAV.IndexRules",filter = "(and(== DirectoryName "..directoryName..")  (== UUID "..postedUuid.."))" }		
				    saveall(0, 1)		
				end)

			--return
			end				
		end
			local reply, error = mbus.modify(
              function()
               local reply1, error1 = mbus.addObjects{ path = "ContentSharing.UPnPAV.IndexRules", 
				param = {Enable=contentSharingState,UUID=postedUuid,PartitionName=pName,DirectoryName = directoryName,EnableMovie=enableMovie,EnableMusic=enableMusic,EnablePicture=enablePicture}}						
				saveall(0, 1)
			
                if error1 ~= nil then												
                        cgilua.redirect("mediaServer.lp")
				end				
                return
                
		end)
			
	elseif POST["dlnaDeleteFlag"] == "1" then	
		--local directoryName=POST["directoryName"]
		--local partitionPath = POST["partitionPath"]				
		--local uuid_id = "uuid_"..partitionPath		
		--local postedUuid=POST[uuid_id]
		for i=1,tonumber(POST["count"]) do
			local filt = POST["dir_name"..i]
			local filt_id = POST["uuid_ID"..i]
		  if POST["dlna_del"..i] == "on" then
			local reply, error = mbus.modify(
                	function()
				local reply1, error1 = mbus.deleteObjects{ path = "ContentSharing.UPnPAV.IndexRules",filter = "(and(== DirectoryName "..filt..")  (== UUID "..filt_id.."))" }		
			
			end)
		  end
		end
		saveall(0,1);
		--cgilua.redirect("mediaServer.lp")
		cgilua.redirect("mediaServer.lp", { back = "true" })
		return
 	elseif POST["dlnaConfFlag"] == "1" then	
		local partitionPath=POST["partitionPath"]
		local directoryName=POST["directoryName"]
		local pName = POST["pname_"..partitionPath]
		local partitionPath = POST["partitionPath"]				
		local uuid_id = "uuid_"..partitionPath		
		local postedUuid=POST[uuid_id]	
		for i=1,tonumber(POST["count"]) do
			local filt = POST["dir_name"..i]
			local filt_id = POST["uuid_ID"..i]
			local enableMovie=POST["movieFlag"]
			local enableMusic=POST["musicFlag"]
			local enablePicture=POST["pictureFlag"]
			local contentSharingState = POST["contentsharing"]
		  if POST["dlna_con"..i] == "on" then			
			local reply, error = mbus.modify(
                	function()
				local reply1, error1 = mbus.setParameters{ path = "ContentSharing.UPnPAV.IndexRules", param = {EnableMovie=enableMovie,EnableMusic=enableMusic,EnablePicture=enablePicture},filter = "(and(== DirectoryName "..filt..")  (== UUID "..filt_id.."))" }			
			end)
		  end
		 	
		end
		saveall(0,1);
		cgilua.redirect("mediaServer.lp", { back = "true" })
		--cgilua.redirect("mediaServer.lp")
		return 						
	end 	  
end

--local unmountWhileUsing = translate([==[Warning: Can not complete the operation of this device]==])
--local removedCPEPort = translate([==[Warning: Device removed improperly]==])

-- DLNA
local dlnaPath, error = mbus.getParameters{path= "ContentSharing.UPnPAV.Stats"}

local movieCount = dlnaPath["ContentSharing.UPnPAV.Stats"][1].param["Movie"]
local musicCount = dlnaPath["ContentSharing.UPnPAV.Stats"][1].param["Music"]
local pictureCount =dlnaPath["ContentSharing.UPnPAV.Stats"][1].param["Picture"]


local sep = "/"

function startswith(sbig, slittle)
  if sbig ~=nil and type(slittle) == "table" then
    for k,v in ipairs(slittle) do
      if string.sub(sbig, 1, string.len(v)) == v then 
        return true
      end
    end
    return false
  end
  return string.sub(sbig, 1, string.len(slittle)) == slittle
end

require"lfs"

function directoryExists(strFolderName)
	if lfs.attributes(strFolderName:gsub("\\$",""),"mode") == "directory" then
		return true
	else
		return false
	end
end
local connectUSBlist = getUSBNameList()
local usbLstStrng = ""
if connectUSBlist ~= nil then
	for i=1,#connectUSBlist do
		usbLstStrng = usbLstStrng.."|"..connectUSBlist[i].name
	end
end
%>
<script language="javascript" src="js/script.js"></script>
<script language="javascript" type="text/javascript">

 if(document.getElementById("remove_usb")!=null) then
 {
//document.getElementById("remove_usb").disabled=false;
 }
var isunMountTrigged = false;
var usbliststr = "<%=usbLstStrng%>";
function usbResponse(data){
	var rsps = data.responseText;
	if(rsps.indexOf("true") > -1 && !isunMountTrigged){
		alert("<%=translate([==[A storage physical resource is physically removed from the CPE port while the Media Server is active and running]==])%>");
		window.location = "mediaServer.lp";
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
 
function currentTab(tab1,tab2) {
<% if isRemote==false then%>
		//alert(partId)
		if(selectedDir!="" && selectedDir!=null && selectedDir!="undefined") {
			document.getElementById(tab1).className="";
			document.getElementById(tab2).className="current";
		} else if(backFlag!="" && backFlag!=null && backFlag!="undefined" && backFlag== "true") {
			document.getElementById(tab1).className="";
			document.getElementById(tab2).className="current";
		} else {
		document.getElementById(tab1).className="current";
		document.getElementById(tab2).className="";
		
		}
<%end%>		
		/*
		var content_links = document.getElementById("content").getElementsByTagName("a");
		for (var i = 0; i < content_links.length; ++i) {
			content_links[i].className = (content_links[i] == link) ? "current" : "";
		}
		*/
    }

var usb_devname = "";
function umount_submit(devname)
{
document.getElementById("remove_usb").disabled=true;

	document.getElementById("mediaServerConfig").style.display = "none";

	document.getElementById("warnUnmount").style.display = "block";
	usb_devname = devname;
}

function confirm_umount_submit()
{
	document.getElementById("remove").removeAttribute("href");
	document.getElementById("remove").onclick = null;
	document.getElementById("remove").className = "aClicked";
	document.getElementById("removeMgmFlag").value = "1";
	document.getElementById("RemoveDisk").value = usb_devname;
	isunMountTrigged = true;
	document.mediaForm.submit();
}

//if original state equals to the current state, it should not submit but redirect to the status page.
function isUpdate()
{
	var isMediaSeverActive = "<%=cs_state%>";
	var isEnableMediaSever = document.getElementById("cs1").checked;

	if(isEnableMediaSever)
	{
		if(isMediaSeverActive=="true")
		{
			return true;
		}
	}else{
		if(isMediaSeverActive=="false")
		{
			return true;
		}
	}
	return false;
}
function config_submit()
{
	if(isUpdate())
	{
		window.location = "mediaServer.lp";
		return true;
	}

	document.getElementById("mediaServerMgmFlag").value = "1";
	document.mediaForm.submit();
}

function cancelForm()
{
	document.getElementById("mediaServerConfig").style.display="block";    
	document.getElementById("warnUnmount").style.display="none";
	document.getElementById("warnEnable").style.display="none";
}

function mediaServerConfigDisplay(tab1,tab2)
{	
	//currentTab(this);
	document.getElementById(tab1).className="";
	document.getElementById(tab2).className="current";
	document.getElementById("mediaConfigBack").style.display = "";
	document.getElementById("mediaStateShow").style.display="none";    
	document.getElementById("mediaConfigShow").style.display="block";
	
	document.getElementById("mediaTitleStato").style.display="none";
	document.getElementById("mediaTitleConfig").style.display="block";		
	<% if usbdisk_info~=nil then %>
		document.getElementById("mediaSharedShow").style.display="block";	
	<%end%>
	
}

function sajax_init_object() {
        var A;
        try {
                A=new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
                try {
                        A=new ActiveXObject("Microsoft.XMLHTTP");
                } catch (oc) {
                        A=null;
                }
        }
        if(!A && typeof XMLHttpRequest != "undefined")
                A = new XMLHttpRequest();
        return A;
}

function ajax_get()
{
	//currentTab('mediaStatus','mediaconfig');
	
    var x = sajax_init_object();
    var url = "findMediaStatus.lp";
    x.open('GET', url, true);
    x.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    x.setRequestHeader("Connection", "close");
    x.send("");
    x.onreadystatechange = function() {
        if (x.readyState == 4) {
            ajax_cb(x.responseText.replace(/\s/g,""));
        }
    };
    delete x;
}

function ajax_cb(status)
{
    if(status == "Profiling")
    {
        document.getElementById("mediaWaring").style.display="block";
    }
    else
    {
        document.getElementById("mediaWaring").style.display="none";
    }   
}

function setIndexFlag(value,id1,id2,id3) {
	
	 if(value == "value2") {
		document.getElementById(id1).value = "false";
		document.getElementById(id2).value = "false";
		document.getElementById(id3).value = "true";			
	}
	else if(value == "value3") {
		document.getElementById(id1).value = "false";
		document.getElementById(id2).value = "true";
		document.getElementById(id3).value = "false";
	}
	else if(value == "value4") {
		document.getElementById(id1).value = "false";
		document.getElementById(id2).value = "true";
		document.getElementById(id3).value = "true";
	}
	else if(value == "value5") {
		document.getElementById(id1).value = "true";
		document.getElementById(id2).value = "false";
		document.getElementById(id3).value = "false";
	}
	else if(value == "value6") {
		document.getElementById(id1).value = "true";
		document.getElementById(id2).value = "false";
		document.getElementById(id3).value = "true";			
	}
	else if(value == "value7") {
		document.getElementById(id1).value = "true";
		document.getElementById(id2).value = "true";
		document.getElementById(id3).value = "false";
	}
	else if(value == "value8") {
		document.getElementById(id1).value = "true";
		document.getElementById(id2).value = "true";
		document.getElementById(id3).value = "true";
	}		
		
}

function dlna_submit() {

	var value = document.getElementById("indexValue").value;
	setIndexFlag(value,"movieFlag","musicFlag","pictureFlag")
	
	var dirName = document.getElementById("directoryName").value;	

	if(dirName !=null && dirName.length > 128) {			
		document.getElementById("mediaContent").style.display="none"; 
		document.getElementById("dirLenCheck").style.display="block";    
		document.getElementById("dirCheck").style.display="none";
		return false;
	} 		

	if( dirName !=null && dirName !="" && dirName !=" " && dirName.length > 0) // this will check for valid directory name
	{
		document.getElementById("dlnaServerFlag").value = "1";
		document.mediaForm.submit();
	} else {	
		document.getElementById("mediaContent").style.display="none"; 
		document.getElementById("dirLenCheck").style.display="none";   
		document.getElementById("dirCheck").style.display="block";			
	}

}

function closeConfirm() {
	document.getElementById("dirCheck").style.display="none";
	document.getElementById("dirLenCheck").style.display="none";	    
	document.getElementById("mediaContent").style.display="block";
}

function closeLenConfirm() {
	document.getElementById("dirCheck").style.display="none";  
	document.getElementById("dirLenCheck").style.display="none";	  
	document.getElementById("mediaContent").style.display="block";
}



function browseDirectory() {
	var partId = document.getElementById("partitionPath").value;
	var deviceName = document.getElementById("dname_"+partId).value;
	var remote_addr = "/var/usbmount/"+deviceName;
	location.href = "browseUsb.lp?filePath="+remote_addr+"&id="+partId

}

function parseSlash(tmp) {		
	var txtArr = tmp.split("/")
	var tmp = "";		
	var selectedDir = ""	
	if (txtArr.length > 1 ) {
	   for(i=1;i<txtArr.length;i++) {
		if( i == 1) {
			tmp = txtArr[i]
		} else {
			tmp = tmp + "&frasl;"+txtArr[i] 
		}
	   }
	   selectedDir = "&frasl;"+tmp;	
	} else {
	   selectedDir = tmp;	
	}
	return selectedDir;
}

window.setInterval("ajax_get()", 1000*5);
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
		window.parent.menu.document.getElementById("media").className="submenuselect1";
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
	
	//body onload
function linkToMedia()
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
		window.parent.menu.document.getElementById("usbst").className="";
	}
	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="submenuselect1";
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
  </script>
</head>
<body onload="ajax_get(),currentTab('mediaStatus','mediaconfig');javascript:linkToMedia();">
	<div class="contentContainer" >
	<!--
<tr id='mediaWaring' style="display:none">
								<td class='msgBgRed'><p><img src='images/msgRedAlert.gif' alt=''><%=translate([==[Please wait, the USB device is indexing]==])%>.</p></td>
							</tr>
-->
	<div id='mediaWaring' style="display:none">
		<div class='msgBgRed'>
		<div class="hdrtxt padleft10"><%=translate([==[Wait, indexing in progress on USB devices]==])%>.</div>
		</div>
		<div class="clrBth"></div>
	</div>
	<div id="mediaContent" >	
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp">Impostazioni Avanzate</a></li><li>|</li><li><a href="mediaServer.lp">Media Server</a></li>
			</ul>
		</div>	
			
					
						<div class="contentTab" id="content">
							<ol id="tocTab">
								
								<li><a id="mediaStatus" href="mediaServer.lp" class="current">
									<div class="tab">
									<span class="tabIcon"></span>  
									<span class="contTabTxt"><%=translate([==[Media Server]==])%></span>
									</div><div class="clrBth"></div></a></li>
								<% if isRemote==false then%>
								<li><a style="margin-left:15px;" onclick="mediaServerConfigDisplay('mediaStatus','mediaconfig');return false;" id="mediaconfig" href="#">
									<div class="tab">
									<span class="contTabTxt"><%=translate([==[Configure]==])%> Media Server</span></div></a></li>
								<% end%>	
							</ol>
						</div>
					
					
				

		<div class='contentcontainer fontSize' id="mediaServerConfig">
			<hr>
			<div class='contentitem'>
				<form method="POST" name="mediaForm" action="">
					<input type="hidden" id="RemoveDisk" name="RemoveDisk" value="" />
					<input type="hidden" id="removeMgmFlag" name="removeMgmFlag" value="0" />
					<input type="hidden" id="mediaServerMgmFlag" name="mediaServerMgmFlag" value="0" />
					<input type="hidden" id="dlnaServerFlag" name="dlnaServerFlag" value="0" />
					<input type="hidden" id="movieFlag" name="movieFlag" value="0" />					
					<input type="hidden" id="musicFlag" name="musicFlag" value="0" />
					<input type="hidden" id="pictureFlag" name="pictureFlag" value="0" />
					<input type="hidden" id="dlnaDeleteFlag" name="dlnaDeleteFlag" value="0" />
					<input type="hidden" id="dlnaConfFlag" name="dlnaConfFlag" value="0" />	
					<input type="hidden" id="count" name="count"></input>
				
					
					
					<!-- <table border="0" width="100%">
					<tr>
						<td class='icon' style='vertical-align:top' width='100px'><img src='images/csharing__xl.gif' alt='Interface'></td>
						<td class='data' style='vertical-align:top'> -->
						
						
						<table cellspacing='0' cellpadding='0' width="100%">							
							<tr id="mediaTitleStato" style="display:block">							
								<td class="midarea2 tableTitle"><%=translate([==[State Media Server]==])%></td>
							</tr>
							<tr id="mediaTitleConfig" style="display:none">							
								<td class="midarea2 tableTitle"><%=translate([==[Configuration Media Server]==])%></td>
							</tr>
							<!--<tr id='mediaWaring' style="display:none">
								<td class='msgBgRed'><p><img src='images/msgRedAlert.gif' alt=''><%=translate([==[Please wait, the USB device is indexing]==])%>.</p></td>
							</tr>
							-->
							<tr>
								<td><br>
									<div id="mediaStateShow" class="marleft40">            
										<table cellspacing='0' cellpadding='0' width='100%'>
											<tr>
											<td class="verticalAlign">
													<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;">
														<tr>
															<td class='wifiMidarea4-2' width='150' style="padding-left:0px;"><%=translate([==[State Media Server]==])%>:</td>
															<td><span><%=cs_state_show%></span></td>
														</tr>
													</table>
												</td>
											</tr>
										</table>

									</div>

									 <div id="mediaConfigShow" style="display:none;" class="marleft40"> 
										<table cellspacing='0' cellpadding='0' width='100%'>
											<tr>
												<td class="verticalAlign">
													<table width='100%' cellspacing='0' cellpadding='0' style="line-height:150%;">
														<tr><td class='wifiMidarea4-2' width='150' style="padding-left:0px;"><%=translate([==[Configure]==])%> Media Server:</td>
															<td>
															<input type="radio" value="true" id="cs1" name="contentsharing" />&nbsp;<%=translate([==[Active]==])%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
															<input type="radio" value="false" id="cs2" name="contentsharing" />&nbsp;<%=translate([==[Disable]==])%>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
										<table cellspacing='0' cellpadding='0' class="txtAlignCenter padtop10">
											<tr>
											<td>&nbsp;</td>	<td align="center" style="padding-left:250px">
												<% if isRemote==false then%>
												<a style='color:black' onclick="config_submit()">
												<div class="midarea6-1 mainButton"><%=translate([==[Save]==])%></div></a>
												<%end%></td><td>&nbsp;</td>
												<td align="center" style="padding-left:50px">
												<%if usbdisk_info==nil then%>					
												<a href ="advance.lp">
												<div class="midarea6-1 secondaryButton"> <%=translate([==[Back]==])%> </div> </a>
												<%end%>
												</td>
											</tr>
										</table>
									</div> 
								</td>
							</tr>
						</table>
					
						<% if usbdisk_info~=nil then 
						isUSBConnected = true
						-- when no usb disk, not display below tables
						 %>                              
						
						
									<table cellspacing='0' cellpadding='0' width='100%' class="padtop10">
										<tr>
											
											<td class="midarea2 tableTitle verticalAlign">
											<%=translate([==[List of connected disks]==])%><br></td>
										</tr>
									</table>
									<table cellspacing='0' cellpadding='0' width='90%' class="marleft40">
										<tr>
										<td class="verticalAlign">
												<table class='edittable width750 tdSpace' cellspacing='0' cellpadding='0' border='0' width='100%'>
									<tr>
									<td align='left' class="tableHd width350 wordWrap"><%=translate([==[Name]==])%></td>
									<td align='left' class="tableHd width110"><%=translate([==[Capacity]==])%></td>
									<td align='left' class="tableHd width130"><%=translate([==[Used space]==])%></td>
									<td align='left' class="tableHd width110"><%=translate([==[Removal]==])%></td></tr>

										<%
										local part_name = {}
										local part_size = {}
										local used_size = {}
										local mount_point={}
										local uuid={}
										local device_name={}
										local fstype = ""
										local rowStyle = "oddrow"
										local rowNum = 0
										for i=1,#usbdisk_info do
											part_name[i] = ""
											part_size[i] = ""
											used_size[i] = ""
											mount_point[i]=""
											device_name[i]={}
											uuid[i]={}
											for j=1,#usbdisk_info[i].part do
												if usbdisk_info[i].part[j].ok == 1 then
													part_name[i] = part_name[i] .. tostring(usbdisk_info[i].part[j].friendly_name) .. '<br>'										
													part_size[i] = part_size[i] .. usbdisk_info[i].part[j].part_size .. '<br>'
													used_size[i] = used_size[i] .. usbdisk_info[i].part[j].part_used_size .. '<br>'
													mount_point[i] = mount_point[i] .. (usbdisk_info[i].part[j].mount_point)

													local pos_str = string.find(mount_point[i],"//")
												
													device_name[i][j] = usbdisk_info[i].part[j].device_name
				
													if pos_str==nil then
														uuid[i] = nil
													else
														uuid[i][j] = string.sub(mount_point[i],pos_str+2)																	
													end					
													
												end
												mount_point[i]=""
											end
											rowNum = rowNum + 1
											if rowNum%2==1 then
												rowStyle = "oddrow"
											else
												rowStyle = "evenrow"
											end
										%>
													<tr>
														<td class="<%=rowStyle%> width350 wordWrap padcell"><div class="width350 wordWrap"><%=part_name[i]%></div></td>														
														<td class="<%=rowStyle%> width110 padcell"><%=part_size[i]%></td>
														<td class="<%=rowStyle%> width130 padcell"><%=used_size[i]%></td>								
														
														<td class="<%=rowStyle%> width110 padcell">
														<% if isRemote==false then%>
														<a onclick="umount_submit('<%=usbdisk_info[i].devname%>')"><div class='midarea6-1 mainButton' style="margin-bottom:0px;" id ="remove_usb"><%=translate([==[Remove]==])%></div></a>								
														<% end%>
													</td>
							 <%end%>
													</tr>
													
												</table>
											</td>
										</tr>
									</table>
								
							
							<table border="0" width="100%" cellpadding="0" cellspacing="0" class="padtop10"> 
							<tr>	
												
								<td class="midarea2 tableTitle"><%=translate([==[DLNA Media Server]==])%></td>
							</tr>
							<tr>
							
								<td class="midareaNoheight tableHd"> <%=translate([==[Indexed Content]==])%></td>
							</tr>
							</table>

							<table border="0" width="100%" cellpadding="0" cellspacing="0"> 
							<tr>
														<td> 
							<table class='edittable marleft40 width750 tdSpace' width='100%' cellspacing='0' cellpadding='0' border='0'>
								<tr><td colspan='3'><img src='images/spacer.gif' border='0' width='1' height='5' alt=''><br></td></tr>
								<tr>
								<td align='left'  class="tableHd" width="30%"><%=translate([==[Video]==])%></td>
								<td align='left'  class="tableHd" width="30%"><%=translate([==[Music Player]==])%></td>
								<td  align='left'  class="tableHd" width="30%"><%=translate([==[Photo]==])%></td>
								</tr>
								<tr><td colspan='3' ><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
								<tr class='oddrow'>
									<td><%=movieCount%></td>
									<td><%=musicCount%></td>
									<td><%=pictureCount%></td>
								</tr>				  
							</table>
							</td>
							</tr>
							</table>

							<table border="0" width="100%" cellpadding="0" cellspacing="0" class="padtop10">							
							<tr> 
							<td> 
							<table  id="mediaSharedShow" style="display:none" width="100%" > 
							<tr>
								<td class="midarea2 tableTitle"> <%=translate([==[Share a new folder]==])%></td>
							</tr>
							<tr>
							<td class="tableHd" width="43%" style="padding-left:40px;vertical-align:middle;" align="left">
								<%=translate([==[Partition]==])%>	
							</td>
							<td  width="10%" >
							</td>
							<td width="29%">
							</td>
							<td class="tableHd" width="10%" align="left">
								<%=translate([==[Content]==])%>
							</td >
							</tr>
							
							<tr>							
							<td style="padding-left:40px;vertical-align:middle;" width="43%">						
							
							<select id="partitionPath" name="partitionPath" class="fontSize inputClass">
							 <%		
							 local display_name = {}
							 local count = 0	
							for i=1,#usbdisk_info do									
								part_name[i] = ""
								display_name[i] = {}
								count = count + 1
								for j=1,#usbdisk_info[i].part do										
									part_name[i] = part_name[i] .. tostring(usbdisk_info[i].part[j].friendly_name)
									display_name[i][j] = part_name[i]							
							%>							
								<option value="<%=i%><%=j%>"> <%=display_name[i][j]%></option>	
								<%part_name[i] = ""%>
								<%end%>															
							<%end%>								
							</select>															
							<%			
							for i=1,count do										
								for j=1,#display_name[i] do								
							%>
								<input type = "hidden" id = "pname_<%=i%><%=j%> " name = "pname_<%=i%><%=j%>" value = "<%=display_name[i][j]%>"></input>
								<%end%>
							<%end%>
							<%		
							for i=1,count do										
								for j=1,#uuid[i] do							
							%>							
							<input type = "hidden" id = "uuid_<%=i%><%=j%>" name = "uuid_<%=i%><%=j%>" value = "<%=uuid[i][j]%>"></input>							
								<%end%>	
							<%end%>
							<%
							for i=1,count do										
								for j=1,#device_name[i] do								
							%>
								<input type = "hidden" id = "dname_<%=i%><%=j%>" name = "dname_<%=i%><%=j%>" value = "<%=device_name[i][j]%>"></input>
								<%end%>
							<%end%>

							</td> 	
							<!--	
							<td style="padding-left:125px"> 
								<%=translate([==[Directory Name]==])%></td>												
--> 
			
							<td style="vertical-align: middle; padding-top: 10px;" width="10%">
								<a href="#" onclick="browseDirectory()" style="cursor:pointer;"><div class="midarea6-browse secondaryButton"><%=translate([==[Browse]==])%></div></a>
							
							</td>

							<td style="vertical-align:middle;" width="29%">
<input type = "hidden" id="directoryName" name = "directoryName" style="white-space:nowrap"> </input> 
<div id="selectedDir" name = "selectedDir" style="padding-left:5px;vertical-align:middle;text-align:left;word-break: break-all;word-wrap: break-word;width:210px;"></div>

							</td>
							
							<td style="vertical-align:middle;" width="10%">
							<select id="indexValue" name="indexValue" class="fontSize inputClass">
								<!-- <option value="value1"><%=translate([==[No content]==])%></option> -->
								<option value="value2"><%=translate([==[Photo]==])%></option>
								<option value="value3"><%=translate([==[Music]==])%></option>
								<option value="value4"><%=translate([==[Music]==])%> & <%=translate([==[Photo]==])%></option>
								<option value="value5"><%=translate([==[Video]==])%></option>
								<option value="value6"><%=translate([==[Photo]==])%> & <%=translate([==[Video]==])%></option>
								<option value="value7"><%=translate([==[Music]==])%> & <%=translate([==[Video]==])%></option>
								<option value="value8"><%=translate([==[All Content]==])%></option> 
							</td>	
							</select>
							</tr>
							<tr><td><br/></td></tr>
							<tr> 
							<td></td>
							<%
							local reply, error = mbus.getParameters{path = "ContentSharing.UPnPAV.IndexRules"}																					
							if #reply["ContentSharing.UPnPAV.IndexRules"] < 8 then		
							%>		
							<td style="padding-left:0px;"> <a style='color:black' onclick="dlna_submit()" href="#"><div class='midarea6-1 mainButton'><%=translate([==[Save]==])%></div></a>		
							<%else 
							%>
							<td style="padding-left:0px;"><div class='midarea6-1 mainButton'><%=translate([==[Save]==])%></div>
							<%end 
							%>
							<td></td>
							</td> <td></td><td></td><td></td><td></td><td></td>
							</tr>
							
						</table>
						</td></tr> 						
						</table>
					<% end %>
					<table border="0" width="100%" cellpadding="0" cellspacing="0" class="marleft40 width750 padtop10">							
						<tr> 
						<td> 
						
						<% 
							local isTableRowExists=0 
						%>
						<div id="partitionTableId" style="display:none">
						<table class='edittable tdSpace' width='100%' cellspacing='0' cellpadding='0' border='0'>
						
								<tr><td colspan='5'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
						
								<tr>
								<tr>
							<td class="midarea2 tableTitle"><div><%=translate([==[List of Shared Folders]==])%></div>
							</td>
						</tr>
								<td width="30%" align='left' class="tableHd" ><%=translate([==[Partition]==])%></td>
								<!--<td width="30%" align='left'  class="tableHd"><%=translate([==[Directory Name]==])%></td>-->
								<td width="20%" align='left'  class="tableHd"><%=translate([==[Content]==])%></td>
																	
								<% if isRemote==false then%>
								<td width="20%" align='left'  class="tableHd"><div style="margin-left:36%"><%=translate([==[Configure]==])%></div></td>
								
								<td width="20%" align='left'  class="tableHd"><div style="margin-left:36%"><%=translate([==[Delete]==])%></div></td>						
								<% end %>
								</tr>
								<tr><td colspan='5'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
							
								<%
								local reply, error = mbus.getParameters{path = "ContentSharing.UPnPAV.IndexRules"}
								local rule = {}
								local style = {}	
								local display = {}	
								for i=1, #reply["ContentSharing.UPnPAV.IndexRules"] do		
								dlna_count =dlna_count+1								
								%>
								<input type = "hidden" id = "dlna_del<%=i%>" name = "dlna_del<%=i%>" value = "off"></input>
								<input type = "hidden" id = "dlna_con<%=i%>" name = "dlna_con<%=i%>" value = "off"></input>
						
								<%
									rule[i] = {}										
									rule[i].PartitionName = reply["ContentSharing.UPnPAV.IndexRules"][i].param["PartitionName"]																		
									rule[i].DirectoryName = reply["ContentSharing.UPnPAV.IndexRules"][i].param["DirectoryName"]
									style[i] = {}                                                                                                                                                         
                                    style[i].uuid = reply["ContentSharing.UPnPAV.IndexRules"][i].param["UUID"]
									
									display[i] = {}
									rule[i].enableMovie = reply["ContentSharing.UPnPAV.IndexRules"][i].param["EnableMovie"]										
									rule[i].enableMusic = reply["ContentSharing.UPnPAV.IndexRules"][i].param["EnableMusic"]								
									rule[i].enablePicture = reply["ContentSharing.UPnPAV.IndexRules"][i].param["EnablePicture"]									
									if rule[i].enableMovie == "false" and rule[i].enableMusic=="false" and rule[i].enablePicture == "true" then
										rule[i].display = translate([==[Photo]==])
											else if rule[i].enableMovie == "false" and rule[i].enableMusic=="true" and rule[i].enablePicture == "false" then
											rule[i].display = translate([==[Music]==])
												else if rule[i].enableMovie == "false" and rule[i].enableMusic=="true" and rule[i].enablePicture == "true" then
												rule[i].display = translate([==[Music Photo]==]) 
													else if rule[i].enableMovie == "true" and rule[i].enableMusic=="false" and rule[i].enablePicture == "false" then
													rule[i].display = translate([==[Video]==])
														else if rule[i].enableMovie == "true" and rule[i].enableMusic=="false" and rule[i].enablePicture == "true" then
														rule[i].display = translate([==[Photo Video]==]) 
															else if rule[i].enableMovie == "true" and rule[i].enableMusic=="true" and rule[i].enablePicture == "false" then
															rule[i].display = translate([==[Music Video]==]) 
																else if rule[i].enableMovie == "true" and rule[i].enableMusic=="true" and rule[i].enablePicture == "true" then
																rule[i].display = translate([==[All Content]==]) 
															end			
														end	
													end	
												end		
											end		
										end		
									end		
								end                                                                                                                                       
                                    local mount_point={}
                                    local uuid={}
				    local directoryNames = {}		
				    local no_con_usb = 0
				if isUSBConnected == true then	
                                    for j=1,#usbdisk_info do  
					no_con_usb = no_con_usb + 1
                                        mount_point[j]=""
                                        uuid[j]={}
					directoryNames[j] = {}	
                                        for k=1,#usbdisk_info[j].part do
						if usbdisk_info[j].part[k].ok == 1 then
                                                mount_point[j] = mount_point[j] .. (usbdisk_info[j].part[k].mount_point)
                                                local pos_str = string.find(mount_point[j],"//")
                                                if pos_str==nil then
                                                    uuid[j] = nil
						    directoryNames[j] = nil
                                                else
                                                    uuid[j][k] = string.sub(mount_point[j],pos_str+2)
						    directoryNames[j][k] = "/var/usbmount/"..usbdisk_info[j].part[k].device_name	
						    -- directoryNames[j][k] = "/home/senthil/Desktop"
                                                end    
						end
						mount_point[j]=""
					end
				    end
				end                               
								
				local is_connectde_dev = 0
				local is_connectde_dir = 0
				local rowStyle = "oddrow_firewall"
				local rowNum = 0 
				for i=1,dlna_count do
					is_connectde_dev = 0
					is_connectde_dir = 0
					if isUSBConnected == true then	
					for j=1,no_con_usb do
					   for k =1, #uuid[j] do
						if(style[i].uuid == uuid[j][k])then
							is_connectde_dev = 1
										
							if rule[i].DirectoryName ~= nil and rule[i].DirectoryName =="/" then
								is_connectde_dir = 1
							else 
								if(directoryExists(directoryNames[j][k]..rule[i].DirectoryName)) then
									is_connectde_dir = 1
								end							
							end	
						end
					    end
					end
					end
					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow_firewall"
					else
						rowStyle = "evenrow_firewall"
					end
					if  (is_connectde_dev == 1 and is_connectde_dir == 1) then 
						 isTableRowExists= isTableRowExists + 1
					%>
                                                 
					<input type="hidden" id="dir_name<%=i%>" name="dir_name<%=i%>" value = "<%=rule[i].DirectoryName%>"></input>
					<input type="hidden" id="uuid_ID<%=i%>" name="uuid_ID<%=i%>" value = "<%=style[i].uuid%>"></input>

					<tr class='<%=rowStyle%>'>

						<td width="30%"> 
						<div id="txtDir<%=i%>" style="vertical-align:middle;text-align:left;word-break: break-all;word-wrap:break-word;width:300px;word-break:break-all;">
						</div></td>
				<script language="javascript" type="text/javascript">
					var display_name = "<%=rule[i].DirectoryName%>";
					display_name = display_name.replace(/\//g, "\\");
					document.getElementById("txtDir<%=i%>").innerHTML = "<%=rule[i].PartitionName%>"+""+(display_name);
				</script>
				
				<td width="20%">
					<div id="indx<%=i%>"><%=rule[i].display%></div>
									
							<div id="indxSel<%=i%>" style="display:none;"><select id="confIndex<%=i%>" name="confIndex<%=i%>" class="inputClass">
								<option value="value2"><%=translate([==[Photo]==])%></option>
								<option value="value3"><%=translate([==[Music]==])%></option>
								<option value="value4"><%=translate([==[Music]==])%> & <%=translate([==[Photo]==])%></option>
								<option value="value5"><%=translate([==[Video]==])%></option>
								<option value="value6"><%=translate([==[Photo]==])%> & <%=translate([==[Video]==])%></option>
								<option value="value7"><%=translate([==[Music]==])%> & <%=translate([==[Video]==])%></option>
								<option value="value8"><%=translate([==[All Content]==])%></option> 
								
						       </select>
							</div>

										</td>
									    <td width="20%">
									<% if isRemote==false then%>
										<a style="display:block;" class="padleft10 linkPointer" id="confEdit<%=i%>" onclick='dlna_conf("<%=i%>","edit")'><img src='images/rename_usb.png' alt=''/ style="margin-left:33%"></a>		
										<a style="display:none;padding-left:15px; padding-top:10px;" class="paddtop10" id="confCancel<%=i%>" onclick='dlna_conf("<%=i%>","cancel")'><div class='midarea6-1 mainButton'><%=translate([==[Cancel]==])%></div></a>

									<% else %>
										<!--<br /><div style="height:23px;padding:5px 0 0 5px;margin:0 10px;">&nbsp;</div>-->
									<% end %>
									</td> 
									<td width="20%">
									<% if isRemote==false then%>	
										<a style="display:block;padding-left:20px;" id="confDel<%=i%>"  onclick='dlna_delete("<%=i%>","delete")'><img src='images/delete_usb.png' alt='' style="margin-left:28%"/></a>
										
										<a style="display:none;padding-top:10px;" id="confSave<%=i%>" onclick='dlna_delete("<%=i%>","save")'><div class='midarea6-1 mainButton' ><%=translate([==[Save]==])%></div></a>
									<% else %>
										<!--<br /><div style="height:23px;padding:5px 0 0 5px;margin:0 10px;">&nbsp;</div>-->
									<% end %>
									</td> 
								        </tr>
									<%
                                    else 
										isTableRowExists= isTableRowExists + 1
									%>
										
										<input type="hidden" id="dir_name<%=i%>" name="dir_name<%=i%>" value = "<%=rule[i].DirectoryName%>"></input>										
										<input type="hidden" id="uuid_ID<%=i%>" name="uuid_ID<%=i%>" value = "<%=style[i].uuid%>"></input>	
									    <tr class='<%=rowStyle%>'>
									    <td  width="30%" class="" style="padding-left:0px">
									   
										<div id="txtDir<%=i%>" class="wordWrap alignMid" style="text-align:left;width:300px;"><%=rule[i].PartitionName%></div>
										</td>
	<script language="javascript" type="text/javascript">
		var display_name = "<%=rule[i].DirectoryName%>";
		display_name = display_name.replace(/\//g, "\\");
		document.getElementById("txtDir<%=i%>").innerHTML = "<%=rule[i].PartitionName%>"+""+(display_name);
	</script>	

	
										<td width="20%" class=""><%=rule[i].display%></td>
									    <td width="20%" class="">
										<% if isRemote==false then%>
										<a style="display:block;" class="padleft10 linkPointer" id="confEdit<%=i%>" onclick='dlna_conf("<%=i%>","edit")'><img src='images/rename_usb.png' alt=''/ style="margin-left:33%"></a>
										
										<% else %>
										<!--<br /><div style="height:23px;padding:5px 0 0 5px;margin:0 10px;">&nbsp;</div>-->
									        <% end %>
									    </td> 
									    <td width="20%" class="">				
											<a style="display:block;padding-left:20px;" id="confDel<%=i%>"  onclick='dlna_delete("<%=i%>","delete")'><img src='images/delete_usb.png' alt='' style="margin-left:28%"/></a>	
										</td>	
								        </tr>
									<%end
								end
								%>
						</table>		
						</div>
						
						<!-- 
							If isTableRowExists == 0; Table is Empty
							If isTableRowExists != 0; Table is Not Empty
						-->
						<% if (isTableRowExists == 0) and (usbdisk_info~=nil) then %>
							<div class="contentTxt" style="color: #5E5E5E;"><%=translate([==[Attention. At the moment is not shared any folder. It is possible to add additional folders from the configuration page.]==])%></div>
						<% else %>
							<% if (isTableRowExists ~= 0) then %>
							<script>
								document.getElementById("partitionTableId").style.display = "block";
							</script>
							<br/>
							<% end %>
						 <% end %>
						 <div id="mediaConfigBack" style="display:none">
						 <% if (usbdisk_info~=nil) then %>
						 <table cellspacing='0' cellpadding='0' width='100%' class="txtAlignCenter padtop10">
							<tr>
							<!-- <td style="padding-left:70px">&nbsp;</td> -->
							<td id="mediaServerMainBackBtn" class="">&nbsp;</td>
							<td><div><a href="advance.lp"><div class="midarea6-1 secondaryButton"><%=translate([==[Back]==])%></div></a><div></td>
						</tr>
						</table> 
						<% end %>
						</div>
					</td></tr>
					
					</table>
					
				</form>
			<script src="js/antiCSRF.js" type="text/javascript"></script>
			</div>
		</div>
	</div>
	<div id="warnUnmount" style="display:none;">

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
                          <td class="errorMessage"><%=translate([==[You are about to make changes]==])%>.</td></tr>
<tr>
                          <td class="errorDesc"><p><%=translate([==[Warning: USB device you want to remove there may be activities of indexing or access files in progress.]==])%></p></td></tr></table><br/>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
			<a class="fright" onclick="confirm_umount_submit()" href="#" id="remove">
						<div class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a></td>
		    <td  class="verticalAlign" style="padding-left:15px;">
<a onclick="cancelForm()" href="#">
						<div class="midarea6-1 mainButton"> <%=translate([==[Cancel]==])%> </div> </a></td></tr></table></td>
            </tr>
				
            </table>
        
</div>
</div>
  
	</div>

	<div id="warnEnable" style="display:none;">
	
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
                          <td class="errorMessage"><%=translate([==[Warning]==])%></td></tr>
            <tr><td class="errorDesc" id="chiaveKOMsg">
			<p><%=translate([==[Warning: disabling File Server, the Media Server will be automatically disabled]==])%>.</p>
				  <p><%=translate([==[Press &quot;Continue&quot; to return to previous page]==])%>.</p>
		<br/></td></tr></table>
                   </td></tr>
                 <tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				     <a onclick="cancelForm()" href="#">
						<div class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
                     						   </td></tr>
                   </table>
        </td></tr></table>
    
</div>
</div>
	</div>
	</div>
	
	<div id="dirCheck" style="display:none">
	<%cgilua.lp.include("webparts/directoryFail.lp")%>
	</div>
	
	<div id="dirLenCheck" style="display:none">
	<%cgilua.lp.include("webparts/directoryLengthCheck.lp")%>
	</div>

	</div>
	
		
	<script language="javascript">
	var cs_state= "<%=cs_state%>";
	if(cs_state=="true"){
			document.getElementById("cs1").checked = true;
	}else{
			document.getElementById("cs2").checked = true;
	}
</script>
<script language="javascript" type="text/javascript">
function dlna_delete(param,txt) {
	//var txt = document.getElementById("confSave"+param).innerHTML;
	//alert("txt-->"+txt)
	if(txt == "delete") {
		document.getElementById("count").value = "<%=dlna_count%>";
		document.getElementById("dlna_del"+param).value = "on";

        	document.getElementById("dlnaDeleteFlag").value = "1";
        	document.mediaForm.submit();
	} else if(txt == "save") {
		document.getElementById("count").value = "<%=dlna_count%>";
		document.getElementById("dlna_con"+param).value = "on";

		var value = document.getElementById("confIndex"+param).value;
		setIndexFlag(value,"movieFlag","musicFlag","pictureFlag")

        	document.getElementById("dlnaConfFlag").value = "1";
        	document.mediaForm.submit();
	}

}

function dlna_conf(param,txt) {
	//var txt = document.getElementById("confCancel"+param).innerHTML;
	//alert("txt-->"+txt)
	if(txt == "edit") {		
		document.getElementById("indxSel"+param).style.display = "block";
		document.getElementById("indx"+param).style.display = "none";

		document.getElementById("confEdit"+param).style.display = "none";
		document.getElementById("confCancel"+param).style.display = "block";

		document.getElementById("confDel"+param).style.display = "none";
		document.getElementById("confSave"+param).style.display = "block";
		mediaServerConfigDisplay('mediaStatus','mediaconfig');
	} else if(txt == "save") {
		document.getElementById("count").value = "<%=dlna_count%>";
		document.getElementById("dlna_con"+param).value = "on";

		var value = document.getElementById("confIndex"+param).value;
		setIndexFlag(value,"movieFlag","musicFlag","pictureFlag")

        	document.getElementById("dlnaConfFlag").value = "1";
        	document.mediaForm.submit();
	} else {
		document.getElementById("dlna_con"+param).value = "off";

		document.getElementById("indxSel"+param).style.display = "none";
		document.getElementById("indx"+param).style.display = "block";

		document.getElementById("confEdit"+param).style.display = "block";
		document.getElementById("confCancel"+param).style.display = "none";

		document.getElementById("confDel"+param).style.display = "block";
		document.getElementById("confSave"+param).style.display = "none";
	}

}

function getQueryStringParameter(name){
    var qry=window.location.href	
	//alert(qry)
    if(typeof qry !== undefined && qry !== ""){
        var keyValueArray = qry.split("&");
        for ( var i = 0; i < keyValueArray.length; i++) {
            if(keyValueArray[i].indexOf(name)>-1){
                return keyValueArray[i].split("=")[1];
            }
        }
    }
    return "";
}
var dlnaFlag = <%= mbusDlna%>;

<% if isRemote==false then%>
var selectedDir = getQueryStringParameter("sdir");
var partId = "<%=cgilua.QUERY["id"]%>";
var backFlag = getQueryStringParameter("back");

if(selectedDir!=null && selectedDir!="" && selectedDir!="undefined") {	
	mediaServerConfigDisplay('mediaStatus','mediaconfig');	
	document.getElementById("mediaStatus").className="";
	document.getElementById("mediaconfig").className="current";
	selectedDir = unescape(selectedDir);
	if(selectedDir !=" "  && dlnaFlag) {
		document.getElementById("partitionPath").value =partId;
		document.getElementById("directoryName").value =unescape(selectedDir);		
		document.getElementById("selectedDir").innerHTML = parseSlash(unescape(selectedDir));
	}
} else if(backFlag!="" && backFlag!=null && backFlag!="undefined" && backFlag== "true") {	
	mediaServerConfigDisplay('mediaStatus','mediaconfig');

	document.getElementById("mediaStatus").className="";
	document.getElementById("mediaconfig").className="current";
	if(document.getElementById("directoryName")){
		document.getElementById("directoryName").value ="";
	}
	if(document.getElementById("selectedDir")){
		document.getElementById("selectedDir").innerHTML = "";
	}
} else {
	document.getElementById("mediaStatus").className="current";
	document.getElementById("mediaconfig").className="";
	//document.getElementById("selectedDir").innerHTML = "";
}

<% end %>
</script>

<script src="js/browser.js" type="text/javascript"></script>
<script>
var browserName = getBrowserName();
var majorVersion = getBrowserMajorVersion();

if (browserName == "Microsoft Internet Explorer")
{
	if (majorVersion <= 7) 
	{
		if(document.getElementById("mediaServerMainBackBtn"))
		{
			document.getElementById("mediaServerMainBackBtn").className="backBtnPadding-ie6nOpera";
		}
	} 
	else
	{
		if(document.getElementById("mediaServerMainBackBtn"))
		{
			document.getElementById("mediaServerMainBackBtn").className="backBtnPadding";
		}
	}	
}
else if (browserName == "Opera" )
{
		if(document.getElementById("mediaServerMainBackBtn"))
		{
			document.getElementById("mediaServerMainBackBtn").className="backBtnPadding-ie6nOpera";
		}
}
else if (browserName == "Chrome" || browserName == "Safari")
{
		if(document.getElementById("mediaServerMainBackBtn"))
		{
			document.getElementById("mediaServerMainBackBtn").className="backBtnPadding-Chrome";
		}
}
else
{
	if(document.getElementById("mediaServerMainBackBtn"))
	{
		document.getElementById("mediaServerMainBackBtn").className="backBtnPadding";
	}
}
</script>

</body>
</html>

