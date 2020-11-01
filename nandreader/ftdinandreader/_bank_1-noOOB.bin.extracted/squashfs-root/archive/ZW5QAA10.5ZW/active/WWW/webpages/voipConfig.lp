<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/master.css" type="text/css"/>
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
local get_assoNum = QUERY["assoNum"]
local assoNum = string.gsub(get_assoNum," ", "+")

if pathId==nil or pathId=="" then
    cgilua.redirect("voipStato.lp")
    return
end
local tprint = require("tableprint")

local switchPath1 = "Device.Services.VoiceService.3.VoiceProfile"
local linePath = "Device.Services.VoiceService.2.VoiceProfile.1.Line"

local linePath1 = "Device.Services.VoiceService.2.VoiceProfile"

local sipUri,dirNum = getFXSDECTSIP("Device.Services.VoiceService.1.VoiceProfile.1.Line")

local totalRowcount = 0
local count = 10
if(tonumber(pathId) == 1)then
	count = 1
else
	count = count + tonumber(pathId)
end
tprint("Path id added with count......")
tprint(count)
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
                    local numForOutgoExist = tostring(POST[inCheckVPId])			
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
        if tonumber(pathId)<3 then
            local posConfigPath = "Device.Services.VoiceService.1.PhyInterface." .. tostring(pathId)
            local oldPosConfig, oldPstnIn, oldPstnOut = POST["oldPosConfig"], POST["oldPstnIn"], POST["oldPstnOut"]
            local status, pstnInStatus, pstnOutStatus = "false", "false", "false"
            if POST["posChk"]=="ON" then
                status = "true"
            end
            if POST["pstnInChk"]=="ON" then
                pstnInStatus = "true"
            end

            if POST["pstnOutChk"]=="ON" then
                pstnOutStatus = "true"
            end
            modify = {}
	    	
            if oldPosConfig ~= status then
				table.insert(modify, {path=posConfigPath, param={X_TELECOMITALIA_IT_POSConfig=status}, datamodel="second"})
			end
			if oldPstnIn ~=  pstnInStatus then
				table.insert(modify, {path=posConfigPath, param={X_TELECOMITALIA_IT_SwitchToPSTNIn=pstnInStatus}, datamodel="second"})
			end
			if oldPstnOut ~= pstnOutStatus then
				table.insert(modify, {path=posConfigPath, param={X_TELECOMITALIA_IT_SwitchToPSTNOut=pstnOutStatus}, datamodel="second"})
			end
            setMBUS_IGD(modify)
		
			local portTypeValue = switchPath1 .. "." .. count .. ".Line.1"	
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
			local toVoicePortPath =   portTypeValue
			local fromVoicePortPath = portTypeValue
	    
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
				local numForInputExist = tostring(POST["assoNum"])
	
				local reply, error = mbus.getParameters{ path = tempPath, param = "DirectoryNumber", filter="(== DirectoryNumber " .. numForInputExist .. ")", datamodel = "second" }
	   		
				if reply[tempPath]~=nil and reply[tempPath][1]~=nil then
				
					for j,w in pairs(reply[tempPath]) do
                    --add the checked numbers to uamap.
					local inCheckId = checkId..j
					local inCheckVPId = checkVPId..j
					local inPriorityId = priorityId..j		

						if numForInputExist~="nil" and numForInputExist~="-" then
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

							local reply1, error1 = mbus.modify(
								function()
									local reply4, error4 = mbus.addObjects{ path = VoiceportmapPath, param = { ToUA = fromUAPath, FromUA = fromVoicePortPath }, datamodel = "second" }                                    
									if error4~=nil or reply4[VoiceportmapPath][1]==nil then
										result=1                                
									end
								end, {datamodel="second"})   

                         end
						end
					end
				end
				end 
			end
        else
            local posDECTConfigPath = "Device.Services.VoiceService.1.PhyInterface.3" 
            local pstnInStatus, pstnOutStatus = "false", "false"
            if POST["pstnDECTInChk"]=="ON" then
                pstnInStatus = "true"
            end

            if POST["pstnDECTOutChk"]=="ON" then
                pstnOutStatus = "true"
            end
            modify = {}
            table.insert(modify, {path=posDECTConfigPath, param={X_TELECOMITALIA_IT_SwitchToPSTNIn=pstnInStatus, X_TELECOMITALIA_IT_SwitchToPSTNOut=pstnOutStatus}, datamodel="second"})
            setMBUS_IGD(modify)

            --deal with the situation of DECT All.
            DECTAllObj = isDECTAllObjExistInUAMap()
            if DECTAllObj=="true" then
                --add other 3 objs after delete DECTAll obj
                -- addOtherThreeUAMapObj(portTypeValue)
            end

            DECTAllObj = isDECTAllObjExistInVpMap()
            if DECTAllObj=="true" then
                --add other 3 objs after delete DECTAll obj
                -- addOtherThreeVpMapObj(portTypeValue)
            end

            --delete all the uamap.
			local portTypeValue = switchPath1 .. "." .. count .. ".Line.1"	
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
			local toVoicePortPath = portTypeValue
			local fromVoicePortPath = portTypeValue
	    
			local outRowNoPrty = {}
			local outRow = {}
			local outCount = 1
			local outCount1 = 1	
			--[[local UAmapPath = "Device.Services.VoiceService.2.X_TELECOMITALIA_IT_UAMapping"	    
			local VoiceportmapPath = "Device.Services.VoiceService.3.X_TELECOMITALIA_IT_UAMapping"
			local toVoicePortPath = "Device.Services.VoiceService.3.VoiceProfile.1.Line.1"
			local fromVoicePortPath = "Device.Services.VoiceService.3.VoiceProfile.1.Line.1"]]
	    
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
			local numForInputExist = tostring(POST["assoNum"])
	
            local reply, error = mbus.getParameters{ path = tempPath, param = "DirectoryNumber", filter="(== DirectoryNumber " .. numForInputExist .. ")", datamodel = "second" }
	   		
            if reply[tempPath]~=nil and reply[tempPath][1]~=nil then
				
                for j,w in pairs(reply[tempPath]) do
                --add the checked numbers to uamap.
				local inCheckId = checkId..j
				local inCheckVPId = checkVPId..j
				local inPriorityId = priorityId..j		
				    					
					if numForInputExist~="nil" and numForInputExist~="-" then
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
						local reply1, error1 = mbus.modify(
							function()
								local reply4, error4 = mbus.addObjects{ path = VoiceportmapPath, param = { ToUA = fromUAPath, FromUA = fromVoicePortPath }, datamodel = "second" }                                    
								if error4~=nil or reply4[VoiceportmapPath][1]==nil then
									result=1                                
								end
							end, {datamodel="second"}) 
                          end
                     end
					end
				end
			end
			end
			end
    saveall(0, 1)
    cgilua.redirect("save_alert.lp", { u="voipStato.lp" })
    return
    end
