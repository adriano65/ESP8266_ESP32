<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/>
<link rel="stylesheet" href="css/menu.css" type="text/css" /> -->
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<script language="javascript" type="text/javascript" src="js/portmap.js"></script>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/form.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/portmap.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<% cgilua.lp.include("lp/voip.lp") %>

<%
local isRemote = isRemoteAccess()
local translate = translate
local POST=cgilua.POST
local QUERY=cgilua.QUERY
local pathId = QUERY["pathId"]
if pathId==nil or pathId=="" then
    cgilua.redirect("voipStato.lp")
    return
end
local tprint = require("tableprint")


local linePath = "Device.Services.VoiceService.3.VoiceProfile."..pathId..".Line"

local linePath1 = "Device.Services.VoiceService.2.VoiceProfile"

local sipUri,dirNum = getFXSDECTSIP(linePath)

local totalRowcount = 0

--check the checkbox is checked or not
function isCheckedService(flag)
    local isChecked = 'checked="checked"'
    if flag~="true" then
        isChecked = ""
    end    
    return isChecked
end

local rowIds = ""	
--get count of phone number.
function countOfLineObj()    	
    local reply1, error1 = mbus.getParameters{ path = linePath1, datamodel = "second" }
    if reply1[linePath1]~=nil and reply1[linePath1][1]~=nil then
	local tmpPrty
        for h,f in pairs(reply1[linePath1]) do	
		local tempPath = f.path..".Line"
		local checkId = "numForUAMap"..h
		local checkVPId = "numForVPMap"..h
		local priorityId = "numPriority"..h  

		local reply, error = mbus.getParameters{ path = tempPath, param = "DirectoryNumber", datamodel = "second" }

		if reply[tempPath]~=nil and reply[tempPath][1]~=nil then
                for j,w in pairs(reply[tempPath]) do
                    --add the checked numbers to uamap.

		    local inCheckId = checkId..j
		    local inCheckVPId = checkVPId..j
		    local inPriorityId = priorityId..j

                    local numForInputExist = tostring(POST[inCheckId])
		    local priorityVP = tostring(POST[inPriorityId])
		    if rowIds == "" then
			rowIds = inPriorityId		    
		    else
			rowIds = rowIds..","..inPriorityId
		    end	 	
		end
		end
	end
	end
    --[[	
    local numberOfLineObj
    local replyLineNum, error = mbus.getParameters{ path = linePath, param = "DirectoryNumber", datamodel = "second" }
    numberOfLineObj = #replyLineNum[linePath]
    return numberOfLineObj
    ]]    
    return rowIds	
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local modify = {}
    if POST["saveFlag"] == "1" then
			local ipStatus = "false"
			if POST["ipStaInChk"]=="ON" then
                ipStatus = "true"
            end
		
		-- Fix for CPE_P00104261: IP phone state configuration not available from GUI
		-- Logic to check whether Enabled Line Status is Un-checked [or] Disabled Line Status in Checked
		local isLineStatusChecked = POST["statusCheckedValue"]
		local lineStatusPathId = "Device.Services.VoiceService.3.VoiceProfile."..pathId..".Line.1"
		if POST["statusDefaultValue"]=="ON" then
			if isLineStatusChecked == "0" then
				-- Disable the Line1
				local reply, error = mbus.modify(
					function()
						local reply, error = mbus.setParameters{path=lineStatusPathId, param={Enable="Disabled"}, datamodel = "second"}
					end, {datamodel="second"})
			end
		else
			if isLineStatusChecked == "1" then
				-- Enable the Line1
				local reply, error = mbus.modify(
					function()
						local reply, error = mbus.setParameters{path=lineStatusPathId, param={Enable="Enabled"}, datamodel = "second"}
					end, {datamodel="second"})
			end		
		end	
		
	     local portTypeValue = "Device.Services.VoiceService.3.VoiceProfile."..pathId..".Line.1"			
            --delete all the uamap.
            local deleteUAmapPath = "Device.Services.VoiceService.2.X_TELECOMITALIA_IT_UAMapping"
				
            local reply, error = mbus.modify(
		function()                    
                        local reply1, error1 = mbus.deleteObjects{path = deleteUAmapPath, filter="(== ToUA " .. portTypeValue .. ")", datamodel = "second"}                   
                end, {datamodel="second"})
			    	
	    --delete all the voiceportmap.
	    local deleteVoiceportmapPath = "Device.Services.VoiceService.3.X_TELECOMITALIA_IT_UAMapping"
		local reply, error = mbus.modify(
                function()                    
                        local reply2, error2 = mbus.deleteObjects{path = deleteVoiceportmapPath, filter="(== FromUA " .. portTypeValue .. ")", datamodel = "second"}                    
                end, {datamodel="second"})
					
		
		
            	local UAmapPath = "Device.Services.VoiceService.2.X_TELECOMITALIA_IT_UAMapping"	    
	    	local VoiceportmapPath = "Device.Services.VoiceService.3.X_TELECOMITALIA_IT_UAMapping"
	    	local fromVoicePortPath = linePath..".1"
  		local toVoicePortPath = linePath..".1"	

		local outRowNoPrty = {}
	    	local outRow = {}
	    	local outCount = 1
	    	local outCount1 = 1
	    	     	

	    local reply1, error1 = mbus.getParameters{ path = linePath1, datamodel = "second" }
	    if reply1[linePath1]~=nil and reply1[linePath1][1]~=nil then
		local tmpPrty
                for h,f in pairs(reply1[linePath1]) do	
		
		local tempPath = f.path..".Line"
		local checkId = "numForUAMap"..h
		local checkVPId = "numForVPMap"..h
		local priorityId = "numPriority"..h
   	

		local reply, error = mbus.getParameters{ path = tempPath, param = "DirectoryNumber", datamodel = "second" }

		if reply[tempPath]~=nil and reply[tempPath][1]~=nil then
                for j,w in pairs(reply[tempPath]) do
                    --add the checked numbers to uamap.

		    local inCheckId = checkId..j
		    local inCheckVPId = checkVPId..j
		    local inPriorityId = priorityId..j

                    local numForInputExist = tostring(POST[inCheckId])

                    if numForInputExist~="nil" then
                        local fromUAPath = w.path					
                        local numLanManaged = isNumLanManaged(fromUAPath)				   	
                        if numLanManaged~="true" then
                            local reply, error = mbus.modify(
                                function()
                                    local reply3, error3 = mbus.addObjects{ path = UAmapPath, param = { FromUA = fromUAPath, ToUA = toVoicePortPath }, datamodel = "second" }
                                    if error3~=nil or reply3[UAmapPath][1]==nil then
                                        result=1                               
                                    end
                                end, {datamodel="second"})
                        end
                    end

		    local numForOutgoExist = tostring(POST[inCheckVPId])	
		    local priorityVP = tostring(POST[inPriorityId])
		    if numForOutgoExist ~= "nil" then
			if priorityVP == "" then
				outRowNoPrty[outCount] = {}
				outRowNoPrty[outCount].toUAPath =  w.path
				outCount = outCount + 1
			else
				outRow[outCount1] = {}
				outRow[outCount1].toUAPath =  w.path
				outRow[outCount1].priority =  priorityVP
				outCount1 = outCount1 + 1
			end						
			
		    end
		
		end
		end
		end 	
		
		 local totalRow = #outRow
		 local count = 1
		 local lastPrty = 0
	         for m=1, totalRow do 
		   local tmpPrty
		   local tmpPath
                   local tmpId
		   for i=1, #outRow do		   	
		   	local v = outRow[i]		   			   	   
		   	if v.priority ~= nil then			
				if tmpPrty == nil then	
			    		tmpPrty = tonumber(v.priority)
					tmpId = i
					tmpPath = v.toUAPath	
		    		end   	
		   		if tmpPrty > tonumber(v.priority) then
					tmpPrty = tonumber(v.priority)
			    		tmpPath = v.toUAPath
					tmpId = i	
		    		else
					-- continue
		    		end		   
		    	end
	            end
		    if lastPrty >= tmpPrty  then					    	
			lastPrty = lastPrty +1
			tmpPrty = lastPrty	
		    else 
			lastPrty = tmpPrty		
		    end		    
                    local reply, error = mbus.modify(
                    function()
                	local reply4, error4 = mbus.addObjects{ path = VoiceportmapPath, param = { ToUA = tmpPath, FromUA = fromVoicePortPath, Priority = tostring(tmpPrty) }, datamodel = "second" }
                        if error4~=nil or reply4[VoiceportmapPath][1]==nil then
                        	result=1
                        end
                    end, {datamodel="second"})                         
		    table.remove(outRow,tmpId) 		
                end
		
		for i=1, #outRowNoPrty do
			local v = outRowNoPrty[i]
			local reply, error = mbus.modify(
                        function()
                        	local reply4, error4 = mbus.addObjects{ path = VoiceportmapPath, param = { ToUA = v.toUAPath, FromUA = fromVoicePortPath }, datamodel = "second" }                                    
                                if error4~=nil or reply4[VoiceportmapPath][1]==nil then
                                	result=1                                
                                end				
                        end, {datamodel="second"})   
		end


            end
        		    
        
    saveall(0, 1)
    cgilua.redirect("save_alert.lp", { u="voipStato.lp" })
    return
    end
