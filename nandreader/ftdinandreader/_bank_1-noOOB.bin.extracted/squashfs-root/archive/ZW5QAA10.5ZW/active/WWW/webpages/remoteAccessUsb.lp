<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css"/>
	
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/usb.lp") %>
<%
local sep = "/"
local print = cgilua.print
local POST = cgilua.POST
local QUERY = cgilua.QUERY
local tprint = require("tableprint")

require"lfs"

function attrdir (path)
	local result = {}
	local i=1
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			result[i] = {}
			local f = tostring(path..sep..file)
			local attr = lfs.attributes (f)	
			local date = ""
			local mod = ""
			if attr~=nil then
				date = os.date("*t", attr.modification)
				if(date.hour <= 9) then					
					date.hour = "0" .. date.hour
				end
				if(date.min <= 9) then					
					date.min = "0" .. date.min
				end
				if(date.sec <= 9) then					
					date.sec = "0" .. date.sec
				end
				mod = date.day .. sep .. date.month .. sep .. date.year .. " " .. date.hour .. ":" .. date.min .. ":" .. date.sec
								
			end
				
				result[i].filePath = f
				result[i].file = file
			if attr~=nil then
				result[i].modDate = mod
				result[i].mode = attr.mode
				result[i].size = attr.size
				result[i].size =(result[i].size / 1024)
			else
				result[i].modDate = ""
				result[i].mode = "" 
				result[i].size = "" 
			end
			i = i + 1
		end
	end
	table.sort(result, function(x, y) return string.lower(x["mode"]) < string.lower(y["mode"]) end)
	return result
end

local pathStr = ""
local isParentFolder = true 
local device_name  
if QUERY["filePath"]~=nil then
	pathStr = tostring(QUERY["filePath"])	 
	device_name = string.sub(pathStr,15)
	local idx = string.find(device_name, "/")
	if idx ~= nil and tonumber(idx) > 0 then
		device_name = string.sub(device_name,1,tonumber(idx-1))
	end
	local valid = string.find(pathStr, "/var/usbmount/sd")
	local validDir = validDirectory(pathStr)
	local get_Usb
	local usb_Name
	local usb_Namecheck = 0
	
	get_Usb = get_usb_list_home()
	if get_Usb ~= nil then
		for i=1,#get_Usb do
			usb_Name = "/var/usbmount/" .. tostring(get_Usb[i].device_name)
			usb_Namecheck = string.find(usb_Name, "/var/usbmount/sd")
		end
	end

	if usb_Namecheck ~= 1 or valid==nil or valid~=1 or validDir==0 then 
		cgilua.redirect("usbStato.lp")
		return
	end
else
	cgilua.redirect("usbStato.lp")
	return
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local filePath = POST["filePath"]
	
	if POST["fileFlag"] == "redirectFolder" then
		cgilua.redirect("remoteAccessUsb.lp", {filePath = filePath})
		return
	elseif POST["fileFlag"] == "downloadFile" then
		--  Fix for TESSA 509 : Reverted changes done to fix tessa 450, 
		--  To solve tessa 509 (Problems with download files on USB device)
		cgilua.redirect(tostring(filePath))
		return
	
	elseif POST["fileFlag"] == "delFile" then
		--Delete the file by the file path.
		os.remove(tostring(filePath))
	
	elseif POST["fileFlag"] == "renameFile" then
		local rowNum = POST["rowNum"]
		if rowNum == "" then
			cgilua.redirect(tostring(filePath))
			return
		end
		local oldFileName = filePath .. sep .. POST["oldFileName"..tostring(rowNum)]
		local newFileName = filePath .. sep .. POST["newFileName"..tostring(rowNum)]
		os.rename(tostring(oldFileName), tostring(newFileName))
		
		if pathStr ~= filePath then				
			pathStr = filePath
			isParentFolder = true
		end		
	elseif POST["fileFlag"] == "mkDir" then
		local newDirName = filePath .. sep .. POST["newDirName"] 
		lfs.mkdir(newDirName)
	else
		--Upload the file by the file path.	
		fileUploadPath = POST["fileUploadPath"] 
		cgilua.redirect("remoteAccessUsb.lp", {filePath = fileUploadPath})
		return
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
</head>
<script language="javascript" src="js/script.js"></script>
<script language="JavaScript" type="text/javascript">
//Redirect to the parent folder
function redirectFolder(filePath)
{
	var p = filePath.split("/");
	var i = 0;
	var parent = "";
	for (i = 0; i < p.length-1; i++)
	{
		parent = parent + p[i];
		if ( i != p.length-2)
			parent = parent + "/";
	}
	document.getElementById("fileFlag").value = "redirectFolder";
	document.getElementById('filePath').value = parent;
	document.radFile.submit();
}

