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

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/form.lp")%>
<% cgilua.lp.include("lp/voip.lp")%>
<%
local translate = translate
local POST=cgilua.POST
local tprint=require("tableprint")

local NumberPath = "Device.Services.VoiceService.2.VoiceProfile"
local VoiceServicePath = "Device.Services.VoiceService.1.VoiceProfile.1"

--Define the param of serviceDECTState is Actived or Inactived
function getDECTHandsetStato()
    local serviceDECTPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyDECT, error = mbus.getParameters{ path = serviceDECTPath, param = {"X_TELECOMITALIA_IT_Enable"}, datamodel = "second" }
    local serviceDECTState = replyDECT[serviceDECTPath][1].param["X_TELECOMITALIA_IT_Enable"]
    return serviceDECTState
end

--Get the DECTHandsetMaxNumberOfEntries
function getDECTHandsetMaxNumber()
    local DECTHandsetMaxNumberPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyMax, error = mbus.getParameters{ path = DECTHandsetMaxNumberPath, param = {"X_TELECOMITALIA_IT_DECTHandsetMaxNumberOfEntries"}, datamodel = "second" }
    local DECTHandsetMaxNumber = replyMax[DECTHandsetMaxNumberPath][1].param["X_TELECOMITALIA_IT_DECTHandsetMaxNumberOfEntries"]
    return DECTHandsetMaxNumber
end

-- Get the Active Dect Handset count
-- Added by Vignesh A J
function getActiveDECTHandsetCount()
    local activeDectCount = 0
    local dectHandsetPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset"
    local reply, error = mbus.getParameters{ path = dectHandsetPath, param = {"Active"}, datamodel = "second" }
    if reply[dectHandsetPath]~=nil then
        for j,k in pairs(reply[dectHandsetPath]) do
			local activeStatusVal = k.param["Active"]
			
            if activeStatusVal=="true" then
                activeDectCount = tonumber(activeDectCount) + 1
            end
        end
    end
    return activeDectCount
end

--Get the DECTHandsetNumberOfEntries
function getDECTHandsetNumber()
    local DECTActive
    local DECTNum = 0
    local DECTHandsetNumberPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset"
    local reply, error = mbus.getParameters{ path = DECTHandsetNumberPath, param = {"Active"}, datamodel = "second" }
    if reply[DECTHandsetNumberPath]~=nil then
        for j,k in pairs(reply[DECTHandsetNumberPath]) do
            DECTActive = k.param["Active"]
            if DECTActive=="true" then
                DECTNum = tonumber(DECTNum) + 1
            end
        end
    end
    return DECTNum
end

--Get the active value which is true
function getDECTHandsetActive()
    local DECTHandsetActivePath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset"
    local replyActive, error = mbus.getParameters{ path = DECTHandsetActivePath, param = "Active", datamodel = "second" }
    local DECTHandsetActive = replyActive[DECTHandsetActivePath][1].param["Active"]
    return DECTHandsetActive
end

--Get the DECT PIN code
function getPINCode()
    local PINCodePath = "Voice.DECT.Base"
    local replyPIN, error = mbus.getParameters{ path = PINCodePath, param = "Pin" }
    local PINCode = replyPIN[PINCodePath][1].param["Pin"]
    return PINCode
end