end

local wrongPriority = translate([==[Warning: there are one or more priority input incorrect. Use only the allowed indexes (1-8).]==])
countOfLineObj()
%>
</head>

<body>
<script type="text/javascript">
//<![CDATA[
function showErrorMsg(errorMsgStr)
{
    document.getElementById("conf_all_num").style.display="none";
    document.getElementById("resultKO").style.display="block";
    document.getElementById("errorMsg").innerHTML=errorMsgStr;
}

function submitSave()
{
	
    var totalIds = '<%=rowIds%>';
    var idArr = totalIds.split(",");
    	
    for (i=0;i<=idArr.length-1;i++)
    {
	if (document.getElementById(idArr[i])!=null && document.getElementById(idArr[i]) != "undefined") {
	        
		var priorityStr = document.getElementById(idArr[i]).value;
        	if(priorityStr!="") {
            		if(!priorityExam(priorityStr))
            		{
                		showErrorMsg('<%=wrongPriority%>');
                		return false;
            		}
        	}
	}
    }
	
	
	/* Fix for CPE_P00104261: IP phone state configuration not available from GUI */
	var isStatusChecked = document.getElementById("ipStaInChk").checked;
	if(isStatusChecked) {
		document.getElementById("statusCheckedValue").value="1";
	} else {
		document.getElementById("statusCheckedValue").value="0";
	}
	
	var statusCurrentValue = document.getElementById("ipStaInChk").value;
	if (statusCurrentValue == "ON" ) {
		document.getElementById("statusDefaultValue").value="ON";
	} else {
		document.getElementById("statusDefaultValue").value="OFF";
	}
	
        document.getElementById("saveFlag").value="1";
        document.configTelephony.submit();
}
function cancelConfirm()
{
    document.getElementById("conf_all_num").style.display = "";
    document.getElementById("confirm").style.display = "none";
    document.getElementById("resultKO").style.display="none";
}