//Download the file
function downloadFile(filePath)
{
	document.getElementById("fileFlag").value = "downloadFile";
	document.getElementById('filePath').value = filePath;
	document.radFile.submit();
}

//Upload the file
function uploadFile(filePath)
{		
	var fileName = document.getElementById("uploadNewFile").value;
	if(fileName == "")
	{
		alert("<%=translate([==[Please choose the upload file!]==])%>");
		return;
	}

	document.uploadFileForm.submit();
	document.getElementById("waitingInfo").style.display = "block";
}

//Delete the file
function deleteFile(filePath)
{	
	if(confirm("<%=translate([==[Do you want to delete the file?]==])%>"))
	{
		document.getElementById("fileFlag").value = "delFile";
		document.getElementById('filePath').value = filePath;
		document.radFile.submit();
	}
}

//Rename the file
function renameFile(filePath, rowNum)
{
	document.getElementById("fileFlag").value = "renameFile";
	document.getElementById('filePath').value = filePath;
	document.getElementById('rowNum').value = rowNum;
	//CPE_P00115567
	var newFileName = document.getElementById("newFileName"+rowNum).value;
	var FileLength = newFileName.length;
	if(newFileName.match(/[/:?*<>|\\]/))
	{
		document.getElementById("remoteUsb").style.display = "none";
		document.getElementById("renameInfo_illegalchar").style.display="block";
	}
	else if(FileLength > 256)
	{
	    document.getElementById("remoteUsb").style.display = "none";
	    document.getElementById("renameInfo_maxlength").style.display="block";
	}
	else {
	    document.radFile.submit();
	}
}

//Show the file name modifying ctrl.
function renameModShow(rowNum)
{
	if(document.getElementById("totalRowNum")){
	var totalRowNum = document.getElementById("totalRowNum").value;
	for(var i=1; i<=totalRowNum; i++)
	{
		document.getElementById("fileNameShow"+i).style.display = "block";
		document.getElementById("fileNameMod"+i).style.display = "none";
	}
	}
	document.getElementById("fileNameShow"+rowNum).style.display = "none";
	document.getElementById("fileNameMod"+rowNum).style.display = "block";
}

//Cancel to show the file name modifying ctrl.
function cancelRenameModShow(rowNum)
{
	document.getElementById("fileNameShow"+rowNum).style.display = "block";
	document.getElementById("fileNameMod"+rowNum).style.display = "none";
	document.getElementById("newFileName"+rowNum).value = document.getElementById("oldFileName"+rowNum).value;
}

//Create the new directory
function mkDir(filePath)
{
	var newDirName = document.getElementById("newDirName").value;
	if(newDirName == "")
	{
		alert("<%=translate([==[Please fill the directory name!]==])%>");
		return;
	}
	else if(newDirName.match(/[/:?*<>|\\]/))
	{
		document.getElementById("remoteUsb").style.display = "none";
		document.getElementById("renameInfo_illegalchar").style.display="block";
		return;
	}
	else if(newDirName.length > 256)
	{
	    document.getElementById("remoteUsb").style.display = "none";
	    document.getElementById("renameInfo_maxlength").style.display="block";
	    return;
	}
	document.getElementById("fileFlag").value = "mkDir";
	document.getElementById('filePath').value = filePath;
	document.radFile.submit();
}

//Show the creating new folder crtl.
function showMkDir()
{	
	document.getElementById("showMkDir").style.display = "none";
	document.getElementById("mkDir").style.display = "block";
}