--Change the value of FaxT38 checkbox
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local modify = {}
    if POST["FaxT38Flag"] == "1" then
        local FaxTPath = "Device.Services.VoiceService.1.VoiceProfile.1.FaxT38"
        local replyFax, error = mbus.getParameters{ path = FaxTPath, param = {"Enable"}, datamodel = "second" }
        local FaxTActive = replyFax[FaxTPath][1].param["Enable"]
        if (POST["FaxTChk"]=="ON" and FaxTActive=="false") or (POST["FaxTChk"]==nil and FaxTActive=="true") then
            local status = "false"
            if POST["FaxTChk"]=="ON" and FaxTActive=="false" then
                status = "true"
            end
            modify = {}
            table.insert(modify, {path=FaxTPath, param= {Enable=status}, datamodel = "second"})
            local result = setMBUS_IGD(modify)
            if result==1 then
                cgilua.redirect("resultKO.lp")
                return
            end
        end
    end
    if POST["DECTInfoFlag"] == "1" then
        local DECTActive = getDECTHandsetStato()
        local enableDECTPath  = "Device.Services.VoiceService.1.PhyInterface.3"
        if (POST["EnableDECTChk"]=="ON" and DECTActive=="false") or (POST["EnableDECTChk"]==nil and DECTActive=="true") then
            local DECTstatus = "false"
            if POST["EnableDECTChk"]=="ON" and DECTActive=="false" then
                DECTstatus = "true"
            end
            modify = {}
            table.insert(modify, {path=enableDECTPath, param= {X_TELECOMITALIA_IT_Enable=DECTstatus}, datamodel = "second"})
            local result = setMBUS_IGD(modify)
            if result==1 then
                cgilua.redirect("resultKO.lp")
                return
            end
        end
    end

    if POST["DECTAttachFlag"] == "1" then
        local attachTerPath = "Voice.DECT.Base"
        modify = {}
        table.insert(modify, {path=attachTerPath, param={StartSubs="true"}})
        local result = setMBUS(modify)
        if result==1 then
            cgilua.redirect("resultKO.lp")
            return
        end
    end

    if POST["FXOInfoFlag"] == "1" then
        local enableFXOPath = "Device.Services.VoiceService.1.PhyInterface.4"
        local replyFXOEnable, error = mbus.getParameters{ path = enableFXOPath, param = {"X_TELECOMITALIA_IT_Enable"}, datamodel = "second" }
        local FXOActive = replyFXOEnable[enableFXOPath][1].param["X_TELECOMITALIA_IT_Enable"]
        if (POST["EnableFXOChk"]=="ON" and FXOActive=="false") or (POST["EnableFXOChk"]==nil and FXOActive=="true") then
            local FXOstatus = "false"
            if POST["EnableFXOChk"]=="ON" and FXOActive=="false" then
                FXOstatus = "true"
            end
            modify = {}
            table.insert(modify, {path=enableFXOPath, param= {X_TELECOMITALIA_IT_Enable=FXOstatus}, datamodel = "second"})
            local result = setMBUS_IGD(modify)
            if result==1 then
                cgilua.redirect("resultKO.lp")
                return
            end
        end
        local PSTNPath = "Device.Services.VoiceService.1.VoiceProfile.1"
        local replyPSTN, error = mbus.getParameters{ path = PSTNPath, param = {"PSTNFailOver"}, datamodel = "second" }
        local PSTNFailOver = replyPSTN[PSTNPath][1].param["PSTNFailOver"]
        if (POST["PSTNState"] == "0" and PSTNFailOver=="true") or (POST["PSTNState"] == "1" and PSTNFailOver=="false") then
            local PSTNFailOverState = "false"
            if (POST["PSTNState"] == "0" and PSTNFailOver=="true") then
                PSTNFailOverState = "false"
            end
            if (POST["PSTNState"] == "1" and PSTNFailOver=="false") then
                PSTNFailOverState = "true"
            end
            modify = {}
            table.insert(modify, {path=PSTNPath, param= {PSTNFailOver=PSTNFailOverState}, datamodel = "second"})
            local result = setMBUS_IGD(modify)
            if result==1 then
                cgilua.redirect("resultKO.lp")
                return
            end
        end
    end

    if POST["FXONumFlag"] == "1" then
        local modify = {}
        local fixedFXONum = POST["fixedLineNum"]
		if fixedFXONum~="" then
			local IsFXONumExist = getFXONum()
			if IsFXONumExist=="" then
				local reply, error = mbus.modify(
				function()
					local reply, error = mbus.addObjects{path = "ENV", param = {Value = fixedFXONum, Name = "IsFXONum"}}
				end)
			else
				local replyFXOPath, errorFXOPath = mbus.getParameters{ path = "ENV", param = { "Name", "Value" }, filter = "(== Name ".. "IsFXONum" ..")" }
				local FXOPath = replyFXOPath["ENV"][1].path
				table.insert(modify, {path = FXOPath, param = {Value = fixedFXONum}})
				setMBUS(modify)
			end
		end
    end

    if POST["DECTTerminalsFlag"] == "1" then
        local rowIndex = POST["rowIndex"]
        local terminalsPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. tostring(rowIndex)
        modify = {}
        table.insert(modify, {path=terminalsPath, param= {Active="false"}, datamodel = "second"})
        local result = setMBUS_IGD(modify)
        if result==1 then
            cgilua.redirect("resultKO.lp")
            return
        end
    end
saveall(0,1)
cgilua.redirect("telephonyNumber.lp")
end