end

-- CPE
local PSTNNumber = getFXONum()
local enablePath = "Device.Services.VoiceService.1.PhyInterface.4"
local replyEnable, error = mbus.getParameters{ path = enablePath, param = "X_TELECOMITALIA_IT_Enable", datamodel = "second" }
local PSTNEnable = replyEnable[enablePath][1].param["X_TELECOMITALIA_IT_Enable"]

local wrongPriority = translate([==[Warning: there are one or more priority input incorrect. Use only the allowed indexes (1-8).]==])
local noPstn = translate([==[Attention! Error in the field "Associated with fixed line."]==]) .. " " .. "<br/>" .. translate([==[Check the page "Telephone Numbers" if the Fixed Line is active or uncheck the Fixed Line association in incoming and outgoing direction from this page.]==])
countOfLineObj()
%>
</head>
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
   setTimeout(function() { alert('Please Wait!'); }, 1);
   var totalIds = '<%=rowIds%>';
    var idArr = totalIds.split(",");
    for (i=0;i<=idArr.length-1;i++)
    {
	if (document.getElementById(idArr[i])!=null && document.getElementById(idArr[i]) != "undefined") {
        	var priorityStr = document.getElementById(idArr[i]).value;
        	if(priorityStr!="") {
            		if(!priorityExam(priorityStr)) {
                		showErrorMsg('<%=wrongPriority%>');
                		return false;
            		}
        	}
    	}
    }
	
    	  
    var tmpId = '<%=pathId%>';	
    var pathId = parseInt(tmpId)
    var pstnInChk,pstnOutChk	
    if(pathId < 3) {		 
    	pstnInChk = document.getElementById("pstnInChk").checked
    	pstnOutChk = document.getElementById("pstnOutChk").checked
    } else {
	pstnInChk = document.getElementById("pstnDECTInChk").checked
    	pstnOutChk = document.getElementById("pstnDECTOutChk").checked
    }

    /*
    var pstnIn = document.getElementById("pstnConfIn").value
    var pstnOut = document.getElementById("pstnConfOut").value
    if (pstnInChk || pstnOutChk) {
	if( pstnIn == "false" || pstnOut == "false") {
	      showErrorMsg('<%=noPstn%>');
              return false;	
	}
    }		
    */

    var PSTNEnable = <%=PSTNEnable%>
    if (pstnInChk || pstnOutChk) {					
    	if (!PSTNEnable) {		
		showErrorMsg('<%=noPstn%>');
        	return false;
	} else if (PSTNEnable) {
		<% if PSTNNumber == "" then %>				
		showErrorMsg('<%=noPstn%>');
        	return false;
		<% end %>
	}		
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
<body>


<div class="contentContainer">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="voipStato.lp"><%=translate([==[Telephony]==])%></a></li> 
			</ul>
		</div>


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
<tr>
    <td class="padLeft37 verticalAlign">
        <table cellspacing='0' cellpadding='0' width="100%">
            <tr><td>
            <br><!-- Begin of showing Telephone Service-->
            <table cellspacing='0' cellpadding='0' width='100%' class="fontSize">
			<tr>
			<td width='0' class="verticalAlign">
			</td>
			<td class="verticalAlign">
            <span class='midarea2_telmain tableTitle'><%=translate([==[Telephone service Configuration]==])%></span><br>
            <table width='100%' class='edittable valueSpace ' cellspacing='0' cellpadding='0' style="line-height:150%;width:770px;">
                <tr><td colspan='7'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><td align='left' class="width85 tableHeader"><div class="wordWrap width85"><%=translate([==[connection]==])%></div></td>
				<!--<th class='tableHd' align='left' width='5%'><%=translate([==[Identity SIP]==])%></th> -->
					<td align='left' class="width70 tableHeader"><div class="wordWrap width48"><%=translate([==[Extension ]==])%><br/><%=translate([==[Number]==])%></div></td>		      	
                    <td align='left' class="width110 tableHeader"><div class="wordWrap width60"><%=translate([==[Associated Number]==])%></div></td>
                <!--<td align='left' class="width110 tableHeader"><div class="wordWrap width60"><%=translate([==[Number of ]==])%><br/><%=translate([==[outgoing]==])%></div></td>
					<td align='left' class="tableHeader width65"><div class="wordWrap width65"><%=translate([==[Priority]==])%></div></td> 	-->
                    <td align='left' class="tableHeader width65"><div class="wordWrap width65">POS/FAX</div></td>                    
                    <td align='left' class="tableHeader wdth120px"><div class="wordWrap width130"><%=translate([==[Associated with fixed ]==])%><br/><%=translate([==[line]==])%></div></td>
                </tr>
                <tr><td colspan='7'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <%
		local linePath = "Device.Services.VoiceService.2.VoiceProfile"
		local dirNumPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                local rowStyle = "oddrow_firewall"
				--local count = 11
                local phoneType
		local pstnConfIn = false
		local pstnConfOut = false
		dirNumPath = dirNumPath .."." .. tostring(pathId)
		local replydir, error = mbus.getParameters{ path = dirNumPath, param = {"DirectoryNumber"}, datamodel = "second"}
		if replydir[dirNumPath]~=nil and replydir[dirNumPath][1]~=nil then
			dirNum = replydir[dirNumPath][1].param["DirectoryNumber"]
		end
                if tonumber(pathId)<3 then
					--[[if(tonumber(pathId) == 2) then
						count = count + 1
					else
						count = 1
					end]]
                    phoneType = "FXS" .. tostring(pathId)
					local switchPath = "Device.Services.VoiceService.1.PhyInterface."..tostring(pathId)
                    local replySwitch, error = mbus.getParameters{ path = switchPath, param = {"X_TELECOMITALIA_IT_POSConfig", "X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
                    if replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"]=="true" then
                        incomingCallNum = translate([==[Fixed Line]==])
                    end
                    if replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"]=="true" then
                        outgoingCallNum = translate([==[Fixed Line]==])
                    end
                    local posFAX = replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_POSConfig"]
                    local PSTNIn = replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"]
                    local PSTNOut = replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"]
                %>
                
                <tr><td class="<%=rowStyle%> fontSize width85"><div class="wordWrap"><%=phoneType%></div></td> 
				<!--<td class="<%=rowStyle%>" style="word-break:break-all;"><div style="width:70px;word-wrap: break-word;"><%=sipUri%></div></td> -->
					<td class="<%=rowStyle%> wordWrap width70"><div class="wordWrap"><%=dirNum%></div></td>
					<td class="<%=rowStyle%> width110"><div class="wordWrap">
					<select id="assoNum" name="assoNum" class="fontSize inputClass">
					<option value="<%=tostring(assoNum)%>"><%=tostring(assoNum)%></option>
                <%
		local reply1, error1 = mbus.getParameters{ path = linePath, datamodel = "second" }
		local result = {}
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
			  local switchPath2 = switchPath1 .. "." .. count .. ".Line.1"
			  local isNumExist = findUAMapNumExist1(switchPath2, v.path)
			   if isNumExist=="true" then
				numUsed = "true"
		       end
			   if enable == "Enabled" then
				enableFlag = "true"
			   end

			  local inCheckId = checkId..i
			   if (v.param["DirectoryNumber"]~="" and v.param["DirectoryNumber"]~=nil) then
			    pstnConfIn = true	
			    if result[i] == nil then
				 result[i] = {}		  		
			    end
				result[i].assoNum = tostring(v.param["DirectoryNumber"])
							if(result[i].assoNum ~= tostring(assoNum) and result[i].assoNum ~="nil" and v.path ~= "Device.Services.VoiceService.2.VoiceProfile.4.Line.1")then
							%>
							<option value="<%=result[i].assoNum%>"><%=result[i].assoNum%></option>
							<%
							end
               end 
              end
             end		
    		end
		end
					if(tostring(assoNum)~="-")then
                %>
						<option value="-">-</option>
				<%	end
				%>
				</select>
                </div></td>
               <!-- <td class="<%=rowStyle%> width110"><div class="wordWrap">
                <%
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
			if priority == nil then
				priority = ""
			end	

			local inCheckId = checkId..i
			local inPriorityId = priorityId..i

			if (v.param["DirectoryNumber"]~="" and v.param["DirectoryNumber"]~=nil) then
				pstnConfOut = true
                                cgilua.print("<div style='display:block';nowrap;>"..tostring(v.param["DirectoryNumber"]).."&nbsp;&nbsp;<input type='checkbox' "..isCheckedService(numUsed).." name='"..inCheckId.."' id='"..inCheckId.."' value='"..isCheckedService(numUsed).."' /></div>")
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
				<td class="<%=rowStyle%> width65" ><div class="wordWrap"><%cgilua.print(newPriority)%></div></td>-->
                <td class="<%=rowStyle%> wordWrap"><div class="wordWrap" style="width:70px;padding-left:20px">
                    <input type="checkbox" <%=isCheckedService(posFAX)%> name="posChk" size="8" value="ON" />
                    <input type="hidden" name="oldPosConfig" value="<%=posFAX%>" />
                </div></td>
                <td class="<%=rowStyle%> wordWrap"><div class="wordWrap">
                    <%=translate([==[in]==])%>&nbsp;<input type="checkbox" <%=isCheckedService(PSTNIn)%> id="pstnInChk"  name="pstnInChk" value="ON" class="alignMid" />
                    <%=translate([==[out]==])%>&nbsp;<input type="checkbox" <%=isCheckedService(PSTNOut)%> id="pstnOutChk"  name="pstnOutChk" value="ON" class="alignMid" />
                    <input type="hidden" name="oldPstnIn" value="<%=PSTNIn%>" />
                    <input type="hidden" name="oldPstnOut" value="<%=PSTNOut%>" />
                </div></td>
                </tr>
                <%
                else
                    phoneType = "DECT" .. tostring(tonumber(pathId)-2)
                    local DECTPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. tostring(tonumber(pathId)-2)
                %>
                <tr><td colspan='7'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><td class="<%=rowStyle%> fontSize width85"><div class="wordWrap"><%=phoneType%></div></td>
				<!--<td class="<%=rowStyle%>" style="word-break:break-all;"><div style="width:70px;word-wrap: break-word;"><%=sipUri%></div></td> -->
					<td class="<%=rowStyle%> wordWrap width70"><div class="wordWrap"><%=dirNum%></div></td>
					<td class="<%=rowStyle%> width110"><div class="wordWrap">
					<select id="assoNum" name="assoNum" class="fontSize inputClass">
					<option value="<%=tostring(assoNum)%>"><%=tostring(assoNum)%></option>
                <%
		local reply1, error1 = mbus.getParameters{ path = linePath, datamodel = "second" }
		local result = {}
		if reply1[linePath]~=nil and reply1[linePath][1]~=nil then
            for h,f in pairs(reply1[linePath]) do	
			local tempPath = f.path..".Line"
			local checkId = "numForUAMap"..h
		    local lanManagedNumber
			local replyLineNum, error = mbus.getParameters{ path = tempPath, param = {"DirectoryNumber", "X_TELECOMITALIA_IT_LANManaged","Enable"}, datamodel = "second" }
			if replyLineNum[tempPath]~=nil and replyLineNum[tempPath][1]~=nil then
			 for i,v in pairs(replyLineNum[tempPath]) do
			 totalRowcount = totalRowcount +1
			 lanManagedNumber = v.param["X_TELECOMITALIA_IT_LANManaged"]
			 local numUsed = "false"
			 local enableFlag = "false"                        
			 local enable = v.param["Enable"]      
			 local switchPath2 = switchPath1 .. "." .. count .. ".Line.1"
			 local isNumExist = findUAMapNumExist1(switchPath2, v.path)
			  if isNumExist=="true" then
				numUsed = "true"
			  end
			
			  if enable == "Enabled" then
				enableFlag = "true"
			  end
			
			 local inCheckId = checkId..i
			  if (v.param["DirectoryNumber"]~="" and v.param["DirectoryNumber"]~=nil) then
			   pstnConfIn = true
			   if result[i] == nil then
				 result[i] = {}		  		
			   end
			   result[i].assoNum = tostring(v.param["DirectoryNumber"])
					if(result[i].assoNum ~= tostring(assoNum) and result[i].assoNum ~="nil" and v.path ~= "Device.Services.VoiceService.2.VoiceProfile.4.Line.1")then
					%>
					<option value="<%=result[i].assoNum%>"><%=result[i].assoNum%></option>
					<%
					end                    
               end
              end
             end
			 end
		 end	
               if(tostring(assoNum)~="-")then
                %>
						<option value="-">-</option>
				<%	
					end
				%>
				</select>
                </div>
				</td>
                <!--<td class="<%=rowStyle%> width110"><div class="wordWrap">
                <%
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
			if priority == nil then
				priority = ""
			end
			
			local inCheckId = checkId..i
			local inPriorityId = priorityId..i
			if (v.param["DirectoryNumber"]~="" and v.param["DirectoryNumber"]~=nil) then
				pstnConfOut = true
                                cgilua.print("<div style='display:block'>"..tostring(v.param["DirectoryNumber"]).."&nbsp;&nbsp;<input type='checkbox' "..isCheckedService(numUsed).." name='"..inCheckId.."' id='"..inCheckId.."' value='"..isCheckedService(numUsed).."' /><br/></div>")
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
                </div></td>-->
				<%
                local DECTPSTNIn, DECTPSTNOut = getDECTPSTNInAndOut()
                %>
				<!--<td class="<%=rowStyle%> width65" ><div class="wordWrap"><%cgilua.print(newPriority)%></div></td>-->
                <td class="<%=rowStyle%> wordWrap txtAlignCenter"><div class="wordWrap" style="width:70px;padding-left:20px"></div></td>
                <td class="<%=rowStyle%> wordWrap"><div class="wordWrap">
                    <%=translate([==[in]==])%>&nbsp;<input type="checkbox" <%=isCheckedService(DECTPSTNIn)%>  id="pstnDECTInChk" name="pstnDECTInChk" value="ON" class="alignMid" />
                    <%=translate([==[out]==])%>&nbsp;<input type="checkbox" <%=isCheckedService(DECTPSTNOut)%> id="pstnDECTOutChk"  name="pstnDECTOutChk" value="ON" class="alignMid" />
                </div></td>
                </tr>
                <%end%>
				<tr><td colspan="7" class="padtop10">
                <table cellspacing='0' cellpadding='0' class="padtop10" width='100%'  style="text-align:center">
                <tr ><td style='padding-left:250px;'>
					<a style='color:black' onclick='javascript: submitSave();'><div class='midarea6-1 mainButton' name="thb10"><%=translate([==[Save]==])%></div></a></td>
					<td style='padding-right:250px;'>
					<a style='color:black' onclick='javascript:document.location.href="voipStato.lp";'><div class='midarea6-1 secondaryButton' name="thb7"><%=translate([==[Back]==])%></div></a></td>
                </tr>
				<input type="hidden" id="pstnConfIn" name="pstnConfIn" value="<%=pstnConfIn%>" />
                <input type="hidden" id="pstnConfOut" name="pstnConfIn" value="<%=pstnConfOut%>" />
                </table></td></tr>
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
