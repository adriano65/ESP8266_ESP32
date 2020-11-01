<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/style.css" type="text/css"/>
<link rel="stylesheet" href="css/menu.css" type="text/css" />
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
local QUERY = cgilua.QUERY
local POST=cgilua.POST

local isRemote = isRemoteAccess()

--check the checkbox is checked or not
function isCheckedService(flag)
    local isChecked = 'checked="checked"'
    if flag~="true" then
        isChecked = ""
    end    
    return isChecked
end

--get port type from UAMap or VoicePortMap
function getPortType(pathStr)
    local reply, error = mbus.getParameters{ path = pathStr, param = "Description", datamodel = "second" }
    return reply[pathStr][1].param["Description"]
end

--check is there any line obj.
function isCheckLineExist()
    local numInfoPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
    local replyInfo, error = mbus.getParameters{ path = numInfoPath, param = "DirectoryNumber", datamodel = "second" }
    if replyInfo[numInfoPath][1]~=nil then
        return true
    end
    return false 
end

if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local modify = {}
    if POST["saveFlag"] == "1" then
        for i=1,2 do
            local posConfigPath = "Device.Services.VoiceService.1.PhyInterface." .. tostring(i)
            local status, pstnInStatus, pstnOutStatus = "false", "false", "false"
            if POST["posChk"..i]=="ON" then
                status = "true"
            end
            if POST["pstnInChk"..i]=="ON" then
                pstnInStatus = "true"
            end

            if POST["pstnOutChk"..i]=="ON" then
                pstnOutStatus = "true"
            end
            modify = {}
            table.insert(modify, {path=posConfigPath, param={X_TELECOMITALIA_IT_POSConfig=status, X_TELECOMITALIA_IT_SwitchToPSTNIn=pstnInStatus, X_TELECOMITALIA_IT_SwitchToPSTNOut=pstnOutStatus}, datamodel="second"})
            setMBUS_IGD(modify)
        end
    saveall(0, 1)
    cgilua.redirect("save_alert.lp", { u="telephonyStato.lp" })
    return
    end

    if POST["configInFlag"] == "1" then
        --delete the old telenumber
        local rowIndex = POST["rowIndex"]
        local portTypeValue, DECTAllObj
        if tonumber(rowIndex)<3 then
            portTypeValue = "Device.Services.VoiceService.1.PhyInterface." .. tostring(POST["pathId"])
        else
            portTypeValue = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. tostring(POST["pathId"])
            DECTAllObj = isDECTAllObjExistInUAMap()
            if DECTAllObj=="true" then
                --add other 3 objs after delete DECTAll obj
                addOtherThreeUAMapObj(portTypeValue)
            end
        end
        if POST["deleteAllFlag"]=="1" then
            if POST["linePathInId"]~="nil" then
                local delUAmap, deleteUAmap = getLinePathFromUAMap(portTypeValue)
                local deleteUAmapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
                local reply, error = mbus.modify(
                    function()
                        if deleteUAmap~=nil then
                            local reply1, error1 = mbus.deleteObjects{path = deleteUAmapPath, filter="(and (== ToVoicePort " .. portTypeValue .. ") (== Preassigned " .. "false" .. "))", datamodel = "second"}
                        end
                    end, {datamodel="second"})
            end
            saveall(0, 1)
            cgilua.redirect("save_alert.lp", { u="telephonyStato.lp" })
            return
        else
            if POST["linePathInId"]~="nil" then
                local delUAmap, deleteUAmap = getLinePathFromUAMap(portTypeValue)
                local deleteUAmapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
                local reply, error = mbus.modify(
                    function()
                        if deleteUAmap~=nil then
                            local reply1, error1 = mbus.deleteObjects{path = deleteUAmapPath, filter="(and (== ToVoicePort " .. portTypeValue .. ") (== Preassigned " .. "false" .. "))", datamodel = "second"}
                        end
                    end, {datamodel="second"})
            end

            --add a new telenumber select from the scroll down
            if tonumber(rowIndex)<3 then
                local selectInIndex = POST["selectInDirectoryNumber"..rowIndex]
                local fromUAPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line." .. selectInIndex
                local toVoicePortPath = "Device.Services.VoiceService.1.PhyInterface." .. POST["pathId"]
                local UAMap_path = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
                local linePathInId, lineNum
                local reply, error = mbus.modify(
                function()
                    local reply1, error1 = mbus.addObjects{ path = UAMap_path, param = { FromUA = fromUAPath, ToVoicePort = toVoicePortPath }, datamodel = "second" }
                    if error1~=nil or reply1[UAMap_path][1]==nil then
                        result=1
                
                    end
                    linePathInId = string.gsub(reply1[UAMap_path][1].path, UAMap_path..".", "")
                end, {datamodel="second"})
                saveall(0, 1)
                local pageStr = "telephonyConfig.lp?pathId="..POST["pathId"].."&linePathInId="..linePathInId.."&lineNum="..fromUAPath
                cgilua.redirect(tostring(pageStr))
                return
            else
                local selectInDECTIndex = POST["selectInDECTDirectoryNumber"..rowIndex]
                local fromUAPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line." .. selectInDECTIndex
                local toVoicePortPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. POST["pathId"]
                local UAMap_path = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
                local linePathInId, lineNum
                local reply, error = mbus.modify(
                function()
                    local reply1, error1 = mbus.addObjects{ path = UAMap_path, param = { FromUA = fromUAPath, ToVoicePort = toVoicePortPath }, datamodel = "second" }
                    if error1~=nil or reply1[UAMap_path][1]==nil then
                        result=1
                
                    end
                    linePathInId = string.gsub(reply1[UAMap_path][1].path, UAMap_path..".", "")
                end, {datamodel="second"})
                saveall(0, 1)
                local pageStr = "telephonyConfig.lp?pathId="..(tonumber(POST["pathId"])+2).."&linePathInId="..linePathInId.."&lineNum="..fromUAPath
                cgilua.redirect(tostring(pageStr))
                return
            end
        end
    end

    if POST["configOutFlag"] == "1" then
        --delete the old telenumber
        local rowIndex = POST["rowIndex"]
        local portTypeValue, DECTAllObj
        if tonumber(rowIndex)<3 then
            portTypeValue = "Device.Services.VoiceService.1.PhyInterface." .. tostring(POST["pathId"])
        else
            portTypeValue = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. tostring(POST["pathId"])
            DECTAllObj = isDECTAllObjExistInVpMap()
            if DECTAllObj=="true" then
                --add other 3 objs after delete DECTAll obj
                addOtherThreeVpMapObj(portTypeValue)
            end
        end
        if POST["deleteAllFlag"]=="1" then
            if POST["linePathOutId"]~="nil" then
                local delVoiceportmap, deleteVoiceportmap = getLinePathFromPortMap(portTypeValue)
                local deleteVoiceportmapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
                local reply, error = mbus.modify(
                    function()
                        if deleteVoiceportmap~=nil then
                            local reply2, error2 = mbus.deleteObjects{path = deleteVoiceportmapPath, filter="(and (== FromVoicePort " .. portTypeValue .. ") (== Preassigned " .. "false" .. "))", datamodel = "second"}
                        end
                    end, {datamodel="second"})
            end
            saveall(0, 1)
            cgilua.redirect("save_alert.lp", { u="telephonyStato.lp" })
            return
        else
            if POST["linePathOutId"]~="nil" then
                local delVoiceportmap, deleteVoiceportmap = getLinePathFromPortMap(portTypeValue)
                local deleteVoiceportmapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
                local reply, error = mbus.modify(
                    function()
                        if deleteVoiceportmap~=nil then
                            local reply2, error2 = mbus.deleteObjects{path = deleteVoiceportmapPath, filter="(and (== FromVoicePort " .. portTypeValue .. ") (== Preassigned " .. "false" .. "))", datamodel = "second"}
                        end
                    end, {datamodel="second"})
            end

            --add a new telenumber select from the scroll down
            if tonumber(rowIndex)<3 then
                local selectOutIndex = POST["selectOutDirectoryNumber"..rowIndex]
                local toUAPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line." .. selectOutIndex
                local fromVoicePortPath = "Device.Services.VoiceService.1.PhyInterface." .. POST["pathId"]
                local VoicePortMap_path = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
                local linePathOutId, lineNum
                local reply, error = mbus.modify(
                function()
                    local reply2, error2 = mbus.addObjects{ path = VoicePortMap_path, param = { ToUA = toUAPath, FromVoicePort = fromVoicePortPath }, datamodel = "second" }
                    if error2~=nil or reply2[VoicePortMap_path][1]==nil then
                        result=1
                
                    end
                    linePathOutId = string.gsub(reply2[VoicePortMap_path][1].path, VoicePortMap_path..".", "")
                end, {datamodel="second"})
                saveall(0, 1)
                local pageStr = "telephonyConfig.lp?pathId="..POST["pathId"].."&linePathOutId="..linePathOutId.."&lineNum="..toUAPath
                cgilua.redirect(tostring(pageStr))
                return
            else
                local selectOutDECTIndex = POST["selectOutDECTDirectoryNumber"..rowIndex]
                local toUAPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line." .. selectOutDECTIndex
                local fromVoicePortPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. POST["pathId"]
                local VoicePortMap_path = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
                local linePathOutId, lineNum
                local reply, error = mbus.modify(
                function()
                    local reply2, error2 = mbus.addObjects{ path = VoicePortMap_path, param = { ToUA = toUAPath, FromVoicePort = fromVoicePortPath }, datamodel = "second" }
                    if error2~=nil or reply2[VoicePortMap_path][1]==nil then
                        result=1
                
                    end
                    linePathOutId = string.gsub(reply2[VoicePortMap_path][1].path, VoicePortMap_path..".", "")
                end, {datamodel="second"})
                saveall(0, 1)
                local pageStr = "telephonyConfig.lp?pathId="..(tonumber(POST["pathId"])+2).."&linePathOutId="..linePathOutId.."&lineNum="..toUAPath
                cgilua.redirect(tostring(pageStr))
                return
            end
        end
    end
    return