function priorityExam(str)
{
    //exam the input box value is number or not.
    //var filter=/^\s*[.,0-9]{0,10240}\s*$/;
    var filter=/^\d/g;
    if ((str.indexOf(' ') != -1) || (!str.match(filter)) || (str > 8))
    {
        return false;
    }
    return true;
}
//]]>
</script>

<div class="contentContainer">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="voipStato.lp"><%=translate([==[Telephony]==])%></a></li> 
			</ul>
		</div>


<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="voipStato.lp"><%=translate([==[Telephony services]==])%></a></td><td align="right"><a href="voipStato.lp">Stato</a></td></tr>
</table> -->

	<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="voipStato.lp" class="current">
		<div class="tab">
			<span class="tabIcon_sttel"></span>  
			<span class="contTabTxt transform"><%=translate([==[Telephony services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemote==false then%> 
			<li><a class="margin15" href="telephonyNumber.lp">
		
		<div class="tab">
			<span class="contTabTxt transform"><%=translate([==[Telephone numbers]==])%></span></div></a></li>
		<% end %> 
			</ol>
	</div>

<div class='contentcontainer'>
<hr>
<div class='contentitem' id="conf_all_num">

<table border="0" width="100%">
<form id="configTelephony" name="configTelephony" action="" method="post">
<input type="hidden" id="pathId" name="pathId" value=""/>
<input type="hidden" id="saveFlag" name="saveFlag" value="0"/>
<input type="hidden" id="totalRC" name="totalRC" value="0"/>
<input type="hidden" id="statusCheckedValue" name="statusCheckedValue" value="0"/>
<input type="hidden" id="statusDefaultValue" name="statusDefaultValue" value="OFF"/>

<tr>
    <!-- <td class='icon' style='vertical-align:top' width='100px'><img src='images/tel___xl.gif' alt=''></td> -->
    <td class="padLeft37 verticalAlign">
        <table cellspacing='0' cellpadding='0' width="100%">
        <!-- <tr>
            <td align='left'><span class='itemtitle'><%=translate([==[Telephony services]==])%></span></td>
        </tr> -->
        <tr><td>
            <br><!-- Begin of showing Telephone Service-->
            <table cellspacing='0' cellpadding='0' width='100%' class="fontSize">
			<tr>
			<td width='0' class="verticalAlign">
			</td>
			<td class="verticalAlign">
            <span class='midarea2_telmain tableTitle'><%=translate([==[Telephone service State]==])%></span><br>
            <table width='100%' class='edittable valueSpace ' cellspacing='0' cellpadding='0' style="line-height:150%;width:770px;">
                <tr><td colspan='8'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><td align='left' class="width85 tableHeader"><div class="wordWrap width85"><%=translate([==[connection]==])%></div></td>
				<!--<th align='left' width='5%'><%=translate([==[Identity SIP]==])%></th>-->
					<td align='left' class="width70 tableHeader">
					<div class="wordWrap width48"><%=translate([==[Extension ]==])%><br/><%=translate([==[Number]==])%></div></td>		      	
                    <td align='left' class="width110 tableHeader">
					<div class="wordWrap width60"><%=translate([==[Number of ]==])%><br/><%=translate([==[input]==])%></div></td>
                    <td align='left' class="width110 tableHeader">
					<div class="wordWrap width60"><%=translate([==[Number of ]==])%><br/><%=translate([==[outgoing]==])%></div></td>
					<td align='left' class="tableHeader width65"><div class="wordWrap width65"><%=translate([==[Priority]==])%></div></td> 	
                    <td align='left' class="tableHeader width78"><div class="wordWrap width78">POS/FAX</div></td>                    
                    <td align='left' class="tableHeader wdth120px"><div class="wordWrap width130"><%=translate([==[Associated with fixed ]==])%><br/><%=translate([==[line]==])%></div></td>
					<td align='left' class="width70 tableHeader txtAlignCenter"><div class="wordWrap"><%=translate([==[Stato]==])%></div></td>
                </tr>
                <tr><td colspan='8'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <%
                local linePath = "Device.Services.VoiceService.2.VoiceProfile"
		local switchPath1 = "Device.Services.VoiceService.3.VoiceProfile."..pathId..".Line.1"

                local rowStyle = "oddrow_firewall"
                local phoneType
                
                local posFAX = "Non" .. "<br/>" .. "applicabile"                    
                local PSTNIn = "Non" .. "<br/>" .. "applicabile"
					
		local replyLineNum, error = mbus.getParameters{ path = switchPath1, param = {"DirectoryNumber", "X_TELECOMITALIA_IT_LineName"}, datamodel = "second" }
		phoneType = replyLineNum[switchPath1][1].param["X_TELECOMITALIA_IT_LineName"]
		if phoneType == nil then 
			phoneType = replyLineNum[switchPath1][1].param["DirectoryNumber"]
		end		
					
                %>
                <tr>
					<td class="<%=rowStyle%> fontSize width85"><div class="wordWrap"><%=phoneType%></div></td> 
				<!--<td class="<%=rowStyle%>" style="word-break:break-all;"><div style="width:70px;word-wrap:break-word;"><%=sipUri%></div></td>-->
					<td class="<%=rowStyle%> wordWrap "><div class="wordWrap"><%=dirNum%></div></td>
					<td class="<%=rowStyle%> "><div class="wordWrap">
                <%

		local reply1, error1 = mbus.getParameters{ path = linePath, datamodel = "second" }
		if reply1[linePath]~=nil and reply1[linePath][1]~=nil then
                    for h,f in pairs(reply1[linePath]) do	
			local tempPath = f.path..".Line"
		

		local checkId = "numForUAMap"..h


                local lanManagedNumber
			
                local replyLineNum, error = mbus.getParameters{ path = tempPath, param = {"DirectoryNumber", "X_TELECOMITALIA_IT_LANManaged","Enable"}, datamodel = "second" }
                if replyLineNum[tempPath]~=nil and replyLineNum[tempPath][1]~=nil then
                    for i,v in pairs(replyLineNum[tempPath]) do
			totalRowcount = totalRowcount +1
			local enableFlag = "false"
                        lanManagedNumber = v.param["X_TELECOMITALIA_IT_LANManaged"]
			local enable = v.param["Enable"]			
                        local numUsed = "false"
                        local isNumExist = findUAMapNumExist1(switchPath1, v.path)	
                        if isNumExist=="true" then
                            numUsed = "true"
                        end
			if enable == "Enabled" then
				enableFlag = "true"
			end
			local inCheckId = checkId..i
                       
			if (v.param["DirectoryNumber"]~="" and v.param["DirectoryNumber"]~=nil) then
                                cgilua.print("<div style='display:block'>"..tostring(v.param["DirectoryNumber"]).."&nbsp;&nbsp;<input type='checkbox' "..isCheckedService(numUsed).." name='"..inCheckId.."' id='"..inCheckId.."' value='"..isCheckedService(numUsed).."' /></div>")                            
                        end

                    end
                end

		 end
                end

                %>
					</div></td>
					<td class="<%=rowStyle%> "><div class="wordWrap">
                <%

		local tprint = require("tableprint")
		local newPriority
		local reply1, error1 = mbus.getParameters{ path = linePath, datamodel = "second" }
		if reply1[linePath]~=nil and reply1[linePath][1]~=nil then
                    for h,f in pairs(reply1[linePath]) do	
			local tempPath = f.path..".Line"


		local checkId = "numForVPMap"..h
		local priorityId = "numPriority"..h

                local lanManagedNumber
                local replyLineNum, error = mbus.getParameters{ path = tempPath, param = {"DirectoryNumber", "X_TELECOMITALIA_IT_LANManaged","Enable"}, datamodel = "second" }
                if replyLineNum[tempPath]~=nil and replyLineNum[tempPath][1]~=nil then
                    for i,v in pairs(replyLineNum[tempPath]) do
			local enableFlag = "false"
                        lanManagedNumber = v.param["X_TELECOMITALIA_IT_LANManaged"]
			local enable = v.param["Enable"]		
                        local numUsed = "false"
                        local priority = ""			
                        local isNumExist = findVPMapNumExist1(switchPath1, v.path)		
                        if isNumExist=="true" then
                            numUsed = "true"
                            priority = getVPMapNumPrio1(switchPath1,v.path)
                        end
			if enable == "Enabled" then
				enableFlag = "true"
			end
                        --local preassOutNum = getPreassignedOutNum(switchPath)
			if priority == nil then
				priority = ""
			end

			local inCheckId = checkId..i
			local inPriorityId = priorityId..i

                        if (v.param["DirectoryNumber"]~="" and v.param["DirectoryNumber"]~=nil) then
                                cgilua.print("<div style='display:block'>"..tostring(v.param["DirectoryNumber"]).."&nbsp;&nbsp;<input type='checkbox' "..isCheckedService(numUsed).." name='"..inCheckId.."' id='"..inCheckId.."' value='"..isCheckedService(numUsed).."' /></div>")
				if newPriority==nil then	
					newPriority = "<input type='text' size='1' name='"..inPriorityId.."' id='"..inPriorityId.."' value='"..tostring(priority).."'/><br>"
				else 
					newPriority = tostring(newPriority) .. "<input type='text' size='1' name='"..inPriorityId.."' id='"..inPriorityId.."' value='"..tostring(priority).."'/><br>"
				end
                        end

                    end
                end

		end
                end

		if newPriority == nil then
			newPriority = ""
		end
				
                %>
					</div></td>
					<td class="<%=rowStyle%> " ><div class="wordWrap"><%cgilua.print(newPriority)%></div></td>
					<td class="<%=rowStyle%> wordWrap width78"><div class="wordWrap width78" ><%=posFAX%></div></td>
					<td class="<%=rowStyle%> "><div class="wordWrap"><%=PSTNIn%></div></td>
				<%				
				local ipStatus = "false"	
				local replyLineNum, error = mbus.getParameters{ path = switchPath1, param = {"Enable"}, datamodel = "second" }
				local ipStato = replyLineNum[switchPath1][1].param["Enable"]
				
				if(ipStato == "Enabled" ) then
					ipStatus = "true"
				%>
					<td class="<%=rowStyle%> wordWrap"><div class="wordWrap padleft10">
						<%=translate([==[Actived]==])%> <input type="checkbox" <%=isCheckedService(ipStatus)%> name="ipStaInChk" id="ipStaInChk" value="ON" class="alignMid "/>
					</div></td>
				<%
				else
					ipStatus = "false"	
				%>
					<td class="<%=rowStyle%> wordWrap"><div class="wordWrap padleft10">
						<%=translate([==[Actived]==])%> <input type="checkbox" <%=isCheckedService(ipStatus)%> name="ipStaInChk" id="ipStaInChk" value="OFF" class="alignMid" />
					</div></td>
				<%	
				end
				%>
                </tr>
                <tr><td colspan="8" class="padtop10">
                <table cellspacing='0' cellpadding='0' class="padtop10" width='100%'  style="text-align:center">
                <tr ><td style='padding-left:250px;'>
					<a style='color:black' onclick='javascript: submitSave();' href="#"><div class='midarea6-1 mainButton' name="thb10"><%=translate([==[Save]==])%></div></a></td>
					<td style='padding-right:250px;'>
					<a style='color:black' onclick='javascript:document.location.href="voipStato.lp";' href="#"><div class='midarea6-1 secondaryButton' name="thb7"><%=translate([==[Back]==])%></div></a></td>
                    
                </tr>
                </table>
				</td></tr>
            </table>
            </td></tr></table>
        </td></tr></table>
    </td>
</tr>
</form>
</table>
</div>
</div>
</div>
<script type="text/javascript">
	document.getElementById("totalRC").value=<%=tonumber(totalRowcount)%>;
</script>
<div id="resultKO" style="display:none">
<%cgilua.lp.include("webparts/resultKO_Priority.lp")%>
</div>
<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>