//Cancel to create the new directory ctrl.
function cancelDir()
{
	document.getElementById("showMkDir").style.display = "block";
	document.getElementById("mkDir").style.display = "none";
}
//body onload
function linkToRemoteUsb()
{	
	var id = "";
	window.parent.menu.document.getElementById("home").style.display="block";
	window.parent.menu.document.getElementById("home").className="";
	window.parent.menu.document.getElementById("base").className="block";
	
	window.parent.menu.document.getElementById("tele").className="";
	window.parent.menu.document.getElementById("teleSub").style.display="none";
	window.parent.menu.document.getElementById("usbst").className="submenuselect1";
	window.parent.menu.document.getElementById("media").className="";
	
	id = window.parent.menu.document.getElementById("ipv6");
	if( id != null ) {
	window.parent.menu.document.getElementById("ipv6").className="";
	if(window.parent.menu.document.getElementById("ipv6list")) {
		window.parent.menu.document.getElementById("ipv6firewall").className="";
		window.parent.menu.document.getElementById("ipv6list").style.display="none";
	}
	}
	
	id = window.parent.menu.document.getElementById("port");
	if( id != null )	
	window.parent.menu.document.getElementById("port").className="";
	
	id = window.parent.menu.document.getElementById("dns");
	if( id != null )	
	window.parent.menu.document.getElementById("dns").className="";
	
	window.parent.menu.document.getElementById("firewa").className="";
	
	id = window.parent.menu.document.getElementById("urlfi");
	if( id != null )	
	window.parent.menu.document.getElementById("urlfi").className="";
	
	//window.parent.menu.document.getElementById("reac").className="";
	window.parent.menu.document.getElementById("waon").className="";
	window.parent.menu.document.getElementById("stru").className="";
	window.parent.menu.document.getElementById("advance").className="Icons";
	window.parent.menu.document.getElementById("d3").style.display="block";
}
var usbliststr = "<%=usbLstStrng%>";
function usbResponse(data){
	var rsps = data.responseText;
	if(rsps.indexOf("true") > -1){		
		window.location = "home.lp";
	}
	setTimeout(function() {
	validateUSBEjct();},3000);	 
}
function validateUSBEjct(){
	if(usbliststr != null && usbliststr != ""){
		var urlStr = "/application_ajax.lp"
		var params="isUSB=true&rmacess=true&usbNames=<%=device_name%>";		
		sajax_get(urlStr, params, usbResponse);		 	
	}
}
validateUSBEjct();
</script>
<body onload="javascript:linkToRemoteUsb();">

<div class="contentContainer">
<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="remoteAccessUsb.lp"><%=translate([==[Disk]==])%> USB</a></li> 
			</ul>
		</div>

<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="#" class="current">
		<div class="tab">
			<span class="tabIcon_stusb"></span>  
			<span class="contTabTxt transform"><%=translate([==[Disk]==])%> USB</span>
		</div>
		<div class="clrBth"></div></a></li>
			</ol>
		</div>