end

%>
</head>

<body>
<script type="text/javascript">
//<![CDATA[
function submitInConf(pathId, linePathInId, rowIndex)
{
    document.getElementById("configInFlag").value="1";
    document.getElementById("pathId").value=pathId;
    document.getElementById("linePathInId").value=linePathInId;
    document.getElementById("rowIndex").value=rowIndex;

    if(rowIndex<3)
    {
        var selectInFXSNum = document.getElementById("selectInDirectoryNumber"+rowIndex).value;
        if(selectInFXSNum=="")
        {
            document.getElementById("configNum").style.display="none";
            document.getElementById("resultKoConfNum").style.display="block";
            return false;
        }
        if(selectInFXSNum=="deleteFlag")
        {
            document.getElementById("deleteAllFlag").value="1";
        }
    }
    else
    {
        var selectInDECTNum = document.getElementById("selectInDECTDirectoryNumber"+rowIndex).value;
        if(selectInDECTNum=="")
        {
            document.getElementById("configNum").style.display="none";
            document.getElementById("resultKoConfNum").style.display="block";
            return false;
        }
        if(selectInDECTNum=="deleteFlag")
        {
            document.getElementById("deleteAllFlag").value="1";
        }
    }
    document.getElementById("configNum").style.display="none";
    document.getElementById("confirm").style.display="block";
}