local DECTMaxNum = getDECTHandsetMaxNumber()
local DECTNum = getDECTHandsetNumber()
local MaxDECTNumber = translate([==[Reached the maximum number of active DECT terminals. For others it is encouraged to combine necessary to delete any of the items]==])
local NoPSTNNumber = translate([==[Before pairing, it is necessary have an active phone service.]==])
%>
<script language="javascript" type="text/javascript">

function showErrorMsg(errorMsgStr)
{
    document.getElementById("set_telephony_number").style.display="none";
    document.getElementById("resultDECTKO").style.display="block";
    document.getElementById("errorMsg").innerHTML=errorMsgStr;
}

function changeTeleEnable()
{
    setTimeout(function() { alert('Please Wait!'); }, 1);
    document.getElementById("FXOInfoFlag").value="1";
    document.modify_voice_server_number.submit();
}

function submitNumToENV()
{
    document.getElementById("configFixedLine").style.display = "none";
    document.getElementById("confirm").style.display = "block";
}

function attachTerminal()
{
    setTimeout(function() { alert('Please Wait!'); }, 1);
    <% if tonumber(DECTNum)==tonumber(DECTMaxNum) then %>
        showErrorMsg('<%=MaxDECTNumber%>');
        return false;
    <% else %>
        document.getElementById("DECTAttachFlag").value="1";
        document.modify_voice_server_number.submit();
    <% end %>
}

function confNumToPSTN()
{
    setTimeout(function() { alert('Please Wait!'); }, 1);
    document.getElementById("FXONumFlag").value="1";
    document.modify_voice_server_number.submit();
}

function enableDect()
{
    setTimeout(function() { alert('Please Wait!'); }, 1);
    document.getElementById("DECTInfoFlag").value="1";
    document.modify_voice_server_number.submit();
}

function disTerminal(rowIndex)//disassociatesNumber:line number
{
    document.getElementById("rowIndex").value=rowIndex;
    document.getElementById("DECTTerminalsFlag").value = "1";
    document.modify_voice_server_number.submit();
}

function changeFaxT38()
{
    setTimeout(function() { alert('Please Wait!'); }, 1);
    document.getElementById("FaxT38Flag").value="1";
    document.modify_voice_server_number.submit();
}

function enableSubmit(PSTNState)
{
    setTimeout(function() { alert('Please Wait!'); }, 1);
    document.getElementById("FXOInfoFlag").value="1";
    document.getElementById("PSTNState").value=PSTNState;
    document.modify_voice_server_number.submit();
}

function submitConfirm()
{
    document.getElementById("modify_voice_server_number").submit();
}

function cancelConfirm()
{
    document.getElementById("set_telephony_number").style.display = "";
    document.getElementById("resultDECTKO").style.display="none";
    document.getElementById("confirm").style.display = "none";
}

</script>

</head>
<body>

<div class="contentContainer">
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="telephonyNumber.lp"><%=translate([==[Telephone numbers]==])%></a></li> 
			</ul>
		</div>

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephonyNumber.lp">Numeri telefonici</a></td><td align="right"><a href="voipStato.lp">Stato</a></td></tr>
</table> -->