<div class="contentcontainer">
<hr> 
<div class='contentitem'> 
<%local id = cgilua.session.storefilepath(pathStr, "", 1)%>
<div id="remoteUsb" class="fontSize">
<table cellspacing='0' cellpadding='0' width="100%">
<tr>
	<!-- <td class='icon' style='vertical-align:top' width='100px'><img src='images/usb__xl.gif' alt='Technicolor Gateway'></td>  -->
	<td class='data' style='vertical-align:top'>
		<table cellspacing='0' cellpadding='0' width="100%" class="fontSize">
		<!-- <tr>
			<td align='left'><span class='itemtitle'><%=translate([==[Remote Access]==])%></span></td>
		</tr>  -->
		<tr><td> 
			<br>
			<form name='radFile' action="" method='post'>
			<input type="hidden" id="rowNum" name="rowNum" value="" />
			<input type="hidden" id="filePath" name="filePath" value="" />
			<input type="hidden" id="fileFlag" name="fileFlag" value="" />
			<table class='edittable marleft40 width770' width='100%' cellspacing='0' cellpadding='0' border='0' style="line-height:150%;"> 
				<tr><td colspan='6' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
				<tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
				<tr>
				<th class="tableHd verticalAlign" align="left" style="width:305px;"><%=translate([==[Name]==])%></th>
				<th class="tableHd txtAlignCenter verticalAlign"><%=translate([==[Download]==])%></th>
				<th class="tableHd txtAlignCenter width120 verticalAlign"><%=translate([==[Delete]==])%></th>
				<th class="tableHd txtAlignCenter verticalAlign"><%=translate([==[Rename]==])%></th>
				<th class="tableHd width130 txtAlignCenter verticalAlign"><%=translate([==[Size]==])%><br/>(KB)</th>
				<th class="tableHd width225 verticalAlign" align="left"><%=translate([==[Date]==])%></th>
				</tr>
				<tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
				<tr><td colspan='6' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
				<%if isParentFolder then%>
				<tr><td colspan='6' class="evenrow_firewall"><div class="fleft"><a href="javascript:redirectFolder('<%=pathStr%>');"><img src="images/folder_up_usb.png" alt="<%=translate([==[Parent folder]==])%>"/></div><div class="usbText"><%=translate([==[Parent folder]==])%></a></div></td></tr>
				<tr><td colspan='6' class="evenrow_firewall"><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
				<%end%>	
			<%				
				
				local file_T = attrdir(pathStr)
				local rowStyle = "oddrow_firewall"
				local rowNum = 0

				for i=1,#file_T do 
					rowNum = rowNum + 1
					if rowNum%2==1 then
						rowStyle = "oddrow_firewall"
					else
						rowStyle = "evenrow_firewall"
					end
					if file_T[i].mode == "directory" then
			%>
						<tr>
							<td class="<%=rowStyle%>">
								<div style="width:340px;">
								<div class="fleft ">
								<a href="remoteAccessUsb.lp?filePath=<%=file_T[i].filePath%>">
								<img src="images/folder_usb.png" alt="<%=translate([==[folder]==])%>"/></div>
								<div  id="fileNameShow<%=i%>" class="wordWrap usbText"><%=file_T[i].file%></div></a>
								<input type="hidden" id="oldFileName<%=i%>" name="oldFileName<%=i%>" value="<%=file_T[i].file%>" />
								<div id="fileNameMod<%=i%>" style="display:none;">
								<table cellspacing='0' cellpadding='0'><tr>
								<td><input type="text" id="newFileName<%=i%>" name="newFileName<%=i%>" value="<%=file_T[i].file%>" /></td>
								<td class="padtop5"><a onclick="renameFile('<%=pathStr%>','<%=i%>')" href="#"><div class="midarea6-1 mainButton" style="width:60px"><%=translate([==[Apply]==])%></div></a></td>
								<td class="padtop5"><a onclick="cancelRenameModShow('<%=i%>')" href="#"><div class="midarea6-1 mainButton" style="width:60px"><%=translate([==[Clear]==])%></div></a></td></tr></table></div></div>
							</td>
							<td class="<%=rowStyle%>"></td>
							<td class="<%=rowStyle%>"></td>
							<td class="<%=rowStyle%> txtAlignCenter">
							<a href="javascript:renameModShow('<%=i%>')"><img src="images/rename_usb.png" alt="<%=translate([==[Rename]==])%>"/></a>
							</td>
							<td class="<%=rowStyle%>"></td>							
							<td class="<%=rowStyle%>"><%=file_T[i].modDate%></td>
						</tr>
					<%else%>
						<tr>
							<td class="<%=rowStyle%>">
								<div style="width:340px;"><div><div class="fleft " style="width:20px;display:block"><img src="images/file_usb.png" alt="File"/></div><div id="fileNameShow<%=i%>" class="wordWrap usbText"><%=file_T[i].file%><input type="hidden" id="oldFileName<%=i%>" name="oldFileName<%=i%>" value="<%=file_T[i].file%>" /></div></div>
								<div id="fileNameMod<%=i%>" style="display:none;">
								<div class="fleft"><table cellspacing='0' cellpadding='0' style="width:300px;padding-left:8px;"><tr><td><input type="text" id="newFileName<%=i%>" name="newFileName<%=i%>" value="<%=file_T[i].file%>" /></td>
								<td class="padtop5"><a onclick="renameFile('<%=pathStr%>','<%=i%>')" href="#"><div class="midarea6-1 mainButton" style="width:60px"><%=translate([==[Apply]==])%></div></a></td>
								<td class="padtop5"><a onclick="cancelRenameModShow('<%=i%>')" href="#"><div class="midarea6-1 mainButton" style="width:60px"><%=translate([==[Clear]==])%></div></a></td></tr></table></div></div></div>
							</td>
							<td class="<%=rowStyle%> txtAlignCenter">
							<a href="javascript:downloadFile(%22<%=file_T[i].filePath%>%22)"><img src="images/download_usb.png" alt="<%=translate([==[Download]==])%>"/></a>
							</td>
							<td class="<%=rowStyle%> txtAlignCenter">
							<a href="javascript:deleteFile(%22<%=file_T[i].filePath%>%22)"><img src="images/delete_usb.png" alt="<%=translate([==[Delete]==])%>"/></a>
							</td>
							<td class="<%=rowStyle%> txtAlignCenter">
							<a href="javascript:renameModShow('<%=i%>')"><img src="images/rename_usb.png" alt="<%=translate([==[Rename]==])%>"/></a>
							</td>
							
							<td id="fileSize<%=rowNum%>" class="<%=rowStyle%> txtAlignCenter width130"></td>
							<td class="<%=rowStyle%>"><%=file_T[i].modDate%></td>
						</tr>
						<script type="text/javascript">
							var fileSize = Math.floor(<%=file_T[i].size%>)
							document.getElementById("fileSize<%=rowNum%>").innerHTML = fileSize;
						</script>
					<%end%>
					<tr><td class="<%=rowStyle%>" colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>					
				<%end%>
				<%
					if rowStyle == "oddrow_firewall" then
						rowStyle = "evenrow_firewall"
					else
						rowStyle = "oddrow_firewall"
					end
					%>
					<tr><td class="paddtop10" style="padding-left:0px;" colspan='6'>
						<div id="mkDir" style="display:none;">
						<table cellspacing='0' cellpadding='0'><tr><td><input type="text" id="newDirName" name="newDirName" value="" /></td>
						<td class="padtop5"><a onclick="mkDir('<%=pathStr%>')"><div class="midarea6-1 mainButton" style="width:60px"><%=translate([==[Apply]==])%></div></a></td>
						<td class="padtop5"><a onclick="cancelDir()"><div class="midarea6-1 mainButton" style="width:60px"><%=translate([==[Cancel]==])%></div></a></td></tr></table>
						</div>
						<!-- <input type="button" value="<%=translate([==[Apply]==])%>" onclick="mkDir('<%=pathStr%>')"/>
						<input type="button" value="<%=translate([==[Cancel]==])%>" onclick="cancelDir()"/></div> -->
						<div id="showMkDir">
						<a onclick="showMkDir()"><div class="midarea7-1 mainButton"><%=translate([==[Click to create new folder]==])%></div></a></div>
						<!-- <input type="button" value="<%=translate([==[Click to create new folder]==])%>" onclick="showMkDir()"/><br/></div> -->
					</td></tr>
			</table>
			</form>
			<input type="hidden" id="totalRowNum" name="totalRowNum" value="<%=rowNum%>" />
			<div class="padleft40 martop5"><form name='uploadFileForm' action="remoteAccessUsb.lp?id=<%=id%>&filePath=<%=pathStr%>" method='post' enctype='multipart/form-data'>
			<div><input type="hidden" id="fileUploadPath" name="fileUploadPath" value="<%=pathStr%>" /></div>
			<div><input type="file"  id="uploadNewFile" name="uploadNewFile" size="50" style="height:24px;" class="linkPointer" /></div>
			<div class="martop5"><a onclick="uploadFile('<%=pathStr%>')"><div class="midarea7-3 mainButton"><%=translate([==[Upload new file]==])%></div></a></div>
						</form>		
		</td></tr></table>
	</td>
