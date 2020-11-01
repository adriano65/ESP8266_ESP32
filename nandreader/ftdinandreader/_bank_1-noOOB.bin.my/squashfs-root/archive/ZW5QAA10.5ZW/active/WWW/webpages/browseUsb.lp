<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css"/>
	<!-- <link rel="stylesheet" href="css/menu.css" type="text/css"/>
	<link rel="stylesheet" href="css/style.css" type="text/css"/> -->
<% cgilua.lp.include("lp/util.lp") %>
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
				mod = date.day .. sep .. date.month .. sep .. date.year .. " " .. date.hour .. ":" .. date.min .. ":" .. date.sec
			end
				
				result[i].filePath = f
				result[i].file = file
			if attr~=nil then
				result[i].modDate = mod
				result[i].mode = attr.mode
				result[i].size = attr.size
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
local pathId = ""
local isParentFolder = true 

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

if QUERY["filePath"]~=nil then
	pathStr = tostring(QUERY["filePath"])
	pathId = tostring(QUERY["id"])
	-- Fix for TI Security Issue mentioned in 20141205-report-agvtf-v2.pdf section D.2
	-- Multiple cross-site scripting vulnerabilities (XSS on page browseUsb.lp)
	pathId = cgilua.urlcode.escape(pathId)
	local valid = string.find(pathStr, "/var/usbmount/sd")
	local validDir = validDirectory(pathStr)	
	if valid==nil or valid~=1 or validDir==0 then
		cgilua.redirect("mediaServer.lp")
		return
	end
else
	cgilua.redirect("mediaServer.lp")
	return
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
	local filePath = POST["filePath"]
	local pathId = POST["pathId"]

	if POST["fileFlag"] == "redirectFolder" then
		cgilua.redirect("browseUsb.lp", {filePath = filePath,id=pathId})
		return	
	end
end

%>
</head>
<script language="JavaScript" type="text/javascript">
//Redirect to the parent folder
function redirectFolder(filePath,pathId)
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
	document.getElementById('pathId').value = pathId;
	document.radFile.submit();
}


//Show the creating new folder crtl.
function showMkDir()
{	
	document.getElementById("showMkDir").style.display = "none";
	document.getElementById("mkDir").style.display = "block";
}

var selectedDir='';
var partId= ''
function selectDirectory(path,name,id) {
	selectedDir=path;
	partId = id;	
	var p = path.split("/");
	var i = 0;
	var parent = "";
	var selectedDir = "";
	if(p.length > 4) {		
		for (i = 4; i < p.length; i++) {
			if(p[i]!="") {
				parent = parent + "/" + p[i];			
			}
		}
		selectedDir = parent+"/"+name;
	} else {
		if(name != "/")	{
			selectedDir = "/"+name;
		} else {
			selectedDir = name;
		}
	}
	document.getElementById("selectedDir").value = selectedDir; 		
	//location.href = "mediaServer.lp?sdir="+selectedDir+"&id="+id
}

function applyDir() {
	var selectedDir = document.getElementById("selectedDir").value;		
	location.href = "mediaServer.lp?sdir="+escape(selectedDir)+"&id="+partId;

}

function cancalDir() {
	location.href = "mediaServer.lp?back=true";
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
<table cellspacing='0' cellpadding='0' width="100%">
<tr>
	
	<td class='data' style='vertical-align:top'>
		<table cellspacing='0' cellpadding='0' width="100%">
		
		<tr><td> 
			<br>
			<form name='radFile' action="" method='post'>
			<input type="hidden" id="rowNum" name="rowNum" value="" />
			<input type="hidden" id="filePath" name="filePath" value="" />
			<input type="hidden" id="pathId" name="pathId" value="" />	
			<input type="hidden" id="fileFlag" name="fileFlag" value="" />
			<table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0' style="line-height:150%;"> 
				<tr><td colspan='2' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
				<tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
				<tr><th align="left"><%=translate([==[Name]==])%></th><th align="left" class="padleft30"><%=translate([==[Select]==])%></th></tr>
				<tr><td colspan='2'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
				<tr><td colspan='2' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
				<%if isParentFolder then%>
				<tr><td colspan='2' class="evenrow_firewall"><a href="javascript:redirectFolder('<%=pathStr%>','<%=pathId%>');"><%=translate([==[Back]==])%></a></td></tr>
				<tr><td colspan='2' class="evenrow_firewall"><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
				<%end%>
					
			<%				
				local file_T = attrdir(pathStr)
				local rowStyle = "oddrow_firewall"
				local rowNum = 1	
				local rowNum_tmp = 1			
				for i=1,#file_T do 
					rowNum = rowNum + 1
														
					if i==1 then
						local spArray = splitPath(pathStr,"/")
					if #spArray == 3 then	
			%>
					<tr>
							<td class="oddrow_firewall">
						<div id="rootDir" style="width:350px;word-wrap:break-word">/</div>							
							</td>
							<td class="oddrow_firewall" style="padding-top:10px;">
							<a href="javascript:selectDirectory('<%=pathStr%>','/','<%=pathId%>')"><div class="midarea6-1  mainButton"><%=translate([==[Select]==])%></div></a>
							</td>
							
						</tr>

			<%
					end
					end
					if file_T[i].mode == "directory"  and startswith(file_T[i].file,".") ~= true then
					rowNum_tmp = rowNum_tmp + 1
					if rowNum_tmp%2==1 then
						rowStyle = "oddrow_firewall"
					else
						rowStyle = "evenrow_firewall"
					end
			%>	
						<tr>
							<td class="<%=rowStyle%>">
								<div id="fileNameShow<%=i%>" style="width:350px;word-wrap:break-word"><a href="browseUsb.lp?filePath=<%=cgilua.urlcode.escape(file_T[i].filePath)%>&id=<%=pathId%>"><%=file_T[i].file%></a></div>
							
							</td>

							<td class="<%=rowStyle%>" style="padding-top:10px;">
							<a href="javascript:selectDirectory('<%=pathStr%>','<%=file_T[i].file%>','<%=pathId%>')"><div class="midarea6-1 mainButton"><%=translate([==[Select]==])%></div></a>
							</td>
							
						</tr>
					<%end%>
					<!--	
					<tr><td class="<%=rowStyle%>" colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
					-->					
				<%end%>
				<%
					--[[if rowStyle == "oddrow_firewall" then
						rowStyle = "evenrow_firewall"
					else
						rowStyle = "oddrow_firewall"
					end]]
				%>
				<tr><td><img src='images/spacer.gif' border='0' width='1' height='15' alt=''><br></td></tr>	
				<tr><td colspan='6'><textarea cols="30" rows="3" disabled id="selectedDir" name = "selectedDir"> </textarea> </td></tr>
				<tr><td><img src='images/spacer.gif' border='0' width='1' height='15' alt=''><br></td></tr>
				<tr>
				<td>
					<a onclick="applyDir()"><div class="midarea6-1 mainButton"><%=translate([==[Apply]==])%></div></a>
					<a onclick="cancalDir()"><div style="margin-left:20px;" class="midarea6-1 secondaryButton "><%=translate([==[Back]==])%></div></a>
				</td>
					
				</tr>

					
					
			</table>
			</form>
			<input type="hidden" id="totalRowNum" name="totalRowNum" value="<%=rowNum%>" />
				
		</td></tr></table>
	</td>
</tr>
</table>

<script src="js/antiCSRF.js" type="text/javascript"></script>

</div>
</body>
</html>