<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="voipStato.lp">
		<div class="tab">
			<span class="tabIcon_sttel"></span>  
			<span class="contTabTxt transform"><%=translate([==[Telephony services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
		
			<li><a href="telephonyNumber.lp"  class="current margin15">
		
		<div class="tab">
			<span class="contTabTxt transform"><%=translate([==[Telephone numbers]==])%></span></div></a></li>
		
			</ol>
	</div>


<div class='contentcontainer' id="set_telephony_number">
<hr>
<form method="POST" name="modify_voice_server_number" id="modify_voice_server_number" action="">
<input type="hidden" id="PSTNState" name="PSTNState" value=""/>
<div class='contentitem'>

<table border="0" width="100%">
<tr>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr><td>
            <br> <!-- Begin of showing telephony numbers-->
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'></td><td style='vertical-align:top'>             
            <span class='midarea2_telmain tableTitle'><%=translate([==[Telephone numbers]==])%></span><br>
                <table class='edittable valueSpace' width='100%' cellspacing='0' cellpadding='0' border='0'>
                <!-- <tr><td colspan='3' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <tr><td colspan='3'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> -->
                <tr><th width='20%' class="tableHd"><%=translate([==[phone Number]==])%></th><th width='35%' class="tableHd"><%=translate([==[Associated terminals for incoming calls]==])%></th><th width='35%' class="tableHd"><%=translate([==[Associated Terminals for outgoing calls]==])%></th></tr>
                <!-- <tr><td colspan='3'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> -->
                <tr><td colspan='3' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <%
                local rowStyle = "oddrow"
                local rowNum = 0
                local phoneNumber, terminalPhoneNumber, lanManagedVal, UAMap, VoicePortMap = "-", "false", "-", "-"
				local reply, error, FromUA, ToUA
				for i=1, 3 do
					local allincomteminal = ""
					local alloutgoteminal = ""
					local extuacount = 0
					NumberPath = "Device.Services.VoiceService.2.VoiceProfile."..i..".Line.1"
					reply, error = mbus.getParameters{ path = NumberPath, param = {"DirectoryNumber", "X_TELECOMITALIA_IT_LANManaged"}, datamodel = "second" }

					if reply[NumberPath][1] ~= nil then
					
                        phoneNumber = reply[NumberPath][1].param["DirectoryNumber"]
						if phoneNumber ~= nil and phoneNumber ~= "" then
						
							terminal_path = "Device.Services.VoiceService.2.X_TELECOMITALIA_IT_UAMapping"
							replyterminal_path, error = mbus.getParameters{ path = terminal_path, param = {"FromUA", "ToUA"}, datamodel = "second" }
							if replyterminal_path[terminal_path] ~= nil and replyterminal_path[terminal_path][1] ~= nil then
								for j,v in pairs(replyterminal_path[terminal_path]) do
									FromUA = v.param["FromUA"]
									ToUA = v.param["ToUA"]
						
									if FromUA == NumberPath then
										replyTopath, error = mbus.getParameters{ path = ToUA, param = {"DirectoryNumber"}, datamodel = "second" }
										terminalPhoneNumber = replyTopath[ToUA][1].param["DirectoryNumber"]

										local UAMapAll, VoicePortMapAll
										local phoneTypePath
										local replydirNumberpath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
										local replydirNumber, error = mbus.getParameters{ path = replydirNumberpath, param = {"DirectoryNumber"}, datamodel = "second" }
										if replydirNumber[replydirNumberpath] ~= nil then
											for l,m in pairs(replydirNumber[replydirNumberpath]) do
												local mapdirNumber = m.param["DirectoryNumber"]
												if mapdirNumber == terminalPhoneNumber then
													phoneTypePath = m.path
												end
											end
										end						
						
										local incomingPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
										local outgoingPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
										local replyIncoming, error = mbus.getParameters{ path = incomingPath, param = {"FromUA", "ToVoicePort"}, filter = "(== FromUA "..tostring(phoneTypePath)..")", datamodel = "second" }
										local replyOutgoing, error = mbus.getParameters{ path = outgoingPath, param = {"ToUA", "FromVoicePort"}, filter = "(== ToUA "..tostring(phoneTypePath)..")", datamodel = "second" }
										for j,k in pairs(replyIncoming[incomingPath]) do
											if (k.param["ToVoicePort"]) ~= nil then
												UAMap = k.param["ToVoicePort"]
												
												if UAMap~=nil then
													local UAMapId = string.sub(UAMap, -1)
													if UAMap=="Device.Services.VoiceService.1.PhyInterface.3" then
														UAMap = "DECT1"..",".."DECT2"..",".."DECT3"..",".."DECT4"..",".."DECT5"
													else
														if string.match(tostring(UAMap), "DECTHandset")~=nil then
															UAMap = "DECT" .. tostring(UAMapId)
														else
															UAMap = "FXS" .. tostring(UAMapId)
														end
													end
													if UAMapAll==nil then
														UAMapAll = UAMap
													else
														UAMapAll = UAMapAll .. "," .. UAMap
													end
												end
											end											
										end
										if UAMapAll==nil then											
											UAMapAll = "-"
										end

										for t,l in pairs(replyOutgoing[outgoingPath]) do
											if (l.param["FromVoicePort"]) ~= nil then
												VoicePortMap = l.param["FromVoicePort"]
												if VoicePortMap~=nil then
													local VoicePortMapId = string.sub(VoicePortMap, -1)
													if VoicePortMap=="Device.Services.VoiceService.1.PhyInterface.3" then
														VoicePortMap = "DECT1"..",".."DECT2"..",".."DECT3"..",".."DECT4"..",".."DECT5"
													else
														if string.match(tostring(VoicePortMap), "DECTHandset")~=nil then
															VoicePortMap = "DECT" .. tostring(VoicePortMapId)
														else
															VoicePortMap = "FXS" .. tostring(VoicePortMapId)
														end
													end
													if VoicePortMapAll ==nil then
														VoicePortMapAll = VoicePortMap 
													else
														VoicePortMapAll = VoicePortMapAll .. "," .. VoicePortMap 
													end
												end
											end
										end
										if VoicePortMapAll==nil then
											VoicePortMapAll = "-"
										end
										if VoicePortMapAll ~= "-" or UAMapAll ~= "-" then
											extuacount = extuacount + 1
											if allincomteminal == "" then
												allincomteminal = UAMapAll
											else
												if extuacount%4 == 0 then
													allincomteminal = tostring(allincomteminal)..", "..tostring(UAMapAll)
												else
													allincomteminal = tostring(allincomteminal)..", "..tostring(UAMapAll)
												end
												if extuacount%3 == 0 then
													allincomteminal = tostring(allincomteminal).." <br/> "
												end
											end
											
											
											if alloutgoteminal == "" then
												alloutgoteminal = VoicePortMapAll
											else
												if extuacount%4 == 0 then
													alloutgoteminal = tostring(alloutgoteminal)..", "..tostring(VoicePortMapAll)
												else
													alloutgoteminal = tostring(alloutgoteminal)..", "..tostring(VoicePortMapAll)
												end
												if extuacount%3 == 0 then
													alloutgoteminal = tostring(alloutgoteminal).." <br/> "
												end
											end
										end
									end
								end
							end
							
							local phyIntf_IP = getIPConnectionInfo()
							local phoneIPType
							if #phyIntf_IP > 0 then
								for i=1, #phyIntf_IP do
									local v = phyIntf_IP[i]
									phoneIPType = v.name
									local inOutCall = v.AllInOutCallNum1
									if inOutCall ~= nil and inOutCall ~= "" then
										local inOutCallArray = split(inOutCall,"##")
										local incomingCallNum, outgoingCallNum = "-", "-"
										incomingCallNum = inOutCallArray[1]
										outgoingCallNum = inOutCallArray[2]
										local strfind = string.find
										local temp, j = 0
										temp = strfind(incomingCallNum, "/>", j)
										if temp ~= nil then
											local incomingCallNumber = split(incomingCallNum,"/>")
											incomingCallNum = incomingCallNumber[2]
										end
										if incomingCallNum == phoneNumber then
											extuacount = extuacount + 1
											if allincomteminal == "" then
												allincomteminal = v.name
											else
												if extuacount%4 == 0 then
													allincomteminal = tostring(allincomteminal)..", "..tostring(v.name)
												else
													allincomteminal = tostring(allincomteminal)..", "..tostring(v.name)
												end
												if extuacount%3 == 0 then
													allincomteminal = tostring(allincomteminal).." <br/> "
												end
											end
											if alloutgoteminal == "" then
												alloutgoteminal = v.name
											else
												if extuacount%4 == 0 then
													alloutgoteminal = tostring(alloutgoteminal)..", "..tostring(v.name)
												else
													alloutgoteminal = tostring(alloutgoteminal)..", "..tostring(v.name)
												end
												if extuacount%3 == 0 then
													alloutgoteminal = tostring(alloutgoteminal).." <br/> "
												end
											end
										end
									end	
								end
							end	
							
							if extuacount ~= 0 then
								rowNum = rowNum + 1
								if rowNum%2==1 then
									rowStyle = "oddrow"
								else
									rowStyle = "evenrow"
								end%>
								
								<tr><td class="<%=rowStyle%>" colspan='3'></td></tr>
								<tr class="<%=rowStyle%>">
								<td class="<%=rowStyle%>" style="word-break:break-all;width:300px;"><%=phoneNumber%></td>
								<td class="<%=rowStyle%>"><%=tostring(allincomteminal)%></td>
								<td class="<%=rowStyle%>"><%=tostring(alloutgoteminal)%></td>
								</tr>
								<tr><td class="<%=rowStyle%>" colspan='3'></td></tr>
							<%end
						end
					end
				end%>
                </table>
            </td></tr></table> <!-- End of showing telephony numbers-->
        </td></tr>
        <tr><td>
  <!-- Begin of Configuring the fixed line -->
            <table cellspacing='0' cellpadding='0' width='100%' id='configFixedLine' class="width770 marleft40" style="clear:both;"><tr><td style='vertical-align:top'>
            <input type="hidden" id="FXOInfoFlag" name="FXOInfoFlag" value="0"/>
            <input type="hidden" id="FXONumFlag" name="FXONumFlag" value="0"/>
            <span class='midarea2_telmain tableTitle martop15 fbold'><%=translate([==[Configuring the fixed line]==])%></span>
            <span class='midarea4_telmain1 tableTitle fbold'><%=translate([==[FXO port]==])%></span>
                <table  cellspacing='0' cellpadding='0' border='0' class="width750">
                <%
                local enablePath = "Device.Services.VoiceService.1.PhyInterface.4"
                local replyEnable, error = mbus.getParameters{ path = enablePath, param = "X_TELECOMITALIA_IT_Enable", datamodel = "second" }
                local Enable = replyEnable[enablePath][1].param["X_TELECOMITALIA_IT_Enable"]
                local FXOEnable = translate([==[Disable]==])
                if Enable=="true" then
                    FXOEnable = translate([==[Active]==])
                end
                --Enable : “Attiva”/”Disattiva”
                %>

                <tr>
					<td class="fleft width200"><%=translate([==[state]==])%>:</td>
					<td class="fleft" colspan="2"><div><%=FXOEnable%></div></td>
				</tr>
                <%
                local isChecked = 'checked="checked"'
                if getFXOVoiceServiceEnable()=="false" then
                    isChecked = ""
                end
                %>
                <tr>
					<td class="fleft width200 paddtop10" ><%=translate([==[Fixed network active]==])%>:</td>
					<td class="fleft paddtop10 width20" >
					<input type="checkbox" <%=isChecked%> name="EnableFXOChk" value="ON" /></td>
					 <td class="fleft verticalAlign padtop5 padleft108">
					 <a onclick='changeTeleEnable()' href="#"><div class='midarea6-1 mainButton'><%=translate([==[Apply]==])%></div></a>
					</td>
					</tr>	
					                <%
                local PSTNNum = getFXONum()
                if Enable=="true" then
                %>
                   <tr>
                    <td class="fleft width200 paddtop10"><%=translate([==[Number of fixed line]==])%>:
                    <input type="text" id="fixedLineNum" name="fixedLineNum" size="12" value="<%=PSTNNum%>" class="inputClass"/></td>
                    <td class="fleft  buttonTop padleft128" colspan="2">
					<a onclick='confNumToPSTN()' href="#"><div class='midarea6-1 mainButton' name="thb9"><%=translate([==[Configure]==])%></div></a>					</td></tr>
                <%
                else
                %>
                   <tr>
                    <td class="fleft width200 paddtop10"><%=translate([==[Number of fixed line]==])%>:</td>
					<td class="fleft paddtop10" colspan="2"><%=PSTNNum%></td></tr>
                <%end%>
				 </table>
				 <table width='100%' cellspacing='0' cellpadding='0' border='0'>
                              <tr><td colspan='2' class='black'>&nbsp;</td></tr>
                <tr><td colspan='2' ><p><%=translate([==[The user must have an active network of telephone numbering PSTN. The fixed line can be switched off when the router is connected only via the internet and not with landline. In this case all calls take place over the Internet]==])%>.</p></td></tr>
                <tr><td colspan='2'>&nbsp;</td></tr>
                <tr><td  class="fleft alignMid padtop5 fallback"><%=translate([==[Enables the functionality of wireline Fall Back]==])%>:</td>
                <td class="fleft" style="width:300px;" >
                <%
                if Enable=="true" then
                    local PSTNPath = "Device.Services.VoiceService.1.VoiceProfile.1"
                    local replyPSTN, error = mbus.getParameters{ path = PSTNPath, param = {"PSTNFailOver"}, datamodel = "second" }
                    local PSTNFailOver = replyPSTN[PSTNPath][1].param["PSTNFailOver"]
                    if PSTNFailOver == "true" then
                %>
					<a onclick="enableSubmit('0')" href="#"><div class='midarea6-1 mainButton'><%=translate([==[Disable]==])%></div></a><br>
                    <!-- <input type="button" value="<%=translate([==[Disable]==])%>" onclick="enableSubmit('0')" /> -->
                    <%else%>
					<a onclick="enableSubmit('1')" href="#"><div class='midarea6-1 mainButton'><%=translate([==[Active]==])%></div></a><br>
                    <!-- <input type="button" value="<%=translate([==[Active]==])%>" onclick="enableSubmit('1')" /> -->
                    <%end%>
                <%end%>
                </td></tr>
                <tr><td colspan='2'>&nbsp;</td></tr>
                <tr style="height:55px"><td colspan='2' ><p ><%=translate([==[The functionality of Fall Back on fixed-line allows you to use DECT and analog telephones connected to the router via the PSTN in the event of a fall Internet connection (either analog telephones, DECT) or interruption to a router (only analog phones). The user must have an active phone numbers on the PSTN]==])%>.</p></td></tr>
                </table></td></tr> </table>
            <!-- End of Configuring the fixed line-->
        </td></tr>
        <tr><td>
            <!-- Begin of DECT information-->
            <table cellspacing='0' cellpadding='0' width='100%' class="width770"><tr><td width='40' style='vertical-align:top'><!-- <img src='#' alt=''> --></td><td style='vertical-align:top'>
            <input type="hidden" id="DECTInfoFlag" name="DECTInfoFlag" value="0"/>
            <input type="hidden" id="DECTAttachFlag" name="DECTAttachFlag" value="0"/>
            <span class='midarea4_telmain1 tableTitle fbold'><%=translate([==[DECT]==])%></span><br>
            <span class='midarea4_telmain1 tableTitle fbold'><%=translate([==[DECT service]==])%></span>
                <table width='100%' cellspacing='0' cellpadding='0' border='0'>
				
                    <% 
                    local DECTState = getDECTHandsetStato()
                    local serviceDECTState = translate([==[Disable]==])
                    if DECTState=="true" then
                        serviceDECTState = translate([==[Active]==])
                    end
                    %>
                    <tr>
					<td class="fleft width200"><%=translate([==[Status]==])%>:</td>
					<td class="fleft" colspan="2" ><%=serviceDECTState%></td></tr>
                    <%
                    local isChecked = 'checked="checked"'
                    if getServiceDECTEnable()=="false" then
                        isChecked = ""
                    end
                    local PINCode = getPINCode()
                    %>
				<tr>
	             <td class="fleft paddtop10 alignMid width200" ><%=translate([==[Enables DECT]==])%>: </td>
				 <td class="fleft paddtop10 alignMid width20">
				 <input type="checkbox" <%=isChecked%> name="EnableDECTChk" value="ON" /></td>
				 <td class="verticalAlign padtop5  fleft enableDECT">
						<a id="enableDECT" name="enableDECT" onclick='enableDect()' href="#">
						<div class='midarea6-1 mainButton'><%=translate([==[Apply]==])%></div>
						</a>
						</td>
				</tr>

				<tr>
					<td colspan='3' ><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br>
					</td>
				</tr>

                    <tr>
					<td class="alignMid fleft width200 paddtop10"><%=translate([==[PIN terminals Association]==])%>:</td>
					<td class="alignMid fleft width50 paddtop10"><div><%=PINCode%></div></td>
					<td class=" fleft padtop5 padleft78">
					<a onclick='attachTerminal()' href="#">
					<div class='midarea7-1 mainButton'><%=translate([==[Attach the terminal]==])%></div></a>
					</td>
					</tr>
                    <tr><td colspan='3' class="padtop5">
					<p><%=translate([==[The PIN you must enter on the register]==])%>.</p>
					</td></tr>
                </table>
            <span class='midarea2_telmain tableTitle padtop10 fbold'>
				<%=translate([==[DECT terminals]==])%></span><!-- <br> -->
                <table class='edittable valueSpace' width='100%' cellspacing='0' cellpadding='0' border='0' id='terminalsDECT'>
                <input type="hidden" id="DECTTerminalsFlag" name="DECTTerminalsFlag" value="0"/>
                <input type="hidden" id="rowIndex" name="rowIndex" value=""/>
                    <%
                    local associatedTerminalsPath = "Device.Services.VoiceService.1.PhyInterface.3"
                    local replyTerminals, error = mbus.getParameters{ path = associatedTerminalsPath, param = {"X_TELECOMITALIA_IT_DECTHandsetMaxNumberOfEntries"}, datamodel = "second" }
                    local associatedTerminals = replyTerminals[associatedTerminalsPath][1].param["X_TELECOMITALIA_IT_DECTHandsetMaxNumberOfEntries"]
                    %>
                    <!-- <tr class='midarea4_newtelmain2'> -->
					<tr><td class=" paddtop10 alignMid"><%=translate([==[Number of terminals associated]==])%>:</td>
					<td  colspan="2"><%=associatedTerminals%></td>
					</tr>
					
					<!-- Fix for CPE_P00104548 -->
				
					<tr><td class=" paddtop10 alignMid"><%=translate([==[Number of terminals associating]==])%>:</td>
					<td colspan="2"><%=getActiveDECTHandsetCount()%></td>
					</tr>
							<tr><td colspan='3'>&nbsp;</td></tr>
					
                    <tr><td  class="tableHd " style="width:200px;"><%=translate([==[terminal Name]==])%></td><td  class="tableHd "><%=translate([==[Status]==])%></td><td class="tableHd" ><%=translate([==[Disassociates terminal]==])%></td></tr>
					<!-- <tr><td colspan='3'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> -->
					<tr><td colspan='3' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                    <%
                    local rowStyle = "oddrow"
                    local rowNum = 0
                    local handsetDECTActive
                    local handsetPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset"
                    local replyHandset, error = mbus.getParameters{ path = handsetPath, param = {"Active", "TerminalName"}, datamodel = "second" }
                    for i,v in pairs(replyHandset[handsetPath]) do
                        handsetDECTActive = "Non associato"
                        local handsetActive = v.param["Active"]
                        local terminalName = v.param["TerminalName"]
                        if handsetActive == "true" then
                            handsetDECTActive = "Associato"
                        end
                        rowNum = rowNum + 1
                        if rowNum%2==1 then
                            rowStyle = "oddrow"
                        else
                            rowStyle = "evenrow"
                        end
                    %>
                    <tr>
                    <td  class="<%=rowStyle%>"><%=terminalName%><input type="hidden" id="terminalName<%=rowNum%>" name="terminalName<%=rowNum%>" value="<%=terminalName%>" /></td>
                    <td  class="<%=rowStyle%>"><%=handsetDECTActive%></td>
                    <%
                        if handsetActive == "true" then
                    %>
                    <td class="<%=rowStyle%> buttonTop">
					<a onclick='javascript: disTerminal("<%=i%>");' href="#"><div class='midarea7-1 mainButton'><%=translate([==[Disassociates terminal]==])%></div></a>
					<!-- <input type="button" class="button" onclick='javascript: disTerminal("<%=i%>");' value="<%=translate([==[Disassociates terminal]==])%>"  /> -->
					</td>
                    <%
                        else
                    %>
                    <td class="<%=rowStyle%>" style="width:170px">Non associato</td>
                        <%end%>
                    <%end%>
                    </tr>
                </table>
            </td><!-- </tr> --></table><!-- End of DECT information-->
        </td></tr>
        <tr><td>
            <br><!-- Begin of Other Options-->
            <table cellspacing='0' cellpadding='0' width='100%' class="width770">
				<tr>
					<td width='40' style='vertical-align:top'><!-- <img src='images/bull__md.gif' alt=''> --></td>
					<td style='vertical-align:top'>
            <input type="hidden" id="FaxT38Flag" name="FaxT38Flag" value="0"/>
            <span class='midarea2_telmain tableTitle fbold'>Fax T.38</span>
                <table class='' width='100%' cellspacing='0' cellpadding='0' border='0'>
                    <%
                    local isChecked = 'checked="checked"'
                    if getFaxTEnable()=="false" then
                        isChecked = ""
                    end
                    local FaxT = getFaxTEnable()
                    local FaxTStato = translate([==[off]==])
                    if FaxT=="true" then
                        FaxTStato = translate([==[on]==])
                    end
                    %>
                    <tr>
						<td class="fleft width200"><%=translate([==[Status]==])%>:</td>
						<td class="fleft " colspan="2"><%=FaxTStato%></td>
					</tr>
                    <tr>
						<td class="fleft width200 paddtop10"><%=translate([==[Configure]==])%>: </td>
						<td class="fleft paddtop10 width20" ><input type="checkbox" <%=isChecked%> name="FaxTChk" value="ON"  class=" alignMid"/>
						</td>
						                    <td class="verticalAlign buttonTop fleft padleft108">
						<a onclick='javascript: changeFaxT38();' href="#"><div class='midarea6-1 mainButton'><%=translate([==[Apply]==])%></div></a>
						</td></tr>
					<tr>
					<td class="fleft width200 paddtop10">&nbsp;</td>

					</tr>
					
                </table>
            </td></tr></table><!-- End of Other Options-->
        </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</form>
</div>

<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<div id="resultDECTKO" style="display:none">
<%cgilua.lp.include("webparts/resultKO_VoIP.lp")%>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>