</tr>
</table>

<script src="js/antiCSRF.js" type="text/javascript"></script>

<div class='contentcontainer uploadMsg' id="waitingInfo" style="display:none;">
<div class='contentitem' >
    <table cellspacing='0' cellpadding='0' width='100%'>
		          <tr>  
                  <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td></tr><tr><td style='vertical-align:top'>
        <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage">
            <tr><td class="errorMessage"><%=translate([==[You are about to upload a file]==])%></td></tr>
            <tr><td class="errorDesc txtAlignCenter"><br/>
                <p><span class="verticalAlign"><img src='images/wait.gif' width="5%" height="5%" alt='Technicolor Gateway'></span><span class="marleft5 verticalAlign"><%=translate([==[Please wait for the file to be uploaded]==])%></span></p>
                <br/>
            </td></tr>
        </table>
    </td></tr></table>
</div>
</div>
</div>
</div>

<!-- Fix for CPE_P00115567 -->
<div class='contentcontainer' id="renameInfo_illegalchar" style="display:none;">
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
              <tr><td class="errorDesc">
                <p><%=translate([==[Following characters not allowed in a filename]==])%> \/:*?<>|</p>
             <br/>
        </td></tr></table>
        </td></tr>
        <tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
                 <a onclick="javascript:document.location.href='remoteAccessUsb.lp?filePath=<%=pathStr%>'">
                <div class="midarea6-1 mainButton" name="thb7"><%=translate([==[Continue]==])%></div></a>
                </td>
            </tr>
        </table>
          </td></tr></table>
</div>
</div>

<div class='contentcontainer' id="renameInfo_maxlength" style="display:none;">
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
              <tr><td class="errorDesc">
                <p><%=translate([==[Filename exceeds maximum characters]==])%>(256)!</p>
             <br/>
        </td></tr></table>
        </td></tr>
        <tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
                 <a onclick="javascript:document.location.href='remoteAccessUsb.lp?filePath=<%=pathStr%>'">
                <div class="midarea6-1 mainButton" name="thb7"><%=translate([==[Continue]==])%></div></a>
                </td>
            </tr>
        </table>
          </td></tr></table>
</div>
</div>

</div>
</body>
</html>