function submitOutConf(pathId, linePathOutId, rowIndex)
{
    document.getElementById("configOutFlag").value="1";
    document.getElementById("pathId").value=pathId;
    document.getElementById("linePathOutId").value=linePathOutId;
    document.getElementById("rowIndex").value=rowIndex;

    if(rowIndex<3)
    {
        var selectOutFXSNum = document.getElementById("selectOutDirectoryNumber"+rowIndex).value;
        if(selectOutFXSNum=="")
        {
            document.getElementById("configNum").style.display="none";
            document.getElementById("resultKoConfNum").style.display="block";
            return false;
        }
        if(selectOutFXSNum=="deleteFlag")
        {
            document.getElementById("deleteAllFlag").value="1";
        }
    }
    else
    {
        var selectOutDECTNum = document.getElementById("selectOutDECTDirectoryNumber"+rowIndex).value;
        if(selectOutDECTNum=="")
        {
            document.getElementById("configNum").style.display="none";
            document.getElementById("resultKoConfNum").style.display="block";
            return false;
        }
        if(selectOutDECTNum=="deleteFlag")
        {
            document.getElementById("deleteAllFlag").value="1";
        }
    }
    document.getElementById("configNum").style.display="none";
    document.getElementById("confirm").style.display="block";
}

function submitConfirm()
{
    document.getElementById("configTelephony").submit();
}

function cancelConfirm()
{
    document.getElementById("configNum").style.display = "";
    document.getElementById("confirm").style.display = "none";
    document.getElementById("resultKoConfNum").style.display="none";
}

function submitSave()
{
    document.getElementById("saveFlag").value="1";
    document.configTelephony.submit();
}

//]]>
</script>

<table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephonyStato.lp"><%=translate([==[Telephony services]==])%></a></td>
<%if isRemote==false then%>
<td align="right"><a href="telephonyNumber.lp"><%=translate([==[Telephone numbers]==])%></a></td>
<%end%>
</tr>
</table>

<div class='contentcontainer' id='configNum'>
<hr>
<div class='contentitem'>

<table border="0" width="100%">
<form id="configTelephony" name="configTelephony" action="" method="post">
<input type="hidden" id="configInFlag" name="configInFlag" value="0"/>
<input type="hidden" id="configOutFlag" name="configOutFlag" value="0"/>
<input type="hidden" id="saveFlag" name="saveFlag" value="0"/>
<input type="hidden" id="pathId" name="pathId" value=""/>
<input type="hidden" id="deleteAllFlag" name="deleteAllFlag" value=""/>
<input type="hidden" id="linePathInId" name="linePathInId" value=""/>
<input type="hidden" id="linePathOutId" name="linePathOutId" value=""/>
<input type="hidden" id="rowIndex" name="rowIndex" value=""/>
<tr>
    <td class='icon' style='vertical-align:top' width='100px'><img src='images/tel___xl.gif' alt=''></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr>
            <td align='left'><span class='itemtitle'><%=translate([==[Telephony services]==])%></span></td>
        </tr>
        <tr><td>
            <br><!-- Begin of showing Telephone Service-->
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td><td style='vertical-align:top'>
            <span class='blocktitle'><%=translate([==[Telephone service State]==])%></span><br>
            <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;">
                <tr><td colspan='6' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><th align='left'><%=translate([==[connection]==])%></th>
                    <th align='left' width='150px'><%=translate([==[Number of input]==])%></th>
                    <th align='left' width='150px'><%=translate([==[Number of outgoing]==])%></th>
                    <th align='left' style="word-break:break-all;width:5%;"><%=translate([==[Configuration]==])%>&nbsp;POS/FAX</th>
                    <th align='left'><%=translate([==[Associated with fixed line]==])%>:In</th>
                    <th align='left'><%=translate([==[Associated with fixed line]==])%>:Out</th>
                </tr>
                <tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><td colspan='6' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <%
                local rowStyle = "oddrow"
                local rowNum = 0
                local phoneType, phyInterfaceEnable

                local phyIntf_T = getConnectionInfo()
                for i=1, #phyIntf_T do
                    rowNum = rowNum + 1
                    if rowNum%2==1 then
                        rowStyle = "oddrow"
                    else
                        rowStyle = "evenrow"
                    end
                    local v = phyIntf_T[i]
                    phoneType = v.name
                    if phoneType=="FXS" then
                        phoneType = "FXS" .. tostring(i)
                    end
                    if phoneType~="FXO" then
                        phyInterfaceEnable = v.enable
                        --if false, just show "Interface off"
                        if phyInterfaceEnable~="true" then
                %>
                <tr><td class="<%=rowStyle%>"><%=phoneType%></td><td class="<%=rowStyle%>" align="left" colspan="6"><%=translate([==[Interface off]==])%></td></tr>
                <%
                        else
                            if phoneType~="DECT" then
                                local incomingCallNum, outgoingCallNum = "-", "-"
                                local switchPath = "Device.Services.VoiceService.1.PhyInterface."..tostring(i)
                                local replySwitch, error = mbus.getParameters{ path = switchPath, param = {"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
                                if replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"]=="true" then
                                    incomingCallNum = translate([==[Fixed Line]==])
                                end
                                if replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"]=="true" then
                                    outgoingCallNum = translate([==[Fixed Line]==])
                                end
                                local linePathInId, linePathOutId = "", ""
                                local posFAX = v.posConfig
                                local PSTNIn = v.switchToPSTNIn
                                local PSTNOut = v.switchToPSTNOut
                                local posFAXValue = translate([==[Disabled]==])
                                local PSTNInValue = translate([==[Disabled]==])
                                local PSTNOutValue = translate([==[Disabled]==])
                                if posFAX~="false" then
                                    posFAXValue = translate([==[Enabled]==])
                                end
                                if PSTNIn~="false" then
                                    PSTNInValue = translate([==[Enabled]==])
                                end
                                if PSTNOut~="false" then
                                    PSTNOutValue = translate([==[Enabled]==])
                                end
                                local pathId = string.sub(v.path, -1)
                                local linePathIn = getLinePathFromUAMap(v.path)
                                local linePathOut = getLinePathFromPortMap(v.path)
                                local g, f, linePathInId, linePathOutId
                                if linePathIn ~= nil then
                                    g, f, linePathInId = string.find(linePathIn, "%.([^.]+)$")
                                    incomingCallNum = getAllInCallNum(v.path)
                                end
                                if linePathOut ~= nil then
                                    g, f, linePathOutId = string.find(linePathOut, "%.([^.]+)$")
                                    outgoingCallNum = getAllOutCallNum(v.path)
                                end
                %>
                <tr><td width='33%' class='<%=rowStyle%>' colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr>
                <td class="<%=rowStyle%>"><%=phoneType%><input type="hidden" id="phoneType<%=rowNum%>" name="phoneType<%=rowNum%>" value="<%=phoneType%>" /></td>
                <td class="<%=rowStyle%>" style="word-break:break-all;width:180px;"><%=incomingCallNum%></td>
                <td class="<%=rowStyle%>" style="word-break:break-all;width:180px;"><%=outgoingCallNum%></td>
                <td class="<%=rowStyle%>">
<%if isRemote~=false then%>
                    <%=posFAXValue%>
<%else%>
                    <input type="checkbox" <%=isCheckedService(posFAX)%> name="posChk<%=i%>" size="8" value="ON" />
<%end%>
                </td>
<%if isRemote~=false then%>
                <td class="<%=rowStyle%>"><%=PSTNInValue%></td>
                <td class="<%=rowStyle%>"><%=PSTNOutValue%></td>
<%else%>
                <td class="<%=rowStyle%>"><input type="checkbox" <%=isCheckedService(PSTNIn)%> name="pstnInChk<%=i%>" value="ON" /></td>
                <td class="<%=rowStyle%>"><input type="checkbox" <%=isCheckedService(PSTNOut)%> name="pstnOutChk<%=i%>" value="ON" /></td>
<%end%>
                </tr>
                    <%      end
                            if phoneType=="DECT" then
                                for j=1,4 do
                                    local incomingCallNum, outgoingCallNum = "-", "-"
                                    local linePathInId, linePathOutId = "", ""
                                    phoneType = "DECT" .. tostring(j)
                                    local DECTPath = v.path .. ".X_TELECOMITALIA_IT_DECTHandset." .. j
                                    local pathId = string.sub(DECTPath, -1)
                                    local linePathIn = getLinePathFromUAMap(DECTPath)
                                    local linePathOut = getLinePathFromPortMap(DECTPath)
                                    local InDECTAllLineNum = getDECTAllInCallNum()
                                    if InDECTAllLineNum~=nil then
                                        incomingCallNum = InDECTAllLineNum
                                    end
                                    local OutDECTAllLineNum = getDECTAllOutCallNum()
                                    if OutDECTAllLineNum~=nil then
                                        outgoingCallNum = OutDECTAllLineNum
                                    end
                                    local g, f, linePathInId, linePathOutId
                                    if linePathIn ~= nil then
                                        g, f, linePathInId = string.find(linePathIn, "%.([^.]+)$")
                                        if InDECTAllLineNum~=nil then
                                            incomingCallNum = tostring(InDECTAllLineNum) .. "<br/>" .. tostring(getAllInCallNum(DECTPath))
                                        else
                                            incomingCallNum = getAllInCallNum(DECTPath)
                                        end
                                    end
                                    if linePathOut ~= nil then
                                        g, f, linePathOutId = string.find(linePathOut, "%.([^.]+)$")
                                        if InDECTAllLineNum~=nil then
                                            outgoingCallNum = tostring(OutDECTAllLineNum) .. "<br/>" .. tostring(getAllOutCallNum(DECTPath))
                                        else
                                            outgoingCallNum = getAllOutCallNum(DECTPath)
                                        end
                                    end
                    %>
                <tr>
                <td class="<%=rowStyle%>"><%=phoneType%><input type="hidden" id="phoneType<%=i+j-1%>" name="phoneType<%=i+j-1%>" value="<%=phoneType%>" /></td>
                <%
                                    local DECTAssociato = getDECTHandsetAssociato(DECTPath)
                                    if DECTAssociato~="true" then
                %>
                <td class="<%=rowStyle%>" colspan="6"><%=translate([==[Terminal is not associated]==])%></td>
                <%
                                    else
                %>
                <td class="<%=rowStyle%>" style="word-break:break-all;width:180px;"><%=incomingCallNum%></td>
                <td class="<%=rowStyle%>" style="word-break:break-all;width:180px;"><%=outgoingCallNum%></td>
                <td class="<%=rowStyle%>"></td>
                <td class="<%=rowStyle%>"></td>
                <td class="<%=rowStyle%>"></td>
                <%
                                    end
                %>
                </tr>
                <%
                                end
                            end
                        end
                    end
                end
                %>
                <br>
<%if isRemote==false then%>
                <table cellspacing='0' cellpadding='0' width='100%' style="text-align:center">
                <tr><td style='vertical-align:top'>
                    <input type="button" class="button" onclick='javascript: submitSave();' value="<%=translate([==[Save]==])%>" name="thb10" />&nbsp;&nbsp;&nbsp;&nbsp;
                    <input type="hidden" id="rowNum" name="rowNum" value="<%=rowNum%>" />
                </td></tr></table>
<%end%>
            </table>
<%if isRemote==false then%>
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'></td><td style='vertical-align:top'>
            <span class='blocktitle'></span><br>
            <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;">
                <tr><td colspan='4' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <tr><td colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><th align='left'><%=translate([==[connection]==])%></th>
                    <th align='left'><%=translate([==[ConfigurazioneIn]==])%></th>
                    <th align='left'><%=translate([==[ConfigurazioneOut]==])%></th>
                    <th width='9' align='left'><%=translate([==[Priority]==])%></th>
                </tr>
                <tr><td colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><td colspan='4' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <tr><td width='33%' class='<%=rowStyle%>' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <%
                local rowStyle = "oddrow"
                local rowNum = 0
                local phoneType, phyInterfaceEnable

                local phyIntf_T = getConnectionInfo()
                for i=1, #phyIntf_T do
                    rowNum = rowNum + 1
                    if rowNum%2==1 then
                        rowStyle = "oddrow"
                    else
                        rowStyle = "evenrow"
                    end
                    local v = phyIntf_T[i]
                    phoneType = v.name
                    if phoneType=="FXS" then
                        phoneType = "FXS" .. tostring(i)
                    end
                    if phoneType~="FXO" then
                        phyInterfaceEnable = v.enable
                        --if false, just show "Interface off"
                        if phyInterfaceEnable~="true" then
                %>
                <tr><td class="<%=rowStyle%>"><%=phoneType%></td><td class="<%=rowStyle%>" align="left" colspan="4"><%=translate([==[Interface off]==])%></td></tr>
                <%
                        else
                            if phoneType~="DECT" then
                                local switchPath = "Device.Services.VoiceService.1.PhyInterface."..tostring(i)
                                local replySwitch, error = mbus.getParameters{ path = switchPath, param = {"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
                                local linePathInId, linePathOutId = "", ""
                                local pathId = string.sub(v.path, -1)
                                local linePathIn = getLinePathFromUAMap(v.path)
                                local linePathOut = getLinePathFromPortMap(v.path)
                                local g, f, linePathInId, linePathOutId
                                if linePathIn ~= nil then
                                    g, f, linePathInId = string.find(linePathIn, "%.([^.]+)$")
                                end
                                if linePathOut ~= nil then
                                    g, f, linePathOutId = string.find(linePathOut, "%.([^.]+)$")
                                end
                %>
                <tr>
                <td class="<%=rowStyle%>"><%=phoneType%><input type="hidden" id="phoneType<%=rowNum%>" name="phoneType<%=rowNum%>" value="<%=phoneType%>" /></td>
                <td class="<%=rowStyle%>">
                    <input type="button" class="button" onclick='submitInConf("<%=pathId%>", "<%=linePathInId%>", "<%=i%>")' value="<%=translate([==[ConfigurazioneIn]==])%>" />
                    <select id="selectInDirectoryNumber<%=i%>" name="selectInDirectoryNumber<%=i%>" style="font-family:Tahoma;width:100px;overflow:hidden">
                    <option value="">&lt;<%=translate([==[Choose]==])%> &gt;</option>
                    <%
                        local preassInNum = getPreassignedInNum(v.path)
                        local allNumberPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                        local replyAll, error = mbus.getParameters{ path = allNumberPath, param = "DirectoryNumber", filter="(== X_TELECOMITALIA_IT_LANManaged " .. "false" .. ")", datamodel = "second" }
                        for u,w in pairs(replyAll[allNumberPath]) do
                            if w.param["DirectoryNumber"]~=preassInNum then
                                cgilua.print("<option title='"..tostring(w.param["DirectoryNumber"]).."' value='"..tostring(string.gsub(w.path, "Device.Services.VoiceService.1.VoiceProfile.1.Line.", "")).."'>"..tostring(w.param["DirectoryNumber"]).."</option>")
                            end
                        end
                    %>
                    <option value="deleteFlag">&nbsp;&nbsp;-&nbsp;&nbsp;</option>
                    </select>
                </td>
                <td class="<%=rowStyle%>">
                    <input type="button" class="button" onclick='submitOutConf("<%=pathId%>", "<%=linePathOutId%>", "<%=i%>")' value="<%=translate([==[ConfigurazioneOut]==])%>" />
                    <select id="selectOutDirectoryNumber<%=i%>" name="selectOutDirectoryNumber<%=i%>" style="font-family:Tahoma;width:100px;overflow:hidden">
                    <option value="">&lt;<%=translate([==[Choose]==])%> &gt;</option>
                    <%
                        local preassOutNum = getPreassignedOutNum(v.path)
                        local allNumberPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                        local replyAll, error = mbus.getParameters{ path = allNumberPath, param = "DirectoryNumber", filter="(== X_TELECOMITALIA_IT_LANManaged " .. "false" .. ")", datamodel = "second" }
                        for u,w in pairs(replyAll[allNumberPath]) do
                            if w.param["DirectoryNumber"]~=preassOutNum then
                                cgilua.print("<option title='"..tostring(w.param["DirectoryNumber"]).."' value='"..tostring(string.gsub(w.path, "Device.Services.VoiceService.1.VoiceProfile.1.Line.", "")).."'>"..tostring(w.param["DirectoryNumber"]).."</option>")
                            end
                        end
                    %>
                    <option value="deleteFlag">&nbsp;&nbsp;-&nbsp;&nbsp;</option>
                    </select>
                </td>
                <td class="<%=rowStyle%>"><input type="text" name="Priority" id="Priority" size="5"></td>
                </tr>
                <tr><td width='33%' class='<%=rowStyle%>' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <%          end
                            if phoneType=="DECT" then
                                for j=1,4 do
                                    local linePathInId, linePathOutId = "", ""
                                    phoneType = "DECT" .. tostring(j)
                                    local DECTPath = v.path .. ".X_TELECOMITALIA_IT_DECTHandset." .. j
                                    local pathId = string.sub(DECTPath, -1)
                                    local linePathIn = getLinePathFromUAMap(DECTPath)
                                    local linePathOut = getLinePathFromPortMap(DECTPath)
                                    local g, f, linePathInId, linePathOutId
                                    if linePathIn ~= nil then
                                        g, f, linePathInId = string.find(linePathIn, "%.([^.]+)$")
                                    end
                                    if linePathOut ~= nil then
                                        g, f, linePathOutId = string.find(linePathOut, "%.([^.]+)$")
                                    end
                %>
                <tr>
                <td class="<%=rowStyle%>"><%=phoneType%><input type="hidden" id="phoneType<%=i+j-1%>" name="phoneType<%=i+j-1%>" value="<%=phoneType%>" /></td>
                <%
                                    local DECTAssociato = getDECTHandsetAssociato(DECTPath)
                                    if DECTAssociato=="true" then
                %>
                <td class="<%=rowStyle%>">
                    <input type="button" class="button" onclick='submitInConf("<%=pathId%>", "<%=linePathInId%>", "<%=(i+j-1)%>")' value="<%=translate([==[ConfigurazioneIn]==])%>" />
                    <select id="selectInDECTDirectoryNumber<%=i+j-1%>" name="selectInDECTDirectoryNumber<%=i+j-1%>" style="font-family:Tahoma;width:100px;overflow:hidden">
                    <option value="">&lt;<%=translate([==[Choose]==])%> &gt;</option>
                    <%
                        local preassDECTInNum = getPreassignedInNum(DECTPath)
                        local allNumberPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                        local replyAll, error = mbus.getParameters{ path = allNumberPath, param = "DirectoryNumber", filter="(== X_TELECOMITALIA_IT_LANManaged " .. "false" .. ")", datamodel = "second" }
                        for u,w in pairs(replyAll[allNumberPath]) do
                            if w.param["DirectoryNumber"]~=preassDECTInNum then
                                cgilua.print("<option title='"..tostring(w.param["DirectoryNumber"]).."' value='"..tostring(string.gsub(w.path, "Device.Services.VoiceService.1.VoiceProfile.1.Line.", "")).."'>"..tostring(w.param["DirectoryNumber"]).."</option>")
                            end
                        end
                    %>
                    <option value="deleteFlag">&nbsp;&nbsp;-&nbsp;&nbsp;</option>
                    </select>
                </td>
                <td class="<%=rowStyle%>">
                    <input type="button" class="button" onclick='submitOutConf("<%=pathId%>", "<%=linePathOutId%>", "<%=(i+j-1)%>")' value="<%=translate([==[ConfigurazioneOut]==])%>" />
                    <select id="selectOutDECTDirectoryNumber<%=i+j-1%>" name="selectOutDECTDirectoryNumber<%=i+j-1%>" style="font-family:Tahoma;width:100px;overflow:hidden">
                    <option value="">&lt;<%=translate([==[Choose]==])%> &gt;</option>
                    <%
                        local preassDECTOutNum = getPreassignedOutNum(DECTPath)
                        local allNumberPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                        local replyAll, error = mbus.getParameters{ path = allNumberPath, param = "DirectoryNumber", filter="(== X_TELECOMITALIA_IT_LANManaged " .. "false" .. ")", datamodel = "second" }
                        for u,w in pairs(replyAll[allNumberPath]) do
                            if w.param["DirectoryNumber"]~=preassDECTOutNum then
                                cgilua.print("<option title='"..tostring(w.param["DirectoryNumber"]).."' value='"..tostring(string.gsub(w.path, "Device.Services.VoiceService.1.VoiceProfile.1.Line.", "")).."'>"..tostring(w.param["DirectoryNumber"]).."</option>")
                            end
                        end
                    %>
                    <option value="deleteFlag">&nbsp;&nbsp;-&nbsp;&nbsp;</option>
                    </select>
                </td>
                <td class="<%=rowStyle%>"><input type="text" name="Priority" id="Priority" size="5"></td>
                </tr>
                                    <%end%>
                <tr><td width='33%' class='<%=rowStyle%>' colspan='4'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                                <%end%>
                            <%end%>
                        <%end%>
                    <%end%>
                <%end%>
            </table>
            </td></tr></table>
<%end%>
            </td></tr></table>
        </td></tr></table>
    </td>
</tr>
</form>
</table>
</div>
</div>
<div id="resultKoConfNum" style="display:none">
<%cgilua.lp.include("webparts/resultKO_noconfnum.lp")%>
</div>
<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>
